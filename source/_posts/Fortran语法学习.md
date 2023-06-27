---
title: Fortran语法学习
date: 2023-06-27 08:46:14
tags: 
- Fortran
- skills
categories: 
- Fortran
typora-root-url: ./../
---

## Fortran语法学习备忘

<!--more-->

 ### Fortran程序设计基础

+ 字符集
+ 书面格式
  + 固定格式
  + 自由格式
+ Fortran的数据类型
  + 整数
  + 浮点数
  + 复数
  + 字符
  + 逻辑判断
+ Fortran的数学表达式
  + 加
  + 减
  + 乘
  + 除
  + 乘幂
  + 括号

### 输入输出及声明

+ 输入输出命令
  + write
  + print
  + read
+ 声明
  + 原则
  + 整数类型
  + 浮点数
    + 单精度
    + 双精度
  + 复数
    + 单精度
    + 双精度
  + 字符及字符串
    + 字符串合并
    + 改变字符串的某一部分
    + 字符串函数
      + char(num)
      + ichar(char)
      + len(string)
      + len_trim(string)
      + trim(string)
      + index(string,key[,.true.])  !为.true.则从右开始 
      + adjustl(string)
      + adjustr(string)
    + 逻辑变量
  + 输入命令write
  + 格式化输入输出(format)
