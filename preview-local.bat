@echo off
chcp 936 >nul
setlocal

REM ============================================================
REM  本地预览脚本：双击后浏览器访问 http://127.0.0.1:4000
REM  修改文章后会自动刷新；按 Ctrl+C 停止预览。
REM ============================================================

set "PATH=C:\Ruby34-x64\bin;%PATH%"
set "RUBYOPT=-Eutf-8"
set "JEKYLL_ENV=development"
cd /d "C:\Code\zoush99.github.io"

echo.
echo 正在启动本地预览，启动后浏览器访问 http://127.0.0.1:4000
echo 修改文章后页面会自动刷新；按 Ctrl+C 停止预览。
echo.

bundle _4.0.6_ exec jekyll serve --config _config.yml,_config_local.yml --host 127.0.0.1 --port 4000 --livereload

endlocal
