@echo off
REM LocalSend Clone Build Script for Windows
REM This script will help you build the LocalSend clone APK on Windows

echo ==========================================
echo   LocalSend Clone - Build Script
echo ==========================================
echo.

REM Check if Flutter is installed
echo [1/8] Checking Flutter installation...
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter is not installed!
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)
echo [OK] Flutter is installed
flutter --version
echo.

REM Check Flutter doctor
echo [2/8] Running Flutter doctor...
flutter doctor -v
echo.

REM Clean previous build
echo [3/8] Cleaning previous build...
flutter clean
echo [OK] Clean completed
echo.

REM Get dependencies
echo [4/8] Getting dependencies...
flutter pub get
echo [OK] Dependencies installed
echo.

REM Run code generation (if needed)
echo [5/8] Running code generation...
findstr /C:"build_runner" pubspec.yaml >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    flutter pub run build_runner build --delete-conflicting-outputs
    echo [OK] Code generation completed
) else (
    echo [SKIP] No code generation needed
)
echo.

REM Check for connected devices
echo [6/8] Checking for devices...
flutter devices
echo.

REM Ask user which build type
echo [7/8] Select build type:
echo 1) Debug APK (for testing)
echo 2) Release APK (optimized, smaller size)
echo 3) App Bundle (for Play Store)
echo 4) Run on connected device
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo Building debug APK...
    flutter build apk --debug
    set APK_PATH=build\app\outputs\flutter-apk\app-debug.apk
) else if "%choice%"=="2" (
    echo Building release APK...
    flutter build apk --release
    set APK_PATH=build\app\outputs\flutter-apk\app-release.apk
) else if "%choice%"=="3" (
    echo Building app bundle...
    flutter build appbundle --release
    set APK_PATH=build\app\outputs\bundle\release\app-release.aab
) else if "%choice%"=="4" (
    echo Running on device...
    flutter run
    exit /b 0
) else (
    echo [ERROR] Invalid choice!
    pause
    exit /b 1
)

echo.
echo [8/8] Build process...
echo.

REM Check if build succeeded
if exist "%APK_PATH%" (
    echo ==========================================
    echo   BUILD SUCCESSFUL!
    echo ==========================================
    echo.
    echo Output file: %APK_PATH%
    echo.
    echo Next steps:
    echo 1. Transfer the APK to your Android device
    echo 2. Install the APK (enable 'Install from Unknown Sources' if needed)
    echo 3. Open LocalSend and start sharing files!
    echo.
    
    REM Offer to open file location
    set /p open_folder="Open output folder? (y/n): "
    if /i "%open_folder%"=="y" (
        explorer build\app\outputs
    )
) else (
    echo ==========================================
    echo   BUILD FAILED!
    echo ==========================================
    echo.
    echo Please check the error messages above.
    echo Common issues:
    echo - Missing Android SDK
    echo - Gradle configuration errors
    echo - Dependency conflicts
    echo.
    pause
    exit /b 1
)

echo.
echo Thank you for using LocalSend Clone!
echo.
pause
