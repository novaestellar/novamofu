<p align="center">
  <img src="assets/logo.svg" alt="NovaMoFu Logo" width="150">
</p>

# NovaMoFu (模糊)

> **视频转提示词引擎** — Gemini原生分析 · 4种输出模式 · 7段式结构 · 反AI感检查

<p align="center">
  <strong>novalabs</strong><br>
  以微知著,模糊成真 — 模糊
</p>

---

## 📋 描述

NovaMoFu 是一个统一的视频分析与提示词生成引擎。通过 Gemini 2.5 的原生视频理解能力,一个 API 调用即可完成视频分析和提示词生成。

专为 Hermes Agent 平台设计,与 [Novahaku](https://github.com/novaestellar/novahaku) 和 [NovaXinWei](https://github.com/novaestellar/novaxinwei) 协同工作:**新信微负责侦察发现,模糊负责视频理解,Mohaku负责漏洞利用。**

### 核心理念

很多 AI 视频提示词看起来完整,生成后还是一眼假。常见问题是:堆砌 "cinematic" "ulrealistic" "8K" 等风格词,但没有写清楚素材的真实来源。

**NovaMoFu 的方法:** 回答一个问题——这段素材是谁、用什么设备、在什么年代、出于什么目的拍下来的?一旦确定了"素材来源身份",所有细节都能推导出来。

### 核心特性

| 特性 | 说明 |
|------|------|
| 🎬 Gemini 原生视频理解 | 视频 + 音频同时分析,单次 API 调用 |
| 🎯 4种提示词模式 | Seedance 2.0 / Sora / Runway / Generic |
| 📐 7段式结构化输出 | 角色、场景、视觉风格、摄像、时间轴、音频、目标 |
| 📱 设备美学包 | DV、VHS、Super 8、智能手机、监控摄像头 |
| 🚫 反 AI 感检查 | 输出前自动检测并去除 AI 生成痕迹 |
| 🔄 双引擎架构 | Gemini (推荐) + ffmpeg fallback |

---

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
pip install -r requirements.txt

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

# 测试分析
bash engine/analyzer.sh "https://www.youtube.com/watch?v=VIDEO_ID"
```

---

## 🧩 目录结构

```
novamofu/
├── SKILL.md                 # Hermes 技能定义
├── engine/                  # 核心引擎
│   ├── analyzer.sh          # Gemini API 视频分析
│   ├── prompt_generator.py  # 提示词生成器
│   ├── frame_extractor.sh   # ffmpeg 帧提取 (fallback)
│   └── templates/           # 提示词模板
├── references/              # 参考文档 (4个)
│   ├── device-aesthetics.md # 设备美学包
│   ├── prompt-structure.md  # 7段式结构
│   ├── anti-ai-checklist.md # 反 AI 感检查
│   └── gemini-api.md        # Gemini API 格式
├── templates/               # 输出模板
├── tests/                   # 测试
├── assets/                  # 资源文件
├── SKILL.md                 # Hermes 技能定义
├── .env.example             # 环境变量模板
├── .gitignore               # Git 忽略配置
├── .gitattributes           # Git 属性
├── README.md                # 项目说明
└── LICENSE                  # MIT 许可证
```

---

## ⚡ 能力详解

### 1. Gemini 原生视频理解

**核心原理:** Gemini 2.5 Pro/Flash 原生支持视频 + 音频同时输入。一个 API 调用即可获取:
- 完整转录(带时间戳)
- 逐场景分解(视觉 + 音频)
- 摄像运动分析
- 光影/色彩分析
- 结构化提示词

**使用方式:**
```bash
source ~/.env
bash engine/analyzer.sh "https://www.youtube.com/watch?v=VIDEO_ID"
```

**成本:**
| 引擎 | 16分钟视频 | 免费额度 |
|------|-----------|----------|
| Gemini 2.5 Flash | $0.00 | ~1,500 RPD |
| Gemini 2.5 Pro | ~$0.37 | ~50 RPD |
| Fallback (ffmpeg) | $0.00 | 无限 |

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

不同设备产生不同的真实感:

| 设备 | 特征 |
|------|------|
| 2000年代消费级 DV | 压缩伪影、褪色、手持抖动、自动对焦搜索 |
| VHS 家用摄像机 | 扫描线、色彩溢出、时间戳、低分辨率 |
| Super 8 胶片 | 胶片颗粒、暗角、划痕、18fps 卡顿 |
| 智能手机竖屏 | 9:16、HDR 处理、电子防抖 |
| 监控摄像头 | 高位俯视、低帧率、时间戳、无声 |

### 5. 反 AI 感检查

输出前自动检查:
- 角色是否一致
- 地点是否具体
- 摄像段是否有物理缺陷
- 时间轴是否有非完美事件
- 音频是否和画面对应
- 有没有混进广告片式运镜和商业调色

---

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

---

## 🔗 与 Novahaku + NovaXinWei 协同

```
用户: "看看这个视频并生成 Seedance prompt: https://youtube.com/..."
     ↓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
阶段1: NovaXinWei (新信微) — 数据采集
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ├─ 获取视频元数据、字幕、评论
  └─ 输出: 视频信息 JSON
     ↓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
阶段2: NovaMoFu (模糊) — 视频分析 + 提示词生成
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ├─ Gemini 原生视频理解 (1 API 调用)
  ├─ 逐场景分解 (视觉 + 音频)
  ├─ 7段式结构化输出
  └─ 输出: Seedance/Sora/Runway 提示词
     ↓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
阶段3: (可选) Novahaku — 安全分析
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  └─ 如果视频包含安全相关内容,进行漏洞分析
```

### 协同约定

| 约定 | 说明 |
|------|------|
| **数据格式** | JSON 格式,通过 Hermes session context 传递 |
| **互不侵入** | NovaMoFu 不写爬虫代码,NovaxinWei 不写提示词代码 |
| **上下文传递** | 通过 Hermes skill chaining,用户意图自动路由 |

---

## 🛡️ 安全说明

- API Key 存储在本地 `.env` 文件中,不会上传到任何服务器
- 视频数据仅发送到 Google Gemini API(不存储)
- 所有分析结果保存在本地
- `NOVAMOFU_ALLOW_PRIVATE=1` 仅限本地测试

---

## 📚 参考文档

`references/` 目录包含4个详细参考文档:

| 文档 | 说明 |
|------|------|
| `device-aesthetics.md` | 设备美学包详情 |
| `prompt-structure.md` | 7段式提示词结构 |
| `anti-ai-checklist.md` | 反 AI 感检查清单 |
| `gemini-api.md` | Gemini API 格式与限制 |

---

## 🤝 贡献

欢迎贡献代码、报告Bug或提出建议。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m '添加了某个特性'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 — 详见 [LICENSE](LICENSE) 文件。

---

## 🏷️ 标签

`#视频分析` `#AI视频` `#提示词生成` `#Seedance` `#Sora` `#Runway` `#Gemini` `#Hermes技能` `#novalabs`
