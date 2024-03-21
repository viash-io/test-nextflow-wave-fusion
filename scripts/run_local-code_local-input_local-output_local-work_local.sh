#!/bin/bash

set -e

script_name=$(basename "$0")
OUT=output/${script_name%.sh}
RES=resources

# clear output dir
[ -d "$OUT" ] && rm -r "$OUT"

# run component
NXF_VER=23.10.0 nextflow run \
  . \
  -main-script target/nextflow/method/main.nf \
  -profile docker \
  --input $RES/input1.txt \
  --multiple_input "$RES/input1.txt;$RES/input2.txt" \
  --publish_dir "$OUT"

# check if output is correct
scripts/verify_output.sh "$OUT"
