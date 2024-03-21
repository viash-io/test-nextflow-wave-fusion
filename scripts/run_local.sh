#!/bin/bash

set -e

OUT=output/local

# clear output dir
[ -d "$OUT" ] && rm -r "$OUT"

# run component
NXF_VER=23.10.0 nextflow run \
  . \
  -main-script target/nextflow/method/main.nf \
  -profile docker \
  --input resources/input1.txt \
  --multiple_input "resources/input1.txt;resources/input2.txt" \
  --publish_dir "$OUT"

# check if output is correct
scripts/verify_output.sh "$OUT"
