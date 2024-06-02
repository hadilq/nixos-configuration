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

cd $OUTPUT_DIR
if [ ! -d "$OUTPUT_DIR/.git" ]; then
  sudo rm -rf $OUTPUT_DIR
  sudo git clone $ORIGIN $OUTPUT_DIR
fi

sudo git fetch -a
sudo git checkout -f $ORIGIN_COMMIT

sudo nixos-rebuild switch

