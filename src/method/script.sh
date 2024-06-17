#!/bin/bash

## VIASH START
par_input="resources/input1.txt"
par_multiple_input="resources/input1.txt;resources/input2.txt"
par_output="output.txt"
par_multiple_output="output_*.txt"
par_output_resource="output_resource.txt"
meta_resources_dir="src/method"
## VIASH END

echo "> Copy resource"
cp "$meta_resources_dir/resource.txt" "$par_output_resource"

echo "> Copying input to output"
cp -r "$par_input" "$par_output"

echo "> Copying multiple inputs to multiple outputs"
IFS=";"
output_ix=0
for input in $par_multiple_input; do
  unset IFS
  output=$(echo "$par_multiple_output" | sed "s/\*/$output_ix/g")
  cp -r "$input" "$output"
  output_ix=$((output_ix + 1))
done

echo "> Done"
