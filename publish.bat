@echo off
chcp 936 >nul
setlocal

REM ============================================================
REM  一键发布：提交本地改动并推送到 GitHub
REM  推送后由 GitHub Actions 自动构建部署，1~3 分钟后线上更新。
REM  用法：改完内容后双击本文件即可。
REM ============================================================

set "SITE_DIR=C://Code//zoush99.github.io"
cd /d "%SITE_DIR%" || goto :error

echo.
echo [1/3] 检查改动...
git add -A
git diff --cached --quiet
if not errorlevel 1 (
  echo     没有需要提交的改动，直接结束。
  goto :done
)

echo [2/3] 提交改动...
git commit -m "更新站点内容" >nul
if errorlevel 1 (
  echo     提交失败，请查看上方信息。
  goto :error
)

echo [3/3] 推送到 GitHub...
set /a tries=0
:push
set /a tries+=1
git push origin main
if errorlevel 1 (
  if %tries% lss 6 (
    echo     推送失败（可能是网络波动），15 秒后重试 %tries%/6...
    timeout /t 15 /nobreak >nul
    goto push
  )
  echo     多次推送失败，请检查网络或代理设置。
  goto :error
)

:done
echo.
echo ============================================================
echo  已推送。GitHub Actions 正在构建，约 1~3 分钟后访问：
echo  https://zoush99.github.io
echo ============================================================
echo.
pause
endlocal
exit /b 0

:error
echo.
echo [错误] 发布未完成，请查看上方日志。
echo.
pause
exit /b 1
