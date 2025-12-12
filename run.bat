@echo off
REM Script chạy Flutter app trên emulator/device

echo.
echo ========================================
echo  Quan ly Garage - Flutter App
echo ========================================
echo.

REM Kiểm tra Flutter
echo Kiem tra Flutter SDK...
flutter --version
if %errorlevel% neq 0 (
    echo LỖI: Flutter không được cài đặt!
    pause
    exit /b 1
)

echo.
echo Kiem tra device...
flutter devices
echo.

REM Cài dependencies
echo Cai dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo LỖI: Không thể cài dependencies!
    pause
    exit /b 1
)

echo.
echo Kiem tra loi (flutter analyze)...
flutter analyze
echo.

REM Chạy ứng dụng
echo Chay ung dung...
echo.
flutter run

pause
