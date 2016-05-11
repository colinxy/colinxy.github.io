#! /bin/sh

set -e

git add . && git commit -m 'just to make sure'

branch=$(git rev-parse --abbrev-ref HEAD)
echo "currently on '$branch' branch"

# check branh
[ "$branch" = 'master' ] || { echo 'only publish on master branch' && exit 1; }


# cleanup, keep only $KEEP in master branch
KEEP=".git .gitignore .nojekyll README.md .publish.sh"
find . -maxdepth 1 ! -name '.' ! -name '.git' ! -name '.gitignore' ! -name '.nojekyll' ! -name 'README.md' ! -name '.publish.sh'  -print

# mv files from _site to root level
SITE=_site
echo "moving files to $SITE"
git checkout source -- "$SITE"


find "$SITE" -maxdepth 1 ! -path "$SITE" -exec gmv -t . {} +
