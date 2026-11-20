---
layout: archive
title: "个人经历"
permalink: /cv/
author_profile: false
redirect_from:
  - /resume
---

{% include base_path %}

<!-- 占位示例数据（爱因斯坦），替换成你自己的经历即可 -->

教育经历
======
* **2018.09 - 2022.06**，西安电子科技大学，网络与信息安全学院，信息安全，学士
  * 学位论文《基于格的ECDSA密码算法分析方法》
  * 研究方向：网络空间安全、密码学、密码分析学
* **2022.09 - 2025.06**，国防科技大学，计算机学院，软件工程，硕士
  * 学位论文《基于抽象解释的Fortran程序浮点性质分析》
  * 研究方向：程序分析、抽象解释、浮点性质分析

工作经历
======
* **2025.07 - 至今**，西安高压电器研究院股份有限公司，技术中心，数字智造研究室，数智化研发工程师
  * 研究方向：电力设备故障诊断、电力设备故障预测、电力设备状态趋势分析
  * 工程方向：电力设备型式/出厂试验管理系统（LIMS）、电力设备试验数据采集软件（Modbus-rtu协议、OCR、手动录入）

论文
======
<ul>{% assign pubs = site.publications | sort: "date" %}{% assign last_year = "" %}{% for post in pubs reversed %}
  {% assign post_year = post.date | date: "%Y" %}
  {% if post_year != last_year %}
    <h2 class="archive__item-year">{{ post_year }}</h2>
    {% assign last_year = post_year %}
  {% endif %}
  {% include archive-single-cv.html %}
{% endfor %}</ul>

荣誉与奖项
======
* 2021，第十三届全国大学生数学竞赛一等奖（西北赛区）
