#!/usr/bin/env python3
"""
NovaMoFu Prompt Generator

Converts Gemini video analysis output into structured prompts
for Seedance/Sora/Runway/generic AI video generation models.
"""

import re
import sys


# ============================================================
# Prompt Templates
# ============================================================

TEMPLATES = {
    "seedance": {
        "name": "Seedance 2.0",
        "lang": "zh",
        "header": "## 素材来源身份",
        "sections": [
            "## 主要角色",
            "## 地点",
            "## 视觉风格",
            "## 摄像风格",
            "## 时间轴",
            "## 音频",
            "## 目标",
        ],
        "negative_prompt": """
没有横屏。没有三脚架稳定。没有专业布光。
没有电影感运镜。没有完美构图。没有商业调色。
没有4K清晰度。没有稳定画面。没有对称构图。
""",
    },
    "sora": {
        "name": "Sora",
        "lang": "en",
        "header": "## Source Identity",
        "sections": [
            "## Subject",
            "## Scene",
            "## Camera",
            "## Timeline",
            "## Audio",
            "## Negative Prompt",
        ],
        "negative_prompt": """
No cinematic framing. No perfect lighting. No stable camera.
No commercial color grading. No symmetrical composition.
No 4K sharpness. No smooth movements. No professional feel.
""",
    },
    "runway": {
        "name": "Runway",
        "lang": "en",
        "header": "## Source",
        "sections": [
            "## Shot Description",
            "## Camera Work",
            "## Lighting & Color",
            "## Motion",
            "## Audio Cues",
        ],
        "negative_prompt": """
Avoid: cinematic look, perfect composition, smooth camera,
professional lighting, commercial grade, clean画面.
""",
    },
    "generic": {
        "name": "Generic",
        "lang": "en",
        "header": "## Video Description",
        "sections": [
            "## Subject",
            "## Action",
            "## Scene",
            "## Camera",
            "## Lighting",
            "## Mood",
        ],
        "negative_prompt": "",
    },
}


def parse_gemini_output(raw_text: str) -> dict:
    """Parse Gemini analysis output into structured sections."""
    if not raw_text or not raw_text.strip():
        return {}

    sections = {}
    current_section = None
    current_content = []

    for line in raw_text.split("\n"):
        # Detect section headers (## or **)
        header_match = re.match(r"^#{1,3}\s+\*{0,2}(.+?)\*{0,2}\s*$", line)
        bold_match = re.match(r"^\*{2}(.+?)\*{2}\s*$", line)

        if header_match or bold_match:
            # Save previous section (only if non-empty content)
            if current_section is not None and current_content:
                content = "\n".join(current_content).strip()
                if content:
                    sections[current_section] = content
            match_obj = header_match if header_match else bold_match
            assert match_obj is not None
            current_section = match_obj.group(1).strip()
            current_content = []
        else:
            if current_section is not None:
                current_content.append(line)

    # Save last section
    if current_section is not None and current_content:
        content = "\n".join(current_content).strip()
        if content:
            sections[current_section] = content

    return sections


def generate_prompt(
    analysis: str,
    mode: str = "seedance",
    video_source: str = "",
) -> str:
    """
    Generate a structured prompt from Gemini video analysis.

    Args:
        analysis: Raw Gemini analysis output
        mode: Output mode (seedance/sora/runway/generic)
        video_source: Original video URL/path

    Returns:
        Structured prompt string
    """
    template = TEMPLATES.get(mode, TEMPLATES["generic"])
    sections = parse_gemini_output(analysis)

    output_parts = []

    # Header
    output_parts.append(f"# NovaMoFu — {template['name']} Prompt")
    if video_source:
        output_parts.append(f"Source: {video_source}")
    output_parts.append("")

    # Source identity (always first)
    source_key = None
    for key in ["素材来源身份", "Source Identity", "Source", "来源"]:
        if key in sections:
            source_key = key
            break

    if source_key:
        output_parts.append(f"## {source_key}")
        output_parts.append(sections[source_key])
        output_parts.append("")

    used_keys = {source_key} if source_key else set()

    for template_section in template["sections"]:  # Process all
        section_name = template_section.replace("## ", "")
        output_parts.append(template_section)

        # Exact match from parsed sections
        found = False
        for key in list(sections.keys()):
            if key in used_keys:
                continue
            if source_key and key == source_key:
                continue
            if section_name == key:
                output_parts.append(sections[key])
                used_keys.add(key)
                found = True
                break

        if not found:
            output_parts.append("[待填充]")

        output_parts.append("")

    # Add negative prompt
    if template["negative_prompt"]:
        output_parts.append("## Negative Prompt")
        output_parts.append(template["negative_prompt"].strip())
        output_parts.append("")

    return "\n".join(output_parts)


def enhance_with_device_pack(prompt: str, device: str) -> str:
    """Add device-specific aesthetic details to the prompt."""
    device_packs = {
        "dv": "2000年代消费级DV拍摄,中等数字压缩伪影,褪色的色彩,柔和的对比度,轻微传感器噪点,强烈手持抖动,频繁自动对焦搜索。没有稳定。没有电影化的摄像机移动。没有现代色彩分级。",
        "vhs": "VHS家用摄像机拍摄,扫描线,色彩溢出,时间戳叠加,低分辨率,磁带噪点。没有数字清晰度。没有16:9宽屏。没有稳定画面。",
        "super8": "Super 8胶片拍摄,胶片颗粒,暗角,划痕,18fps卡顿感,光晕,暖色调。没有数字锐度。没有稳定画面。没有现代色彩。",
        "phone": "智能手机竖屏拍摄,9:16竖构图,轻微过度锐化和HDR处理感,电子防抖。没有横屏。没有三脚架稳定。没有专业布光。",
        "cctv": "监控摄像头拍摄,高位俯视角度,低帧率,时间戳叠加,无声,广角畸变。没有声音。没有移动镜头。没有高帧率。",
        "gopro": "GoPro运动相机拍摄,超广角鱼眼畸变,防水特性。没有标准镜头透视。没有稳定器。没有浅景深。",
    }

    pack = device_packs.get(device.lower(), "")
    if pack:
        # Insert after 视觉风格 or Camera section
        lines = prompt.split("\n")
        for i, line in enumerate(lines):
            if "视觉风格" in line or "Camera" in line or "摄像" in line:
                # Find end of this section
                j = i + 1
                while j < len(lines) and not lines[j].startswith("##"):
                    j += 1
                lines.insert(j, pack)
                lines.insert(j + 1, "")
                return "\n".join(lines)

    return prompt


# ============================================================
# CLI
# ============================================================

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python prompt_generator.py <analysis_file> [--mode seedance|sora|runway|generic]")
        sys.exit(1)

    # Read analysis file
    analysis_file = sys.argv[1]
    mode = "seedance"

    if "--mode" in sys.argv:
        idx = sys.argv.index("--mode")
        if idx + 1 < len(sys.argv):
            mode = sys.argv[idx + 1]

    with open(analysis_file, "r", encoding="utf-8") as f:
        analysis = f.read()

    # Generate prompt
    prompt = generate_prompt(analysis, mode=mode)
    print(prompt)
