#!/run/current-system/sw/bin/bash

if ! [[ -z "$(git status -s)" ]]; then
  echo "dirty source! commit it first." >&2
  exit 1;
fi

ORIGIN=$PWD
ORIGIN_COMMIT=`git show --format="%H" --no-patch`
#OUTPUT_DIR=$(mktemp -d /tmp/nixos-configuration-XXXX)
OUTPUT_DIR=/persist/etc/nixos
echo "output dir: $OUTPUT_DIR" >&2

LOCAL_CHANGES_BRANCH=local-users-network
cd $OUTPUT_DIR
if [ ! -d "$OUTPUT_DIR/.git" ]; then
  sudo rm -rf $OUTPUT_DIR
  sudo git clone $ORIGIN $OUTPUT_DIR
  sudo git checkout -b $LOCAL_CHANGES_BRANCH
  echo "cloning completed, but you need to commit users.nix and network.nix files manually!" >&2
  exit 2;
fi

LOCAL_COMMIT=`sudo git show --format="%H" --no-patch`
echo "local commit is $LOCAL_COMMIT" >&2

sudo git branch -D main
sudo git fetch -a
sudo git checkout -f main # In case of `commit --ammend` this works, but not `pull --rebase`
sudo git branch -D $LOCAL_CHANGES_BRANCH
sudo git checkout -b $LOCAL_CHANGES_BRANCH # creating this branch on the HEAD of main now
sudo git clean -fdx
sudo git cherry-pick $LOCAL_COMMIT

sudo nixos-rebuild switch

