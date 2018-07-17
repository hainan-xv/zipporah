# zipporah

The method of this toolkit is decribed in the paper "Zipporah: a Fast and Scalable Data Cleaning System
for Noisy Web-Crawled Parallel Corpora."

If you have question, feel free to email me at hainan.xv AT gmail Dot com. I left my JHU email in the paper however it seems to classify some of the query emails as spam. 

### Step 1,
```
$> git clone https://github.com/hainan-xv/zipporah.git
$> cd zipporah
$> git checkout paper-version
$> ./make.sh
```

### Step 2,
Change the config file; an example is `configs/test`. First you need to change the following variables,
```
working=/your/working/directory/
ROOT=/your/path/to/zipporah/
moses=your/path/to/mosesdecoder/
srilm=your/path/to/srilm/   # for branch paper-version only
```

### Step 3,
Provide the location for your corpus. We need good/dev/bad-corpus variables set. The meaning of those corpora are,
- "bad" corpus refers to the data you want to filter on;
- "good" corpus refers to the "training data" described in the paper. We recommend that you use a large and clean corpus for this, e.g. Europarl
- "dev" corpus refers to the "dev data" in the paper. We recommend that you use a clean corpus for this, and a size of 2000-3000 parallel sentence pairs is sufficient.

Have either

```
raw_stem_bad=your/raw//data/that/you/want/to/clean
raw_stem_good=your/raw/train/data
raw_stem_dev=your/raw/dev/data
```
or
```
clean_stem_bad=your/tokenized/and/truecased/data/that/you/want/to/clean
clean_stem_good=your/tokenized/and/truecased/train/data
clean_stem_dev=your/tokenized/and/truecased/dev/data
```

The `*stem_good/*stem_bad` variables should be a prefix of text files. For example, if `clean_stem_dev` is `/home/user/newstest` and `input/output-lang` are `es/en`, then the system would look for file `/home/user/newstest.es` and `/home/user/newstest.en` and use them as the "dev data".

The word "clean" or "raw" would indicate whether the corpus is tokenized and truecased. If it's raw, then Zipporah would try to tokenize and truecase them; if "clean" is provided then Zipporah would start processing them directly.

### Step 4, 
```
$> ./run.sh [config-file]
```

would run the data selection and generate a score file in
`$working/$experiment_id/step-4/bad/corpus.xz`

(experiment_id will be an integer starting from 0; if a directory n is already
there, then experiment_id will become n+1)

`./run.sh` supports more arguments 
- `./run.sh config-file experiment-id` would force to use the experiment-id argument
- `./run.sh config-file experiment-id` stage would start at a specific stage

There are 4 stages in the system, see `scripts/[1234].sh`
- 1.sh processes good data and dev data
- 2.sh processes bad data
- 3.sh computes the features on all data
- 4.sh trains the logistic regression model and computes scores

Common issues:

1. The system assumes you have GridEngine installed and you are running the system on a grid. If not, you might get errors complaining about qsub not being installed. If that happens, you can change the "queue.pl" file to this file instead (`https://github.com/kaldi-asr/kaldi/blob/master/egs/wsj/s5/utils/parallel/run.pl`, just copy the content of this file and override the old queue.pl file and no other changes are needed. Thanks Kaldi developers for writing this wrapper), and then the system would run locally. If you need to make this change, you may also want to change all the number of jobs config to 1 to avoid overloading your machine.
2. You would need to pre-install Moses (`https://github.com/moses-smt/mosesdecoder`). We use a number of commands in Moses and you might need to change the paths if the system complains about */mosesdecoder/* commands, e.g. fast_align and kenlm.
3. Right now there seems to be a bug regarding providing trained truecasers. I prepared a fix at branch "fix-truecaser-bug" which I think should fix the issue but this has not been extensively tested. If you want to use your custom truecaser you can use that branch. I will try to merge it when it's fully tested. If you want Zipporah to train the truecaser automatically, you can use branch "paper-version", which is bug-free and is the version we used in the paper. The newer version, however, seems to perform slightly better than the paper-version.
