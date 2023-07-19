---
title: git的使用
date: 2023-06-13 17:06:18
tags: 
- git
categories: 
- git
typora-root-url: ./../
---

## 主要介绍git的使用规则

<!--more-->

![](/paper_source/git指令/graph.jpg)

一些信息查找命令。

```sh
git branch
git branch -al
git branch -r
```

在要推送的项目下，打开git，首先需要初始化。

```sh
git init
```

然后连接远程仓库，这个远程仓库需要自己预先建立（github或其他代码管理平台都可以），如我想连接自己的zoush99。

```sh
git remote add origin git@github.com:zoush99/zoush99.github.io.git
```

将远程仓库的某个分支拉取到本地。（第一个参数是远程分支，第二个参数是本地分支）

```sh
git pull --set-upstream-to=origin/source source
```

将本地仓库加入到提交目录中。（加入了所有文件，也可以加入特定文件）

```sh
git add .
```

提交到仓库

```sh
git commit -m "提交备注"
```

上传到远程仓库。（第一个参数是远程分支，第二个参数是本地分支）如果加上参数`-u`则会将本地分支作为追踪分支。

```sh
git push origin source
```

以上是完整的过程，但是还需要一些常见的指令。

将远程仓库的文件复制到本地。（将默认的分支拉取到本地，后面一个参数是将本地文件夹重命名为source）

```sh
git clone git@github.com:zoush99/zoush99.github.io.git source
```

拉取指定分支。

```sh
git clone -b source git@github.com:zoush99/zoush99.github.io.git source
```

拉取到本地后，可以查看是哪个分支。

```sh
git branch
```

新建并且切换为本地分支。

```sh
git checkout -b source
```

新建本地分支，并且从远程仓库拉取代码。

```sh
git checkout -b source origin/source
```
删除本地分支，注意要切换到其他分支后，才能删除本地分支，在当前分支时不能删除当前分支。

```sh
git branch -d source
```

删除远程分支。

```sh
git push origin -d source
```

其他需要注意的：用命令`git pull --set-upstream-to=origin/source source`将修改的远程代码拉取到本地后，直接用`git push origin source`提交，不需要`add`和`commit`，因为`pull=fetch+merge`。

注意`fetch`和`merge`指令和`pull`指令。

更新远程仓库的某个分支到本地。

```sh
git fetch origin source
```

将远程仓库的某个分支下载到本地新建的分支。

```sh
git fetch origin source:source
```

将远程分支合并到本地当前分支。

```sh
git merge origin/source
```

上面两个命令连续执行，相当于如下的`pull`。

```sh
git pull origin source
```

版本回滚操作，回到之前的版本，防止数据丢失。

查看版本号。

```sh
git log
```

使用指令回到目标版本号指定的版本。

```sh
git reset --hard 目标版本号
```

再提交。

```sh
git push -f
```

也可以用`revert`操作。但这里不打算介绍这种方法，看起来有些麻烦。
