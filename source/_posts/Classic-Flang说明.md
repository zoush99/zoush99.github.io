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

## LLVM IR生成文件过程

```sh
.c --frontend--> AST --frontend--> LLVM IR --LLVM opt--> LLVM IR --LLVM llc--> .s Assembly --OS Assembler--> .o --OS Linker--> executable
```

## LLVM IR语法的基本概念

### 注释

以`;`开头并一直延申到行尾，作为注释行。

### 主程序

主程序是可执行程序执行的入口点，所以任何可执行程序都需要`main`函数才能运行。

```llvm
define i32 @main() {
    ret i32 0
}
```

就是主程序，在`@main()`之后的就是函数的函数体，`ret i32 0`就代表C语言中的`return 0;`。因此，如果要增加代码，就只需要在大括号内，`ret i32 0`前增加代码即可。

### 目标数据布局

LLVM也支持我们手动定制这样的数据布局，例如，我们可以在LLVM IR的源代码中写：

```llvm
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
```

这一长串文字就定义了目标的数据布局。具体而言：

* `e`: 小端序
* `m:e`: 符号表中使用ELF格式的命名修饰
* `p270:32:32-p271:32:32-p272:64:64`: 与地址空间有关
* `i64:64`: 将`i64`类型的变量采用64位的ABI对齐
* `f80:128`: 将`long double`类型的变量采用128位的ABI对齐
* `n8:16:32:64`: 目标CPU的原生整型包含8位、16位、32位和64位
* `S128`: 栈以128位自然对齐

### C的例子

关于符号和符号表，这些还是挺抽象的，我们不如用一个具体的C语言的例子来看看效果：

```c
int a;
extern int b;
static int c;
void d(void);
void e(void) {}
static void f(void) {}
```

首先我们先理解一下这个C语言代码各个符号的含义：

* `a`

   定义在**当前文件中的全局变量**，别的文件也可以使用这个符号
* `b`

   定义在**别的文件中的全局变量**，当前文件需要使用这个符号
* `c`

   定义在**当前文件中的全局变量，别的文件不可以使用这个符号**
* `d`

   定义在**别的文件中的函数，当前文件需要使用这个符号**
* `e`

   定义在**当前文件中的函数，别的文件也可以使用这个符号**
* `f`

   定义在**当前文件中的函数，别的文件不可以使用这个符号**

以上六种，是我们在C语言编程中最常见的符号形式。

我们使用Clang将其编译为LLVM IR，是什么样子的呢？

```llvm
@a = dso_local global i32 0, align 4
@b = external global i32, align 4
@c = internal global i32 0, align 4

declare void @d()

define dso_local void @e() {
  ret void
}

define internal void @f() {
  ret void
}
```

我们可以发现几件事（在默认的编译选项下）：

* C语言中的`static`，也就是当前文件中定义，别的文件不可以用的，都会加上`internal`修饰符
* C语言中的`extern`，也就是别的文件中定义的，全局变量会加上`external`修饰符，函数会使用`declare`
* C语言中定义的，可以给别的文件使用的全局变量或函数，不会加上链接类型修饰符，并且会加上`dso_local`保证不会被抢占

## 寄存器和栈

这两种数据我选择放在一起讲。我们知道，大多数对数据的操作，如加减乘除、比大小等，都需要操作的是**寄存器**内的数据。那么，我们为什么需要把数据放在**栈**上呢？主要有两个原因：

* 寄存器数量不够
* 需要操作内存地址

如果我们一个函数内有三四十个局部变量，但是家用型CPU最多也就十几个通用寄存器，所以我们不可能把所有变量都放在寄存器中。因此我们需要把一部分数据放在内存中，栈就是一个很好的存储数据的地方；此外，有时候我们需要直接操作内存地址，但是寄存器并没有通用的地址表示，所以只能把数据放在栈上来完成对地址的操作。

因此，**在不操作内存地址的前提下，栈只是寄存器的一个替代品。**如果寄存器的数量足够，并且代码中没有需要操作内存地址的时候，寄存器是足够胜任的，并且更加高效的。

## 寄存器

正因为如此，LLVM IR引入了虚拟寄存器的概念。在LLVM IR中，一个函数的局部变量可以是寄存器或者栈上的变量。对于寄存器而言，我们只需要像普通的赋值语句一样操作，但需要注意名字必须以`%`开头：

```llvm
%local_variable = add i32 1, 2
```

此时，`%local_variable`这个变量就代表一个寄存器，它此时的值就是`1`和`2`相加的结果。我们可以写一个简单的程序验证这一点：

```llvm
; register_test.ll
define i32 @main() {
    %local_variable = add i32 1, 2
    ret i32 %local_variable
}
```

我们查看其编译出的汇编代码，其主函数为：

```x86asm
main:
    movl    $2, %eax
    addl    $1, %eax
    retq
```

确实这个局部变量`%local_variable`变成了寄存器`eax`。

关于寄存器，我们还需了解一点。在不同的ABI下，会有一些callee-saved register和caller-saved register。简单来说，就是在函数内部，某些寄存器的值不能改变。或者说，在函数返回时，某些寄存器的值要和进入函数前相同。比如，在System V的ABI下，`rbp`, `rbx`, `r12`, `r13`, `r14`, `r15`都需要满足这一条件。由于LLVM IR是面向多平台的，所以我们需要一份代码适用于多种ABI。因此，**LLVM IR内部自动帮我们做了这些事。如果我们把所有没有被保留的寄存器都用光了，那么LLVM IR会帮我们把这些被保留的寄存器放在栈上，然后继续使用这些被保留寄存器。当函数退出时，会帮我们自动从栈上获取到相应的值放回寄存器内。**

那么，如果所有通用寄存器都用光了，该怎么办？LLVM IR会帮我们把剩余的值放在栈上，但是对我们用户而言，*实际上都是虚拟寄存器，用户是感觉不到差别的。*

因此，我们可以粗略地理解LLVM IR对寄存器的使用：

* 当所需寄存器数量较少时，直接使用callee-saved register，即不需要保留的寄存器
* 当callee-saved register不够时，将caller-saved register原本的值压栈，然后使用caller-saved register
* 当寄存器用光以后，就把多的虚拟寄存器的值压栈

## 栈

我们之前说过，当不需要操作地址并且寄存器数量足够时，我们可以直接使用寄存器。而LLVM IR的策略保证了我们可以**使用无数的虚拟寄存器**。那么，*在需要操作地址以及需要可变变量时，我们就需要使用栈。*

LLVM IR对栈的使用十分简单，直接使用`alloca`指令即可。如：

```llvm
%local_variable = alloca i32
```

就可以声明一个在栈上的变量了。关于栈上变量的操作，我会在之后提到，目前我们对栈上变量的了解只需这么多。

###数据的使用

在之前的两篇文章中，我们解释了LLVM中是如何对应数据区、寄存器和栈上的数据的。那么，这些数据定义了以后，该如何使用呢？

### 全局变量和栈上变量皆指针

下面，我们就需要讲怎样使用*全局变量和栈上的变量*。这两种变量实际上是类似的，LLVM IR把它们都看作指针。也就是说，对于全局变量：

```llvm
@global_variable = global i32 0
```

和栈上变量

```llvm
%local_variable = alloca i32
```

这两个变量实际上都是`ptr`指针，指向它们所处的一个`i32`大小的内存区域。所以，我们不能这样：

```llvm
%1 = add i32 1, @global_variable ; Wrong!
```

因为`@global_variable`只是一个指针。

如果要操作这些值，必须使用`load`和`store`这两个命令。如果我们要获取`@global_variable`的值，就需要

```llvm
%1 = load i32, ptr @global_variable
```

这个指令的意思是，把一个`ptr`指针`@global_variable`的`i32`类型的值赋给虚拟寄存器`%1`，然后我们就能愉快地

```llvm
%2 = add i32 1, %1
```

这样了。

类似地，如果我们要将值存储到全局变量或栈上变量里，会需要`store`命令：

```llvm
store i32 1, ptr @global_variable
```

这个代表将`i32`类型的值`1`赋给`ptr`类型的全局变量`@global_variable`所指的内存区域中。

### SSA

LLVM IR是一个严格遵守SSA(Static Single Assignment)策略的语言。SSA的要求很简单：每个变量只被赋值一次。也就是说，你不能

```llvm
%1 = add i32 1, 2
%1 = add i32 3, 4
```

对`%1`同时赋值两次是不被允许的。

SSA作为一个历史悠久的概念，已经有了相当成熟的相关技术。通过使用SSA，编译器可以进行更好的优化，应用更成熟的算法，得到更好的结果。这里因为个人能力有限，就不再多对SSA进行介绍。我们只需要知道，通过约束每个变量只被赋值一次，可以让LLVM更好地优化。

上面这个例子好做，直接把3加4的结果赋值给一个新的虚拟寄存器就好了。但是，并非所有的情况都这么简单。在一些复杂情况下，将值存储在栈上再取出来，或者使用`phi`指令，也是一个更好的选择。

## 类型系统

我们知道，汇编语言是弱类型的，我们操作汇编语言的时候，实际上考虑的是一些二进制序列。但是，LLVM IR却是强类型的，在LLVM IR中所有变量都必须有类型。这是因为，我们在使用高级语言编程的时候，往往都会使用强类型的语言，弱类型的语言无必要性，也不利于维护。因此，使用强类型语言，LLVM IR可以更好地进行优化。

### 基本的数据类型

LLVM IR中比较基本的数据类型包括：

* 空类型（`void`）
* 整型（`iN`）
* 浮点型（`float`、`double`等）

空类型一般是作为不返回值的函数的返回类型，没有特别的含义，就代表「什么都没有」。

整型是指`i1`, `i8`, `i16`, `i32`, `i64`这类的数据类型。这里`iN`的`N`可以是任意正整数，可以是`i3`，`i1942652`。但最常用，最符合常理的就是`i1`以及8的整数倍。`i1`有两个值：`true`和`false`。也就是说，下面的代码可以正确编译：

```llvm
%boolean_variable = alloca i1
store i1 true, ptr %boolean_variable
```

对于大于1位的整型，也就是如`i8`, `i16`等类型，我们可以直接用数字字面量赋值：

```llvm
%integer_variable = alloca i32
store i32 128, ptr %integer_variable
store i32 -128, ptr %integer_variable
```

### 符号

有一点需要注意的是，在LLVM IR中，整型默认是有符号整型，也就是说我们可以直接将`-128`以补码形式赋值给`i32`类型的变量。在LLVM IR中，整型的有无符号是**体现在操作指令而非类型上**的，比方说，对于两个整型变量的除法，LLVM IR分别提供了`udiv`和`sdiv`指令分别适用于无符号整型除法和有符号整型除法：

```llvm
%1 = udiv i8 -6, 2    ; Get (256 - 6) / 2 = 125
%2 = sdiv i8 -6, 2    ; Get (-6) / 2 = -3
```

我们可以用这样一个简单的程序验证：

```llvm
; div_test.ll
define i8 @main() {
    %1 = udiv i8 -6, 2
    %2 = sdiv i8 -6, 2
    
    ret i8 %1
}
```

分别将`ret`语句的参数换成`%1`和`%2`以后，将代码编译成可执行文件，在终端下运行并查看返回值即可。

总结一下就是，LLVM IR中的*整型默认按有符号补码存储*，但一个变量究竟是否要被看作有无符号数需要看其参与的指令。

### 转换指令

与整型密切相关的就是转换指令，比如说，将`i8`类型的数`-127`转换成`i32`类型的数，将`i32`类型的数`257`转换成`i8`类型的数等。总的来说，LLVM IR中提供三种指令：`trunc` .. `to`指令，`zext` .. `to`指令和`sext` .. `to`指令。

将长的整型转换成短的整型很简单，直接把多余的高位去掉就行，LLVM IR提供的是`trunc` .. `to`指令：

```llvm
%trunc_integer = trunc i32 257 to i8 ; Trunc 32 bit 100000001 to 8 bit, get 1
```

将短的整型变成长的整型则相对比较复杂。这是因为，在补码中最高位是符号位，并不表示实际的数值。因此，如果单纯地在更高位补`0`，那么`i8`类型的`-1`（补码为`11111111`）就会变成`i32`的`255`。这虽然符合道理，但有时候我们需要`i8`类型的`-1`扩展到`i32`时仍然是`-1`。LLVM IR为我们提供了两种指令：零扩展的`zext` .. `to`指令和符号扩展的`sext` .. `to`指令。

零扩展就是最简单的，直接在高位补`0`，而符号扩展则是用原数的符号位来填充。也就是说我们如下的代码：

```llvm
%zext_integer = zext i8 -1 to i32 ; Extend 8 bit 0xFF to 32 bit 0x000000FF, get 255
%sext_integer = sext i8 -1 to i32 ; Extend 8 bit 0xFF to 32 bit 0xFFFFFFFF, get -1
```

类似地，浮点型的数和整型的数也可以相互转换，使用`fptoui` .. `to`, `fptosi` .. `to`, `uitofp` .. `to`, `sitofp` .. `to`可以分别将浮点数转换为无符号、有符号整型，将无符号、有符号整型转换为浮点数。不过有一点要注意的是，如果将大数转换为小的数，那么并不保证截断，如将浮点型的`257.1`转换成`i8`（上限为`128`），那么就会产生未定义行为。所以，在浮点型和整型相互转换的时候，需要在高级语言层面做一些调整，如使用饱和转换等。

## 指针类型

LLVM IR中的指针类型就是`ptr`。与C语言不同，LLVM IR中的指针不含有其指向内容的类型，也就是说，类似于C语言中的`void *`。我们之前提到，LLVM IR中的全局变量和栈上分配的变量都是指针，所以其类型都是指针类型。

在高级语言中，直接操作裸指针的机会都比较少，除非在性能极其敏感的场景下，由最厉害的大佬才能操作裸指针。这是因为，裸指针极其危险，稍有不慎就会出现段错误等致命错误，所以我们使用指针时应该慎之又慎。

LLVM IR为大佬们提供了操作裸指针的一些指令。在C语言中，我们会遇到这种场景：

```c
int x, y;
size_t address_of_x = (size_t)&x;
size_t address_of_y = address_of_x - sizeof(int);
int also_y = *(int *)address_of_y;
```

这种场景比较无脑，但确实是合理的，需要将指针看作一个具体的数值进行加减。到x86_64的汇编语言层次，取地址就变成了`lea`命令，解引用倒是比较正常，就是一个简单的`mov`。

在LLVM IR层次，为了使指针能像整型一样加减，提供了`ptrtoint` .. `to`指令和`inttoptr` .. `to`指令，分别解决将指针转换为整型，和将整型转换为指针的功能。也就是说，我们可以粗略地将上面的程序转写为

```llvm
%x = alloca i32 ; %x is of type ptr, which is the address of variable x
%y = alloca i32 ; %y is of type ptr, which is the address of variable y
%address_of_x = ptrtoint ptr %x to i64
%address_of_y = sub i64 %address_of_x, 4
%also_y = inttoptr i64 %address_of_y to ptr ; %also_y is of type ptr, which is the address of variable y
```

## 聚合类型

比起指针类型而言，更重要的是**聚合类型**。我们在C语言中常见的聚合类型有数组和结构体，LLVM IR也为我们提供了相应的支持。

数组类型很简单，我们要声明一个类似C语言中的`int a[4]`，只需要

```llvm
%a = alloca [4 x i32]
```

也就是说，C语言中的`int[4]`类型在LLVM IR中可以写成`[4 x i32]`。注意，这里面是个`x`不是`*`。

我们也可以使用类似地语法进行初始化：

```llvm
@global_array = global [4 x i32] [i32 0, i32 1, i32 2, i32 3]
```

特别地，我们知道，字符串在底层可以看作字符组成的数组，所以LLVM IR为我们提供了语法糖：

```llvm
@global_string = global [12 x i8] c"Hello world\00"
```

在字符串中，转义字符必须以`\xy`的形式出现，其中`xy`是这个转义字符的ASCII码。比如说，字符串的结尾，C语言中的`\0`，在LLVM IR中就表现为`\00`。

结构体的类型也相对比较简单，在C语言中的结构体

```c
struct MyStruct {
    int x;
    char y;
};
```

在LLVM IR中就成了

```llvm
%MyStruct = type {
    i32,
    i8
}
```

我们初始化一个结构体也很简单：

```llvm
@global_structure = global %MyStruct { i32 1, i8 0 }
; or
@global_structure = global { i32, i8 } { i32 1, i8 0 }
```

值得注意的是，无论是数组还是结构体，其作为全局变量或栈上变量，依然是指针，也就是说，`@global_array`的类型是`ptr`, `@global_structure`的类型也是`ptr`。接下来的问题就是，我们如何对聚合类型进行操作呢？

在LLVM IR中，如果我们想对一个聚合类型的某些字段进行操作，需要区分这个聚合类型是指针形式的，也就是以全局变量或者栈形式存储，还是值形式的，也就是以寄存器形式存储。

### `getelementptr`

首先，我们将介绍以指针形式存储的聚合类型，该如何访问其字段。

#### 访问数组元素字段

我们先来看一个最直观的例子：

```c
struct MyStruct {
    int x;
    int y;
};

void foo(struct MyStruct *my_structs_ptr) {
    int my_y = my_structs_ptr[2].y;
}
```

我们有一个`foo`函数，其接收了一个参数`my_structs_ptr`。从函数体的语义可知，这里这个参数，实际上指向了一个数组，我们要取这个数组的第三个元素的`y`字段。

我们先直接看结论，用LLVM IR来表示为

```llvm
%MyStruct = type { i32, i32 }

define void @foo(ptr %my_structs_ptr) {
    %my_y_in_stack = alloca i32
    %my_y_ptr = getelementptr %MyStruct, ptr %my_structs_ptr, i64 2, i32 1
    %my_y_val = load i32, ptr %my_y_ptr
    store i32 %my_y_val, ptr %my_y_in_stack
    ret void
}
```

我们可以注意到，最核心的就是`getelementptr`指令了。它的四个参数的语义分别为* `%MyStruct`

   我们要取地址的指针，它指向区域的类型为`%MyStruct`
* `ptr %my_structs_ptr`

   我们要操作的指针，是`ptr %my_structs_ptr`
* `i64 2`

   取偏移量为2的那个元素，也就是`my_structs_ptr[2]`
* `i32 1`

   对于获得到的那个元素，取索引为1的字段，也就是`my_structs_ptr[2].y`

通过这个指令，我们获得了`my_structs_ptr[2].y`的地址，随后的LLVM IR指令就是将这个地址的值放到了局部变量中。

#### 访问指针字段

接下来，我们看这样一个例子：

```c
struct MyStruct {
    int x;
    int y;
};

void foo(struct MyStruct *my_structs_ptr) {
    int my_y = my_structs_ptr->y;
}
```

其对应的LLVM IR为

```llvm
%MyStruct = type { i32, i32 }

define void @foo(ptr %my_structs_ptr) {
    %my_y_in_stack = alloca i32
    %my_y_ptr = getelementptr %MyStruct, ptr %my_structs_ptr, i64 0, i32 1
    %my_y_val = load i32, ptr %my_y_ptr
    store i32 %my_y_val, ptr %my_y_in_stack
    ret void
}
```

唯一的改动，就是将之前的偏移量`i64 2`改为`i64 0`。

这看上去挺符合直觉的。等等，符合直觉吗？

我们发现，即使是将`my_structs_ptr`看作是指向结构体的指针，而非指向数组的指针，仍然要加一个偏移量`0`。这是因为，C语言中，对于一个数组`array`，`&array[0]`和指向首元素的`array_ptr`是同一个东西。为了兼容C语言这个特性，LLVM IR在`getelementptr`中，将所有的指针都看作一个指向数组首地址的指针。因此，我们需要额外加一个`i64 0`的偏移量来解决这个问题。

#### 级联访问

此外，`getelementptr`还可以接多个参数，类似于级联调用。我们有C程序：

```c
struct MyStruct {
    int x;
    int y[5];
};

struct MyStruct my_structs[4];
```

那么如果我们想获得`my_structs[2].y[3]`的地址，只需要

```llvm
%MyStruct = type {
    i32,
    [5 x i32]
}
%my_structs = alloca [4 x %MyStruct]

%1 = getelementptr [4 x %MyStruct], ptr %my_structs, i64 2, i32 1, i64 3
```

我们可以查看官方提供的[The Often Misunderstood GEP Instruction](http://llvm.org/docs/GetElementPtr.html)指南更多地了解`getelementptr`的机理。

## `extractvalue`和`insertvalue`

除了我们上面讲的这种情况，也就是把结构体分配在栈或者全局变量，然后操作其指针以外，还有什么情况呢？我们考虑这种情况：

```llvm
; extract_insert_value.ll
%MyStruct = type {
    i32,
    i32
}
@my_struct = global %MyStruct { i32 1, i32 2 }

define i32 @main() {
    %1 = load %MyStruct, ptr @my_struct

    ret i32 0
}
```

这时，我们的结构体是直接放在虚拟寄存器`%1`里，`%1`并不是存储`@my_struct`的指针，而是直接存储这个结构体的值。这时，我们并不能用`getelementptr`来操作`%1`，因为这个指令需要的是一个指针。因此，LLVM IR提供了`extractvalue`和`insertvalue`指令。

因此，如果要获得`@my_struct`第二个字段的值，我们需要

```llvm
%2 = extractvalue %MyStruct %1, 1
```

这里的`1`就代表第二个字段（从`0`开始）。

类似地，如果要将`%1`的第二个字段赋值为`233`，只需要

```llvm
%3 = insertvalue %MyStruct %1, i32 233, 1
```

然后`%3`就会是`%1`将第二个字段赋值为`233`后的值。

`extractvalue`和`insertvalue`并不只适用于结构体，也同样适用于**存储在虚拟寄存器中的数组**，这里不再赘述。

## 标签类型

在汇编语言中，一切的控制语句、函数调用都是由标签来控制的，在LLVM IR中，控制语句也是需要标签来完成。其具体的内容我会在之后专门有一篇控制语句的文章来解释。

## 元数据类型

在我们使用Clang将C语言程序输出成LLVM IR时，会发现代码的最后几行有

```llvm
!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Homebrew clang version 16.0.6"}
```

类似于这样的东西。

在LLVM IR中，以`!`开头的标识符为**元数据**。元数据是为了*将额外的信息附加在程序中传递给LLVM后端，使后端能够好地优化或生成代码。*用于Debug的信息就是通过元数据形式传递的。我们可以使用`-g`选项：

```shell
clang -S -emit-llvm -g test.c
```

来在LLVM IR中附加额外的Debug信息。关于元数据，在后续的章节里会有更具体的介绍。

## 属性

最后，还有一种叫做属性的概念。属性并不是类型，其一般用于函数。比如说，告诉编译器这个函数不会抛出错误，不需要某些优化等等。我们可以看到

```llvm
define void @foo() nounwind {
    ; ...
}
```

这里`nounwind`就是一个属性。

有时候，一个函数的属性会特别特别多，并且有多个函数都有相同的属性。那么，就会有大量重复的篇幅用来给每一个函数说明属性。因此，**LLVM IR引入了属性组的概念**，我们在将一个简单的C程序编译成LLVM IR时，会发现代码中有

```llvm
attributes #0 = { noinline nounwind optnone ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "darwin-stkchk-strong-link" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "probe-stack"="___chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
```

这种一大长串的，就是属性组。属性组总是以`#`开头。当我们函数需要它的时候，只需要

```llvm
define void @foo #0 {
    ; ...
}
```

直接使用`#0`即可。关于属性，后续也会有专门的章节进行介绍。

## 控制流

在程序分析领域，往往会强调一对概念：**数据流与控制流**。所谓数据流，就是指一个程序中的数据，从硬盘到内存，从内存到寄存器，等等一系列的数据搬运、处理的过程。这一过程，在之前的文章中已经详细地介绍了。

而控制流，则是指程序执行指令的顺序。最简单地，我们的程序在除了顺序执行指令，还可以通过`if`语句进行条件跳转，通过`for`、`while`语句进行循环，还可以通过函数调用进入到别的函数。凡此种种，都是程序控制流的变化。

在使用LLVM作为编译器的时候，控制流往往就意味着更多的优化可能，如分支布局、函数内联。在使用LLVM作为静态分析工具的过程中，控制流也意味着更高的复杂度，如间接跳转、间接调用的识别和恢复。

因此，我们需要仔细了解LLVM中的控制流。
