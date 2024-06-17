#!/bin/bash

set -e

script_name=$(basename "$0")
TMPOUT=s3://data-intuitive-tmp/test-nextflow-wave-fusion/output/${script_name%.sh}
OUT=output/${script_name%.sh}
RES=s3://data-intuitive-tmp/test-nextflow-wave-fusion/resources
WORK=s3://data-intuitive-tmp/test-nextflow-wave-fusion/work/${script_name%.sh}
NXF_CONFIG=/tmp/${script_name%.sh}.config
PARAMS=/tmp/${script_name%.sh}.yaml

# set aws profile
export AWS_PROFILE=di
echo "aws profile: $AWS_PROFILE"

# clear output dir
echo "Clearing output directory"
aws s3 rm $TMPOUT --recursive
[ -d "$OUT" ] && rm -r "$OUT"

# run component
echo "Running component"

cat > $NXF_CONFIG <<EOF
process {
    executor = 'awsbatch'
    queue = 'nextflow_queue_nofusion'
    container = 'bash:4.0'
}

aws {
    region = 'eu-west-1'
    batch {
        cliPath = '/home/ec2-user/miniconda/bin/aws'
    }
}
EOF

cat > $PARAMS <<EOF
input: $RES/input1.txt
multiple_input: "$RES/input1.txt;$RES/input2.txt"
publish_dir: "$TMPOUT"
EOF

tw launch \
  viash-io/test-nextflow-wave-fusion \
  --revision main_build \
  --main-script target/nextflow/method/main.nf \
  --work-dir $WORK \
  --workspace XXX \
  --compute-env YYY \
  --config $NXF_CONFIG \
  --params-file $PARAMS

# sync output
echo "Syncing output"
aws s3 sync $TMPOUT $OUT

# check if output is correct
echo "Checking output"
scripts/verify_output.sh "$OUT"
