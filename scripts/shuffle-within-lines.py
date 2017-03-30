import sys
import random

for line in sys.stdin:
  words = line.split()

  random.shuffle(words)

  for word in words:
    print word,

  print ""
  
