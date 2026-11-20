---
layout: archive
title: "总结"
permalink: /summary/
author_profile: false
---

{% include base_path %}

{% assign summaries = site.summaries | sort: "date" %}
{% assign last_year = "" %}
{% for post in summaries reversed %}
  {% assign post_year = post.date | date: "%Y" %}
  {% if post_year != last_year %}
<h2 class="archive__item-year">{{ post_year }}</h2>
    {% assign last_year = post_year %}
  {% endif %}
  {% include archive-single.html %}
{% endfor %}
