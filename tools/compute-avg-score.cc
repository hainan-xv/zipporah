#include <iostream>
#include <string>
#include <map>

using namespace std;

int main(int argc, char **argv) {
  string url1, url2;
  double score;
  map<string, double> sum;
  map<string, int> count;

  while (cin >> url1 >> url2 >> score) {
    string key = url1 + " " + url2;

    sum[key] += score;
    count[key] += 1;
  }
  
  for (map<string, double>::iterator iter = sum.begin(); iter != sum.end(); iter++) {
    string key = iter->first;
    double score = iter->second;
    score = score / count[key];
    
    cout << key << "\t" << score << endl;
  }
}
