Mul function
============

Genericity polymorphism 'mul' function

=============== ============ ================================
**Parameters**   **Type**      **Description**
*mat*            Matrix       The matrix to multiply
*mat*            int/double   The multiplicative coefficient
=============== ============ ================================

Returns
-------
	Matrix
	
	The product between the self matrix and the argument, depending of argument type :
		* Matrix mean a matrix product
		* integer mean a lambda product
		* double mean a lambda product

Examples
--------
>>> m=rand(3)
>>> n=rand(3)
>>> print(m)
| +4.000 | +1.000 | +7.000 |
| +2.000 | +9.000 | +7.000 |
| +8.000 | +6.000 | +6.000 |
printed
>>> print(n)
| +2.000 | +1.000 | +5.000 |
| +3.000 | +5.000 | +0.000 |
| +2.000 | +2.000 | +7.000 |
printed
>>> print(m*n)
| +50.000 | +41.000 | +51.000 |
| +22.000 | +48.000 | +56.000 |
| +68.000 | +62.000 | +70.000 |
printed

See Also
--------
:func:`cmatrix.Matrix.op`