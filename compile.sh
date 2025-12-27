#!/bin/bash

echo "===== LpkUnpacker CLI Compiler (Linux) ====="
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

# Kiểm tra Nuitka
$RUN_PY -c "import nuitka" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Nuitka not found. Please install: pip install nuitka"
    exit 1
fi

# Đảm bảo các thư viện runtime cần thiết đã được cài đặt
$RUN_PY -c "import websockets, requests" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Missing packages detected. Installing: websockets, requests"
    $RUN_PY -m pip install websockets requests
fi

echo "Compiling application with Nuitka..."

# Lệnh biên dịch chính
# - Target: LpkUnpacker.py (CLI)
# - Loại bỏ plugin pyqt5
# - Loại bỏ các flag windows
$RUN_PY -m nuitka --onefile \
    --output-dir=build \
    --jobs=$(nproc) \
    --lto=no \
    --show-progress \
    --nofollow-import-to=matplotlib,scipy,pandas,tkinter \
    --python-flag=no_site \
    --python-flag=no_docstrings \
    --assume-yes-for-downloads \
    --remove-output \
    LpkUnpacker.py

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

echo ""
echo "Compilation completed successfully!"
echo "Executable can be found in the 'build' directory: build/LpkUnpacker"
