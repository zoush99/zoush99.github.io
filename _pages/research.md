---
layout: page
title: 研究项目
permalink: /research/
description: 研究课题、技术路线与阶段结论。条目按重要度排序。
nav: true
nav_order: 1
---

<div class="projects">
  {% assign research_items = site.projects | where: "category", "research" | sort: "importance" %}
  {% if research_items.size > 0 %}
  <div class="row row-cols-1 row-cols-md-3">
    {% for project in research_items %}
      {% include projects.liquid %}
    {% endfor %}
  </div>
  {% else %}
  <p>暂无研究项目条目。</p>
  {% endif %}
</div>
