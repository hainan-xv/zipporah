#!/bin/python

import sys
import datetime
import math
from collections import OrderedDict

def similarity(sent1, sent2, smoothing_constant):
  words1 = sent1.split()
  words2 = sent2.split()

  count1 = {}

  normalizer1 = 0.0
  for i in range(len(words1) / 2):
    word = words1[2 * i]
    c = words1[2 * i + 1]
    count1[word] = count1.get(word, 0) + float(c)
    normalizer1 = normalizer1 + float(c)

  count2 = {}
  normalizer2 = 0.0
  for word in words2:
    count2[word] = count2.get(word, 0) + 1.0
    normalizer2 = normalizer2 + 1.0


  if normalizer1 == 0.0:
    return 999

  ans = 0

  for word in count2:
#    ans = ans + (count2[word] - count1.get(word, 0)) * (count2[word] - count1.get(word, 0))
    ans = ans + (count2[word] / normalizer2) * math.log((count2[word] / normalizer2) / ((count1.get(word, 0) / normalizer1) + smoothing_constant))

#    length2 = length2 + count2[word] * count2[word]
#  length2 = math.sqrt(length2)
#  print "lengths are ", length1, length2

  return ans

def main():
  argv = sys.argv[1:]

  file1 = argv.pop(0)
  file2 = argv.pop(0)
  smoothing_constant = float(argv.pop(0))

  if file1 == '-':
    f1 = sys.stdin
  else:
    f1 = open(file1, 'r')
  f2 = open(file2, 'r')

  for line1 in f1:
#    print "read line", line1
    line2 = f2.readline()
#    print "read line", line2
    print similarity(line1, line2, smoothing_constant)

if __name__ ==  "__main__":
  main()

    

