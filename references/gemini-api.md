# Gemini API 视频分析格式 (Gemini Video API)

## 基本格式

### URL 视频分析

```bash
curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro-preview:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [
        {"fileData": {"mimeType": "video/mp4", "fileUri": "https://youtu.be/VIDEO_ID"}},
        {"text": "分析这个视频..."}
      ]
    }]
  }'
```

### 本地文件分析

```bash
# 1. 上传文件
curl -s -X POST "https://generativelanguage.googleapis.com/upload/v1beta/files?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{"file":{"display_name":"video.mp4"}}' \
  --upload-file "video.mp4" \
  -o upload_response.json

# 2. 获取 file_uri
FILE_URI=$(python3 -c "import json; d=json.load(open('upload_response.json')); print(d['file']['uri'])")

# 3. 分析
curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro-preview:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"contents\": [{
      \"parts\": [
        {\"fileData\": {\"mimeType\": \"video/mp4\", \"fileUri\": \"$FILE_URI\"}},
        {\"text\": \"分析这个视频...\"}
      ]
    }]
  }"
```

## 重要格式注意事项

### 字段名称

- ✅ 使用 `fileData` (不是 `video` 或 `file_data`)
- ✅ 使用 `mimeType` 和 `fileUri`
- ❌ 不要使用 `"video"` 或 `"file_data"` — API 会拒绝

### MIME 类型

| 格式 | mimeType |
|------|----------|
| MP4 | `video/mp4` |
| WebM | `video/webm` |
| QuickTime | `video/quicktime` |
| AVI | `video/x-msvideo` |

### 模型选择

| 模型 | 免费额度 | 最大视频长度 | 推荐场景 |
|------|----------|------------|----------|
| gemini-3.6-flash | ~1,500 RPD | ~55分钟 | 日常使用(推荐) |
| gemini-3.1-pro-preview | ~50 RPD | ~55分钟 | 高质量分析 |

## 响应格式

```json
{
  "candidates": [{
    "content": {
      "parts": [{
        "text": "分析结果..."
      }]
    }
  }],
  "usageMetadata": {
    "promptTokenCount": 1234,
    "candidatesTokenCount": 5678,
    "totalTokenCount": 6912
  }
}
```

## 错误处理

| 错误码 | 原因 | 解决方案 |
|--------|------|----------|
| 400 | 字段名错误 | 使用 `fileData` 不是 `video` |
| 401 | API Key 无效 | 重新生成 Key |
| 429 | Rate limit | 等待或切换到 Flash 模型 |
| 500 | 服务器错误 | 重试或使用 fallback |

## 成本估算

视频分析按 token 计费:
- 视频: ~300 tokens/秒 (1fps采样)
- 音频: ~32 tokens/秒
- 文本: 按字符数

**示例:** 16分钟视频
- 视频 tokens: ~288,000
- 音频 tokens: ~32,000
- 总计: ~320,000 tokens
- Flash 免费额度内
- Pro 费用: ~$0.37

## 最佳实践

1. **优先使用 Flash 模型** — 免费额度大,速度快
2. **视频长度控制** — 尽量分析短视频(<5分钟)
3. **Prompt 要具体** — 明确告诉模型要分析什么
4. **检查 usageMetadata** — 监控 token 使用量
5. **处理 rate limit** — 准备 fallback 方案
