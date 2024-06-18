#!/bin/bash

set -e

script_name=$(basename "$0")
BUCKET=""  # REPLACE
TMPOUT=$BUCKET/test-nextflow-wave-fusion/output/${script_name%.sh}
OUT=output/${script_name%.sh}
RES=$BUCKET/test-nextflow-wave-fusion
WORK=$BUCKET/test-nextflow-wave-fusion/work/${script_name%.sh}
NXF_CONFIG=/tmp/${script_name%.sh}.config
PARAMS=/tmp/${script_name%.sh}.yaml
WORKSPACE=""  # REPLACE
COMPUTE_ENV=""  # REPLACE
TOWER_API_ENDPOINT="" # REPLACE

export TOWER_ACCESS_TOKEN=""  # REPLACE
export TOWER_API_ENDPOINT=""  # REPLACE

# clear output dir
echo "Clearing output directory"
aws s3 rm $TMPOUT --recursive
[ -d "$OUT" ] && rm -r "$OUT"

# run component
echo "Running component"
cat > $NXF_CONFIG <<EOF
tower {
    enabled = true
    endpoint = '$TOWER_API_ENDPOINT'   
}
EOF

cat > $PARAMS <<EOF
input: $RES/input1.txt
multiple_input: "$RES/input1.txt;$RES/input2.txt"
publish_dir: "$TMPOUT"
EOF

tw launch \
  test-nextflow-wave-fusion \
  --revision build_0_8_6 \
  --main-script target/nextflow/method/main.nf \
  --work-dir $WORK \
  --workspace $WORKSPACE \
  --compute-env $COMPUTE_ENV \
  --config $NXF_CONFIG \
  --params-file $PARAMS

# sync output
echo "Syncing output"
echo "aws s3 sync $TMPOUT $OUT"

# check if output is correct
echo "Checking output"
echo "scripts/verify_output.sh $OUT"