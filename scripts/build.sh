#!/bin/bash

set -e

# build component
rm -r target && viash ns build --parallel --setup cb