#!/bin/sh
cd "$(dirname "$0")"

IMAGE=rawinby/notesnook-web
VERSION=${1:-latest}

# Build image สำหรับ platform เดียว (สถาปัตยกรรมเครื่องที่รัน)
docker build \
  --no-cache \
  --build-arg VERSION_NUMBER=$VERSION \
  -t $IMAGE:$VERSION \
  -f ./config/Dockerfile \
  .

# Push image ขึ้น Docker Hub หลัง build เสร็จ
docker push $IMAGE:$VERSION

# การใช้งาน:
# ./build.bat 1.0.2   # Build และ Push พร้อมระบุ version
# ./build.bat         # Build และ Push ด้วย version "latest"



