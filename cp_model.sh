#!/bin/bash

working=$1
from=$2
to=$3

if [ "$#" != 3 ]; then
  echo wrong number of parameters, need 3 but got $#
  echo $0 working-dir from-id to-id
  exit 1
fi

cd $working

if [ -d $to ]; then
  echo $working/$to already exists
  exit 1
fi

mkdir $to

cd $to/

ln -s ../$from/step-1
