Sequence recognition algorithm
==============================

Here, the sequence recognization algorithm.
The algorithm is working in three steps:

	* From the original data as raw list, I create mutants list containing all the subset of the main list
	* I consider each mutant as a claiming sequence
	* I verifiy and count (if verified) the number of repetition

.. autosummary::
	:toctree: Sequence recognition algorithm

	cmatrix.count_seq
	cmatrix.create_mutants
	cmatrix.cut
	cmatrix.find_invariant
	cmatrix.find_max
	cmatrix.find_mul_seq
	cmatrix.find_seq
	cmatrix.find_seq_in_list
	cmatrix.split_data
	cmatrix.split_number