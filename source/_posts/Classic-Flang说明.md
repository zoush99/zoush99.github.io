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

安装完成后，我还需要将编译得到的一些动态或静态库复制到系统默认查询位置中`/usr/lib`或`/usr/local`。这样才算完全没问题。

## 使用Flang

使用命令：

` flang -help`

来查找它所接受的命令，Flang本身支持所有的Clang的命令，而且支持针对Fortran特定的命令。

```sh
OVERVIEW: clang LLVM compiler

USAGE: clang-14 [options] file...

OPTIONS:
  -###                    Print (but do not run) the commands to run for this compilation
  -cpp                    Enable predefined and command line preprocessor macros
  -c                      Only run preprocess, compile, and assemble steps
  -D <macro>=<value>      Define <macro> to <value> (or 1 if <value> omitted)
  -E                      Only run the preprocessor
  -falternative-parameter-statement
                          Enable the old style PARAMETER statement
  -fbackslash             Specify that backslash in string introduces an escape character
  -fcolor-diagnostics     Enable colors in diagnostics
  -fdefault-double-8      Set the default double precision kind to an 8 byte wide type
  -fdefault-integer-8     Set the default integer kind to an 8 byte wide type
  -fdefault-real-8        Set the default real kind to an 8 byte wide type
  -ffixed-form            Process source files in fixed form
  -ffixed-line-length-<value>
                          Set line length in fixed-form format Fortran, current supporting only 72 and 132 characters
  -ffree-form             Process source files in free form
  -finput-charset=<value> Specify the default character set for source files
  -fintrinsic-modules-path <dir>
                          Specify where to find the compiled intrinsic modules
  -flarge-sizes           Use INTEGER(KIND=8) for the result type in size-related intrinsics
  -fno-color-diagnostics  Disable colors in diagnostics
  -fno-fixed-form         Disable fixed-form format for Fortran
  -fno-free-form          Disable free-form format for Fortran
  -fopenacc               Enable OpenACC
  -fopenmp                Parse OpenMP pragmas and generate parallel code.
  -help                   Display available options
  -I <dir>                Add directory to the end of the list of include search paths
  -module-dir <dir>       Put MODULE files in <dir>
  -nocpp                  Disable predefined and command line preprocessor macros
  -o <file>               Write output to <file>
  -pedantic               Warn on language extensions
  -P                      Disable linemarker output in -E mode
  -std=<value>            Language standard to compile for
  -U <macro>              Undefine macro <macro>
  --version               Print version information
  -W<warning>             Enable the specified warning
  -Xflang <arg>           Pass <arg> to the flang compiler
```

因为我们要用的只是将Fortran转成IR，而且不涉及并行程序（OpenMP），所以只用传统的一些命令行转化即可。

下面列举出一些可以使用的组合命令，以及它们的功能。

```sh
flang -emit-llvm test.f90 -S -c -o test.ll
# 传统的clang命令生成llvm IR，且是可读版本.ll：汇编文件
flang -emit-llvm test.f90 -c -o test.bc
# 从源码转换成机器码.bc：位码文件
llvm-as test.ll -o test.bc
# 将.ll转换成.bc
llvm-dis test.bc -o test.ll
# 将.bc转换成.ll
lli test.bc
# 直接执行.bc文件
llvm-extract --func=foo test.bc -o test-func.bc	# 用test.ll也可以
# 从位码文件中抽取函数名为foo的函数，除了抽取函数，还可以抽取别名和全局变量
```

一般来说，只用生成汇编文件或位码文件即可，汇编文件用来人为阅读，位码文件直接输入到IKOS中进行分析。

列出Clang的一些命令如下：

```sh
# 1. .c -> .i
clang -E -c test.c -o test.i
# 2. .c -> .bc
clang -emit-llvm test.c -c -o test.bc
# 3. .c -> .ll
clang -emit-llvm test.c -S -o test.ll
# 4. .i -> .bc
clang -emit-llvm test.i -c -o test.bc
# 5. .i -> .ll
clang -emit-llvm test.i -S -o test.ll
# 6. .bc -> .ll
llvm-dis test.bc -o test.ll
# 7. .ll -> .bc
llvm-as test.ll -o test.bc
# 8. 多 bc 合并为一个 bc
llvm-link test1.bc test2.bc -o test.bc
```

![img](/paper_source/Classic-Flang说明/Center.jpg)

## Flang转换成.ll的结果

```sh
source_filename = "/path/to/source.c"
# 这里描述了源文件的名称和所在路径
target datalayout = "layout specification"
# 这里描述了目标机器中数据的内存布局方式，包括字节序、类型以及对齐方式
# 这个参数对理解LLVM关系不大
target triple = "ARCHITECTURE-VENDOR-OPERATIONG_SYSTEM"
target triple = "ARCHITECTURE-VENDOR-OPERATING_SYSTEM-ENVIRONMENT"
# 描述了目标机器是什么，从而指示后端生成相应的目标代码
Identifiers
# 标识符分为：全局标识符和局部标识符。全局标识符以@开头，如全局函数、全局变量。局部标识符以%开头，类似于汇编语言中的寄存器
# 标识符有3种形式：
## 有名称的值，表示带有前缀（@或%）的字符串。如：%Val, @name
## 无名称的值，表示带前缀（@或%）的无符号数值。如%0, %1, @2
## 常量
Functions
# define用于定义一个函数
define [linkage] [PreemptionSpecifier] [visibility] [DLLStorageClass]
       [cconv] [ret attrs]
       <ResultType> @<FunctionName> ([argument list])
       [(unnamed_addr|local_unnamed_addr)] [AddrSpace] [fn Attrs]
       [section "name"] [comdat [($name)]] [align N] [gc] [prefix Constant]
       [prologue Constant] [personality Constant] (!name !N)* { ... }
# 示例
define dso_local void @foo(i32 %x) #0 {
  ; 省略 ...
}
# define void @foo(i32 %x) { ... }，表示定义一个函数。其函数名称为foo，返回值的数据类型为void，参数（用%x表示）的数据类型为 i32（占用4字节的整型）
# #0，用于修饰函数时表示一组函数属性。这些属性定义在文件末尾
  7 define weak dso_local void @foo(i32 %x) #0 {
  8 entry:
  9   %x.addr = alloca i32, align 4
 10   %y = alloca i32, align 4
 11   %z = alloca i32, align 4
 12   store i32 %x, i32* %x.addr, align 4
 13   %0 = load i32, i32* %x.addr, align 4
 14   %cmp = icmp eq i32 %0, 0
 15   br i1 %cmp, label %if.then, label %if.end
 16 
 17 if.then:                                          ; preds = %entry
 18   store i32 5, i32* %y, align 4
 19   br label %if.end
 20 
 21 if.end:                                           ; preds = %if.then, %entry
 22   %1 = load i32, i32* %x.addr, align 4
 23   %tobool = icmp ne i32 %1, 0
 24   br i1 %tobool, label %if.end2, label %if.then1
 25 
 26 if.then1:                                         ; preds = %if.end
 27   store i32 6, i32* %z, align 4
 28   br label %if.end2
 29 
 30 if.end2:                                          ; preds = %if.then1, %if.end
 31   ret void
 32 }
# LLVM IR中，函数体是由基本块构成的。基本块是由一系列顺序执行的语句构成的，并（可选地）以标签作为起始。不同的标签代表不同的基本块
# 基本块的特点如下：
## 仅有一个入口，即基本块中的第一条指令
## 仅有一个出口，即基本块中的最后一条指令（被称为terminator instruction）。该指令要么跳转到其他基本块（不包括入口基本块），要买从函数返回
## 函数体中第一个出现的基本块，称为入口基本块（Entry Basic Block）。它是一个特殊的基本块，在进入函数时立即执行该基本块，并且不允许作为其他基本块的跳转目标（即不允许该基本块有前继结点）
```

