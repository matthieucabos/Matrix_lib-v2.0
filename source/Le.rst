Le function
===========

Genericity polymorphism 'le' function

=============== ================ =======================================
**Parameters**   *type*           **Description**
*mat*            Matrix           The matrix to test
=============== ================ =======================================

Examples
--------
>>> m=rand(4)
>>> n=rand(3)
>>> print(n<=m)
True
>>> print(m<=n)
False

Returns
-------
	bint
		Return the test less or equal between the length of the self matrix and the length of mat argument.

See Also
--------
cmatrix.len