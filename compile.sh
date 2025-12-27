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

# Tạo thư mục build
mkdir -p build

# Cài đặt dependency nếu thiếu
$RUN_PY -c "import nuitka" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Installing Nuitka..."
    $RUN_PY -m pip install nuitka
fi

echo "Compiling application with Nuitka..."

# --- SỬA LỖI Ở ĐÂY ---
# Đã có --output-dir=build thì -o chỉ cần ghi tên file (LpkUnpacker)
# Nuitka sẽ tự động đặt nó vào build/LpkUnpacker
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
    ls -lh build/LpkUnpacker
else
    echo "Compilation failed or file not found in build/ directory."
    echo "Listing build directory contents:"
    ls -la build/
    exit 1
fi
