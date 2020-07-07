Getitem function
================

Genericity polymorphism 'getitem' function.

=============== ================ ======================================================
**Parameters**   **type**        **Description**
*key*            tuple            i,j values
*key*            tuple of tuple   (i,j),(k,l) values (in case of submatrix extraction)
=============== ================ ======================================================

Returns
-------
	double
		The (i,j) item from the self Matrix

	Matrix
		the (i,j) => (k,l) sub matrix extracted from self Matrix

Examples
--------
>>> m=rand(4)
>>> print(m)
| +9.000 | +13.000 | +5.000 | +15.000 |
| +12.000 | +6.000 | +5.000 | +4.000 |
| +2.000 | +5.000 | +4.000 | +2.000 |
| +15.000 | +15.000 | +8.000 | +9.000 |
printed
>>> m[0,0]
9.0
>>> print(m[(0,0),(2,2)])
| +9.000 | +13.000 |
| +12.000 | +6.000 |
printed                                   

See Also
--------
:func:`cmatrix.Matrix.get_ij`
:func:`cmatrix.Matrix.xtract_sub_matrix`