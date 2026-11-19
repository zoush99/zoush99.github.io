---
layout: page
title: 项目
permalink: /projects/
description: 交付过的软件系统与工程实践，含技术栈、职责与实现要点。
nav: true
nav_order: 3
---

<div class="projects">
  {% assign engineering_items = site.projects | where: "category", "engineering" | sort: "importance" %}
  {% if engineering_items.size > 0 %}
  <div class="row row-cols-1 row-cols-md-3">
    {% for project in engineering_items %}
      {% include projects.liquid %}
    {% endfor %}
  </div>
  {% else %}
  <p>暂无项目条目。</p>
  {% endif %}
</div>
