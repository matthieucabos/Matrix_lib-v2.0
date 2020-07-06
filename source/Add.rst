Add function
============

Ad hoc polymorphism 'add' function

=============== ========= ====================
**Parameters**   **Type**   **Description**
*mat*           Matrix    The matrix to add
=============== ========= ====================

Returns
-------
	Matrix
	The sum of the self matrix and the mat arg matrix

Examples
--------
>>> m=rand(3)
>>> n=rand(3)
>>> print(m)
| +5.000 | +1.000 | +6.000 | 
| +4.000 | +3.000 | +7.000 | 
| +3.000 | +9.000 | +7.000 | 
printed
>>> print(n)
| +5.000 | +7.000 | +3.000 | 
| +2.000 | +4.000 | +7.000 | 
| +9.000 | +5.000 | +2.000 | 
printed
>>> print(m+n)
| +10.000 | +8.000 | +9.000 | 
| +6.000 | +7.000 | +14.000 | 
| +12.000 | +14.000 | +9.000 | 
printed

See Also
--------
cmatrix.op