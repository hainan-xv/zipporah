#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <string>
#include <sstream>

using namespace std;

int StringToInt(string in) {
  int res;
  stringstream ss(in);
  ss >> res;
  return res;
}

int NumWords(const string &in) {
  stringstream ss(in);
  string tmp;
  int ans = 0;
  while (ss >> tmp) {
    ans++;
  }
  return ans;
}

int main(int argc, char **argv) {
  if (argc != 4) {
    cout << argv[0] << " line_file text_file num_words_limit # lines are 0-based" << endl;
    return -1;
  }

  vector<int> line_to_num_words;

  int limit = StringToInt(argv[3]);

  ifstream lines_file(argv[1]);
  {
    ifstream text_file(argv[2]);
    string sent;
    while (getline(text_file, sent)) {
      line_to_num_words.push_back(NumWords(sent));
    }
  }

  int word_count = 0;

  vector<int> lines;
  int line;
  while (lines_file >> line) {
    int to_add = line_to_num_words[line];
    if (word_count + to_add > limit) {
      break;
    }
    lines.push_back(line);
    word_count += to_add;
  }

  sort(lines.begin(), lines.end());

  int cur_line_in_text = 0;

  ifstream text_file(argv[2]);
  string sent;
  getline(text_file, sent);
  for (int i = 0; i < lines.size(); i++) {
    while (cur_line_in_text != lines[i]) {
      cur_line_in_text++;
      getline(text_file, sent);
    }
    cout << sent << endl;
  }
}
