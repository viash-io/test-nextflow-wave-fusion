#!/bin/bash

set -e

script_name=$(basename "$0")
OUT=output/${script_name%.sh}
RES=s3://data-intuitive-tmp/test-nextflow-wave-fusion/resources

# set aws profile
export AWS_PROFILE=di
echo "aws profile: $AWS_PROFILE"

# clear output dir
[ -d "$OUT" ] && rm -r "$OUT"

# run component
NXF_VER=23.10.0 nextflow run \
  viash-io/test-nextflow-wave-fusion \
  -r main_build \
  -main-script target/nextflow/method/main.nf \
  -profile docker \
  -latest \
  --input $RES/input1.txt \
  --multiple_input "$RES/input1.txt;$RES/input2.txt" \
  --publish_dir "$OUT"

# check if output is correct
scripts/verify_output.sh "$OUT"
