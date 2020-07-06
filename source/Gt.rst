Gt function
===========

Genericity polymorphism 'gt' function

=============== ================ =======================================
**Parameters**   *type*           **Description**
*mat*            Matrix           The matrix to test
=============== ================ =======================================

Returns
-------
	bint
		Return the test greater than between the length of the self matrix and the length of mat argument.

Examples
--------
>>> m=rand(4)
>>> n=rand(3)
>>> print(m>n)
True
>>> print(n>m)
False			