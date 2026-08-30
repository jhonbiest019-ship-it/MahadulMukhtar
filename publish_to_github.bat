@echo off
echo ==================================================
echo   🕌 Al Mukhtar Islamic Institute - GitHub Publisher
echo ==================================================
echo.

set /p GITHUB_USER="Apna GitHub Username likhein aur Enter dabein: "

if "%GITHUB_USER%"=="" (
    echo Username blank nahi ho sakta!
    pause
    exit /b
)

echo.
echo Connecting to GitHub repository: https://github.com/%GITHUB_USER%/AlMukhtar-Islamic-Institute.git ...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/%GITHUB_USER%/AlMukhtar-Islamic-Institute.git
git branch -M main
git push -u origin main

echo.
echo ==================================================
echo   ✅ SUCCESS! App source code GitHub par upload ho gaya hai.
echo ==================================================
pause
