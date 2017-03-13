#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <map>
#include <assert.h>
#include <cstring>
#include <vector>

using namespace std;

void Similarity(const vector<string> &en_words, const vector<string> &fr_words,
                const map<string, double> &unigram_en, 
                const map<string, double> &unigram_fr,
                const map<string, vector<pair<string, double> > > &lex);

vector<string> Split(string input) {
  vector<string> ans;
  string word;
  stringstream ss(input);
  while (ss >> word) {
    ans.push_back(word);
  }
  return ans;
}

double abs(double i) {
  if (i >= 0) return i;
  return -i;
}

int main(int argc, char** argv) {
  if (argc != 5) {
    cerr << argv[0] << " lex.e2f unigram-count.en corpus.en corpus.fr" << endl;
    return -1;
  }


  // read lex table
  map<string, double> lex;
  {
    ifstream ifile;
    if (strcmp(argv[1], "-") != 0) {
      ifile.open(argv[1]);
    }
    istream& input = (strcmp(argv[1], "-") == 0) ? cin : ifile;

    string a, b;
    double prob;
    while (input >> a >> b >> prob) {
      lex[a + " " + b] = prob;
    }
  }

  // read unigram-counts and generate en unigram
  map<string, double> unigram_en;
  {
    ifstream ifile;
    if (strcmp(argv[2], "-") != 0) {
      ifile.open(argv[2]);
    }
    istream& input = (strcmp(argv[2], "-") == 0) ? cin : ifile;

    string word;
    double count;
    double total = 0;
    while (input >> count >> word) {
      unigram_en[word] = count;
      total += count;
    }

    double check = 0.0;
    for (auto iter = unigram_en.begin(); iter != unigram_en.end(); iter++) {
      iter->second /= total;
      check += iter->second;
    }

    assert(abs(1 - check) < 0.01);
  }

  // generate unigram for fr
  map<string, double> unigram_fr;
  for (auto iter = lex.begin(); iter != lex.end(); iter++) {
    string fr, en;
    {
      stringstream ss(iter->first);
      ss >> fr >> en;
      unigram_fr[fr] += iter->second * unigram_en[en];
    }
  }

  {
    double prob_total = 0.0;
    for (auto iter = unigram_fr.begin(); iter != unigram_fr.end(); iter++) {
      prob_total += iter->second;
    }

  //  cout << "prob total is " << prob_total << endl;
    assert(abs(1 - prob_total) < 0.01);
  }

  map<string, vector<pair<string, double> > > new_lex; // for more efficient computation
  for (auto iter = lex.begin(); iter != lex.end(); iter++) {
    string fr, en;
    {
      stringstream ss(iter->first);
      ss >> fr >> en;

      auto i = new_lex.find(en);
      if (i == new_lex.end()) {
        vector<pair<string, double> > j;
        j.push_back(make_pair(fr, iter->second));
        new_lex[en] = j;
      } else {
        i->second.push_back(make_pair(fr, iter->second));
      }
    }
  }

  ifstream en_file(argv[3]), fr_file(argv[4]);
  string en_sent, fr_sent;
  while (getline(en_file, en_sent)) {
    getline(fr_file, fr_sent);
    vector<string> en_words, fr_words;
    en_words = Split(en_sent);
    fr_words = Split(fr_sent);
    Similarity(en_words, fr_words, unigram_en, unigram_fr, new_lex);
  }

}

void Similarity(const vector<string> &en_words, const vector<string> &fr_words,
                const map<string, double> &unigram_en, 
                const map<string, double> &unigram_fr,
                const map<string, vector<pair<string, double> > > &lex) {
  map<string, double> translation;
  map<string, double> french;

  for (auto i: fr_words) {
    auto iter = unigram_fr.find(i);
    if (iter != unigram_fr.end()) {
      french[i] += iter->second;
    }
  }
  
  for (auto w: en_words) {
    auto iter = lex.find(w);
    if (iter == lex.end()) {
      continue;
    }

    const vector<pair<string, double> > &translation_table = iter->second;
    
    auto iter2 = unigram_en.find(w);
    if (iter2 == unigram_en.end()) {
      continue;
    }

    double uni_prob = iter2->second;
    for (auto i: translation_table) {
      const string &fr_word = i.first;
      double trans_prob = i.second;

      translation[fr_word] += uni_prob * trans_prob;
    }
  }

  for (auto kv: french) {
    const string &word = kv.first;
    double prob = kv.second;
    translation[word] -= prob;
  }

  double ans = 0;
  for (auto kv: translation) {
    ans += kv.second * kv.second;
  }
  cout << ans << endl;
}
