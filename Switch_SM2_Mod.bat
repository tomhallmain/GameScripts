@echo off
setlocal enabledelayedexpansion

:: Space Marine 2 Mod Switcher Script
:: This script switches between modded and non-modded versions of Warhammer: Space Marine 2
:: by managing pak files and config backups

:: Configuration - Update these paths to match your system
set "STEAM_LIBRARY_PATH=D:\SteamLibrary"
set "GAME_PATH=%STEAM_LIBRARY_PATH%\steamapps\common\Space Marine 2"
set "MODS_PATH=%GAME_PATH%\client_pc\root\mods"
set "UNUSED_MODS_PATH=%GAME_PATH%\client_pc\root\unused_mods"
set "STEAM_USER_ID=76561199557313614"
set "CONFIG_BACKUP_PATH=%LOCALAPPDATA%\SaberBackup\Space Marine 2\storage\steam\user\%STEAM_USER_ID%\Main\config"
set "ORIGINAL_CONFIG_PATH=%LOCALAPPDATA%\Saber\Space Marine 2\storage\steam\user\%STEAM_USER_ID%\Main\config"

echo.
echo ========================================
echo   Space Marine 2 Mod Switcher v1.0
echo ========================================
echo.

:: Check if game directory exists
if not exist "%GAME_PATH%" (
    echo Error: Game directory not found at: %GAME_PATH%
    echo Please update the STEAM_LIBRARY_PATH variable in this script.
    pause
    exit /b 1
)

:: Check if mods directory exists
if not exist "%MODS_PATH%" (
    echo Error: Mods directory not found at: %MODS_PATH%
    echo Please verify your game installation.
    pause
    exit /b 1
)

:: Create unused_mods directory if it doesn't exist
if not exist "%UNUSED_MODS_PATH%" (
    echo Creating unused_mods directory...
    mkdir "%UNUSED_MODS_PATH%" 2>nul
    if errorlevel 1 (
        echo Error: Could not create unused_mods directory
        pause
        exit /b 1
    )
)

:: Create config backup directory if it doesn't exist
if not exist "%CONFIG_BACKUP_PATH%" (
    echo Creating config backup directory...
    mkdir "%CONFIG_BACKUP_PATH%" 2>nul
    if errorlevel 1 (
        echo Error: Could not create config backup directory
        pause
        exit /b 1
    )
)

:: Check current state
set "MODS_ACTIVE=0"
for %%f in ("%MODS_PATH%\*.pak") do set "MODS_ACTIVE=1"

echo Current state:
if !MODS_ACTIVE!==1 (
    echo   Mods are currently ACTIVE
    echo   Will switch to: DISABLE mods (backup config, move mods to unused_mods)
) else (
    echo   Mods are currently INACTIVE
    echo   Will switch to: ENABLE mods (restore config, copy mods)
)
echo.

:: Auto-toggle based on current state
if !MODS_ACTIVE!==1 (
    goto :disable_mods
) else (
    goto :enable_mods
)

:enable_mods
echo.
echo Enabling mods and restoring config...

:: First, restore config files if backup exists
if exist "%CONFIG_BACKUP_PATH%" (
    echo Restoring config files...
    if not exist "%ORIGINAL_CONFIG_PATH%" (
        echo Original config directory doesn't exist. Creating it...
        mkdir "%ORIGINAL_CONFIG_PATH%" 2>nul
        if errorlevel 1 (
            echo Error: Could not create original config directory
            pause
            goto :end
        )
    )
    
    xcopy "%CONFIG_BACKUP_PATH%\*" "%ORIGINAL_CONFIG_PATH%\" /E /I /Y >nul 2>&1
    if errorlevel 1 (
        echo Error: Could not restore config files
    ) else (
        echo   Config files restored successfully!
    )
) else (
    echo No config backup found. Skipping config restore.
)

:: Check if there are any pak files in unused_mods
set "files_found=0"
for %%f in ("%UNUSED_MODS_PATH%\*.pak") do set "files_found=1"

if %files_found%==0 (
    echo Error: No pak files found in unused_mods folder.
    echo Cannot enable mods - no mod files available to copy.
    echo Please ensure mod pak files are placed in the unused_mods folder first.
    pause
    exit /b 1
)

:: Copy pak files from unused_mods to mods (keeping originals as backup)
echo Copying pak files from unused_mods to mods folder...
for %%f in ("%UNUSED_MODS_PATH%\*.pak") do (
    echo   Copying: %%~nxf
    copy "%%f" "%MODS_PATH%\" >nul 2>&1
    if errorlevel 1 (
        echo Error copying %%~nxf
    ) else (
        echo   Successfully copied %%~nxf
    )
)

echo.
echo Mods have been enabled and config restored! (Originals kept in unused_mods as backup)
pause
goto :end

:disable_mods
echo.
echo Disabling mods and backing up config...

:: First, backup config files if they exist
if exist "%ORIGINAL_CONFIG_PATH%" (
    echo Backing up config files...
    xcopy "%ORIGINAL_CONFIG_PATH%\*" "%CONFIG_BACKUP_PATH%\" /E /I /Y >nul 2>&1
    if errorlevel 1 (
        echo Error: Could not backup config files
    ) else (
        echo   Config files backed up successfully!
    )
) else (
    echo No original config found. Skipping config backup.
)

:: Check if there are any pak files in mods
set "files_found=0"
for %%f in ("%MODS_PATH%\*.pak") do set "files_found=1"

if %files_found%==0 (
    echo No pak files found in mods folder.
    echo Mods are already inactive.
    pause
    goto :end
)

:: Move pak files from mods to unused_mods (keeping as backup)
echo Moving pak files from mods to unused_mods folder...
for %%f in ("%MODS_PATH%\*.pak") do (
    echo   Moving: %%~nxf
    move "%%f" "%UNUSED_MODS_PATH%\" >nul 2>&1
    if errorlevel 1 (
        echo Error moving %%~nxf
    ) else (
        echo   Successfully moved %%~nxf
    )
)

echo.
echo Mods have been disabled and config backed up! (Files moved to unused_mods as backup)
pause
goto :end


:end
echo.
echo Thank you for using Space Marine 2 Mod Switcher.
echo.
