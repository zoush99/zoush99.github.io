#!/usr/bin/env bash
# ============================================================
#  本地预构建静态文件 -> 推送 gh-pages 一键部署脚本 (Git Bash)
#  本站不依赖云端 Jekyll 构建，静态文件由本地生成后直接上传。
# ============================================================
set -euo pipefail

SITE_DIR="/c/Code/zoush99.github.io"
export PATH="/c/Ruby34-x64/bin:$PATH"
export RUBYOPT="-Eutf-8"
export JEKYLL_ENV=production
DEPLOY_DIR="/tmp/zoush99-ghpages-deploy"

echo "[1/5] 进入项目目录..."
cd "$SITE_DIR"

echo "[2/5] 本地构建静态站点..."
bundle _4.0.6_ exec jekyll build --config _config.yml,_config_local.yml

echo "[3/5] 添加 .nojekyll（让 Pages 跳过构建）..."
touch _site/.nojekyll

echo "[4/5] 准备 gh-pages 部署目录..."
git worktree remove --force "$DEPLOY_DIR" 2>/dev/null || true
git worktree add --detach "$DEPLOY_DIR" origin/gh-pages
cd "$DEPLOY_DIR"
git rm -rf -q .
cp -a "$SITE_DIR/_site/." .
git add -A

echo "[5/5] 提交并推送到 gh-pages..."
git commit -m "Deploy pre-rendered static site (local build)" || echo "(无变更可提交)"
git push origin HEAD:gh-pages

cd "$SITE_DIR"
git worktree remove --force "$DEPLOY_DIR" 2>/dev/null || true

echo ""
echo "============================================================"
echo " 部署完成！稍等 1-2 分钟访问 https://zoush99.github.io"
echo "============================================================"
