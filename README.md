# Python Matrix Module #


Utilitary scripts wrote in Python

# Matrix module

Author : CABOS Matthieu

Date   : 09/07/2020

Organization : INRA-CNRS

Prerequires
-----------
Install Python 3.8 from https://www.python.org/

Install associated libraries :
 * *numpy*
 * *random*
 * *cython*
 * *sphinx*
 * *numpydoc*
 * *sphinx-autoapi*
 * *sphinx-automodapi*
 * *sphinx-rtd-theme*
 
 The librairies prerequired could be installed from the install_prerequires.sh and install_prerequires.bat 
 (depending of system : .sh is the linux style script and .bat is the windows style script)
 
Installation
------------

This repository contain my last work :
The cmatrix.pyx is the optimised version of the matrix.py library containing all standar
algebrica opeations on matrix and usefull utils (save and load, quick access, quick programming, etc...)
It contains also a sequence recognition algorithm from raw data list (found as standalone methods of the module).

To compile it write in the command prompt :
 
 **python setup.py build_ext --inplace**
 
 Once compiled, load the module in python since the current directory with :
 
 **from cmatrix import * **
 
 Documentation
 -------------
 
 The help documentation may be found using index.html or with the associated download link.
 
 You can use the Dependencies graph as Documentation summary for a better Understanding of the document.
 You have to generate it using the command:
 
 **.\make html**     (Windows users)

or

**make html**         (UNIX users)

 or download it at :  https://drive.google.com/file/d/1FrYlPV3HUc3P8KnVFtgXF4iX8yuBBDXZ/view?usp=sharing
 
I've been working on an high-performance matrix code to rule standard matrix computation
on the Anubis calculator from Lenovo (Graph transistion matrix, System resolution, etc).

The library is fully operationnal on CentOS Unix-based system, tested and approved for Windows, Linux, and MacOS

Support
-------

Please to send failure reports

support at : matthieu.cabos@tse-fr.eu
