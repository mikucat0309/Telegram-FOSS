#!/usr/bin/env bash
set -ex

cd /src/TMessagesProj/jni
./build_libvpx_clang.sh
./build_ffmpeg_clang.sh
./patch_ffmpeg.sh
./patch_boringssl.sh
./build_boringssl.sh
cd /src
gradle :TMessagesProj_App:assembleAfatRelease
