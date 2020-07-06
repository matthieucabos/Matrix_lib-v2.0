Eq function
===========

Genericity polymorphism 'eq' function

=============== ================ =======================================
**Parameters**   *type*           **Description**
*mat*            Matrix           The matrix to test
=============== ================ =======================================

Returns
-------
	bint
		Return the test of equality between the self matrix and the mat argument.

Examples
--------
>>> m=rand(3)
>>> n=m.clone()
>>> print(m==n)
True

See Also
--------
cmatrix.same_size, cmatrix.size_r, cmatrix.size_c, cmatrix.get_ij