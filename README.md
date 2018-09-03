# PlenCalToolbox
A toolbox for the calibration of plenoptic cameras accompanying the paper "Calibrating Focused Light-Field Cameras Using Plenoptic Disc Features" published at 3DV2018.

This code was tested on Matlab 2016a. Results may vary in other versions of Matlab due to changes to the checker-board detector in different versions. 

Datasets are available here:

Dataset R-A : https://cloudstor.aarnet.edu.au/plus/s/hjx3KRbPL5rYQ6X
Dataset R-B : https://cloudstor.aarnet.edu.au/plus/s/gPh38jHOfkH3M2X
Dataset R-C : https://cloudstor.aarnet.edu.au/plus/s/lcBuDAxuQiGZ55j

To test the code with these datasets, 
1. Create a subdirectory of the `data' directory called `Dataset_R_X', where X is A B or C depending on which dataset was downloaded.
2. Place all the raw images of the corresponding dataset into this directory.
3. Run the script files calibration_R_X.m , where X is A B or C to run through the code. 

The entire process may take up to 30 minutes. Percentage counters have been added into the code and these progress counters will be printed to the console. The error results are printed at the very end of the calibration process. 
