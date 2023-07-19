---
title: Classic-Flang说明
date: 2023-07-14 10:38:24
tags: 
- project
- Flang
categories:
- learn
typora-root-url: ./../
---

## Flang的使用情况

<!--more-->

之前搞了那么久，现在终于得开始了解这个工具了。先慢慢使用，看看它的能力以及学习一下转换而来的LLVM IR的语法。



## 安装Flang

![](/paper_source/Classic-Flang说明/安装Flang.jpg)

我安装的是github网站上的flang-compiler项目的legacy版本[flang-compiler/flang at legacy (github.com)](https://github.com/flang-compiler/flang/tree/legacy)。使用的安装脚本是根据网站上提供的安装脚本，并稍作修改：改进了下载版本等信息，总体而言没有做太大改进。为了保证开源包的安全性（可用性），fork到个人目录下：[zoush99/flang at legacy (github.com)](https://github.com/zoush99/flang/tree/legacy)。

为了让自己养成良好习惯，在这里记录一下安装的步骤。

安装LLVM需要一系列现代编译链：build-essensial和CMake的版本不低于3.3，并且应该到LLVM的网站满足所需要的依赖，才能进行安装步骤。推荐链接：[Getting started with LLVM](http://llvm.org/docs/GettingStarted.html#host-c-toolchain-both-compiler-and-standard-library)和[CMake llvm](http://llvm.org/docs/CMake.html)。

安装需要依赖后，直接安装其提供的LLVM14版本。其中的一些细节不做讨论。一些解释详见[Building Flang · flang-compiler/flang Wiki (github.com)](https://github.com/flang-compiler/flang/wiki/Building-Flang)

我们这里需要直接将安装脚本罗列下来，并且依次执行即可。

首先是安装的初始化脚本：将CMake的命令进行初始设置，一定要提前执行。

```sh
INSTALL_PREFIX=`pwd`/install

# Targets to build should be one of: X86 PowerPC AArch64
CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DLLVM_CONFIG=$INSTALL_PREFIX/bin/llvm-config \
    -DCMAKE_CXX_COMPILER=$INSTALL_PREFIX/bin/clang++ \
    -DCMAKE_C_COMPILER=$INSTALL_PREFIX/bin/clang \
    -DCMAKE_Fortran_COMPILER=$INSTALL_PREFIX/bin/flang 
    -DCMAKE_Fortran_COMPILER_ID=Flang \
    -DLLVM_TARGETS_TO_BUILD=X86"
```

然后是安装llvm14的脚本，直接执行即可。

```sh
. setup.sh

if [[ ! -d classic-flang-llvm-project ]]; then
    git clone -b release_14x https://github.com/zoush99/classic-flang-llvm-project.git
fi

cd classic-flang-llvm-project
mkdir -p build && cd build
cmake $CMAKE_OPTIONS -DCMAKE_C_COMPILER=/usr/bin/gcc -DCMAKE_CXX_COMPILER=/usr/bin/g++ -DLLVM_ENABLE_CLASSIC_FLANG=ON -DLLVM_ENABLE_PROJECTS="clang;openmp" -DCMAKE_BUILD_TYPE=Release ../llvm
make -j4
sudo make install
```

将classic-flang-llvm-project/build/bin目录加入到环境变量，或install/bin加入到环境变量。测试Clang命令是否正确执行，这时发现也会存在Flang的命令，但只是将Flang链接到Clang命令，之后安装Flang才会对Fortran程序起作用。

然后安装Flang的legacy版本，这个版本最近更新是在8个月前，因为要适配IKOS/Clam，所以需要llvm14版本。目前Flang已经更新到15或更高版本。

````sh
. setup.sh

if [[ ! -d flang ]]; then
    git clone -b legacy https://github.com/zoush99/flang.git
fi

(cd flang/runtime/libpgmath
 mkdir -p build && cd build
 cmake $CMAKE_OPTIONS ..
 make -j4
 sudo make install)

cd flang
mkdir -p build && cd build
cmake $CMAKE_OPTIONS -DFLANG_LLVM_EXTENSIONS=ON ..
make -j4
sudo make install
````

这样就把Flang安装成功，之后若使用IKOS还需要安装一个14版本的llvm，但二者相互不影响，因为他们针对不同的处理模块。等安装IKOS时需要将原有的（安装Flang所需）Clang从环境变量中移除（加注释），而安装新的llvm从而加入到环境变量中。之后需要编译IKOS时应该使用官方llvm。

之后所作更改时（Flang和IKOS各自）应该记住这点，因为所使用的llvm版本相同但内容不同，且不冲突。

## 使用Flang

使用指令：

` flang -help`

来查找它所接受的命令，Flang本身支持所有的Clang的指令，而且支持针对Fortran特定的指令。

```
```

