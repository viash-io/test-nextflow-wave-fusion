#!/bin/bash

set -e

script_name=$(basename "$0")
TMPOUT=s3://data-intuitive-tmp/test-nextflow-wave-fusion/output/${script_name%.sh}
OUT=output/${script_name%.sh}
RES=s3://data-intuitive-tmp/test-nextflow-wave-fusion/resources
WORK=s3://data-intuitive-tmp/test-nextflow-wave-fusion/work/${script_name%.sh}
NXF_CONFIG=/tmp/${script_name%.sh}.config

# clear output dir
echo "Clearing output directory"
aws s3 rm $TMPOUT --recursive
[ -d "$OUT" ] && rm -r "$OUT"

# create config
cat > $NXF_CONFIG <<EOF
fusion {
    enabled = true
    exportStorageCredentials = true
}

wave {
    enabled = true
}
EOF


# run component
echo "Running component"
NXF_VER=23.10.1 nextflow run \
  viash-io/test-nextflow-wave-fusion \
  -r main_build \
  -main-script target/nextflow/method/main.nf \
  -profile docker \
  -latest \
  -w $WORK \
  -c $NXF_CONFIG \
  --input $RES/input1.txt \
  --multiple_input "$RES/input1.txt;$RES/input2.txt" \
  --publish_dir "$TMPOUT"

# sync output
echo "Syncing output"
aws s3 sync $TMPOUT $OUT

# check if output is correct
echo "Checking output"
scripts/verify_output.sh "$OUT"
