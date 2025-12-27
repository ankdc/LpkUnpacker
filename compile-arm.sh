#!/bin/bash

echo "===== LpkUnpacker CLI Compiler (Linux aarch64) ====="
echo "Starting compilation process..."

# Xác định lệnh python
if command -v python3 &> /dev/null; then
    RUN_PY="python3"
elif command -v python &> /dev/null; then
    RUN_PY="python"
else
    echo "Error: Python not found."
    exit 1
fi

echo "Using Python: $RUN_PY"
$RUN_PY --version

# Tạo thư mục build
mkdir -p build

echo "--- Installing Dependencies ---"
# Cài đặt pip packages cần thiết
# Vì chạy trong container aarch64 sạch, ta cần cài dependencies tại đây
if [ -f "requirements.txt" ]; then
    echo "Installing requirements from requirements.txt..."
    $RUN_PY -m pip install -r requirements.txt
else
    echo "Warning: requirements.txt not found."
fi

# Cài đặt Nuitka và các gói hỗ trợ build
echo "Installing Nuitka and build tools..."
$RUN_PY -m pip install nuitka zstandard ordered-set

echo "--- Compiling with Nuitka ---"

# Lệnh biên dịch
$RUN_PY -m nuitka --onefile \
    --output-dir=build \
    -o LpkUnpacker \
    --jobs=$(nproc) \
    --lto=no \
    --show-progress \
    --nofollow-import-to=matplotlib,scipy,pandas,tkinter \
    --python-flag=no_site \
    --python-flag=no_docstrings \
    --assume-yes-for-downloads \
    --remove-output \
    LpkUnpacker.py

# Kiểm tra kết quả
if [ -f "build/LpkUnpacker" ]; then
    echo "Compilation completed successfully!"
    echo "Executable is located at: build/LpkUnpacker"
    
    # Kiểm tra kiến trúc file để chắc chắn nó là aarch64
    echo "File Architecture Info:"
    file build/LpkUnpacker
else
    echo "Compilation failed or file not found in build/ directory."
    echo "Listing build directory contents:"
    ls -la build/
    exit 1
fi
