---
name: novamofu
version: 1.0.0
description: "NovaMoFu (模糊) — Video-to-Prompt engine. Watch any video via Gemini, generate Seedance/Sora/Runway prompts. YouTube URL → analyze → structured prompt."
triggers:
  - novamofu
  - video to prompt
  - watch video
  - generate prompt
  - seedance prompt
  - sora prompt
  - runway prompt
  - analyze video
  - video analysis
  - ai video prompt
capabilities:
  - Gemini 2.5 native video understanding (1 API call)
  - YouTube URL direct analysis
  - Local file upload analysis
  - 4 prompt modes: seedance, sora, runway, generic
  - 7-segment structured output (character, location, style, camera, timeline, audio, goal)
  - Device aesthetic packs (DV, VHS, Super 8, smartphone, CCTV)
  - Anti-AI-slop checklist
  - Fallback: ffmpeg frame extraction + vision_analyze
dependencies:
  - ffmpeg (required)
  - yt-dlp (optional, for YouTube download)
  - curl (required, for Gemini API)
  - python3 (optional, for response parsing)
env_vars:
  - GEMINI_API_KEY (required for Gemini engine)
  - GROQ_API_KEY (optional, for Whisper fallback)
---

# NovaMoFu (模糊)

**Video-to-Prompt 生成引擎** — 观看任何视频，生成 AI 视频生成提示词。

专为 Hermes Agent 设计，与 [Novahaku](https://github.com/novaestellar/novahaku) 和 [NovaXinWei](https://github.com/novaestellar/novaxinwei) 协同工作。

## 📋 描述

NovaMoFu 是一个统一的视频分析与提示词生成引擎。通过 Gemini 2.5 的原生视频理解能力，一个 API 调用即可完成视频分析和提示词生成。

**核心理念：** 不是堆砌 "cinematic" "ultra realistic" "8K"，而是回答一个问题——这段素材是谁、用什么设备、在什么年代、出于什么目的拍下来的？

### 核心特性

| 特性 | 说明 |
|------|------|
| 🎬 Gemini 原生视频理解 | 视频 + 音频同时分析，单次 API 调用 |
| 🎯 4种提示词模式 | Seedance 2.0 / Sora / Runway / Generic |
| 📐 7段式结构化输出 | 角色、场景、视觉风格、摄像、时间轴、音频、目标 |
| 📱 设备美学包 | DV、VHS、Super 8、智能手机、监控摄像头 |
| 🚫 反 AI 感检查 | 输出前自动检测并去除 AI 生成痕迹 |
| 🔄 双引擎架构 | Gemini (推荐) + ffmpeg fallback |

## 🚀 快速安装

### 前置条件

```bash
# Python 3.10+
python --version

# 核心依赖
which ffmpeg
which curl

# 可选依赖 (YouTube 下载)
pip install yt-dlp
```

### 安装

```bash
# 方法1: 克隆仓库
git clone https://github.com/novaestellar/novamofu.git
cd novamofu

# 方法2: Hermes Agent 自动安装
# (放入 ~/.hermes/skills/creative/novamofu/ 即可)
```

### 环境变量配置

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑配置 (至少填写 Gemini API Key)
vim .env
```

### 验证安装

```bash
# 检查依赖
bash engine/analyzer.sh --check

# 测试分析 (需要 API Key)
bash engine/analyzer.sh "https://www.youtube.com/watch?v=VIDEO_ID"
```

## 🧩 目录结构

```
novamofu/
├── SKILL.md                 # Hermes 技能定义
├── engine/                  # 核心引擎
│   ├── analyzer.sh          # Gemini API 视频分析
│   ├── prompt_generator.py  # 提示词生成器
│   ├── frame_extractor.sh   # ffmpeg 帧提取 (fallback)
│   └── templates/           # 提示词模板
├── references/              # 参考文档
│   ├── device-aesthetics.md # 设备美学包
│   ├── prompt-structure.md  # 7段式结构
│   ├── anti-ai-checklist.md # 反 AI 感检查
│   └── gemini-api.md        # Gemini API 格式
├── templates/               # 输出模板
├── tests/                   # 测试
├── assets/                  # 资源文件
├── .env.example             # 环境变量模板
├── .gitignore               # Git 忽略配置
├── .gitattributes           # Git 属性
├── README.md                # 项目说明
└── LICENSE                  # MIT 许可证
```

## ⚡ 能力详解

### 1. Gemini 原生视频理解

**一个 API 调用，同时分析视频和音频：**

```bash
source ~/.env
bash engine/analyzer.sh "https://www.youtube.com/watch?v=VIDEO_ID"
```

输出包含：
- 完整转录（带时间戳）
- 逐场景分解（视觉 + 音频）
- 摄像运动分析
- 光影/色彩分析
- 结构化提示词

### 2. 4种提示词模式

| 模式 | 输出风格 | 适用场景 |
|------|----------|----------|
| seedance | Seedance 2.0 风格 | Seedance、Dreamina、即梦 |
| sora | Sora 风格 | OpenAI Sora |
| runway | Runway 风格 | Runway Gen-3/4 |
| generic | 通用风格 | 通用 AI 视频模型 |

### 3. 7段式结构化输出

```
1. 主要角色：谁出现在画面里，外貌和服装如何保持一致
2. 地点：具体空间、时代元素、光影和环境细节
3. 视觉风格：真实感层级和素材气质
4. 摄像风格：设备类型、画面缺陷、操作失误、负面约束
5. 时间轴：10 到 15 秒内每个镜头发生什么
6. 音频：现场声音和环境声音如何对应画面
7. 目标：这段素材最终要像什么
```

### 4. 设备美学包

不同设备产生不同的真实感：

- **2000年代消费级 DV：** 压缩伪影、褪色、手持抖动、自动对焦搜索
- **VHS 家用摄像机：** 扫描线、色彩溢出、时间戳、低分辨率
- **Super 8 胶片：** 胶片颗粒、暗角、划痕、18fps 卡顿
- **智能手机竖屏：** 9:16、HDR 处理、电子防抖
- **监控摄像头：** 高位俯视、低帧率、时间戳、无声

### 5. 反 AI 感检查

输出前自动检查：
- 角色是否一致
- 地点是否具体
- 摄像段是否有物理缺陷
- 时间轴是否有非完美事件
- 音频是否和画面对应
- 有没有混进广告片式运镜和商业调色

## 🔧 使用方式

### YouTube 视频分析

```
/novamofu https://www.youtube.com/watch?v=VIDEO_ID
```

### 本地文件分析

```
分析这个视频并生成 Seedance prompt: ~/Downloads/video.mp4
```

### 带自定义提示

```
watch this video and focus on camera movement and lighting:
https://youtube.com/watch?v=xxxx
```

### 中文使用

```
看看这个视频，分析拍摄手法，然后写一段 Seedance 2.0 的提示词
```

## 📊 成本

| 引擎 | 16分钟视频 | 免费额度 |
|------|-----------|----------|
| Gemini 2.5 Flash | $0.00 | ~1,500 RPD |
| Gemini 2.5 Pro | ~$0.37 | ~50 RPD |
| Fallback (ffmpeg) | $0.00 | 无限 |

## 🔗 与 Novahaku + NovaXinWei 协同

```
用户: "看看这个视频并生成 Seedance prompt: https://youtube.com/..."
     ↓
1. NovaXinWei → 获取视频元数据、字幕、评论
2. NovaMoFu → Gemini 分析视频 + 生成提示词
3. (可选) Novahaku → 如果视频包含安全相关内容，进行分析
```

## 🛡️ 安全说明

- API Key 存储在本地 `.env` 文件中，不会上传到任何服务器
- 视频数据仅发送到 Google Gemini API（不存储）
- 所有分析结果保存在本地
- `NOVAMOFU_ALLOW_PRIVATE=1` 仅限本地测试

## 📚 参考文档

`references/` 目录包含详细参考文档：

| 文档 | 说明 |
|------|------|
| `device-aesthetics.md` | 设备美学包详情 |
| `prompt-structure.md` | 7段式提示词结构 |
| `anti-ai-checklist.md` | 反 AI 感检查清单 |
| `gemini-api.md` | Gemini API 格式与限制 |

## 📄 许可证

MIT License — 详见 [LICENSE](LICENSE) 文件。

## 🏷️ 标签

`#视频分析` `#AI视频` `#提示词生成` `#Seedance` `#Sora` `#Runway` `#Gemini` `#Hermes技能` `#novalabs`
