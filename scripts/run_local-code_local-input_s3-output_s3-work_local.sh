#!/bin/bash

set -e

script_name=$(basename "$0")
TMPOUT=s3://data-intuitive-tmp/test-nextflow-wave-fusion/output/${script_name%.sh}
OUT=output/${script_name%.sh}
RES=s3://data-intuitive-tmp/test-nextflow-wave-fusion/resources

# set aws profile
export AWS_PROFILE=di
echo "aws profile: $AWS_PROFILE"

# clear output dir
echo "Clearing output directory"
aws s3 rm $TMPOUT --recursive
[ -d "$OUT" ] && rm -r "$OUT"

# run component
echo "Running component"
NXF_VER=23.10.1 nextflow run \
  . \
  -main-script target/nextflow/method/main.nf \
  -profile docker \
  -latest \
  --input $RES/input1.txt \
  --multiple_input "$RES/input1.txt;$RES/input2.txt" \
  --publish_dir "$TMPOUT"

# sync output
echo "Syncing output"
aws s3 sync $TMPOUT $OUT

# check if output is correct
echo "Checking output"
scripts/verify_output.sh "$OUT"
