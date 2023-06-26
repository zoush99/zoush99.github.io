# !
# This simple script is designed to make it easier to publish my github pages and to be able to synchronize the source code updates to the sourcecode branch.

function get_curr_bran{
    br=`git branch | grep "*"`
    echo ${br/* /}
}
bran=`obtain_git_branch`
echo "the name of this scipt is publish"
echo "First post on pages"
hexo g -d
echo "Then upload to sourcecode branch"
read -p "Enter submission notes:" notes
echo "Determine if the local branch is a sourcecode branch, if so, upload directly, otherwise switch to sourcecode branch and upload again"
echo "Current git branch is $bran"
if ["$bran"=="sourcecode"]
    then 
        echo "the branch is sourcecode, upload directly"
    else
        echo "Switch to the sourcecode branch, then upload"
        git checkout -b sourcecode 
fi 

git pull origin sourcecode &&
git add . &&
git commit -m $notes && 
git push origin source
