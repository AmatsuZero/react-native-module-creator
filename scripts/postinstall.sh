#!/usr/bin/env bash

# 安装template下的依赖
pushd template
npm i
popd

# 检出字模块
git submodule init
git submodule update

# 编译出命令行工具
pushd XcodeHelper
xcodebuild -scheme XcodeHelper archive
popd
