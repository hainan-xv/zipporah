#include <iostream>
#include <fstream>
#include <unordered_map>
#include <vector>
#include <string>
#include <sstream>
#include <map>
#include <assert.h>

using namespace std;

struct TransProb {
  TransProb(string w, double p):
    word(w), prob(p) {}
  string word;
  double prob;
};

vector<string> Split(string input) {
  vector<string> ans;
  string word;
  stringstream ss(input);
  while (ss >> word) {
    ans.push_back(word);
  }
  return ans;
}

double ToDouble(string input) {
  stringstream ss(input);
  double ans = 0;
  ss >> ans;
  return ans;
}

unordered_map<string, vector<TransProb> > GetTable(istream &input) {
  unordered_map<string, vector<TransProb> > ans;

  string line;
  while (getline(input, line)) {
    vector<string> words = Split(line);
    string key = words[0];
    string value = words[1];
    double prob = ToDouble(words[2]);

    if (ans.find(key) != ans.end()) {
      ans[key].push_back(TransProb(value, prob));
    } else {
      ans[key] = vector<TransProb>();
      ans[key].push_back(TransProb(value, prob));
    }
  }

/*
  for (unordered_map<string, vector<TransProb> >::iterator iter = ans.begin();
                                                           iter != ans.end();
                                                           iter++) {
    double sum = 0.0;
    for (size_t i = 0; i < iter->second.size(); i++) {
      cout << iter->first << ": " << iter->second[i].word << ", " << iter->second[i].prob << endl;
      sum += iter->second[i].prob;
    }
    cout << "sum is " << sum << endl;
  }
// */
  return ans;
}

void DoTranslate(const unordered_map<string, vector<TransProb> >&table,
                 istream& input) {
  string line;
  int lines_processed = 0;
  while (getline(input, line)) {
    map<string, double> ans;
    vector<string> words = Split(line);

//    int n_words = words.size();
//    n_words = 1; // not normalizing here...
    for (size_t i = 0; i < words.size(); i++) {
      const unordered_map<string, vector<TransProb> >::const_iterator
        iter = table.find(words[i]);
      if (iter == table.end()) {
        // OOV, words not apperaing in the lex
//        ans["OOOOOOOOV"] = ans["OOOOOOOOV"] + 1.0;
        ans[words[i]] += 1.0;
        continue;
      }

      const vector<TransProb>& t = iter->second;

      for (size_t j = 0; j < t.size(); j++) {
//        ans[t[j].word] += t[j].prob / n_words;
        ans[t[j].word] += t[j].prob;
//        cout << "adding proba " << t[j].prob << endl;
      }
    }

    for (map<string, double>::iterator iter = ans.begin();
                                       iter != ans.end();
                                       iter++) {
      cout << iter->first << " " << iter->second << " ";
    }
    cout << endl;
    /*
    if (lines_processed++ % 1000 == 999) {
      cerr << "processing line: " << lines_processed << endl;
    }
    //*/
  }
}

int main(int argc, char** argv) {
  if (argc != 3) {
    cerr << argv[0] << " table-file file-to-translate" << endl
         << endl
         << argv[0] << " requires 3 parameters; got instead " << argc << endl;
    return -1;
  }

  string table_file = argv[1];
  string file_to_translate = argv[2];

  if (table_file == "-" && file_to_translate == "-") {
    cerr << "Can not have stdin for both inputs" << endl;
    return -1;
  }

  unordered_map<string, vector<TransProb> > table;

  cerr << "# Starting Reading Table" << endl;

  if (table_file == "-") {
    table = GetTable(cin);
  } else {
    ifstream ifile(table_file);
    table = GetTable(ifile);
  }

  cerr << "# Starting Translation" << endl;

  if (file_to_translate == "-") {
    DoTranslate(table, cin);
  } else {
    ifstream ifile(file_to_translate);
    DoTranslate(table, ifile);
  }
  return 0;
}
