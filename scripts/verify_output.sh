#!/bin/bash

set -e

OUTPUT_PATH="$1"

# check if output is correct
diff -r expected "$OUTPUT_PATH" || (echo "Output is not correct" && exit 1)

echo "Output is correct"

