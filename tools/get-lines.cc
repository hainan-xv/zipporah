#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <string>

using namespace std;

int main(int argc, char **argv) {
  if (argc != 3) {
    cout << argv[0] << " line_file text_file # lines are 0-based" << endl;
    return -1;
  }
  ifstream lines_file(argv[1]);
  ifstream text_file(argv[2]);

  vector<int> lines;
  int line;
  while (lines_file >> line) {
    lines.push_back(line);
  }

  sort(lines.begin(), lines.end());

  int cur_line_in_text = 0;

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
