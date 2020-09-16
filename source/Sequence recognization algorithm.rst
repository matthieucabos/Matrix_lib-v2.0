Sequence recognition algorithm
==============================

Here, the sequence recognization algorithm.
The algorithm is working in three steps:

	* From the original data as raw list, I create mutants list containing all the subset of the main list
	* I consider each mutant as a claiming sequence
	* I verifiy and count (if verified) the number of repetition

.. autosummary::
	.. :recursive:

.. autofunction:: cmatrix.count_seq
.. autofunction:: cmatrix.create_mutants
.. autofunction:: cmatrix.cut
.. autofunction:: cmatrix.find_invariant
.. autofunction:: cmatrix.find_max
.. autofunction:: cmatrix.find_mul_seq
.. autofunction:: cmatrix.find_seq
.. autofunction:: cmatrix.find_seq_in_list
.. autofunction:: cmatrix.split_data
.. autofunction:: cmatrix.split_number
