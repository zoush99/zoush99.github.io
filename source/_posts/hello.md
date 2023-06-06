---
title: hello
date: 2023-06-06 19:14:08
tags: hello
---

## 安装llvm-flang

记录基于链接https://github.com/llvm/llvm-project/tree/release/14.x/flang，也就是说基于14版本。

> 一些常见需要的地址

文档目录地址：https://github.com/llvm/llvm-project/blob/release/14.x/flang/docs

编译的命令：

https://github.com/llvm/llvm-project/blob/release/14.x/flang/docs/Overview.md

### 两种方法编译flang

1. 在编译它所依赖的项目的时同时编译。被称为building in tree。

2. 首先编译它的所需要的所有的项目，然后仅仅编译flang的代码。单独编译的好处是既小又快。一旦创建了基础编译环境，可以创造很多单独的编译块。

编译的说明在：https://llvm.org/docs/GettingStarted.html

其中安装的llvm的时候，一些软件依赖需要被满足。

我们应该先满足这些条件后，才继续下一步，如果版本的问题不满足我记得会有很多麻烦的问题。

### 第一种方法

贴下需要使用的指令。

```
git clone https://github.com/llvm/llvm-project.git my-project
```

> 需要注意的是，我需要下载的是llvm14版本，所以直接下载对应版本就可以，那么输入的命令是：

```
git clone -b llvmorg-14.0.6 --depth=1 https://github.com/llvm/llvm-project.git my-project
```

一旦下载完成，接下来的指令是：

```
sudo apt install build-essential
sudo apt install gcc-multilib
cd my-project

rm -rf build
mkdir -p build

cd build

cmake -DZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so -G Ninja ../llvm -DCMAKE_BUILD_TYPE=Release -DFLANG_ENABLE_WERROR=On -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_TARGETS_TO_BUILD=host -DCMAKE_INSTALL_PREFIX=$INSTALLDIR -DLLVM_LIT_ARGS=-v -DLLVM_ENABLE_PROJECTS="clang;mlir;flang" -DLLVM_ENABLE_RUNTIMES="compiler-rt" -DCOMPILER_RT_DEFAULT_TARGET_ARCH="x86_64" -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON -DCMAKE_INSTALL_PREFIX="/usr/local/llvm"

ninja
```

为了测试flang是否安装成功，在build目录下执行以下命令：

```
ninja check-flang
```

已经证明这样安装成功了！但是问题是版本太新，没什么功能，而且与clam不适配，所以我现在需要去安装老版本的flang，也就是classic flang。

### 第二种方法

第二种安装方式，这里贴需要的指令。但是第二种方法仍然依赖于第一种方法，即第一种方法安装的flang。

```
git clone https://github.com/llvm/llvm-project.git standalone
```

完成下载后，执行如下命令：

```
cd standalone
base=<directory that contains the in tree build>

cd flang
rm -rf build
mkdir build
cd build

cmake \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DFLANG_ENABLE_WERROR=On \
  -DLLVM_TARGETS_TO_BUILD=host \
  -DLLVM_ENABLE_ASSERTIONS=On \
  -DLLVM_BUILD_MAIN_SRC_DIR=$base/build/lib/cmake/llvm \
  -DLLVM_LIT_ARGS=-v \
  -DLLVM_DIR=$base/build/lib/cmake/llvm \
  -DCLANG_DIR=$base/build/lib/cmake/clang \
  -DMLIR_DIR=$base/build/lib/cmake/mlir \
  ..

ninja
```

如果需要检查flang是否正确执行，在flang/build目录下执行：

```
ninja check-flang
```

## 安装classical flang

安装这个相对容易，只要按照顺序执行脚本就可以了，最后再将flang加入环境变量就可以在任何位置执行。

<u>但是现在遇到一个问题，是我将原来的安装脚本的位置install改为了flang-install后，便在中间的某一步出错了。在链接上有相关回答，先尝试一下！如果没有问题就按照这样去做，否则按照原来的脚本去直接做。[解决错误链接](https://github.com/flang-compiler/flang/issues/1338)</u>。

**经过排查发现不是文件夹名的问题，是因为分支过于古老，导致的不兼容。现在尝试将较为活跃的版本clone下来，然后再安装到本机上。通过比较才发现不只是llvm可以尝试用新版本14，flang也可以用最新版本[活跃版本](https://github.com/flang-compiler/flang/tree/shivaram_1336)。**

> setup.sh

```sh
INSTALL_PREFIX=`pwd`/install		#原来的脚本是INSTALL_PREFIX=`pwd`/install
# Targets to build should be one of: X86 PowerPC AArch64
CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DLLVM_CONFIG=$INSTALL_PREFIX/bin/llvm-config -DCMAKE_CXX_COMPILER=$INSTALL_PREFIX/bin/clang++ -DCMAKE_C_COMPILER=$INSTALL_PREFIX/bin/clang -DCMAKE_Fortran_COMPILER=$INSTALL_PREFIX/bin/flang -DCMAKE_Fortran_COMPILER_ID=Flang -DLLVM_TARGETS_TO_BUILD=X86" 
```

> build-llvm-project.sh

```sh
. setup.sh

if [[ ! -d classic-flang-llvm-project ]]; then
    git clone -b release_100x https://github.com/flang-compiler/classic-flang-llvm-project.git
fi

cd classic-flang-llvm-project
mkdir -p build && cd build
cmake $CMAKE_OPTIONS -DCMAKE_C_COMPILER=/usr/bin/gcc -DCMAKE_CXX_COMPILER=/usr/bin/g++ -DLLVM_ENABLE_CLASSIC_FLANG=ON -DLLVM_ENABLE_PROJECTS="clang;openmp" ../llvm
make -j4
sudo make install
```

切换不同版本更改的规则是改变分支，上面的脚本用的分支是release_100，如果改变可以是release_14x。下面build-flang可以选择clone -b legacy分支。为了防止以后版本更新或者其他原因，我个人认为，需要把源代码下载到本地或者pull到自己的github仓库中，防止之后没法使用。

这里原来的readme中是release_100，但是这个是两年前的版本，所以需要更改到最新的版本（原来的版本会有不兼容等特点）。我尝试了一种新版本release_15x加master是没有问题的，但是因为需要和clam兼容，那么需要llvm14版本。<u>再用release_14x尝试一下。用release_14x发现也没问题，不过flang的版本需要用legacy。我们在实验环境需要的就是这种版本，所以安装成功。</u>

> build-flang.sh

```sh
. setup.sh

if [[ ! -d flang ]]; then
    git clone https://github.com/flang-compiler/flang.git
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
```

## 安装clam: LLVM front-end for Crab

这个分支支持llvm14。Clam是一个基于抽象解释静态分析器，它可以基于Crab库为llvm字节码计算归纳不变式。因为之前预计的不能满足我的要求，所以将所有llvm版本设置到14的话，应该可以满足说明。

在虚拟机上，可以通过一下命令安装环境依赖：

```sh
 sudo apt-get install libboost-all-dev libboost-program-options-dev
 sudo apt-get install libgmp-dev
 sudo apt-get install libmpfr-dev	
 sudo apt-get install libflint-dev
```

解释架构依赖于很多Python包，可以通过安装一下包来实现目标。

```sh
 pip3 install lit
 pip3 install OutputCheck
```

基础的编译步是（需要将github上的文件下载到本地），然后进入到文件夹中。**注意此步骤和下面编译步骤只用执行一个步骤就好了，而不是所有的都执行**

```sh
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$DIR ../
cmake --build . --target crab && cmake ..   
cmake --build . --target extra && cmake ..                  
cmake --build . --target install 
```

在第二行的命令将会在标准路径中找llvm14，如果没有把llvm14安装在标准路径，需要在第二行加上选项：-DLLVM_DIR=$LLVM-14_INSTALL_DIR/lib/cmake/llvm。第三行将要下载Crab并且编译。第四行Clam使用两个扩展部分并且安装扩展的目标。如下图所示：

![](C:/Users/Admin/Nutstore/1/研究生/项目开发/flang and seahorn/安装/扩展部分.png)

里面也集成了一些抽象域：Boxes,Apron,Elina,PPlite。

使用Boxes：-DCRAB_USE_LDD=ON

使用Apron：-DCRAB_USE_APRON=ON

使用Elina：-DCRAB_USE_ELINA=ON

使用PPlite：-DCRAB_USE_APRON=ON -DCRAB_USE_PPLITE=ON

Apron和Elina是不兼容的，所以不能同时使用它们。

安装Clam（包含Boxes和Apron）：

```sh
1. mkdir build && cd build
2. cmake -DCMAKE_INSTALL_PREFIX=$DIR -DCRAB_USE_LDD=ON -DCRAB_USE_APRON=ON ../
3. cmake --build . --target crab && cmake ..
4. cmake --build . --target extra && cmake ..                
5. cmake --build . --target ldd && cmake ..
6. cmake --build . --target apron && cmake ..             
7. cmake --build . --target install 
```


检查是否安装成功：

```sh
 cmake --build . --target test-simple
```

## 安装成功

在这里安装成功，安装使用的是llvm14.0.1版本加上flang legacy分支，clam使用的是dev14版本。在编译的过程中为了将llvm-lit加入到环境变量，而导致后面的步骤可能出错，即用flang生成可执行文件。那么只需要将llvm-lit的环境变量注释掉即可。中间需要将clang所在的那个文件夹bin的路径加入到环境变量中。

## flang的命令

flang中除了原来的clang中支持的所有命令还有自己特殊的命令，作为fortran语言的前端部分。

```sh
% flang -help

-noFlangLibs          Do not link against Flang libraries
-mp                   Enable OpenMP and link with with OpenMP library libomp
-nomp                 Do not link with OpenMP library libomp
-Mbackslash           Treat backslash in quoted strings like any other character
-Mnobackslash         Treat backslash in quoted strings like a C-style escape character (Default)
-Mbyteswapio          Swap byte-order for unformatted input/output
-Mfixed               Assume fixed-format source
-Mextend              Allow source lines up to 132 characters
-Mfreeform            Assume free-format source
-Mpreprocess          Run preprocessor for Fortran files
-Mrecursive           Generate code to allow recursive subprograms
-Mstandard            Check standard conformance
-Msave                Assume all variables have SAVE attribute
-module               path to module file (-I also works)
-Mallocatable=95      Select Fortran 95 semantics for assignments to allocatable objects
-Mallocatable=03      Select Fortran 03 semantics for assignments to allocatable objects (Default)
-static-flang-libs    Link using static Flang libraries
-M[no]daz             Treat denormalized numbers as zero
-M[no]flushz          Set SSE to flush-to-zero mode
-Mcache_align         Align large objects on cache-line boundaries
-M[no]fprelaxed       This option is ignored
-fdefault-integer-8   Treat INTEGER and LOGICAL as INTEGER*8 and LOGICAL*8
-fdefault-real-8      Treat REAL as REAL*8
-i8                   Treat INTEGER and LOGICAL as INTEGER*8 and LOGICAL*8
-r8                   Treat REAL as REAL*8
-fno-fortran-main     Don't link in Fortran main
```
