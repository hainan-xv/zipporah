#!/bin/bash

config=$1
input=$2
output=$3

. $config

echo $moses/tools/fast_align -i $input -d -o -v
$moses/tools/fast_align -i $input -d -o -v > $output.forward

echo $moses/tools/fast_align -i $input -d -o -v -r
$moses/tools/fast_align -i $input -d -o -v -r > $output.backward

echo $moses/tools/atools -i $output.forward -j $output.backward -c grow-diag-final-and
$moses/tools/atools -i $output.forward -j $output.backward -c grow-diag-final-and > $output
