#!/bin/bash

# Script chạy Flutter app trên macOS/Linux

echo ""
echo "========================================"
echo "  Quản lý Garage - Flutter App"
echo "========================================"
echo ""

# Kiểm tra Flutter
echo "Kiểm tra Flutter SDK..."
flutter --version
if [ $? -ne 0 ]; then
    echo "LỖI: Flutter không được cài đặt!"
    exit 1
fi

echo ""
echo "Kiểm tra device..."
flutter devices
echo ""

# Cài dependencies
echo "Cài dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "LỖI: Không thể cài dependencies!"
    exit 1
fi

echo ""
echo "Kiểm tra lỗi (flutter analyze)..."
flutter analyze
echo ""

# Chạy ứng dụng
echo "Chạy ứng dụng..."
echo ""
flutter run
