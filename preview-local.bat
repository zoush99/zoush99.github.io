@echo off
chcp 936 >nul
setlocal

REM ============================================================
REM  本地预览：启动 Jekyll 后浏览器访问 http://127.0.0.1:4000
REM  改内容保存后页面自动刷新；按 Ctrl+C 停止。
REM ============================================================

set "SITE_DIR=C://Code//zoush99.github.io"
set "PATH=C://Ruby34-x64//bin;%PATH%"
set "RUBYOPT=-Eutf-8"
set "JEKYLL_ENV=development"
cd /d "%SITE_DIR%" || goto :error

REM 本机未装 ImageMagick，需要本地覆盖配置关闭响应式图片；缺失时自动生成
if not exist _config_local.yml (
  echo imagemagick:> _config_local.yml
  echo   enabled: false>> _config_local.yml
  echo 已生成本地覆盖配置 _config_local.yml
)

echo.
echo 正在启动本地预览，稍后浏览器访问 http://127.0.0.1:4000
echo 改内容保存后页面会自动刷新；按 Ctrl+C 停止预览。
echo.

bundle _4.0.6_ exec jekyll serve --config _config.yml,_config_local.yml --host 127.0.0.1 --port 4000 --livereload
endlocal
exit /b 0

:error
echo [错误] 未找到项目目录 %SITE_DIR%
pause
exit /b 1
