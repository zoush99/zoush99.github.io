# !
# This simple script is designed to make it easier to publish my github pages and to be able to synchronize the source code updates to the sourcecode branch.


echo "the name of this scipt is publish"
echo "First post on pages"
# hexo g -d

result=`git branch | grep "*"`
curBranch=${result:2}
echo "Then upload to sourcecode branch"
read -p "Enter submission notes:" notes
echo "Determine if the local branch is a sourcecode branch, if so, upload directly, otherwise switch to sourcecode branch and upload again"
echo "Current git branch is $curBranch"
if [${curBranch} == "sourcecode"]
    then 
        echo "the branch is sourcecode, upload directly"
    else
        echo "Switch to the sourcecode branch, then upload"
        git checkout sourcecode 
fi 

git pull origin sourcecode &&
git add . &&
git commit -m $notes && 
git push origin source
