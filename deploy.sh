#!/run/current-system/sw/bin/bash

if ! [[ -z "$(git status -s)" ]]; then
  echo "dirty source! commit it first." >&2
  exit 1;
fi

CONFIGURATION_FILE="configuration.tar.gz"
# OUTPUT_DIR=$(mktemp -d /tmp/nixos-configuration-XXXX)
OUTPUT_DIR=/persist/etc/nixos
echo "output dir: $OUTPUT_DIR" >&2

git archive --format=tar.gz -o $CONFIGURATION_FILE main

sudo tar -xf $CONFIGURATION_FILE --directory $OUTPUT_DIR
sudo chown -R root:root $OUTPUT_DIR
sudo chmod -R 750 $OUTPUT_DIR
sudo nixos-rebuild switch

