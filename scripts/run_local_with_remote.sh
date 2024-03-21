#!/bin/bash

set -e

OUT=output/local_with_remote

# clear output dir
rm -r "$OUT"

# run component
NXF_VER=23.10.0 nextflow run \
  viash-io/test-nextflow-wave-fusion \
  -r main_build \
  -main-script target/nextflow/method/main.nf \
  -profile docker \
  --input resources/input1.txt \
  --multiple_input "resources/input1.txt;resources/input2.txt" \
  --publish_dir "$OUT"

# check if output is correct
scripts/verify_output.sh "$OUT"
