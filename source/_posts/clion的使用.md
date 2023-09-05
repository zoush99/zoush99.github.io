---
title: clion的使用
date: 2023-09-05 15:29:16
tags: 
- IKOS
- Project
categories: 
- learn
typora-root-url: ./../
---

## 将Clion作为编程工具

<!--more-->

首先将Clion中的一些快捷指令快速记录，以备后续之需。目前的工作主要是将Clion作为C++语言的开发工具，加上在ubuntu上使用十分方便。

### 快捷键

- ALT+1：显示隐藏工程栏
- CTRL+/：注释or解注释光标所在行
- CTRL+SHIFT+/：注释or解注释选中的多行代码
- 在某个函数的上面一行输入/**+ENTER：快速生成某种格式的注释（for 大型项目）
- CTRL+D：快速复制光标所在行
- CTRL+X：快速剪切光标所在行
- CTRL+W：实现某个字符、某个字符串、某段代码的扩选（智能扩选）
- ALT+SHIFT+INSERT：按以下此组合建，在选中代码，可以实现多行某段代码的选中
- CTRL+ALT+ “-” or “+” ：展开or折叠光标所在的花括号
- CTRL+SHIFT+ “-” or “+” ：展开or折叠所有花括号
- CTRL+鼠标左键：由函数声明跳转到函数定义 or 由函数定义跳转回函数声明
- CTRL+ALT+R：重新格式化代码
- ALT+ENTER：智能提示代码错误与解决方案
- CTRL+F：匹配查找代码
- CTRL+Z：返回编辑前
- SHIFT+CTRL+Z：返回编辑后信息
- CTRL+F：查找
- CTRL+R：替换
- CTRL+L：向后查找
- CTRL+Shift+L：向前查找
- CTRL+ALT+S：设置
- Shift+F10：运行
- Shift+F9：调试

### 断点调试

- 单步运行（不跳转至其他标签，仅在本程序内）
- 单步运行（可调转到自己编写的库or头文件）
- 单步运行（可强制跳转到第三方库or头文件）
- 从第三方库跳回源文件
- 监测选中的变量
