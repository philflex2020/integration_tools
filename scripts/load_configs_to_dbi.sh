#!/bin/bash

BIN_DIR=/usr/local/bin
DBI_CONFIG_DIR=/usr/local/etc/config/dbi

# Load ESS configs to dbi
shopt -s nullglob
FILES=$(find $DBI_CONFIG_DIR/ess_controller -type f -name '*.json')

for f in $FILES
do
    fName=$(basename ${f})
    dir=$(dirname ${f})
    echo "Loading $fName from $dir to database..."
    $BIN_DIR/fims_send -m set -u /dbi/ess_controller/configs_${fName%.*} -f $f
done
shopt -u nullglob

# Load the UI assets/dashboard configs to dbi
$BIN_DIR/fims_send -m set -u /dbi/ui_config/assets -f $DBI_CONFIG_DIR/web_ui/assets.json
$BIN_DIR/fims_send -m set -u /dbi/ui_config/dashboard -f $DBI_CONFIG_DIR/web_ui/dashboard.json
$BIN_DIR/fims_send -m set -u /dbi/ui_config/dashboard -f $DBI_CONFIG_DIR/web_ui/layout.json
