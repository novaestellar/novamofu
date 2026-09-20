#!/usr/bin/env bash
# ============================================================
# NovaMoFu (模糊) — Gemini Video Analyzer
# ============================================================
# Usage: bash analyzer.sh <video_url_or_path> [--mode seedance|sora|runway|generic]
#
# Requirements: curl, ffmpeg (for fallback), GEMINI_API_KEY
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Load .env
if [ -f "$REPO_DIR/.env" ]; then
    set -a
    source "$REPO_DIR/.env"
    set +a
elif [ -f "$HOME/.hermes/.env" ]; then
    set -a
    source "$HOME/.hermes/.env"
    set +a
fi

# Defaults
ENGINE="${NOVAMOFU_ENGINE:-gemini}"
MODEL="${NOVAMOFU_GEMINI_MODEL:-gemini-2.5-flash}"
OUTPUT_FORMAT="${NOVAMOFU_OUTPUT_FORMAT:-seedance}"

# Parse args
VIDEO_INPUT=""
MODE="$OUTPUT_FORMAT"

while [[ $# -gt 0 ]]; do
    case $1 in
        --check)
            echo "=== NovaMoFu Dependency Check ==="
            echo -n "curl: $(which curl 2>/dev/null && echo '✅' || echo '❌ NOT FOUND')"
            echo -n "ffmpeg: $(which ffmpeg 2>/dev/null && echo '✅' || echo '❌ NOT FOUND')"
            echo -n "yt-dlp: $(which yt-dlp 2>/dev/null && echo '✅' || echo '❌ NOT FOUND')"
            echo -n "GEMINI_API_KEY: ${GEMINI_API_KEY:+✅ set}${GEMINI_API_KEY:-❌ NOT SET}"
            echo -n "GROQ_API_KEY: ${GROQ_API_KEY:+✅ set}${GROQ_API_KEY:-❌ NOT SET}"
            echo "Engine: $ENGINE | Model: $MODEL | Format: $MODE"
            exit 0
            ;;
        --mode)
            MODE="$2"
            shift 2
            ;;
        --engine)
            ENGINE="$2"
            shift 2
            ;;
        --model)
            MODEL="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            VIDEO_INPUT="$1"
            shift
            ;;
    esac
done

if [ -z "$VIDEO_INPUT" ]; then
    echo "Usage: bash analyzer.sh <video_url_or_path> [--mode seedance|sora|runway|generic]" >&2
    exit 1
fi

# ============================================================
# Prompt templates per mode
# ============================================================

get_prompt_seedance() {
    cat <<'PROMPT'
分析这个视频,然后按照以下7段式结构生成 Seedance 2.0 风格的视频提示词。

要求:
1. 确定"素材来源身份":谁在拍,用什么设备,什么年代,什么目的
2. 输出必须是 Seedance 2.0 原生格式(中文)
3. 包含具体的负面约束(关闭AI默认审美)
4. 时间轴包含"非完美事件"(真实失误)

输出格式:

## 素材来源身份
[一段话说明这段素材的真实来源]

## 主要角色
[角色描述,保持一致性]

## 地点
[具体空间、时代元素、光影和环境细节]

## 视觉风格
[真实感层级和素材气质]

## 摄像风格
[设备类型、画面缺陷、操作失误、负面约束]

## 时间轴
[00:00-XX:XX 每个镜头的详细描述]

## 音频
[现场声音和环境声音如何对应画面]

## 目标
[这段素材最终要像什么]
PROMPT
}

get_prompt_sora() {
    cat <<'PROMPT'
Analyze this video and generate a structured prompt for OpenAI Sora.

Requirements:
1. Determine the "source identity": who filmed, what device, when, why
2. Output in Sora-compatible format (English)
3. Include specific negative prompts to disable AI defaults
4. Timeline with "imperfect events" for realism

Output format:

## Source Identity
[One paragraph describing the real source of this footage]

## Subject
[Character/subject description with consistency details]

## Scene
[Location, era, lighting, environmental details]

## Camera
[Device type, lens, movement, defects, negative constraints]

## Timeline
[00:00-XX:XX detailed description per shot]

## Audio
[Ambient sounds matching visuals]

## Negative Prompt
[What to avoid: cinematic, perfect, commercial, etc.]
PROMPT
}

get_prompt_runway() {
    cat <<'PROMPT'
Analyze this video and generate a structured prompt for Runway Gen-3/4.

Requirements:
1. Determine the "source identity": who filmed, what device, when, why
2. Output in Runway-compatible format (English)
3. Focus on visual fidelity and motion description
4. Include camera movement and lighting details

Output format:

## Source
[Real-world source description]

## Shot Description
[Detailed visual description per shot]

## Camera Work
[Movement, angle, lens characteristics]

## Lighting & Color
[Natural lighting, color temperature, mood]

## Motion
[Subject movement, camera shake, transitions]

## Audio Cues
[Ambient sounds, dialogue, music references]
PROMPT
}

get_prompt_generic() {
    cat <<'PROMPT'
Analyze this video and generate a detailed prompt for AI video generation.

Focus on:
1. What is happening in the video (subject, action, scene)
2. Camera work (angle, movement, lens)
3. Lighting and color palette
4. Mood and atmosphere
5. Any text or overlays visible
6. Audio description

Output a structured prompt that could be used to recreate this video with AI.
PROMPT
}

# Select prompt based on mode
case "$MODE" in
    seedance) PROMPT=$(get_prompt_seedance) ;;
    sora)     PROMPT=$(get_prompt_sora) ;;
    runway)   PROMPT=$(get_prompt_runway) ;;
    generic)  PROMPT=$(get_prompt_generic) ;;
    *)        echo "Unknown mode: $MODE" >&2; exit 1 ;;
esac

# ============================================================
# Gemini API call
# ============================================================

analyze_with_gemini() {
    local input="$1"
    local prompt="$2"

    if [ -z "${GEMINI_API_KEY:-}" ]; then
        echo "ERROR: GEMINI_API_KEY not set. Add it to .env or ~/.hermes/.env" >&2
        exit 1
    fi

    # Determine if URL or local file
    if [[ "$input" =~ ^https?:// ]]; then
        # URL — use fileData with URI
        local payload
        payload=$(python3 -c "
import json
prompt = '''$prompt'''
payload = {
    'contents': [{
        'parts': [
            {'fileData': {'mimeType': 'video/mp4', 'fileUri': '$input'}},
            {'text': prompt}
        ]
    }]
}
print(json.dumps(payload))
" 2>/dev/null || echo '{"contents":[{"parts":[{"text":"ERROR: Failed to build payload"}]}]}')
    else
        # Local file — upload first, then analyze
        echo "Uploading local file to Gemini..." >&2
        local upload_response
        upload_response=$(curl -s -X POST \
            "https://generativelanguage.googleapis.com/upload/v1beta/files?key=$GEMINI_API_KEY" \
            -H "Content-Type: application/json; charset=utf-8" \
            -d "{\"file\":{\"display_name\":\"$(basename "$input")\"}}" \
            --upload-file "$input" 2>/dev/null)

        local file_uri
        file_uri=$(echo "$upload_response" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('file',{}).get('uri',''))" 2>/dev/null)

        if [ -z "$file_uri" ]; then
            echo "ERROR: File upload failed. Response: $upload_response" >&2
            exit 1
        fi

        local payload
        payload=$(python3 -c "
import json
prompt = '''$prompt'''
payload = {
    'contents': [{
        'parts': [
            {'fileData': {'mimeType': 'video/mp4', 'fileUri': '$file_uri'}},
            {'text': prompt}
        ]
    }]
}
print(json.dumps(payload))
")
    fi

    # Call Gemini API
    local response
    response=$(curl -s -X POST \
        "https://generativelanguage.googleapis.com/v1beta/models/$MODEL:generateContent?key=$GEMINI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>/dev/null)

    # Extract text from response
    echo "$response" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    if 'candidates' in d:
        text = d['candidates'][0]['content']['parts'][0]['text']
        # Show usage metadata if available
        usage = d.get('usageMetadata', {})
        if usage:
            tokens = usage.get('totalTokenCount', 0)
            print(f'<!-- Tokens: {tokens} -->')
        print(text)
    elif 'error' in d:
        print(f'ERROR: {d[\"error\"].get(\"message\", \"unknown\")}', file=sys.stderr)
        sys.exit(1)
    else:
        print('ERROR: Unexpected response format', file=sys.stderr)
        print(json.dumps(d, indent=2)[:500])
        sys.exit(1)
except Exception as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)
"
}

# ============================================================
# Fallback: ffmpeg frame extraction
# ============================================================

analyze_with_fallback() {
    local input="$1"
    local prompt="$2"

    echo "Using fallback engine (ffmpeg + vision_analyze)..." >&2

    local tmpdir="/tmp/novamofu_$$"
    mkdir -p "$tmpdir/frames"

    # Download if URL
    local video_file="$input"
    if [[ "$input" =~ ^https?:// ]]; then
        echo "Downloading video..." >&2
        yt-dlp -o "$tmpdir/video.%(ext)s" -f "bestvideo[height<=720]+bestaudio/best[height<=720]" "$input" 2>/dev/null || \
            yt-dlp -o "$tmpdir/video.%(ext)s" "$input" 2>/dev/null
        video_file=$(ls "$tmpdir"/video.* 2>/dev/null | head -1)
    fi

    # Get duration
    local duration
    duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$video_file" 2>/dev/null | cut -d. -f1)

    # Determine interval
    local interval=30
    if [ "$duration" -lt 120 ] 2>/dev/null; then
        interval=10
    fi

    # Extract frames
    echo "Extracting frames (interval: ${interval}s)..." >&2
    for t in $(seq 0 "$interval" "$duration"); do
        ffmpeg -y -ss "$t" -i "$video_file" -vframes 1 -q:v 3 -vf "scale=480:-1" \
            "$tmpdir/frames/frame_$(printf '%04d' "$t").jpg" 2>/dev/null
    done

    local frame_count
    frame_count=$(ls "$tmpdir"/frames/*.jpg 2>/dev/null | wc -l)
    echo "Extracted $frame_count frames" >&2

    # Fallback prompt: describe frames and generate prompt
    local fallback_prompt="I have extracted $frame_count frames from a video at ${interval}-second intervals.

Analyze these frames and generate a structured video prompt in $MODE format.

For each frame, describe:
- What is visible (subject, action, scene)
- Camera angle and movement
- Lighting and color
- Any text overlays

Then synthesize into a complete prompt.

Prompt requirements:
1. Determine the source identity (who filmed, device, era)
2. Include negative constraints (avoid AI defaults)
3. Timeline with imperfect events for realism

Output in $MODE format."

    # Note: In actual Hermes usage, the agent would use vision_analyze on each frame
    echo "=== Fallback Analysis ==="
    echo "Video: $input"
    echo "Duration: ${duration}s"
    echo "Frames extracted: $frame_count"
    echo "Interval: ${interval}s"
    echo ""
    echo "To complete analysis, use Hermes vision_analyze on frames in: $tmpdir/frames/"
    echo "Then generate $MODE prompt from the visual descriptions."

    # Cleanup
    # rm -rf "$tmpdir"  # Uncomment after analysis
}

# ============================================================
# Main
# ============================================================

echo "=== NovaMoFu (模糊) — Video Analyzer ===" >&2
echo "Input: $VIDEO_INPUT" >&2
echo "Mode: $MODE" >&2
echo "Engine: $ENGINE" >&2
echo "" >&2

case "$ENGINE" in
    gemini)
        if [ -z "${GEMINI_API_KEY:-}" ]; then
            echo "WARNING: GEMINI_API_KEY not set, falling back to ffmpeg" >&2
            analyze_with_fallback "$VIDEO_INPUT" "$PROMPT"
        else
            analyze_with_gemini "$VIDEO_INPUT" "$PROMPT"
        fi
        ;;
    fallback)
        analyze_with_fallback "$VIDEO_INPUT" "$PROMPT"
        ;;
    *)
        echo "Unknown engine: $ENGINE" >&2
        exit 1
        ;;
esac
