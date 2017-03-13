#include <iostream>
#include <cstdlib>
#include <time.h>
using namespace std;

int main(int argc, char** argv) {
  srand (time(NULL));

  if (argc != 3) {
    cout << argv[0] << " " << "n k # n >= k; output is 0-based" << endl;
    return -1;
  }

  int n, k;
  n = atoi(argv[1]);
  k = atoi(argv[2]);

  if (n < k) {
    cout << "n should not be less than k!" << endl;
    return -2;
  }

  int *v = new int[n];
  for (int i = 0; i < n; i++) {
    v[i] = i;
  }

//  for (int i = 0; i < n; i++) {
  for (int i = 0; i < k; i++) { // I feel like this is OK too
    int s = rand() % (n - i);
    swap(v[i], v[s]);
  }

  for (int i = 0; i < k; i++) {
    cout << v[i] << endl;
  }
}
