cd tools

for i in align-to-dict generate-bow-xent generate-bow-scores; do
  g++ $i.cc -O2 -std=c++11 -o $i
done
