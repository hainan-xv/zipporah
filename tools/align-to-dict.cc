#include <iostream>
#include <fstream>
#include <vector>
#include <map>
#include <sstream>
#include <math.h> 

using namespace std;

int min_count = 1;
int min_total_count = 1;

void Output(map<string, map<string, double> > d, ofstream& ofile) {
  for (map<string, map<string, double> >::iterator iter = d.begin();
                                                   iter != d.end(); iter++) {
    for (map<string, double>::iterator iter2 = iter->second.begin();
                                       iter2 != iter->second.end();
                                       iter2++) {
      ofile << iter->first << " " << iter2->first << " " << iter2->second << endl;
    }
  }
}

vector<string> Split(string input) {
  vector<string> ans;
  string word;
  stringstream ss(input);
  while (ss >> word) {
    ans.push_back(word);
  }
  return ans;
}

vector<int> SplitToInt(string input) {
  vector<int> ans;
  int word;
  stringstream ss(input);
  while (ss >> word) {
    ans.push_back(word);
  }
  return ans;
}

void PairToIndex(string str, int *a, int *b) {
  for (int i = 0; i < str.size(); i++) {
    if (str[i] == '-') {
      str[i] = ' ';
      break;
    }
  }

  vector<int> s = SplitToInt(str);
  *a = s[0];
  *b = s[1];

}

void Normalize(map<string, double> &d) {
  double normalizer = 0.0;
  for (map<string, double>::iterator iter = d.begin(); iter != d.end();) {
    if (iter->second < min_count) {
      d.erase(iter++);
      continue;
    }
    normalizer += iter->second;
//    normalizer += iter->second * iter->second;
    iter++;
  }

//  normalizer = sqrt(normalizer);

  if (normalizer < min_total_count) {
    d.clear();
    return;
  }

  for (map<string, double>::iterator iter = d.begin(); iter != d.end(); iter++) {
    iter->second /= normalizer;
  }
}

void Normalize(map<string, map<string, double> >& d) {
  for (map<string, map<string, double> >::iterator iter = d.begin();
                                                   iter != d.end();) {
    Normalize(iter->second);
    if (iter->second.size() == 0) {
      d.erase(iter++);
    } else {
      iter++;
    }
  }
}

int main(int argc, char **argv) {
  int i = 1;

  if (argc != 7) {
    cout << argv[0] << "min_count en_file fr_file align_file out_dict1 out_dict2" << endl;
    return -1;
  }

  string min_count_str = argv[i++];
  {
    stringstream ss(min_count_str);
    ss >> min_count;
  }

  string en_file = argv[i++];
  string fr_file = argv[i++];
  string align_file = argv[i++];
  string out_dict_1 = argv[i++];
  string out_dict_2 = argv[i++];

  ifstream en(en_file.c_str());
  ifstream fr(fr_file.c_str());
  ifstream align(align_file.c_str());

  map<string, map<string, double> > en_to_fr_dict;
  map<string, map<string, double> > fr_to_en_dict;

  string en_line, fr_line, align_line;
  
  int cur_line = 0;
  while (getline(en, en_line)) {
    if (cur_line % 10000 == 0) {
      cout << "processing line " << cur_line << endl;
    }
    cur_line++;

    getline(fr, fr_line);
    getline(align, align_line);

    vector<string> en_words = Split(en_line);
    vector<string> fr_words = Split(fr_line);
    vector<string> align_words = Split(align_line);
    
    for (int i = 0; i < align_words.size(); i++) {
      string aligned_pair = align_words[i];
      int a, b;
      PairToIndex(aligned_pair, &a, &b);
      string en_word = en_words[a];
      string fr_word = fr_words[b];

      map<string, map<string, double> >::iterator iter;
      {
        iter = en_to_fr_dict.find(en_word);
        if (iter == en_to_fr_dict.end()) {
          map<string, double> m;
          m[fr_word] = 1;
          en_to_fr_dict[en_word] = m;
        } else {
          iter->second[fr_word] ++;
        }
      }
      {
        iter = fr_to_en_dict.find(fr_word);
        if (iter == fr_to_en_dict.end()) {
          map<string, double> m;
          m[en_word] = 1;
          fr_to_en_dict[fr_word] = m;
        } else {
          iter->second[en_word] ++;
        }
      }
    }
  }
  Normalize(en_to_fr_dict);
  Normalize(fr_to_en_dict);

  en.close();
  fr.close();
  align.close();

  ofstream ofile1(out_dict_1.c_str());
  ofstream ofile2(out_dict_2.c_str());

  Output(en_to_fr_dict, ofile1);
  Output(fr_to_en_dict, ofile2);




}
