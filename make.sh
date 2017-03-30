cd tools

#for i in bow-translation lex-prune get-rand-index get-lines get-lines-by-words select-by-url \
#      align-to-dict compute-avg-score generate-bow-scores; do
##  echo g++ $i.cc -O2 -std=c++11 -o $i
#  g++ $i.cc -O2 -std=c++11 -o $i
##  g++ $i.cc -g -std=c++11 -o $i
#done

for i in align-to-dict generate-bow-xent generate-bow-scores; do
#  echo g++ $i.cc -O2 -std=c++11 -o $i
#  g++ $i.cc -O2 -std=c++11 -o $i
  g++ $i.cc -O2 -std=c++11 -o $i
#  g++ $i.cc -g -std=c++11 -o $i
done
