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
:func:`cmatrix.Matrix.same_size`
:func:`cmatrix.Matrix.size_r`
:func:`cmatrix.Matrix.size_c`
:func:`cmatrix.Matrix.get_ij`