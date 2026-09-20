# 设备美学包 (Device Aesthetics Packs)

不同设备产生不同的真实感。在提示词中指定设备类型,可以让 AI 模型生成符合特定年代和设备特征的画面。

## 2000年代消费级 DV

**关键词:** `digital artifacts, faded colors, soft contrast, sensor noise, heavy handheld shake, frequent autofocus hunting, exposure fluctuation`

**特征:**
- 中等数字压缩伪影
- 褪色的色彩
- 柔和的对比度
- 轻微传感器噪点
- 强烈手持抖动
- 频繁自动对焦搜索
- 在阳光和阴影间移动时曝光波动

**负面约束:**
```
没有稳定。没有电影化的摄像机移动。没有现代色彩分级。
没有三脚架。没有专业布光。没有4K清晰度。
```

**适用场景:** 家庭录像、校园生活、日常vlog、怀旧内容

## VHS 家用摄像机

**关键词:** `scan lines, color bleeding, timestamp, low resolution, tape noise, tracking errors`

**特征:**
- 扫描线
- 色彩溢出(bleeding)
- 时间戳叠加
- 低分辨率
- 磁带噪点
- 跟踪错误

**负面约束:**
```
没有数字清晰度。没有16:9宽屏。没有稳定画面。
没有自动曝光补偿。没有降噪处理。
```

**适用场景:** 80-90年代家庭录像、恐怖片风格、复古美学

## Super 8 胶片

**关键词:** `film grain, vignette, scratches, 18fps stutter, light leaks, warm tones`

**特征:**
- 胶片颗粒
- 暗角(vignette)
- 划痕
- 18fps 卡顿感
- 光晕(light leaks)
- 暖色调

**负面约束:**
```
没有数字锐度。没有稳定画面。没有现代色彩。
没有60fps流畅度。没有数字特效。
```

**适用场景:** 文艺片、回忆片段、复古广告、艺术短片

## 智能手机竖屏

**关键词:** `9:16, HDR processing, electronic stabilization, slight over-sharpening, finger near lens edge`

**特征:**
- 9:16 竖屏构图
- HDR 处理痕迹
- 电子防抖(EIS)
- 轻微过度锐化
- 手指偶尔擦过镜头边缘

**负面约束:**
```
没有横屏。没有三脚架稳定。没有专业布光。
没有光学变焦。没有电影感运镜。
```

**适用场景:** 短视频、社交媒体内容、街头拍摄、即兴记录

## 监控摄像头

**关键词:** `high angle, low frame rate, timestamp, silent, wide angle distortion, fixed position`

**特征:**
- 高位俯视角度
- 低帧率(5-15fps)
- 时间戳叠加
- 无声
- 广角畸变
- 固定机位

**负面约束:**
```
没有声音。没有移动镜头。没有高帧率。
没有色彩校正。没有变焦。
```

**适用场景:** 安全监控、恐怖/悬疑、纪录片素材

## GoPro 运动相机

**关键词:** `wide angle, fisheye, high frame rate, waterproof, mounted perspective`

**特征:**
- 超广角/鱼眼畸变
- 高帧率(60-120fps)
- 防水特性
- 安装视角(头戴、胸挂、车载)

**负面约束:**
```
没有标准镜头透视。没有稳定器。没有浅景深。
没有电影色彩。没有慢动作(除非原始就是慢动作)。
```

**适用场景:** 运动、极限运动、旅行、第一人称视角

## 电影摄影机

**关键词:** `shallow depth of field, film grain, dynamic range, professional lighting, steady cam`

**特征:**
- 浅景深
- 胶片颗粒(如果是胶片机)
- 高动态范围
- 专业布光
- 稳定画面

**负面约束:**
```
这个设备本身就是"专业"的,不需要负面约束。
但要注意:如果目标是"真实感",应该避免这种设备。
```

**适用场景:** 电影、广告、高端商业内容

## 使用方法

在提示词的"摄像风格"段落中指定设备:

```
摄像风格:
智能手机竖屏拍摄,9:16竖构图,轻微过度锐化和HDR处理感,
走路时画面有上下浮动,光线从阴影切到阳光时曝光短暂波动。
没有横屏。没有三脚架稳定。没有专业布光。
```

设备选择决定了:
1. 画面质量(分辨率、帧率、色彩)
2. 稳定性(手持vs三脚架)
3. 视角(广角vs标准vs长焦)
4. 声音(有声vs无声)
5. 缺陷特征(噪点、畸变、伪影)
