![](https://spinati.com/wp-content/uploads/2015/03/logo-cnrs.png)

# Python Matrix Module #

# Matrix module

**Author** : *CABOS Matthieu*

**Release Date**   : *23/09/2020*

**Organization** : *INRAE-CNRS*

______________________________________________________________________________________________________

This repository contain my optimized Python Matrix lib..

The cmatrix.pyx is the cythonized version of the matrix.py library containing all standard
algebrica operations on matrix and usefull utils (save and load, quick access, quick programming, etc...)

## Description


Welcome in the CMatrix Module. This module, written with python and Cython, is as fast as a c/c++ Librairie file. It has been thinked for Matrix complex computation. This Module have been splitted into three main parts :

* **A Matrix Generators Section**
		The Matrix Generators section permit to generate automatically standard algebrica matrix as :

 	* **A Laplacian mean Matrx**
	* **A Gaussian mean Matrix**
	* **A Mean filter Matrix**
	* **A Random Permutation Matrix**
	* **A Unit Matrix**
	* **A Zeros Matrix**

* **A Sequence Recognition Section**
		This Sequence Recognition Algorithm permit us to find in any list any repeated sequence from **nothing** .
		This Algorithm is splitted into 10 functions : 1 main algorithm and 9 sub-function.
		The main algorithm function name is find_mul_seq, meaning Find Multiples Seqneces function.
		The 9 sub-functions used to make it works are :

	* **count_seq** : A sequence counter
	* **create_mutants** : A list mutants generator function
	* **cut** : A list cutter function
	* **find_invariant** : An invariant finder function
	* **find_max** : Get the max length list function
	* **find_seq** : A sequence finder function
	* **find_seq_in_list** : An advanced sequence finder function
	* **split_data** : Data splitter function
	* **split_number** : A number splitter function

* **The Main Matrix Engine**
		The main matrix engine define an new Matrix Object into your Python code.
		This matrix should be extracted and readed from :

	* **Pictures**
	* **Video**
	* **Signals**
	* **Float and Int matrix**
	* **etc**
		
	It contains differents kind of function :

	* Primary utility functions as Ribbon converter, usual operators, ...
	* Middle level functions as Matrix extraction/recognition, usuals algebrica operations, ...
	* Hard level functions as Strassen algorithm, Convolutions, System resolution, Tensorial operations, ...

To read a matrix from an external file, you can use the Matrix Getter py file into the main github repository to extract and use any matrix with this lib.

The full description of each part is avaible on the left tree entries of the documentation.
All the functions are documented and a small example will be used as an Usage Guide.

## Setup

To setup manually :

* Install all prerequires as following :

  * Get python3.8 from www.python.org
  * pip install sphinx
  * pip install numpy
  * pip install random
  * pip install cython
  * pip install sphinxcontrib-napoleon
  * pip install sphinx-autoapi
  
To compile it write in the command prompt :
 ```bash
 python setup.py build_ext --inplace
```
 And use it in Python with standard command
  ```python
 import cmatrix
  ```
 The help documentation may be found at : https://matrix-lib-v20.readthedocs.io/en/latest/
 
 Or compile it on your local computer using
  ```bash
 make html
  ```
I've been working on an high-performance matrix code to rule many of standard calculation
on the Anubis calculator (Graph transistion matrix, System resolution, etc) from Lenovo.

The library is fully operationnal on CentOS Unix-based system

## Matrix Convertor

The Matrix_convertor script can be used to convert a Matrix from the cmatrix to another Format. 

Each converion is reversible except in pdf format. 

Avaible conversion formats are :
* **List** : via the Matrix2List* and reverse *List2Matrix*methods
* **Numpy Array** : via the *Matrix2Numpy* and reverse *Numpy2Matrix* methods
* **Pandas DataFrame** : via the *Matrix2Panda* and reverse *Panda2Matrix* methods
* **Office Ods file** : via the *Matrix2Ods* and reverse *Ods2Matrix* methods
* **Excel Xlsx file** : via the *Matrix2xlsx* and reverse *xlsx2Matrix* methods
* **Latex file** : via the *Matrix2tex* and reverse *tex2Matrix* methods
* **Picture Png file** : via the *Matrix2png* and reverse *png2Matrix* methods
* **Pdf file** : via the *Matrix2pdf* method
	
To install requirements, please to use the following command :

```bash
./Install_Requirements.sh
```

To use, just import the file using the command

```python
from Matrix_convertor import *
```

## Support

Please to send failure reports

support at : matthieu.cabos@tse-fr.eu
