# Python Matrix Module #


Utilitary scripts wrote in Python

# Matrix module

Author : CABOS Matthieu

Date   : 30/06/2020

This repository contain my current works in progress :
The cmatrix.pyx is the optimised version of the matrix.py library containing all standard
algebrica opeations on matrix and usefull utils (save and load, quick access, quick programming, etc...)
 To compile it write in the command prompt :
 
 python setup.py build_ext --inplace
 
 The help documentation may be found using index.html
 You have to generate it using the command:
 
 make html
 
I've been working on an high-performance matrix code to rule many of standard calculation
on the Anubis calculator (Graph transistion matrix, System resolution, etc) from Lenovo.

The library is fully operationnal on CentOS Unix-based system

Please to send failure reports

support at : matthieu.cabos@tse-fr.eu
