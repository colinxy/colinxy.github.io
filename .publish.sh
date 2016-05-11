#! /bin/sh

branch=$(git rev-parse --abbrev-ref HEAD)
echo "currently on '$branch' branch"

# check branh
[ "$branch" = 'master' ] || echo 'only publish on master branch' && exit 1

# mv files from _site to root level
SITE=_site
echo "moving files to $SITE"
git checkout source -- "$SITE"
find "$SITE" -maxdepth 1 ! -path "$SITE" -print0 -exec mv -t "$SITE" {} +
