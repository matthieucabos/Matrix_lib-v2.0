Mod function
============

Genericity polymorphism 'mod' function

=============== ========= ===============================
**Parameters**  **Type**   **Description**
*value*         double    The modulo value
*value*			    int       The modulo value
=============== ========= ===============================

Returns
-------
	Matrix
	The modulo matrix

Examples
--------
>>> m=rand(4)
>>> print(m)
| +12.000 | +5.000 | +10.000 | +5.000 |
| +9.000 | +10.000 | +2.000 | +2.000 |
| +10.000 | +9.000 | +0.000 | +2.000 |
| +13.000 | +9.000 | +8.000 | +16.000 |
printed
>>> print(m%2)
| +0.000 | +1.000 | +0.000 | +1.000 |
| +1.000 | +0.000 | +0.000 | +0.000 |
| +0.000 | +1.000 | +0.000 | +0.000 |
| +1.000 | +1.000 | +0.000 | +0.000 |
printed

See Also
--------
:func:`cmatrix.Matrix.op`