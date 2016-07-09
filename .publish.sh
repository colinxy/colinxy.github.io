#! /bin/sh

set -e

BLOG='colinxy.github.io'

# primary check, directory
CURR_PATH=${PWD##*/}
[ "$BLOG" = "$CURR_PATH" ] ||
    { echo "NOT THE BLOG DIRECTORY" && exit 1; }


# git add . && git commit -m 'blog update'

branch=$(git rev-parse --abbrev-ref HEAD)
printf '\033[0;36m==>\033[0m '
echo "currently on '$branch' branch"

# check branch
[ "$branch" = 'master' ] ||
    { echo 'ONLY PUBLISH ON MASTER BRANCH' && exit 1; }


# cleanup, keep only $KEEP in master branch
KEEP=".git .gitignore .nojekyll README.md .publish.sh"

printf '\033[0;36m==>\033[0m '
echo "clear site, keep only $KEEP"
find . -maxdepth 1 ! -name '.' ! -name '.git' ! -name '.gitignore' ! -name '.nojekyll' ! -name 'README.md' ! -name '.publish.sh'  -exec rm -r {} \;

# checkout site from source branch
SITE=_site

printf '\033[0;36m==>\033[0m '
echo "moving files to $SITE"
git checkout source -- "$SITE"  # blog content on source branch

# generate site by moving lifting everything in $SITE to blog root level
find "$SITE" -maxdepth 1 ! -path "$SITE" -exec mv {} . \;


echo
echo "publish success"
printf "\033[0;36m===\033[0m you should commit and push now \033[0;36m===\033[0m\n"
