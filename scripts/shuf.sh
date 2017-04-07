#!/bin/bash

input="-"

all=`cat $input`

n=`echo "$all" | wc -l | awk '{print $1}'`

#echo "$all"
#echo num-lines is $n

half=`echo $n | awk '{print int($1/2)}'`

head=`echo "$all" | head -n -$half  | shuf`
tail=`echo "$all" | tail -n $half | shuf`

echo "$tail"
echo "$head"
