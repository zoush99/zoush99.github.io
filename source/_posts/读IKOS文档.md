---
title: 读IKOS文档
date: 2023-09-06 19:53:54
tags: 
- ikos
- project
categories: 
- ikos
- learn
typora-root-url: ./../
---

## 读IKOS文档

<!--more-->

主要记录IKOS文档的信息，以备自己之后做更改时，可以更好地回忆。

### 前端工作部分

![image-20230906195706369](/paper_source/读IKOS文档/前端修改LLVM2AR.jpg)

前端的工作主要是在两个地址：

```
include/ikos/frontend/llvm/import contains definition of the translation from LLVM to AR.
src/import contains implementation of the translation from LLVM to AR.
```

这是肯定要做修改的部分，后续可能需要修改下游的一些关联数据。但是目前设计的思路是先将原来进行的转换部分先读懂。如果按照原来的思路能进行便按照最简单的方法进行，否则全部重新设计工作量太大。
