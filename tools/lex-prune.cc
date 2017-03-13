#include <iostream>
#include <fstream>
#include <map>
#include <string>
#include <sstream>
#include <cstring>

using namespace std;

int main(int argc, char** argv) {
  if (argc != 3) {
    cerr << argv[0] << " lex-file thresh" << endl;
    return -1;
  }

  double thresh;
  {
    stringstream ss(argv[2]);
    ss >> thresh;
  }

  ifstream ifile;
  if (strcmp(argv[1], "-") != 0) {
    ifile.open(argv[1]);
  }
  istream& input = (strcmp(argv[1], "-") == 0) ? cin : ifile;

  map<string, double> lex;
  map<string, double> normalizer;

  string a, b;
  double prob;
  while (input >> a >> b >> prob) {
    if (prob < thresh) {
      continue;
    }
    lex[a + " " + b] = prob;
    normalizer[b] += prob;
  }

//  for (map<string, double>::iterator iter = normalizer.begin(); 
//                                     iter != normalizer.end(); iter++) {
//    cout << "normalizer " << iter->first << " " << iter->second << endl;
//  }

  for (map<string, double>::iterator iter = lex.begin(); iter != lex.end(); iter++) {
    string a, b;
    {
      stringstream ss(iter->first);
      ss >> a >> b;
    }
    cout << iter->first << " " << iter->second / normalizer[b] << endl;
  }
  return 0;
}

