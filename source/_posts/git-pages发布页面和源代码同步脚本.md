---
title: git pages发布页面和源代码同步脚本
date: 2023-06-26 16:51:00
tags: 
- blog
categories: 
- blog
typora-root-url: ./../
---

## github pages界面和源代码同步

<!--more-->

>  为了便于自己记录并且保存自己的做项目或者生活中记录的重点事项，也为了多设备单账号协同发布。所以打算写一个脚本用来便于运行脚本分别发布并且同步源代码。

```shell
# !
# This simple script is designed to make it easier to publish my github pages and to be able to synchronize the source code updates to the sourcecode branch.


echo "the name of this scipt is publish"
echo "First post on pages"
hexo g -d

result=`git branch | grep "*"`
curBranch=${result:2}
echo "Then upload to sourcecode branch"
read -p "Enter submission notes:" notes
echo "Determine if the local branch is a sourcecode branch, if so, upload directly, otherwise switch to sourcecode branch and upload again"
echo "Current git branch is $curBranch"
if [ ${curBranch} == "sourcecode" ]
    then 
        echo "the branch is sourcecode, upload directly"
    else
        echo "Switch to the sourcecode branch, then upload"
        git checkout sourcecode 
fi 

git pull origin sourcecode &&
git add . &&
git commit -m $notes && 
git push origin sourcecode
```

实现了简单的快捷上传操作。
