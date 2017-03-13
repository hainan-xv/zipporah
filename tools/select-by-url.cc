#include <iostream>
#include <string>
#include <map>
#include <vector>
#include <fstream>

using namespace std;

int main(int argc, char** argv) {
  int i = 1;


  if (argc != 7) {
    cerr << argv[0] << " "
         << "bad_url all_pasted all_score all_url out_pasted out_score" << endl
         << "got  " << argc << " arguments" << endl;
    
    return -1;
  }

  string bad_url_file = argv[i++];

  string all_pasted_file = argv[i++];
  string gmm_score_file = argv[i++];
  string all_url_file = argv[i++];

  string out_pasted_file = argv[i++];
  string out_score_file = argv[i++];

  ifstream bad_url_in(bad_url_file.c_str());

  string line;
  map<string, int> bad_urls;
  while (getline(bad_url_in, line)) {
    bad_urls[line] = 1;
  }
  bad_url_in.close();

  ifstream pasted_in(all_pasted_file.c_str());
  ifstream gmm_in(gmm_score_file.c_str());
  ifstream url_in(all_url_file.c_str());

  ofstream pasted_out(out_pasted_file.c_str());
  ofstream gmm_out(out_score_file.c_str());

  string line_pasted, line_url, line_gmm;
  while (getline(pasted_in, line_pasted)) {
    getline(url_in, line_url);
    getline(gmm_in, line_gmm);

    if (bad_urls.find(line_url) != bad_urls.end()) {
      // discard since its source might be bad
      continue;
    }

    // now we know it's not from a "bad" source

    pasted_out << line_pasted << endl;
    gmm_out << line_gmm << endl;
  }

  pasted_in.close();
  gmm_in.close();
  url_in.close();
  pasted_out.close();
  gmm_out.close();

}
