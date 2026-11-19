# 个人主页（Academic Pages）

基于 [Academic Pages](https://github.com/academicpages/academicpages.github.io) 模板改的个人主页，界面为中文，包含四个板块：研究项目、论文、项目、经历。

线上地址：https://zoush99.github.io

## 日常更新

改 Markdown 文件 → 双击 `publish.bat`（或手动 `git push`）→ GitHub Actions 自动构建，1~3 分钟后线上更新。**本机不需要装 Ruby，也不用自己构建。**

### 各类内容放在哪

| 想改什么 | 改哪里 |
| --- | --- |
| 首屏简介 | `_pages/about.md` |
| 论文 | `_publications/` 下新建一个 `.md`（文件名 `年-月-日-标题.md`） |
| 研究项目 / 项目 | `_portfolio/` 下新建 `.md`，用 `category: research` 进研究项目页、`category: engineering` 进项目页 |
| 经历（教育/工作/技能/荣誉） | `_pages/cv.md` |
| 顶部导航 | `_data/navigation.yml` |
| 姓名、简介、头像、邮箱、社交链接 | `_config.yml` 的 `author:` 段 |
| 左侧头像图片 | 覆盖 `images/profile.png` |
| 配色主题 | `_config.yml` 的 `site_theme`（default / air / sunrise / mint / dirt / contrast） |

新增一篇论文的最小写法：

```markdown
---
title: "论文标题"
collection: publications
category: manuscripts   # manuscripts=期刊论文，conferences=会议论文
permalink: /publication/2026-my-paper
excerpt: "一句话摘要"
date: 2026-03-01
venue: "期刊名"
paperurl: "https://doi.org/..."
citation: "作者 (2026). &quot;论文标题.&quot; <i>期刊名</i>."
---
正文（可选，会显示在论文详情页）
```

## 本机构建（可选）

```bash
bundle install      # 首次安装依赖
bundle exec jekyll serve   # 本地预览 http://127.0.0.1:4000
```

## 部署机制

`.github/workflows/deploy.yml`：推送 `main` → `bundle install` → `jekyll build` → 把 `_site` 发布到 `gh-pages` 分支。GitHub Pages 托管 `gh-pages` 分支。

## 目录说明

| 路径 | 作用 |
| --- | --- |
| `_config.yml` | 站点全局配置（作者信息、主题、分类等） |
| `_data/navigation.yml` | 顶部导航 |
| `_data/ui-text.yml` | 界面文案（已设 `locale: zh-CN`，自动用中文标签） |
| `_pages/` | 独立页面：首页、论文、研究项目、项目、经历、404 |
| `_publications/` | 论文条目 |
| `_portfolio/` | 研究项目与项目条目 |
| `_includes/` `_layouts/` `_sass/` | 主题模板与样式 |
| `images/` | 头像与图片资源 |

## 许可

模板遵循 [MIT License](./LICENSE)。
