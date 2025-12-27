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

# Tạo thư mục build trước để tránh lỗi đường dẫn
mkdir -p build

# Cài đặt dependency nếu thiếu
$RUN_PY -c "import nuitka" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Installing Nuitka..."
    $RUN_PY -m pip install nuitka
fi

echo "Compiling application with Nuitka..."

# Lệnh biên dịch chính
# -o build/LpkUnpacker: Bắt buộc xuất file ra thư mục build với tên LpkUnpacker
$RUN_PY -m nuitka --onefile \
    --output-dir=build \
    -o build/LpkUnpacker \
    --jobs=$(nproc) \
    --lto=no \
    --show-progress \
    --nofollow-import-to=matplotlib,scipy,pandas,tkinter \
    --python-flag=no_site \
    --python-flag=no_docstrings \
    --assume-yes-for-downloads \
    --remove-output \
    LpkUnpacker.py

# Kiểm tra kết quả thực tế
if [ -f "build/LpkUnpacker" ]; then
    echo "Compilation completed successfully!"
    echo "Executable is located at: build/LpkUnpacker"
    ls -lh build/LpkUnpacker
else
    echo "Compilation failed or file not found in build/ directory."
    # List file ra để debug xem nó nằm ở đâu
    echo "Listing current directory:"
    ls -la
    echo "Listing build directory:"
    ls -la build/
    exit 1
fi
