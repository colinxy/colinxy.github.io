#! /bin/sh

set -e

BLOG='colinxy.github.io'

# primary check, directory
CURR_PATH=${PWD##*/}
[ "$BLOG" = "$CURR_PATH" ] ||
    { echo "NOT THE BLOG DIRECTORY" && exit 1; }


git add . && git commit -m 'just to make sure'

branch=$(git rev-parse --abbrev-ref HEAD)
echo "currently on '$branch' branch"

# check branh
[ "$branch" = 'master' ] ||
    { echo 'ONLY PUBLISH ON MASTER BRANCH' && exit 1; }


# cleanup, keep only $KEEP in master branch
KEEP=".git .gitignore .nojekyll README.md .publish.sh"
echo "clear site, keep only $KEEP"
find . -maxdepth 1 ! -name '.' ! -name '.git' ! -name '.gitignore' ! -name '.nojekyll' ! -name 'README.md' ! -name '.publish.sh'  -exec rm -r {} \;

# checkout site from source branch
SITE=_site
echo "moving files to $SITE"
git checkout source -- "$SITE"

# generate site by moving lifting everything in $SITE to root level
find "$SITE" -maxdepth 1 ! -path "$SITE" -exec gmv -t . {} +
# bash mv sucks, use GNU ls


echo
echo "=== you should commit and push now ==="
