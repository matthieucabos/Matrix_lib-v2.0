Setitem function
================

Genericity polymorphism 'setitem' function

=============== ================ =======================================
**Parameters**   **type**        **Description**
*key*            tuple            i,j values
*value*          double           the value to set
*value*			 Matrix           the sub-matrix to set from (i,j) arg
=============== ================ =======================================

Returns
-------
	Matrix
		The self matrix updated with new value(s)

Examples
--------
>>> m=Matrix(4,4)
>>> insert=rand(2)
>>> print(insert)
| +3.000 | +4.000 |
| +3.000 | +1.000 |
printed
>>> m[0,0]=insert
>>> print(m)
| +3.000 | +4.000 | +0.000 | +0.000 |
| +3.000 | +1.000 | +0.000 | +0.000 |
| +0.000 | +0.000 | +0.000 | +0.000 |
| +0.000 | +0.000 | +0.000 | +0.000 |
printed
>>> m[3,3]=10.123456
>>> print(m)
| +3.000 | +4.000 | +0.000 | +0.000 |
| +3.000 | +1.000 | +0.000 | +0.000 |
| +0.000 | +0.000 | +0.000 | +0.000 |
| +0.000 | +0.000 | +0.000 | +10.123 |
printed

See Also
--------
:func:`cmatrix.set_ij`
:func:`cmatrix.insert_sub_matrix`