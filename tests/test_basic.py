#!/usr/bin/env python3
"""Basic tests for NovaMoFu prompt generator."""

import sys
import os

# Add parent to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from engine.prompt_generator import generate_prompt, parse_gemini_output, enhance_with_device_pack


def test_parse_gemini_output():
    """Test parsing Gemini analysis output."""
    sample = """## 素材来源身份
一段2024年路人用智能手机在纽约街头拍到的早晨通勤片段。

## 主要角色
一名30岁上班族,深灰色大衣,白色衬衫。

## 地点
纽约曼哈顿街角,清晨7点。

## 时间轴
00:00-00:02 镜头从地铁口抬起。
00:02-00:04 上班族走出来。"""

    sections = parse_gemini_output(sample)
    assert "素材来源身份" in sections
    assert "主要角色" in sections
    assert "30岁上班族" in sections["主要角色"]
    print("✅ test_parse_gemini_output PASSED")


def test_generate_seedance_prompt():
    """Test Seedance prompt generation."""
    sample = """## 素材来源身份
路人用智能手机拍到的街头片段。

## 主要角色
30岁男性,灰色大衣。

## 地点
纽约街头。

## 时间轴
00:00-00:05 男人走过。"""

    prompt = generate_prompt(sample, mode="seedance")
    assert "NovaMoFu" in prompt
    assert "Seedance" in prompt
    assert "30岁男性" in prompt
    print("✅ test_generate_seedance_prompt PASSED")


def test_generate_sora_prompt():
    """Test Sora prompt generation."""
    sample = """## Source Identity
A person filming with smartphone on NYC street.

## Subject
30-year-old male in gray coat.

## Scene
NYC street corner.

## Timeline
00:00-00:05 Man walks by."""

    prompt = generate_prompt(sample, mode="sora")
    assert "Sora" in prompt
    assert "30-year-old" in prompt
    print("✅ test_generate_sora_prompt PASSED")


def test_enhance_with_device_pack():
    """Test device aesthetic pack injection."""
    prompt = """## 视觉风格
真实感

## 摄像风格
智能手机拍摄

## 时间轴
00:00-00:05 测试"""

    enhanced = enhance_with_device_pack(prompt, "phone")
    assert "9:16" in enhanced
    assert "HDR" in enhanced
    print("✅ test_enhance_with_device_pack PASSED")


def test_negative_prompt_included():
    """Test that negative prompts are included."""
    prompt = generate_prompt("## 测试\n内容", mode="seedance")
    assert "没有" in prompt
    assert "三脚架" in prompt
    print("✅ test_negative_prompt_included PASSED")


if __name__ == "__main__":
    test_parse_gemini_output()
    test_generate_seedance_prompt()
    test_generate_sora_prompt()
    test_enhance_with_device_pack()
    test_negative_prompt_included()
    print("\n🎉 All tests passed!")
