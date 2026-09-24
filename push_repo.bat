@echo off
setlocal

echo ========================================================
echo           Pushing Tux Package Manager to GitHub        
echo ========================================================

set GIT="C:\devkitPro\msys2\usr\bin\git.exe"
set PATH=C:\devkitPro\msys2\usr\bin;C:\devkitPro\msys2\usr\lib\git-core;%PATH%

set TOKEN=%GH_TOKEN%
if "%TOKEN%"=="" set TOKEN=%1
if "%TOKEN%"=="" (
    echo [ERROR] No GitHub token provided!
    echo Usage: push_repo.bat [GITHUB_TOKEN]
    echo Or set GH_TOKEN environment variable.
    exit /b 1
)

if not exist .git (
    echo Initializing git repository...
    %GIT% init
    %GIT% branch -M main
)

%GIT% config user.name "CrimsonOnGit-hub"
%GIT% config user.email "allaboutgames2268@gmail.com"

echo Adding files to git staging...
%GIT% add .

echo Committing files...
%GIT% commit -m "Revive Tux universal package manager with sebrepository support"

echo Setting remote repository...
%GIT% remote remove origin >nul 2>nul
%GIT% remote add origin https://%TOKEN%@github.com/CrimsonOnGit-hub/tux.git

echo Pushing to GitHub main branch...
%GIT% push -u origin main --force

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo   [SUCCESS] Tux successfully pushed to GitHub!
    echo ========================================================
) else (
    echo.
    echo [ERROR] Git push failed.
)
