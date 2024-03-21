#!/bin/bash

set -e

# build component
rm -r target && viash ns build --parallel --setup cb

# clear output dir
rm -r output/local

# run component
NXF_VER=23.10.0 nextflow run \
  . \
  -main-script target/nextflow/method/main.nf \
  -profile docker \
  --input resources/input1.txt \
  --multiple_input "resources/input1.txt;resources/input2.txt" \
  --publish_dir output/local

# check if output is correct
scripts/verify_output.sh output/local
