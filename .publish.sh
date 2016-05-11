#! /bin/sh

set -e

CURR_PATH=$(pwd)
echo "$CURR_PATH"

git add . && git commit -m 'just to make sure'

branch=$(git rev-parse --abbrev-ref HEAD)
echo "currently on '$branch' branch"

# check branh
[ "$branch" = 'master' ] || { echo 'ONLY PUBLISH ON MASTER BRANCH' && exit 1; }


# cleanup, keep only $KEEP in master branch
KEEP=".git .gitignore .nojekyll README.md .publish.sh"
echo "clear site, keep only $KEEP"
find . -maxdepth 1 ! -name '.' ! -name '.git' ! -name '.gitignore' ! -name '.nojekyll' ! -name 'README.md' ! -name '.publish.sh'  -exec rm -r {} \;

# mv files from _site to root level
SITE=_site
echo "moving files to $SITE"
git checkout source -- "$SITE"

# generate site by moving lifting everything in $SITE to root level
find "$SITE" -maxdepth 1 ! -path "$SITE" -exec gmv -t . {} +
