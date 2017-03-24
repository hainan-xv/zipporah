#include <iostream>
#include <fstream>
#include <vector>
#include <map>
#include <sstream>
#include <math.h> 
#include <assert.h>


using namespace std;

int min_count = 5;
int min_total_count = 100;

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

//int Normalize(map<string, double> &d, double normalizer) {
//  // returns the sum of numerator
//  int sum = 0;
//  normalizer = sqrt(normalizer);
//
//  if (normalizer < min_total_count) {
//    d.clear();
//    return 0;
//  }
//
//  for (map<string, double>::iterator iter = d.begin(); iter != d.end(); iter++) {
//    sum += iter->second;
//    iter->second /= normalizer;
//  }
//
//  return sum;
//}
//
//void Normalize(map<string, map<string, double> >& d, map<string, double> &counts) {
//  for (map<string, map<string, double> >::iterator iter = d.begin();
//                                                   iter != d.end();) {
//    double count = 0;
//    auto iter2 = counts.find(iter->first);
//    assert(iter2 != counts.end());
//    count = iter2->second;
//    iter2->second = Normalize(iter->second, count);
//    if (iter->second.size() == 0) {
//      d.erase(iter++);
//    } else {
//      iter++;
//    }
//  }
//}

void Output(map<string, map<string, double> > &d,
            map<string, double> &w_c,
            map<string, double> &a_c,
            ofstream& ofile) {
  for (map<string, map<string, double> >::iterator iter = d.begin();
                                                   iter != d.end(); iter++) {
    double word_count = w_c[iter->first];

    if (word_count < min_total_count) {
      continue;
    }
    double align_count = a_c[iter->first];
    for (map<string, double>::iterator iter2 = iter->second.begin();
                                       iter2 != iter->second.end();
                                       iter2++) {
      ofile << iter->first << " " << iter2->first << " "
            << iter2->second / word_count << " "
            << align_count * 1.0 / word_count << endl;
    }
  }
}

int main(int argc, char **argv) {
  int i = 1;

  if (argc != 8) {
    cout << argv[0] << " min_count min-total-count en_file fr_file align_file out_dict1 out_dict2" << endl;
    return -1;
  }

  string min_count_str = argv[i++];
  {
    stringstream ss(min_count_str);
    ss >> min_count;
  }
  string min_tot_count_str = argv[i++];
  {
    stringstream ss(min_tot_count_str);
    ss >> min_total_count;
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

  map<string, double> en_word_counts;
  map<string, double> fr_word_counts;

  map<string, double> en_align_counts;
  map<string, double> fr_align_counts;

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

    for (int i = 0; i < en_words.size(); i++) {
      en_word_counts[en_words[i]] ++;
    }

    for (int i = 0; i < fr_words.size(); i++) {
      fr_word_counts[fr_words[i]] ++;
    }
    
    for (int i = 0; i < align_words.size(); i++) {
      string aligned_pair = align_words[i];
      int a, b;
      PairToIndex(aligned_pair, &a, &b);

      string en_word = en_words[a];
      string fr_word = fr_words[b];

      en_align_counts[en_word] ++;
      fr_align_counts[fr_word] ++;

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

//  Normalize(en_to_fr_dict, en_word_counts);
//  Normalize(fr_to_en_dict, fr_word_counts);

  en.close();
  fr.close();
  align.close();

  ofstream ofile1(out_dict_1.c_str());
  ofstream ofile2(out_dict_2.c_str());

  Output(en_to_fr_dict, en_word_counts, en_align_counts, ofile1);
  Output(fr_to_en_dict, fr_word_counts, fr_align_counts, ofile2);

}
