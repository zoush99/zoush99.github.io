---
permalink: /
title: "你好，我是 Sheng"
author_profile: true
---

我在工业软件与人工智能视觉方向做研发，关注怎么把深度学习与数据处理方法真正落到工业现场的检测和分析流程里。

目前主要在做三件事：局部放电图谱的模式识别、试验数据的处理与报告自动化、面向小样本的数据增强。

## 最新文章

{% if site.posts.size > 0 %}
<ul>
  {% for post in site.posts limit: 3 %}
  <li>
    <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
    <span class="page__meta">　{{ post.date | date: "%Y-%m-%d" }}</span>
  </li>
  {% endfor %}
</ul>
<p><a href="{{ '/blog/' | relative_url }}">查看全部文章 →</a></p>
{% else %}
<p>还没有文章。</p>
{% endif %}

## 板块速览

- [博客]({{ '/blog/' | relative_url }})：研究笔记、工程踩坑与阶段性思考
- [项目]({{ '/portfolio/' | relative_url }})：研究项目与交付过的软件系统
- [论文]({{ '/publications/' | relative_url }})：按类型分组的论文列表
- [经历]({{ '/cv/' | relative_url }})：教育、工作、技能与荣誉
- [总结]({{ '/summary/' | relative_url }})：阶段性的研究总结与能力盘点
- [关于]({{ '/about/' | relative_url }})：更详细的自我介绍与联系方式
