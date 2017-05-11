# zipporah

git clone https://github.com/hainan-xv/zipporah.git

cd zipporah

./make.sh

change the config file; an example is configs/test
- will need the "working directory" as $working
- will need the zipporah location as $ROOT
- also need moses and srilm paths, but can keep it as it is on the CLSP grid
- need clean_stem_good or raw_stem_good
- need clean_stem_bad or raw_stem_bad
- need clean_stem_dev or raw_stem_dev

then ./run.sh [config-file] would run the data selection and generate a score file in
$working/$experiment_id/step-4/bad/corpus.xz

./run.sh supports more arguments 
- ./run.sh config-file experiment-id would force to use the experiment-id argument
- ./run.sh config-file experiment-id stage would start at a specific stage

There are 4 stages in the system, see scripts/[1234].sh
- 1.sh processes good data and dev data
- 2.sh processes bad data
- 3.sh computes the features on all data
- 4.sh trains the logistic regression model and computes scores
