#!/bin/bash

set -e

script_name=$(basename "$0")
TMPOUT=s3://data-intuitive-tmp/test-nextflow-wave-fusion/output/${script_name%.sh}
OUT=output/${script_name%.sh}
RES=s3://data-intuitive-tmp/test-nextflow-wave-fusion/resources
WORK=s3://data-intuitive-tmp/test-nextflow-wave-fusion/work/${script_name%.sh}
NXF_CONFIG=/tmp/${script_name%.sh}.config

# set aws profile
export AWS_PROFILE=di
echo "aws profile: $AWS_PROFILE"

# clear output dir
echo "Clearing output directory"
aws s3 rm $TMPOUT --recursive
[ -d "$OUT" ] && rm -r "$OUT"

# create config
cat > $NXF_CONFIG <<'EOF'
fusion {
    enabled = true
}

wave {
    enabled = true
}

docker {
  runOptions = '-v $HOME/.aws/credentials:/credentials -e AWS_SHARED_CREDENTIALS_FILE=/credentials -e AWS_PROFILE=$AWS_PROFILE'
}
EOF


# run component
echo "Running component"
NXF_VER=24.04.2 nextflow run \
  viash-io/test-nextflow-wave-fusion \
  -r build_0_7_5 \
  -main-script target/nextflow/method/main.nf \
  -profile docker \
  -latest \
  -w $WORK \
  -c $NXF_CONFIG \
  --input $RES/input1.txt \
  --multiple_input "$RES/input2.txt" \
  --publish_dir "$TMPOUT"

# sync output
echo "Syncing output"
aws s3 sync $TMPOUT $OUT

# check if output is correct
echo "Checking output"
scripts/verify_output.sh "$OUT"
