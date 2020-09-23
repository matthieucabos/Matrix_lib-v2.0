# Python Matrix Module #


Utilitary scripts wrote in Python

# Matrix module

Author : CABOS Matthieu

Date   : 30/06/2020

This repository contain my current works in progress.

The cmatrix.pyx is the optimised version of the matrix.py library containing all standard
algebrica opeations on matrix and usefull utils (save and load, quick access, quick programming, etc...)

Setup
-----

To compile it write in the command prompt :
 
 **python setup.py build_ext --inplace**
 
 And use it in Python with
 
 **from cmatrix import ***
 
 The help documentation may be found at : https://matrix-lib-v20.readthedocs.io/en/latest/
 
 Or compile it on your local computer using
 
 **make html**
 
I've been working on an high-performance matrix code to rule many of standard calculation
on the Anubis calculator (Graph transistion matrix, System resolution, etc) from Lenovo.

The library is fully operationnal on CentOS Unix-based system

Support
-------

Please to send failure reports

support at : matthieu.cabos@tse-fr.eu
