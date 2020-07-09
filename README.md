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
 
 The help documentation may be found using index.html or with the associated download link
 You have to generate it using the command:
 
 make html
 
 or download it at :  https://drive.google.com/file/d/1Qd9Dew-D46k1ZAu1qyLlGMLjzUaCiCcl/view?usp=sharing
 
I've been working on an high-performance matrix code to rule standard matrix computation
on the Anubis calculator from Lenovo (Graph transistion matrix, System resolution, etc).

The library is fully operationnal on CentOS Unix-based system, tested and approved for Windows, Linux, and MacOS

Please to send failure reports

support at : matthieu.cabos@tse-fr.eu
