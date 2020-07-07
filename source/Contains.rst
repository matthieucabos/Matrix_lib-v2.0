Contains function
=================

Genericity polymorphism 'contains' function

=============== ================ =======================================
**Parameters**   *type*           **Description**
*mat*            Matrix           The matrix to test
=============== ================ =======================================

Returns
-------
	bint
		Return the appartenance test (x in A) wher x i the submatrix mat as arguement and A is the self matrix

Examples
--------
>>> m=rand(3)
>>> main=Matrix(5,5)
>>> main[1,1]=m
>>> print(main)
| +0.000 | +0.000 | +0.000 | +0.000 | +0.000 |
| +0.000 | +9.000 | +6.000 | +7.000 | +0.000 |
| +0.000 | +6.000 | +6.000 | +4.000 | +0.000 |
| +0.000 | +1.000 | +3.000 | +1.000 | +0.000 |
| +0.000 | +0.000 | +0.000 | +0.000 | +0.000 |
printed
>>> print(m)
| +9.000 | +6.000 | +7.000 |
| +6.000 | +6.000 | +4.000 |
| +1.000 | +3.000 | +1.000 |
printed
>>> print(m in main)
True
>>> n=rand(3)
>>> print(n)
| +5.000 | +9.000 | +9.000 |
| +8.000 | +8.000 | +1.000 |
| +7.000 | +3.000 | +0.000 |
printed
>>> print(n in main)
False

See Also
--------
:func:`op`