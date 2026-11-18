@echo off
chcp 65001 >nul
setlocal

REM ============================================================
REM  本地预构建静态文件 -> 推送 gh-pages 一键部署脚本
REM  本站不依赖云端 Jekyll 构建，静态文件由本地生成后直接上传。
REM ============================================================

set "SITE_DIR=C:\Code\zoush99.github.io"
set "RUBY_BIN=C:\Ruby34-x64\bin"
set "DEPLOY_DIR=C:\Code\zoush99-ghpages-deploy"

echo [1/5] 配置环境...
set "PATH=%RUBY_BIN%;%PATH%"
set "RUBYOPT=-Eutf-8"
set "JEKYLL_ENV=production"
cd /d "%SITE_DIR%" || goto :error

echo [2/5] 本地构建静态站点...
call bundle _4.0.6_ exec jekyll build --config _config.yml,_config_local.yml
if errorlevel 1 goto :error

echo [3/5] 添加 .nojekyll（让 Pages 跳过构建）...
type nul > _site\.nojekyll

echo [4/5] 准备 gh-pages 部署目录...
if exist "%DEPLOY_DIR%" rmdir /s /q "%DEPLOY_DIR%"
git worktree add --detach "%DEPLOY_DIR%" origin/gh-pages
if errorlevel 1 goto :error
cd /d "%DEPLOY_DIR%" || goto :error
git rm -rf -q .
robocopy "%SITE_DIR%\_site" . /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 goto :error
git add -A

echo [5/5] 提交并推送到 gh-pages...
git commit -m "Deploy pre-rendered static site (local build)"
git push origin HEAD:gh-pages
if errorlevel 1 goto :error

echo.
echo ============================================================
echo  部署完成！稍等 1-2 分钟访问 https://zoush99.github.io
echo ============================================================
goto :cleanup

:error
echo.
echo [错误] 部署失败，请查看上方日志。
exit /b 1

:cleanup
cd /d "%SITE_DIR%"
git worktree remove --force "%DEPLOY_DIR%" 2>nul
endlocal
