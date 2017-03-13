#!/bin/bash

config=$1
input=$2
output=$3

. $config

$moses/tools/fast_align -i $input -d -o -v > $output
