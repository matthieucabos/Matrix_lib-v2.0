Sub function
============

Ad hoc polymorphism 'sub' function

=============== ========= ====================
**Parameters**   **Type**   **Description**
*mat*           Matrix    The matrix to sub
=============== ========= ====================

Returns
-------
	Matrix
	The difference between the self matrix and the mat arg matrix

Examples
--------
>>> m=rand(3)
>>> n=rand(3)
>>> print(m)
| +8.000 | +3.000 | +6.000 | 
| +1.000 | +9.000 | +4.000 | 
| +0.000 | +8.000 | +4.000 | 
printed
>>> print(n)
| +8.000 | +7.000 | +8.000 | 
| +2.000 | +5.000 | +9.000 | 
| +0.000 | +9.000 | +7.000 | 
printed
>>> print(m-n)
| +0.000 | -4.000 | -2.000 | 
| -1.000 | +4.000 | -5.000 | 
| +0.000 | -1.000 | -3.000 | 
printed

See Also
--------
:func:`op`