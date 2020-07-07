Div function
============

Genericity polymorphism 'div' function

=============== ========= ===============================
**Parameters**  **Type**   **Description**
*value*         double    The diviser value
*value*			    int       The diviser value
=============== ========= ===============================

Returns
-------
	Matrix
	The divided matrix

Examples
--------
>>> m=rand(4)
>>> print(m)
| +15.000 | +9.000 | +12.000 | +3.000 |
| +9.000 | +14.000 | +8.000 | +4.000 |
| +15.000 | +14.000 | +0.000 | +9.000 |
| +8.000 | +8.000 | +6.000 | +8.000 |
printed
>>> print(m/10)
| +1.500 | +0.900 | +1.200 | +0.300 |
| +0.900 | +1.400 | +0.800 | +0.400 |
| +1.500 | +1.400 | +0.000 | +0.900 |
| +0.800 | +0.800 | +0.600 | +0.800 |
printed

See Also
--------
:func:`cmatrix.Matrix.op`