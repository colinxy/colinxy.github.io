#! /bin/sh

branch=$(git rev-parse --abbrev-ref HEAD)
echo "currently on '$branch' branch"

[ "$branch" = 'master' ] || echo 'only publish on master branch' && exit 1
