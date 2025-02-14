#!/run/current-system/sw/bin/bash

if ! [[ -z "$(git status -s)" ]]; then
  echo "dirty source! commit it first." >&2
  exit 1;
fi

ORIGIN=$PWD
ORIGIN_COMMIT=`git show --format="%H" --no-patch`
#OUTPUT_DIR=$(mktemp -d /tmp/nixos-configuration-XXXX)
OUTPUT_DIR=/persist/etc/nixos
# Since I continuously delete its directory!
BACKUP_DIR=/persist/etc/nixos-back
echo "output directory: $OUTPUT_DIR" >&2
echo "backup directory: $BACKUP_DIR" >&2

LOCAL_CHANGES_BRANCH=local-users-network
cd $OUTPUT_DIR
if [ ! -d "$OUTPUT_DIR/.git" ]; then
  sudo rm -rf $OUTPUT_DIR
  sudo git clone $ORIGIN $OUTPUT_DIR
  sudo git checkout -b $LOCAL_CHANGES_BRANCH
fi

sudo rm flake.lock
sudo git config --global user.email "hadilq.dev@gmail.com"
sudo git config --global user.name "Hadi"
sudo git pull --rebase origin $LOCAL_CHANGES_BRANCH

sudo rm -rf $BACKUP_DIR
sudo cp -a $OUTPUT_DIR $BACKUP_DIR

sudo nixos-rebuild switch

