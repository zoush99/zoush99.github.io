@echo off
chcp 936 >nul
setlocal

REM ============================================================
REM  【备选方案】本地构建静态文件 -> 直接推送 gh-pages
REM
REM  日常更新请优先用 publish.bat（推 main，由 GitHub Actions
REM  自动构建部署）。只有 Actions 构建失败、需要立即上线时，
REM  才用本脚本在本地构建后直接推 gh-pages。
REM ============================================================

set "SITE_DIR=C://Code//zoush99.github.io"
set "RUBY_BIN=C://Ruby34-x64//bin"
set "DEPLOY_DIR=C://Code//zoush99-ghpages-deploy"

echo [1/5] 配置环境...
set "PATH=%RUBY_BIN%;%PATH%"
set "RUBYOPT=-Eutf-8"
set "JEKYLL_ENV=production"
cd /d "%SITE_DIR%" || goto :error

if not exist _config_local.yml (
  echo imagemagick:> _config_local.yml
  echo   enabled: false>> _config_local.yml
)

echo [2/5] 本地构建静态站点...
call bundle _4.0.6_ exec jekyll build --config _config.yml,_config_local.yml
if errorlevel 1 goto :error

echo [3/5] 添加 .nojekyll...
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
git commit -m "本地构建部署静态站点"
git push origin HEAD:gh-pages
if errorlevel 1 goto :error

echo.
echo 部署完成，稍等 1-2 分钟访问 https://zoush99.github.io
goto :cleanup

:error
echo.
echo [错误] 部署失败，请查看上方日志。
pause
exit /b 1

:cleanup
cd /d "%SITE_DIR%"
git worktree remove --force "%DEPLOY_DIR%" 2>nul
pause
endlocal
