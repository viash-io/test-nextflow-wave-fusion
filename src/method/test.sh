#!/bin/bash

set -e

echo "> Run executable"
"$meta_executable" \
  --input "$meta_resources_dir/resources/input1.txt" \
  --multiple_input "$meta_resources_dir/resources/input2.txt;$meta_resources_dir/resources/input1.txt" \
  --output "output.txt" \
  --multiple_output "multiple_output_*.txt" \
  --output_resource "output_resource.txt"

echo "> Check if output files exist"
[ ! -f "output.txt" ] && echo "output.txt does not exist" && exit 1
[ ! -f "multiple_output_0.txt" ] && echo "multiple_output_0.txt does not exist" && exit 1
[ ! -f "multiple_output_1.txt" ] && echo "multiple_output_1.txt does not exist" && exit 1
[ ! -f "output_resource.txt" ] && echo "output_resource.txt does not exist" && exit 1

echo "> Check output file contents"
diff -q "output.txt" "$meta_resources_dir/resources/input1.txt"
diff -q "multiple_output_0.txt" "$meta_resources_dir/resources/input2.txt"
diff -q "multiple_output_1.txt" "$meta_resources_dir/resources/input1.txt"
diff -q "output_resource.txt" "$meta_resources_dir/resource.txt"

echo "> Done"
