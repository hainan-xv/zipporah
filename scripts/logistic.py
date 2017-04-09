#!/usr/bin/python

import sys
import matplotlib.pyplot as plt
import numpy as np
from sklearn import linear_model, datasets

train_data  = sys.argv[1]
train_label = sys.argv[2]
test_data   = sys.argv[3]
#test_label  = sys.argv[4]
output_txt  = sys.argv[4]

X = np.loadtxt(train_data)
Y = np.loadtxt(train_label)

devX = np.loadtxt(test_data)
#devY = np.loadtxt(test_label)

logreg = linear_model.LogisticRegression(C=1e5)

logreg.fit(X, Y)

Z = logreg.decision_function(devX)

np.savetxt(output_txt, Z, "%s")
