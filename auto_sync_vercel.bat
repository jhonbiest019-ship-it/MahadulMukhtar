@echo off
echo ==================================================
echo   🕌 Al Mukhtar Islamic Institute - Auto Vercel Sync
echo ==================================================
echo.
echo Uploading local changes to GitHub & Vercel Live...
echo.

git add .
git commit -m "Auto sync updates to Live Vercel & Firebase Cloud - %date% %time%"
git push origin main

echo.
echo ==================================================
echo   ✅ SUCCESS! All local changes are now LIVE on Vercel!
echo ==================================================
pause
