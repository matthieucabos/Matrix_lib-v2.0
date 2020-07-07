import numpy as np 
import random as r
import time as t
import os
from cython.parallel import  prange, parallel

__author__="CABOS Matthieu"
__date__=24_06_2020

#%%

# Counting CPU to parallelize the loops occurences 

CPU_cores=os.cpu_count()

######################################
########### Timed tester #############
######################################

def timeit(func):
	"""
		Time a function using @timeit syntax.

		=============== =========== ===============================
		**Parameters**    **Type**   **Description**
		*func*             Function  The function to be stopwatch
		=============== =========== ===============================

		Examples
		--------
		>>> from matrix import *
		>>> @timeit
		... def isalpha(char):
		...     return (char in ['0','1','2','3','4','5','6','7','8','9'])
		...
		>>> isalpha('9')
		<function isalpha at 0x0337B6F0> executed 10 000 times in 0.011322021484375 = 1.1322021484375e-06 /s.
		True

		Returns
		-------
		Executed decorated function with originals arguments
	"""
	def do(*arg,**kwarg):
		cdef int i
		start=t.time()
		for i in range(0,10000):
			func(*arg,**kwarg)
		now=t.time()-start
		print(str(func)+" executed 10 000 times in "+str(now)+" = "+str(now/10000)+" s/exec.")
		return(func(*arg,**kwarg))
	return do

#%%

#####################################
########### Maths utils #############
#####################################

cpdef bint isalpha(str c):
	"""
		Test if the given arguments is alphanum.

		Returns
		-------
		Bool
			The tested condition
	"""
	return (c in ['0','1','2','3','4','5','6','7','8','9'])

#double way switch
def switch(x,*arg):
	"""
		Redefined C-like switch.
		Could also be used as an inverse switch where x is a value and arg the differents variables to test.

		==============   ============== ==================================================
		**Parameters**   **Type**        **Description**
		*x*              string          the variable name to switch
		*arg*            string/generic  the differents states to switch, defined mod 2 :
										 "string",function,"string",function,...
		==============   ============== ==================================================

		Examples
		--------
		>>> test1=False
		>>> test2=False
		>>> test3=True
		>>> test4=False
		>>> val=switch(True,
		...     test1,1,
		...     test2,2,
		...     test3,3,
		...     test4,4)
		>>> print(val)
		3
		>>> val=switch(test3,
		...     True,3,
		...     False,4)
		>>> print(val)
		3

		Returns 
		-------
		Generic
			The function or action corresponding to the switch entry.
	"""
	cdef int i
	dic ={}
	for i in range(int(len(arg)-1)):
		dic[arg[i]]=arg[i+1]
	return dic.get(x,'default')

cpdef list reverse(list liste):
	"""
		I think comments are not necessary for this function.
	"""
	cdef list res
	cdef int i
	res=[]
	for i in range(0,len(liste)):		
		res.append(liste[len(liste)-i-1])
	return res

cpdef list split_number(int num,int base):
	"""
		Split a number by heigth in decimal base.

		Returns
		-------
			list
				The splitted number as a list

		Examples
		--------
		>>> num=654321
		>>> base=10
		>>> split=split_number(num,base)
		>>> print(split)
		[6, 5, 4, 3, 2, 1]
	"""
	cdef list res
	res=[]
	while(num>0):
		res.append(num % base)
		num=int(num/base)
	return reverse(res)

cpdef int complement_at(int x,int base=2):
	"""
		Utility function computing the complement from x and base.

		=============== ========== ===============================
		**Parameters**   **type**   **Description**
		*x*              int        the value to base-complement
		*base*           int        the numeric base as reference
										(2 by default)
		=============== ========== ===============================

		Returns
		-------
			int
			the 1st level complement (on one digit)

		Examples
		--------
		>>> num=7
		>>> base=10
		>>> cp=complement_at(num,base)
		>>> print(cp)
		2
		>>> num=2
		>>> base=3
		>>> cp=complement_at(num,base)
		>>> print(cp)
		0
	"""
	return (base-1-x)

cpdef double complement(int x,int base=2):
	"""
		Return the x complement in the given base (generic algorithm).

		=============== ========== ==============================
		**Parameters**  **type**   **Description**
		*x*             int        The value to complement
		*base*          int        The numeric base as reference
										(2 by default)
		=============== ========== ==============================

		Returns
		-------
			double
			The x complement in given base

		See Also
		--------
		:func:`split_number`
		:func:`complement_at`
		
		Examples
		--------
		>>> num=123456
		>>> base=10
		>>> cp=complement(num,base)
		>>> print(cp)
		876543
		>>> num=11100101
		>>> base=2
		>>> cp=complement(num,base)
		>>> print(cp)
		11010

	"""
	cdef double final_res
	cdef list splitted
	cdef int i
	
	splitted=split_number(x,10)
	final_res=0
	for i in range(0,len(splitted)):
		splitted[i]=complement_at(splitted[i],base)
		final_res*=10
		final_res+=splitted[i]
	return final_res

cpdef double abs(double x):
	"""
		Get the absolute value of the given argument.

		=============== ========== ==============================
		**Parameters**  **type**   **Description**
		*x*             double     The raw value to treat
		=============== ========== ==============================

		Returns
		-------
			double
			The absolute value of x

		Examples
		--------
		>>> m=-123
		>>> n=123
		>>> abs(m)
		123
		>>> abs(n)
		123
	"""
	if(x<0):
		return -x 
	else:
		return x

cpdef tuple swap(double a,double b):
	"""
		Swap a and b as double values.

		=============== ========== ==============================
		**Parameters**  **type**   **Description**
		*a*             double      value to swap
		*b*             double      value to swap
		=============== ========== ==============================

		Returns
		-------
			tuple
			the swapped values

		Examples
		--------
		>>> from cmatrix import *
		>>> a=123
		>>> b=456
		>>> swap(a,b)
		(456.0, 123.0)	
	"""
	# no ram swap
	b+=a
	a=b-a 
	b=b-a 
	return(a,b)

#TODO : remplacer par tri shell
cpdef list tri(list liste,int mode):

	#0=>selection
	#1=>bulle
	cdef int i
	cdef int j
	cdef bint valid
	j=0
	if(not mode):
		for i in range(0,len(liste)-1):
			for j in range(i+1,len(liste)):
				if(liste[j]<liste[i]):
					liste[i],liste[j]=swap(liste[i],liste[j])
	else:
		valid=True
		while(valid):
			valid=False
			for i in range(0,len(liste)-1):
				if(liste[i]>liste[i+1]):
					liste[i],liste[j]=swap(liste[i],liste[j])
					valid=True		
	return liste
#%%

######################################
############# Compressor #############
######################################

######################################
##### Sequence finder algorithm ######
######################################

cpdef list cut(list liste,double piv):
	"""
		Cut the liste from the pivot (as double argument).

		=============== ========== ====================================
		**Parameters**  **type**   **Description**
		*liste*          list       The liste to cut
		*piv*            double     The pivot value as cutter delimiter
		=============== ========== ====================================

		Returns
		-------
			list
			The cutted list from the pivot value

		Examples
		--------
		>>> l=[1,2,3,4,5,6]
		>>> piv=3
		>>> cut(l,piv)
		[3, 4, 5, 6]
	"""
	cdef int i
	
	for i in range(0,len(liste)):
		if(liste[i]==piv):
			return(liste[i:])
	return []

cpdef bint find_seq_in_list(list seq,list liste):
	"""
		Test if the given sequence have been found in the raw data (given as list)

		=============== ========== ====================================
		**Parameters**  **type**   **Description**
		*seq*           list       The sequence to search in liste
		*liste*         list       Raw data as a list
		=============== ========== ====================================

		Returns
		-------
			bint
				* True  => The sequence has been found
				* False => The sequence hasn't been found

		Examples
		--------
		>>> seq=[3,7,5]
		>>> l=[1,2,3,4,5,3,7,5,3,7,5,3,7,5]
		>>> find_seq_in_list(seq,l)
		True
		>>> seq=[9,8,7]
		>>> l=[1,2,3,4,5,6,7]
		>>> find_seq_in_list(seq,l)
		False

	"""
	cdef bint res
	cdef int j
	cdef int i
	
	res=False
	j=0
	if(len(seq)!=len(liste)):
		for i in range(0,len(liste)):
			if(liste[i]==seq[j] and not res):
				res=True
			if(res):
				res=res and (liste[i]==seq[j])
				if((j+1)<len(seq)):
					j+=1
				else:
					return res
	return res

cpdef list create_mutants(list liste,int mode =0):
	"""
		Create the 'mutants lists' from  the original one.

		Two mode are avaible :

            * Mutants created from the begin
            * Mutants created from the end

		=============== ========== ==========================================================
		**Parameters**  **type**   **Description**
		*liste*         list        The original liste to generate mutants

		*mode*          int         The mode define the way to generate mutants :

		                             * 0 => The mutants lists are cutted since the begining
		                             * 1 => The mutants lists are cutted since the end
		=============== ========== ==========================================================

		Returns
		-------
			list list
			    A list of list containing all the mutants generated

		Examples
		--------
		>>> l=[1,2,3,4,5,6,7]
		>>> create_mutants(l)
		[[2, 3, 4, 5, 6, 7], [3, 4, 5, 6, 7], [4, 5, 6, 7], [5, 6, 7], [6, 7], [7]]
	"""
	cdef list res
	res=[]
	if not mode:
		for i in range(1,len(liste)):
			res.append(liste[i:])
	else:
		for i in range(1,len(liste)):
			res.append(liste[:i])
	return res

cpdef list find_seq(list liste):
	"""
		Search a sequence into the parameter list.
		This is the first naïve step of the algorithm.

		=============== ========== ========================================
		**Parameters**  **type**   **Description**
		*liste*         list       The raw data to treat as list
		=============== ========== ========================================

		Returns
		-------
			list
			A list containing the sequence repeated from the begining to the end if found

		Examples
		--------
		>>> find_seq([1,2,3,1,2,3,1,2,3])
		[1, 2, 3]

		See Also
		--------
		:func:`find_seq_in_list`
	"""
	cdef list res
	cdef int i
	cdef bint breaker
	
	res=[liste[0]]
	for i in range(1,len(liste)):
		breaker=find_seq_in_list(res,liste)
		if(not breaker):
			return res[:-1]
		if((not find_seq_in_list(res,liste[i:])) and res[len(res)-1]!=liste[i]):
			res.append(liste[i])
		else:
			res
	return res

cpdef list find_max(list liste):
	"""
		Search into the list of list containing all the claiming sequences the longest one.

		=============== ========== ========================================
		**Parameters**  **type**   **Description**
		*liste*         list       A list of list to treat
		=============== ========== ========================================

		Returns
		-------
			list
			A list containing the longest list found

		Examples
		--------
		>>> l=[1,2,3,5,6,3,5,6,3,5,6]
		>>> m=create_mutants(l)
		>>> print(m)
		[[2, 3, 5, 6, 3, 5, 6, 3, 5, 6], [3, 5, 6, 3, 5, 6, 3, 5, 6], [5, 6, 3, 5, 6, 3, 5, 6], [6, 3, 5, 6, 3, 5, 6], [3, 5, 6, 3, 5, 6], [5, 6, 3, 5, 6], [6, 3, 5, 6], [3, 5, 6], [5, 6], [6]]
		>>> find_max(m)
		[2, 3, 5, 6, 3, 5, 6, 3, 5, 6]	 
	"""
	cdef int maxi
	cdef list res
	cdef int i
	
	maxi=len(liste[0])
	res=liste[0]
	for i in range(0,len(liste)):
		res = liste[i] if len(liste[i]) > maxi else res
		maxi = len(liste[i]) if len(liste[i]) > maxi else maxi 
	return res 

cpdef list suppr_double(list liste):
	"""
		Utilitary function to del all duplicates values in the parameter list.

		=============== ========== ========================================
		**Parameters**  **type**   **Description**
		*liste*          list      The raw data to treat as list
		=============== ========== ========================================

		Returns
		-------
			list
			The given liste where all uplicates values have been removed

		Examples
		--------
		>>> l=[1,1,1,2,3,4,4,4,5,6,6]
		>>> suppr_double(l)
		[1, 2, 3, 4, 5, 6]
	"""
	cdef list res
	cdef int i
	
	res=[liste[0]]
	for i in range(1,len(liste)):
		if (not liste[i] in res):
			res.append(liste[i])
	return res

cpdef tuple find_mul_seq(list liste):
	"""
		The main sequence finder algorithm.
		Return the sequence (if founded) with number of repetition.
		First thinked as data compressor, it should be used as ARN/ADN sequence analizer :)
		The algorithm use the various micro-function written above.

		=============== ========== ========================================
		**Parameters**  **type**   **Description**
		*liste*         list       The raw data to treat as list
		=============== ========== ========================================

		Returns
		-------
			tuple
			A tuple containing the sequence as list and the number of repetition as int (if found)

		Examples
		--------
		>>> l=[1,2,3,7,3,4,7,3,4,7,3,4]
		>>> m=[4,2,1,4,2,1,4,2,1,5,7,9]
		>>> n=[1,2,6,4,5,6,4,5,6,4,5,8,3,9]
		>>> find_mul_seq(l)
		([7, 3, 4], 3)
		>>> find_mul_seq(m)
		([4, 2, 1], 3)
		>>> find_mul_seq(n)
		([6, 4, 5], 3)

		See Also
		--------		
		:func:`create_mutants`
		:func:`find_seq_in_list`
		:func:`count_seq`
		:func:`suppr_double`
		:func:`find_max`
	"""
	#Return the sequence (if founded) with number of repetition
	#Should be used as ARN/ADN sequence analizer :)
	#(I'm still working on a MUCH BETTER version, thanks 4 patience)
	cdef list mutants
	cdef list tmp
	cdef list mutants_2nd
	cdef int i

	tmp=[]
	i=0
	mutants=create_mutants(liste)

	tmp=[]
	for i in range(0,len(mutants)):
		mutants_2nd=create_mutants(mutants[i],1)
		for j in range(0,len(mutants_2nd)):
			if(find_seq_in_list(mutants_2nd[j],liste)) and (count_seq(liste,mutants_2nd[j])>1):
				tmp.append(mutants_2nd[j])
		mutants_2nd=[]
	try :
		return (suppr_double(find_max(tmp)),count_seq(liste,suppr_double(find_max(tmp))))
	except:
		return([],0)

cpdef list find_invariant(list liste,list seq):
	"""
		Find the invariant part since the beggining until the sequence repetitions start.

		=============== ========== ========================================
		**Parameters**  **type**   **Description**
		*liste*          list       the raw data as list
		*seq*            list       the sequence found in the data list
		=============== ========== ========================================

		Returns
		-------
			list
			A list containing the unsequenced begining of liste   
	
		Examples
		--------
		>>> n=[1,2,6,4,5,6,4,5,6,4,5,8,3,9]
		>>> seq=[6,4,5]
		>>> find_invariant(n,seq)
		[1, 2]

	"""
	cdef list res
	cdef int i
	cdef int j
	
	res=[]
	j=0
	for i in range(0,len(liste)):
		if(liste[i]!=seq[j]):
			res.append(liste[i])
		else:
			return res 
	return res

cpdef int count_seq(list liste,list seq):
	"""
		Count the number of sequences repetiotion in the given data segment as list.

		=============== ========== ========================================
		**Parameters**  **type**   **Description**
		*liste*          list      The liste containing the given sequence
		*seq*            list      The sequence as list
		=============== ========== ========================================

		Returns
		-------
			int
			The number of repetition of the sequence in da list

		Examples
		--------
		>>> l=[1,2,3,7,3,4,7,3,4,7,3,4]
		>>> seq=[7,3,4]
		>>> count_seq(l,seq)
		3

	"""
	cdef int res
	cdef bint tmp
	cdef int i
	cdef int j
	
	res=0
	tmp=False
	try :
		for i in range(0,len(liste)):
			tmp=False
			if(liste[i]==seq[0]):
				tmp=True
				for j in range(0,len(seq)):
					tmp=tmp and (liste[i+j]==seq[j])
				if tmp :
					res+=1
		return res
	except:
		return 0

#TODO :Fix
cpdef list split_data(list data,int size_r):
	"""
		A data splitter to treat a large amount of data.
		Must be improved to treat efficiently a large amount of data.

		=============== ========== ========================================
		**Parameters**  **type**   **Description**
		*data*          list        The raw data as list
		*size_r*        int         The size_row arguments (considering data 
									as a Matrix)
		=============== ========== ========================================

		Returns
		-------
			list of list
			The splitted data into equal size parts

	"""
	cdef list res
	cdef list tmp
	cdef int i
	
	res=[]
	tmp=[]
	for i in range(0,len(data)):
		tmp.append(data[i])
		if(i%size_r==0):
			res.append(tmp)
			tmp=[]
	return res

#%%

#####################################
######## class definition ###########
#####################################

cdef class Matrix(object):

	"""
		Fast matrix computing object.                                                      

		=============== ==============
		**Attributes**   **Type**                                                          
		*size_raw*        int
		*size_column*     int
		*data*            double list
		=============== ==============

	"""
	cdef int size_raw
	cdef int size_column
	cdef list data
	cdef double coef
	
	def __cinit__(self,int sr,int sc,double init_value=0):
		
		self.size_raw=sr
		self.size_column=sc
		self.data=[init_value]*sr*sc
		self.coef=0.0

	def __dealloc__(self):
		global x
		x=self
#%%
#####################################
########### Xpress ribbon ###########                                                     
#####################################

	cpdef int ij_2_ind(self,int i,int j,int size_raw):    
		"""
			Convert (i,j) values to raw ribbon index.
		"""                        
		return j*size_raw+i

	cpdef tuple ind_2_ij(self,int ind,int size_raw):
		"""
			Convert ribbon index to (i,j) values.
		"""
		return (int(ind/size_raw),ind%size_raw)

	cpdef int size_r(self):
		"""
			Getters : size of rows
		"""
		return self.size_raw

	cpdef int size_c(self):
		"""
			Getters : size of columns
		"""
		return self.size_column

	cpdef double get_ij(self,i,j):
		"""
			Getters : get the (i,j) value
		"""
		return self.data[self.ij_2_ind(i,j,self.size_r())]

	cpdef void set_ij(self,i,j,value):
		"""
			Setters : set the (i,j) value
		"""
		self.data[self.ij_2_ind(i,j,self.size_r())]=value

	cpdef double get_ind(self,ind):
		"""
			Getters : get the index value from raw data vector
		"""
		return self.data[ind]

	cpdef bint same_size(self,Matrix m2):
		"""
			Assertion : same size
		"""
		return ((self.size_r()==m2.size_r()) and (self.size_c()==m2.size_c()))

	cpdef bint mult_compatible(self,Matrix m2):
		"""
			Assertion : multiplication compatibility
		"""
		return (self.size_r()==m2.size_c())

	cpdef void Print(self):
		"""
			Screen Printer
		"""
		cdef int i
		cdef int j 
		cdef str to_print
		
		for i in range(0,self.size_r()):
			for j in range(0,self.size_c()):
				if(j==0):
					try:
						to_print='| '+ "{:+06.3f}".format(self.get_ij(i,j)) + ' | '
					except:
						to_print='| '+ "{:10}".format(self.get_ij(i,j)) + ' | '
				elif(j!=self.size_c()-1):
					try:
						to_print+="{:+06.3f}".format(self.get_ij(i,j)) + ' | '
					except:
						to_print+='| '+ "{:10}".format(self.get_ij(i,j)) + ' | '
				else:
					try:
						to_print+="{:+06.3f}".format(self.get_ij(i,j)) + ' | '
					except:
						to_print+='| '+ "{:10}".format(self.get_ij(i,j)) + ' | '
					print(to_print)
					to_print=''
				if(self.size_c()==1):
					print(to_print)

	cpdef Matrix clone(self):
		"""
			Object Cloner.
		"""
		cdef Matrix res
		cdef int i
		cdef int j 
		res=Matrix(self.size_r(),self.size_c(),0.0)
		for i in range(0,self.size_r()):
			for j in range(0,self.size_c()):
				res.set_ij(i,j,self.get_ij(i,j))
		return res

	cpdef Matrix xtract_sub_matrix(self,tuple from_ij,tuple to_ij):
		"""
			Extract the [from_ij] [to_ij] matrix in the self object (if exists)

			=============== ========== ===========================================
			**Parameters**   **Type**   **Description**
			*from_ij*        int tuple  tuple containing top left up i,j corner
			*to_ij*          int tuple  tuple containing top right down i,j corner
			=============== ========== ===========================================

			Returns
			-------
				Matrix
				The extracted sub matrix

			Examples
			--------
			>>> mat=gaussian(5,0,1)
			>>> xtract=mat.xtract_sub_matrix([1,1],[4,4])
			>>> Print(mat)
			| +0.004 | +0.016 | +0.023 | +0.016 | +0.004 |
			| +0.016 | +0.062 | +0.094 | +0.062 | +0.016 |
			| +0.023 | +0.094 | +0.141 | +0.094 | +0.023 |
			| +0.016 | +0.062 | +0.094 | +0.062 | +0.016 |
			| +0.004 | +0.016 | +0.023 | +0.016 | +0.004 |
			printed
			>>> Print(xtract)
			| +0.062 | +0.094 | +0.062 |
			| +0.094 | +0.141 | +0.094 |
			| +0.062 | +0.094 | +0.062 |
			printed

			See Also
			--------
			:func:`set_ij`
			:func:`get_ij`
		"""
		cdef int from_i
		cdef int from_j
		cdef int to_i
		cdef int to_j
		cdef Matrix xtract

		from_i=from_ij[0]
		from_j=from_ij[1]
		to_i=to_ij[0]
		to_j=to_ij[1]
		xtract=Matrix(to_i-from_i,to_j-from_j)


		for i in range(from_i,to_i):
			for j in range(from_j,to_j):
				xtract.set_ij(i-from_i,j-from_j,self.get_ij(i,j))
		return xtract
	
	cpdef void insert_sub_matrix(self,tuple to_ij,Matrix to_insert):
		"""
			Insert the givven sub-matrix in the self matrix if and only if to_insert is smaller.

			=============== ============== ================================================================
			**Parameters**   **Type**      **Description**
			*to_ij*          double tuple  The 2D coor representing the inserting point in the self matrix
			*to_insert*      Matrix        The atrix to insert
			=============== ============== ================================================================
			
			Examples
			--------
			>>> mat2=zeros(5,5)
			>>> mat2.insert_sub_matrix([1,1],xtract)
			>>> Print(mat2)
			| +0.000 | +0.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +0.062 | +0.094 | +0.062 | +0.000 |
			| +0.000 | +0.094 | +0.141 | +0.094 | +0.000 |
			| +0.000 | +0.062 | +0.094 | +0.062 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +0.000 | +0.000 |
			printed
			
			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`get_ij`
		"""
		cdef int to_i
		cdef int to_j
		cdef int i
		cdef int j

		if(to_insert.size_r()<=self.size_r() and to_insert.size_c()<=self.size_c()):
			to_i = to_ij[0]
			to_j = to_ij[1]
			for i in range(to_i,to_insert.size_r()+to_i):
				for j in range(to_j,to_insert.size_c()+to_j):
					self.set_ij(i,j,to_insert.get_ij(i-to_i,j-to_j))
		else:
			print("Please check size.")

	cpdef bint find_sub_matrix(self,Matrix sub):
		"""
			Search the sub)matrix in the self matrix.
			The given sub must be smaller than the self matrix.
	
			=============== ========== ======================
			**Parameters**   **Type**   **Description**
			*sub*            Matrix     the matrix to search
			=============== ========== ======================

			Returns
			-------
				Boolean
					* True mean the sub)matrix is in the main matrix
					* False mean the sub)matrix isn't contained in the main matrix

			Examples
			--------
			>>> mat=gaussian(5,0,0)
			>>> Print(mat)
			| +1.000 | +4.000 | +6.000 | +4.000 | +1.000 |
			| +4.000 | +16.000 | +24.000 | +16.000 | +4.000 |
			| +6.000 | +24.000 | +36.000 | +24.000 | +6.000 |
			| +4.000 | +16.000 | +24.000 | +16.000 | +4.000 |
			| +1.000 | +4.000 | +6.000 | +4.000 | +1.000 |
			printed
			>>> xtract=mat.xtract_sub_matrix([1,1],[4,4])
			>>> Print(xtract)
			| +16.000 | +24.000 | +16.000 |
			| +24.000 | +36.000 | +24.000 |
			| +16.000 | +24.000 | +16.000 |
			printed
			>>> mat2=unit(5)
			>>> Print(mat2)
			| +1.000 | +0.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +1.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +1.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +0.000 | +1.000 |
			printed
			>>> mat.find_sub_matrix(xtract)
			True
			>>> mat2.find_sub_matrix(xtract)
			False

			See Also
			--------
			:func:`get_ij`
			:func:`size_r`
			:func:`size_c`
		"""
		cdef bint res 
		cdef int i 
		cdef int j 
		cdef int k 
		cdef int l

		res=False
		for i in range(0,self.size_r()):
			for j in range(0,self.size_c()):
				if(self.get_ij(i,j)==sub.get_ij(0,0)):
					try:
						res=True
						for k in range(0,sub.size_r()):
							for l in range(0,sub.size_c()):
								res&=(self.get_ij(i+k,j+l)==sub.get_ij(k,l))
						return res
					except:
						pass
		return res

# #%%

# #####################################
# ## Standard operators redefinition ##
# #####################################

	cpdef Matrix op(self,mat2,str op):            
		"""
			Standard operators factorization                              

			Eventually complete the description with details as :

			The given operator as a string is interpreted and the corresponding computing is returned

			=============== ========= ======================================
			**Parameters**   **Type**   **Description**
			*mat2*           Matrix     The matrix second term
			*op*             String     the operation to realize between :
											* + : add
											* - : sub
											* * : multiply
											* & : logic and
											* | : logic or
											* ~ : logic nand
											* ¤ : logic nor
											* ¨ : logic xor
			=============== ========= ======================================

			Examples
			--------
			>>> # Decimal Operator Factorisation
			>>> t=gaussian(5,1,0)
			>>> Print(t) # initializing
			| +1.000 | +2.000 | +4.000 | +2.000 | +1.000 |
			| +2.000 | +4.000 | +8.000 | +4.000 | +2.000 |
			| +4.000 | +8.000 | +16.000 | +8.000 | +4.000 |
			| +2.000 | +4.000 | +8.000 | +4.000 | +2.000 |
			| +1.000 | +2.000 | +4.000 | +2.000 | +1.000 |
			printed
			>>> u=unit(5)*100
			>>> Print(u) # initializing
			| +100.000 | +0.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +100.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +100.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +100.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +0.000 | +100.000 |
			printed
			>>> Print(t.op(u,'+')) # applying operator
			| +101.000 | +2.000 | +4.000 | +2.000 | +1.000 |
			| +2.000 | +104.000 | +8.000 | +4.000 | +2.000 |
			| +4.000 | +8.000 | +116.000 | +8.000 | +4.000 |
			| +2.000 | +4.000 | +8.000 | +104.000 | +2.000 |
			| +1.000 | +2.000 | +4.000 | +2.000 | +101.000 |
			printed
			>>> Print(t.op(u,'-')) # applying operator
			| -99.000 | +2.000 | +4.000 | +2.000 | +1.000 |
			| +2.000 | -96.000 | +8.000 | +4.000 | +2.000 |
			| +4.000 | +8.000 | -84.000 | +8.000 | +4.000 |
			| +2.000 | +4.000 | +8.000 | -96.000 | +2.000 |
			| +1.000 | +2.000 | +4.000 | +2.000 | -99.000 |
			printed
			>>> Print(t.op(u,'*')) # applying operator
			| +100.000 | +200.000 | +400.000 | +200.000 | +100.000 |
			| +200.000 | +400.000 | +800.000 | +400.000 | +200.000 |
			| +400.000 | +800.000 | +1600.000 | +800.000 | +400.000 |
			| +200.000 | +400.000 | +800.000 | +400.000 | +200.000 |
			| +100.000 | +200.000 | +400.000 | +200.000 | +100.000 |
			printed
			>>> # Binary Operator Factorisation
			>>> t=rand_perm(3)
			>>> Print(t)
			| +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 |
			| +0.000 | +1.000 | +0.000 |
			printed
			>>> u=unit(3)
			>>> Print(u)
			| +1.000 | +0.000 | +0.000 |
			| +0.000 | +1.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 |
			printed
			>>> # Logical And
			>>> Print(t.op(u,'&'))
			| +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 |
			printed
			>>> # Logical Or
			>>> Print(t.op(u,'|'))
			| +1.000 | +0.000 | +0.000 |
			| +0.000 | +1.000 | +1.000 |
			| +0.000 | +1.000 | +1.000 |
			printed
			>>> # Logical Nand
			>>> Print(t.op(u,'~'))
			| +0.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 |
			printed
			>>> # Logical Nor
			>>> Print(t.op(u,'¤'))
			| +0.000 | +1.000 | +1.000 |
			| +1.000 | +0.000 | +0.000 |
			| +1.000 | +0.000 | +0.000 |
			printed
			>>> # Logical Xor
			>>> Print(t.op(u,'¨'))
			| +0.000 | +0.000 | +0.000 |
			| +0.000 | +1.000 | +1.000 |
			| +0.000 | +1.000 | +1.000 |
			printed

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`same_size`
			:func:`get_ij`
			:func:`set_ij`
			:func:`mult_compatible`
			:func:`transpose`
		"""
		cdef double tmp
		cdef int i 
		cdef int j 

		res=Matrix(self.size_r(),self.size_c())
		if(op=='+'):
			if(self.same_size(mat2)):
				for i in range(0,self.size_r()):
					for j in range(0,self.size_c()):
						res.set_ij(i,j,self.get_ij(i,j)+mat2.get_ij(i,j))
		elif(op=='-'):
			if(self.same_size(mat2)):
				for i in range(0,self.size_r()):
					for j in range(0,self.size_c()):
						res.set_ij(i,j,self.get_ij(i,j)-mat2.get_ij(i,j))
		elif(op=='*'):
			if(self.mult_compatible(mat2)):
				res=Matrix(mat2.size_r(),self.size_c())
				tmp=0.0
				for i in range(0,self.size_r()):
					for j in range(0,self.size_c()):
						for k in range(0,mat2.size_r()):
							tmp+=self.get_ij(k,i)*mat2.get_ij(j,k)
						res.set_ij(i,j,tmp)
						tmp=0.0
				res=res.transpose()
		elif(op=='/' or op=='%'):
			if(isinstance(mat2,int) or isinstance(mat2,float)):
				res=Matrix(self.size_r(),self.size_c())
				for i in range(0,self.size_r()):
					for j in range(0,self.size_c()):
						if(op=='/'):
							res.set_ij(i,j,self.get_ij(i,j)/mat2)
						else:
							res.set_ij(i,j,self.get_ij(i,j)%mat2)
				return res
		else :
			if(self.same_size(mat2)):
				res=Matrix(mat2.size_r(),mat2.size_c())
				for i in range(0,res.size_r()):
					for j in range(0,mat2.size_c()):
						if (op=='&'):
							res.set_ij(i,j,self.get_ij(i,j) and mat2.get_ij(i,j))
						elif (op=='|'):
							res.set_ij(i,j,self.get_ij(i,j) or mat2.get_ij(i,j))
						elif(op=='~'):
							res.set_ij(i,j,not(self.get_ij(i,j) and mat2.get_ij(i,j)))
						elif(op=='¤'):
							res.set_ij(i,j,not(self.get_ij(i,j) or mat2.get_ij(i,j)))
						elif(op=='¨'):
							res.set_ij(i,j,((self.get_ij(i,j) and (not mat2.get_ij(i,j))) or ((not self.get_ij(i,j)) and mat2.get_ij(i,j))))
		return res

	def __add__(self,Matrix mat):
		"""
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
			op
		"""
		return self.op(mat,'+')

	def __iadd__(self,mat):
		self=self+mat
		return self

	def __sub__(self,mat):
		"""
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
			op
		"""
		return self.op(mat,'-')

	def __isub__(self,mat):
		self=self-mat
		return self

	def __mul__(self,mat):
		"""
			Genericity polymorphism 'mul' function

			=============== ========= ================================
			**Parameters**   **Type**   **Description**
			*mat*            Matrix    The matrix to multiply
			*mat             int       The multiplicative coefficient
			*mat*            double    The multiplicative coefficient
			=============== ========= ================================

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
			op
		"""
		if isinstance(mat,Matrix):
			# if(mat.square() and self.square() and (self.size_r()%2==0) and len(self)>99):
			# 	return self.strassen(mat)
			# else:
			return self.op(mat,'*')
		else:
			for i in range(0,self.size_r()):
				for j in range(self.size_c()):
					self.set_ij(i,j,self.get_ij(i,j)*mat)
			return self

	def __imul__(self,mat):
		self=self*mat
		return self

	def __truediv__(self,value):
		"""
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
			op
		"""
		return self.op(value,'/')

	def __itruediv__(self,value):
		self=self/value
		return self 

	def __mod__(self,value):
		"""
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
			op
		"""
		return self.op(value,'%')


	# def __pow__(self,n):
	# 	for i in range(1,n):
	# 		self=self*self
	# 	return self

	# def __ipow__(self,n):
	# 	self=self**n
	# 	return self

	def __neg__(self):
		"""
			Genericity polymorphism 'neg' function

			Returns
			-------
				Matrix
				The opposite Matrix from self

			Examples
			--------
			>>> m=rand(3)
			>>> print(m)
			| +5.000 | +0.000 | +7.000 |
			| +9.000 | +4.000 | +8.000 |
			| +9.000 | +4.000 | +6.000 |
			printed
			>>> print(-m)
			| -5.000 | -0.000 | -7.000 |
			| -9.000 | -4.000 | -8.000 |
			| -9.000 | -4.000 | -6.000 |
			printed

			See Also
			--------
			op
		"""
		ret=Matrix(self.size_r(),self.size_c())
		for i in range(0,self.size_r()):
			for j in range(self.size_c()):
				ret.set_ij(i,j,-self.get_ij(i,j))
		return ret

	def __str__(self):
		"""
			Genericity polymorphism 'str' function

			Examples
			--------
			>>> m=rand(4)
			>>> print(m)
			| +7.000 | +9.000 | +14.000 | +3.000 |
			| +0.000 | +7.000 | +14.000 | +12.000 |
			| +2.000 | +12.000 | +11.000 | +7.000 |
			| +3.000 | +16.000 | +11.000 | +7.000 |
			printed

			See Also
			--------
			Print
		"""
		self.Print()
		return 'printed'

	def __len__(self):
		"""
			Genericity polymorphism 'len' function

			Examples
			--------
			>>> m=rand(4)
			>>> len(m)
			16
		"""
		return(self.size_r()*self.size_c())

	def __getitem__(self, key):
		"""
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
			get_ij, xtract_sub_matrix
		"""
		x=key[0]
		y=key[1]
		if(isinstance(key[0],int)):
			return self.get_ij(x,y)
		else:
			return self.xtract_sub_matrix((key[0][0],key[0][1]),(key[1][0],key[1][1]))

	def __setitem__(self,key,value):
		"""
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
			set_ij, insert_sub_matrix
		"""
		#To insert a sub matrix, give a matrix as value
		if isinstance(value,float) or isinstance(value,int):
			self.set_ij(key[0],key[1],value)
		else:
			try:
				self.insert_sub_matrix((key[0],key[1]),value)
			except:
				print("Size overload error")

	def __eq__(self,mat):
		"""
			Genericity polymorphism 'eq' function

			=============== ================ =======================================
			**Parameters**   *type*           **Description**
			*mat*            Matrix           The matrix to test
			=============== ================ =======================================

			Returns
			-------
				bint
					Return the test of equality between the self matrix and the mat argument.

			Examples
			--------
			>>> m=rand(3)
			>>> n=m.clone()
			>>> print(m==n)
			True

			See Also
			--------
			same_size, size_r, size_c, get_ij
		"""

		res=True
		if(self.same_size(mat)):
			for i in range(0,self.size_r()):
				for j in range(0,self.size_c()):
					res&=(self.get_ij(i,j)==mat.get_ij(i,j))
		return res 

	def __ne__(self,mat):
		"""
			Genericity polymorphism 'ne' function

			=============== ================ =======================================
			**Parameters**   *type*           **Description**
			*mat*            Matrix           The matrix to test
			=============== ================ =======================================

			Examples
			--------
			>>> m=rand(3)
			>>> n=rand(3)
			>>> print(m==n)
			False

			Returns
			-------
				bint
					Return the test of non-equality between the self matrix and the mat argument.

		"""
		return not (self==mat) 

	def __le__(self,mat):
		"""
			Genericity polymorphism 'le' function

			=============== ================ =======================================
			**Parameters**   *type*           **Description**
			*mat*            Matrix           The matrix to test
			=============== ================ =======================================

			Examples
			--------
			>>> m=rand(4)
			>>> n=rand(3)
			>>> print(n<=m)
			True
			>>> print(m<=n)
			False

			Returns
			-------
				bint
					Return the test less or equal between the length of the self matrix and the length of mat argument.

			See Also
			--------
			len
		"""
		return (len(self)<=len(mat))

	def __ge__(self,mat):
		"""
			Genericity polymorphism 'ge' function

			=============== ================ =======================================
			**Parameters**   *type*           **Description**
			*mat*            Matrix           The matrix to test
			=============== ================ =======================================

			Returns
			-------
				bint
					Return the test greater or equal between the length of the self matrix and the length of mat argument.

			Examples
			--------
			>>> m=rand(4)
			>>> n=rand(3)
			>>> print(m>=n)
			True
			>>> print(n>=m)
			False			

			See Also
			--------
			len
		"""
		return (len(self)>=len(mat))

	def __lt__(self,mat):
		"""
			Genericity polymorphism 'lt' function

			=============== ================ =======================================
			**Parameters**   *type*           **Description**
			*mat*            Matrix           The matrix to test
			=============== ================ =======================================

			Returns
			-------
				bint
					Return the test less than between the length of the self matrix and the length of mat argument.

			Examples
			--------
			>>> m=rand(4)
			>>> n=rand(3)
			>>> print(n<m)
			True
			>>> print(m<n)
			False

			See Also
			--------
			len
		"""
		return (len(self)<len(mat))

	def __gt__(self,mat):
		"""
			Genericity polymorphism 'gt' function

			=============== ================ =======================================
			**Parameters**   *type*           **Description**
			*mat*            Matrix           The matrix to test
			=============== ================ =======================================

			Returns
			-------
				bint
					Return the test greater than between the length of the self matrix and the length of mat argument.

			Examples
			--------
			>>> m=rand(4)
			>>> n=rand(3)
			>>> print(m>n)
			True
			>>> print(n>m)
			False

			See Also
			--------
			len
		"""
		return (len(self)>len(mat))

	def __contains__(self,mat):
		"""
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
			find_sub_matrix
		"""
		if (mat<self):
			return self.find_sub_matrix(mat)

	# Not Fixed : Do Not Use
	cpdef Matrix sqrt(self,int precision=1000):
		"""
			Compute the self sqrt matrix
			Not Fixed : Do Not Use

			===============  ===========  ==================================
			**Parameters**    *type*       **Description**
			*precision*        int         Precision parameter
			===============  ===========  ==================================

			Returns
			-------
				Matrix
					The sqrt matrix from self matrix

			See Also
			--------
			:func:`square`
			:func:`clone`
			:func:`size_r`
			:func:`inverse`
		"""
		cdef Matrix Y
		cdef Matrix Z 
		cdef int i

		if(self.square()):
			Y=self.clone()
			Z=unit(self.size_r())
			for i in range(0,precision):
				Y=(Y+Z.inverse())*1/2
				Z=(Z+Y.inverse())*1/2
		return Y

	cpdef void converter(self,int mode):
		"""
			Convert the self matrix values into a string base converted values.

			=============== ========== =============================================
			**Parameters**   **Type**   **Description**
			*mode*           int        int value representing the function profile:
											* 0 => binary conversion
											* 1 => octal conversion
											* 2 => hexadecimal conversion
			=============== ========== =============================================

			Examples
			--------
			>>> mat=gaussian(3,0,0)
			>>> mat.converter(0)
			>>> Print(mat)
			| 0b1        | | 0b10       | | 0b1        |
			| 0b10       | | 0b100      | | 0b10       |
			| 0b1        | | 0b10       | | 0b1        |
			printed
			>>> mat=gaussian(3,0,0)
			>>> mat.converter(1)
			>>> Print(mat)
			| 0o1        | | 0o2        | | 0o1        |
			| 0o2        | | 0o4        | | 0o2        |
			| 0o1        | | 0o2        | | 0o1        |
			printed
			>>> mat=gaussian(3,0,0)
			>>> mat.converter(2)
			>>> Print(mat)
			| 0x1        | | 0x2        | | 0x1        |
			| 0x2        | | 0x4        | | 0x2        |
			| 0x1        | | 0x2        | | 0x1        |
			printed

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`get_ij`
		"""
		cdef int i
		cdef int j
		
		for i in range(0,self.size_r()):
			for j in range(0,self.size_c()):
				self.set_ij(i,j,switch(mode,
					0,bin(int(self.get_ij(i,j))),
					1,oct(int(self.get_ij(i,j))),
					2,hex(int(self.get_ij(i,j)))))


	def __bin__(self):
		self.converter(0)

	def __oct__(self):
		self.converter(1)

	def __hex__(self):
		self.converter(2)

# 	##################
# 	# Binary methods #
# 	##################

	cpdef Matrix mand (self,mat):
		"""
			Realize a big and between self matrix and mat

			=============== ========== =====================
			**Parameters**   **type**  **Description**
			*mat*            Matrix*    the matrix operand
			=============== ========== =====================

			Returns
			-------
				Matrix

					The matrix obtained from a big and between self matrix and given matrix argument

			Examples
			--------
			>>> m=Matrix(4,4,1)
			>>> n=rand_perm(4)
			>>> print(m)
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			printed
			>>> print(n)
			| +0.000 | +0.000 | +0.000 | +1.000 |
			| +0.000 | +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 | +0.000 |
			| +1.000 | +0.000 | +0.000 | +0.000 |
			printed
			>>> print(m.mand(n))
			| +0.000 | +0.000 | +0.000 | +1.000 |
			| +0.000 | +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 | +0.000 |
			| +1.000 | +0.000 | +0.000 | +0.000 |
			printed

			See Also
			--------
			:func:`op`
		"""
		return self.op(mat,'&')

	cpdef Matrix mor (self,mat):
		"""
			Realize a big or between self matrix and mat

			=============== ========== =====================
			**Parameters**   **type**  **Description**
			*mat*            Matrix*    the matrix operand
			=============== ========== =====================

			Returns
			-------
				Matrix

					The matrix obtained from a big or between self matrix and given matrix argument


			Examples
			--------
			>>> m=Matrix(4,4,1)
			>>> n=rand_perm(4)
			>>> print(m)
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			printed
			>>> print(n)
			| +0.000 | +0.000 | +0.000 | +1.000 |
			| +0.000 | +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 | +0.000 |
			| +1.000 | +0.000 | +0.000 | +0.000 |
			printed
			>>> print(m.mor(n))
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			printed

			See Also
			--------
			:func:`op`
		"""
		return self.op(mat,'|')

	cpdef Matrix mnand(self,mat):
		"""
			Realize a big nand between self matrix and mat

			=============== ========== =====================
			**Parameters**   **type**  **Description**
			*mat*            Matrix*    the matrix operand
			=============== ========== =====================

			Returns
			-------
				Matrix

					The matrix obtained from a big nand between self matrix and given matrix argument

			Examples
			--------
			>>> m=Matrix(4,4,1)
			>>> n=rand_perm(4)
			>>> print(m)
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			printed
			>>> print(n)
			| +0.000 | +0.000 | +0.000 | +1.000 |
			| +0.000 | +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 | +0.000 |
			| +1.000 | +0.000 | +0.000 | +0.000 |
			printed
			>>> print(m.mnand(n))
			| +1.000 | +1.000 | +1.000 | +0.000 |
			| +1.000 | +0.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +0.000 | +1.000 |
			| +0.000 | +1.000 | +1.000 | +1.000 |
			printed

			See Also
			--------
			:func:`op`
		"""
		return self.op(mat,'~')

	cpdef Matrix mnor(self,mat):
		"""
			Realize a big nor between self matrix and mat

			=============== ========== =====================
			**Parameters**   **type**  **Description**
			*mat*            Matrix*    the matrix operand
			=============== ========== =====================

			Returns
			-------
				Matrix

					The matrix obtained from a big nor between self matrix and given matrix argument

			Examples
			--------
			>>> m=Matrix(4,4,1)
			>>> n=rand_perm(4)
			>>> print(m)
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			printed
			>>> print(n)
			| +0.000 | +0.000 | +0.000 | +1.000 |
			| +0.000 | +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 | +0.000 |
			| +1.000 | +0.000 | +0.000 | +0.000 |
			printed
			>>> print(m.mnor(n))
			| +0.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +0.000 |
			printed

			See Also
			--------
			:func:`op`
		"""
		return self.op(mat,'¤')

	cpdef Matrix mxor(self,mat):
		"""
			Realize a big xor between self matrix and mat

			=============== ========== =====================
			**Parameters**   **type**  **Description**
			*mat*            Matrix*    the matrix operand
			=============== ========== =====================

			Returns
			-------
				Matrix

					The matrix obtained from a big xor between self matrix and given matrix argument

			Examples
			--------
			>>> m=Matrix(4,4,1)
			>>> n=rand_perm(4)
			>>> print(m)
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			printed
			>>> print(n)
			| +0.000 | +0.000 | +0.000 | +1.000 |
			| +0.000 | +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 | +0.000 |
			| +1.000 | +0.000 | +0.000 | +0.000 |
			printed
			>>> print(m.mxor(n))
			| +1.000 | +1.000 | +1.000 | +0.000 |
			| +1.000 | +0.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +0.000 | +1.000 |
			| +0.000 | +1.000 | +1.000 | +1.000 |
			printed

			See Also
			--------
			:func:`op`
		"""
		return self.op(mat,'¨')

# #%%
# #####################################
# ############### Utils ###############
# #####################################

	cpdef list column(self,int ind):
		"""
			Xtract the ind column of the self Matrix object.

			=============== ========== ====================================
			**Parameters**   **type**   **Description**
			*ind*            int        the indice of the column to xtract
			=============== ========== ====================================

			Returns
			-------
			List
				The list containig all the matrix column values

			Examples
			--------
			>>> mat=unit(4)
			>>> mat.column(0)
			[1, 0, 0, 0]
			>>> mat.column(1)
			[0, 1, 0, 0]
			>>> mat.column(2)
			[0, 0, 1, 0]
			>>> mat.column(3)
			[0, 0, 0, 1]

		"""
		cdef list res 
		cdef int i 

		res=[]
		for i in range(0,self.size_raw):
			res.append(self.get_ij(i,ind))
		return res 

	cpdef list line(self,int ind):
		"""
			Extract the ind line of the self Matrix object.

			=============== ========== ====================================
			**Parameters**   **type**   **Description**
			*ind*            int        the indice of the line to xtract
			=============== ========== ====================================

			Returns
			-------
			List
				The list containig all the matrix line values

			Examples
			--------
			>>> mat=unit(4)
			>>> mat.line(0)
			[1, 0, 0, 0]
			>>> mat.line(1)
			[0, 1, 0, 0]
			>>> mat.line(2)
			[0, 0, 1, 0]
			>>> mat.line(3)
			[0, 0, 0, 1]

			See Also
			--------
			:func:`get_ij`
		"""
		cdef list res 
		cdef int i

		res=[]	
		for i in range(0,self.size_column):
			res.append(self.get_ij(ind,i))
		return res 

	cpdef Matrix swap_col(self,int a,int b):
		"""
			Swap the two given columns of the self matrix object from the given a and b index

			=============== ========== =========================
			**Parameters**   **Type**   **Description**
			*a*              int        the first column index
			*b*              int        the second column index
			=============== ========== =========================

			Returns
			-------
			Matrix
				The matrix with a-th and b-th column swaped

			Examples
			--------
			>>> m=rand(4)
			>>> print(m)
			| +4.000 | +14.000 | +10.000 | +16.000 |
			| +7.000 | +9.000 | +13.000 | +9.000 |
			| +3.000 | +7.000 | +7.000 | +6.000 |
			| +3.000 | +2.000 | +9.000 | +16.000 |
			printed
			>>> print(m.swap_col(0,2))
			| +10.000 | +14.000 | +4.000 | +16.000 |
			| +13.000 | +9.000 | +7.000 | +9.000 |
			| +7.000 | +7.000 | +3.000 | +6.000 |
			| +9.000 | +2.000 | +3.000 | +16.000 |
			printed

			See Also
			--------
			:func:`size_r`
			:func:`get_ij`
			:func:`set_ij`
		"""
		cdef list tmpa
		cdef list tmpb
		cdef int i

		tmpa=[]
		tmpb=[]
		for i in range(0,self.size_r()):
			tmpa.append(self.get_ij(i,a))
			tmpb.append(self.get_ij(i,b))
			self.set_ij(i,a,tmpb[i])
			self.set_ij(i,b,tmpa[i])
		return self 

	cpdef Matrix swap_line(self,int a,int b):
		"""
			Swap the two given lines of the self matrix object from the given a and b index

			=============== ========== =========================
			**Parameters**   **Type**   **Description**
			*a*              int        the first line index
			*b*              int        the second line index
			=============== ========== =========================

			Returns
			-------
			Matrix
				The matrix with a-th and b-th line swaped

			Examples
			--------
			>>> m=rand(4)
			>>> print(m)
			| +13.000 | +5.000 | +8.000 | +1.000 |
			| +13.000 | +13.000 | +6.000 | +5.000 |
			| +16.000 | +0.000 | +0.000 | +0.000 |
			| +10.000 | +2.000 | +16.000 | +13.000 |
			printed
			>>> print(m.swap_line(0,2))
			| +16.000 | +0.000 | +0.000 | +0.000 |
			| +13.000 | +13.000 | +6.000 | +5.000 |
			| +13.000 | +5.000 | +8.000 | +1.000 |
			| +10.000 | +2.000 | +16.000 | +13.000 |
			printed

			See Also
			--------
			:func:`size_r`
			:func:`get_ij`
			:func:`set_ij`
		"""
		cdef list tmpa 
		cdef list tmpb 
		cdef int i

		tmpa=[]
		tmpb=[]
		for i in range(0,self.size_c()):
			tmpa.append(self.get_ij(a,i))
			tmpb.append(self.get_ij(b,i))
			self.set_ij(a,i,tmpb[i])
			self.set_ij(b,i,tmpa[i])
		return self

	cpdef Matrix mirror_mat(self,int mode):
		"""
			Create the mirror matrix from the self matrix object from the given mode argument

			=============== ========== ================================================
			**Parameters**   **Type**   **Description**
			*mode*           int        mode define the profile of algorithm between :
			                             * 0 => vertical  mirror
			                             * 1 => horizontal mirror
			=============== ========== ================================================

			Returns
			-------
			Matrix
				The self mirror matrix

			Examples
			--------
			>>> m=rand(4)
			>>> print(m)
			| +5.000 | +14.000 | +8.000 | +6.000 |
			| +14.000 | +11.000 | +4.000 | +0.000 |
			| +2.000 | +14.000 | +12.000 | +0.000 |
			| +16.000 | +0.000 | +11.000 | +4.000 |
			printed
			>>> print(m.mirror_mat(0))
			| +6.000 | +8.000 | +14.000 | +5.000 |
			| +0.000 | +4.000 | +11.000 | +14.000 |
			| +0.000 | +12.000 | +14.000 | +2.000 |
			| +4.000 | +11.000 | +0.000 | +16.000 |
			printed
			>>> print(m.mirror_mat(1))
			| +16.000 | +0.000 | +11.000 | +4.000 |
			| +2.000 | +14.000 | +12.000 | +0.000 |
			| +14.000 | +11.000 | +4.000 | +0.000 |
			| +5.000 | +14.000 | +8.000 | +6.000 |
			printed

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`clone`
			:func:`transpose`
			:func:`swap_col`
		"""
		cdef Matrix res 
		cdef int i 
		cdef int midle 
		
		res=Matrix(self.size_r(),self.size_c(),0.0)
		if(not mode):
			res=self.clone()
		else:
			res=self.clone().transpose()
		for i in range(0,int(self.size_c()/2)):
			if(res.size_c()%2==0):
				res.swap_col(i,self.size_c()-i-1)
			else:
				midle=int(self.size_c()/2)
				if(i!=midle):
					res.swap_col(i,self.size_c()-i-1)
		if(not mode):
			return res
		else:
			return res.transpose()

	cpdef list nth_diagonal(self,int n,int mode,bint rec=False):
		"""
			Get the nth diagonal from the current matrix and given n as a list.
			
			============== =========== ================================================
			**Parameters**   **Type**   **Description**
			*n*              int        the diagonal index to xtract
			*mode*           int        mode define the profile of algorithm between : 
			                               * 0 => ascendant
			                               * 1=> descendent
			*rec*            boolean    Recursion manager
			============== =========== ================================================

			Returns
			-------
			List
				the list containing the expected n-th diagonal

			Examples
			--------
			>>> m=rand(4)
			>>> print(m)
			| +13.000 | +6.000 | +9.000 | +9.000 |
			| +12.000 | +16.000 | +2.000 | +13.000 |
			| +3.000 | +8.000 | +5.000 | +2.000 |
			| +12.000 | +11.000 | +11.000 | +9.000 |
			printed
			>>> for i in range(0,7):
			...     print(m.nth_diagonal(i,0))
			...
			[13.0]
			[6.0, 12.0]
			[9.0, 16.0, 3.0]
			[9.0, 2.0, 8.0, 12.0]
			[13.0, 5.0, 11.0]
			[2.0, 11.0]
			[9.0]
			>>> for i in range(0,7):
			...     print(m.nth_diagonal(i,1))
			...
			[12.0]
			[3.0, 11.0]
			[12.0, 8.0, 11.0]
			[13.0, 16.0, 5.0, 9.0]
			[6.0, 2.0, 2.0]
			[9.0, 13.0]
			[9.0]

			See Also
			--------
			:func:`size_r`
			:func:`nth_diagonal`
			:func:`mirror_mat`
			:func:`get_ij`
			:func:`reverse`
		"""
		cdef list res 
		cdef int i
		cdef int j

		res=[]
		j=n
		if(n>=self.size_r() and (not rec)):
			return self.nth_diagonal((n+1),mode,True)

		if(mode):
			self=self.mirror_mat(1)
		if(n==0):
			return [self.get_ij(0,0)]
		else:
			if(n<self.size_r()):
				for i in range(0,n+1):
					res.append(self.get_ij(i,j))
					j-=1
			else:
				i=j%self.size_r()
				j=self.size_r()-1
				while(i<self.size_r()):
					res.append(self.get_ij(i,j))
					j-=1
					i+=1
		if mode:
			return reverse(res)
		else:
			return res

	cpdef double get_coef(self):
		"""
			Return the coefficient to mean a filter mask

			returns
			-------
			float
				The computed coef.

			Examples
			--------
			>>> mat=gaussian(3,0,0)
			>>> Print(mat)
			| +1.000 | +2.000 | +1.000 |
			| +2.000 | +4.000 | +2.000 |
			| +1.000 | +2.000 | +1.000 |
			printed
			>>> mat.get_coef()
			0.0625

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`get_ij`
		"""
		cdef double summ 
		cdef int i
		cdef int j

		summ=0
		for i in range(self.size_r()):
			for j in range(0,self.size_c()):
				summ+=self.get_ij(i,j)
		self.coef=1/summ
		return self.coef

	cpdef double mul_coef(self,double x):
		return x*self.coef

	cpdef Matrix resize(self,double ratio=0.5):
		"""
			Resize the self matrix from given float ratio.
			A ratio of 0.5 mean the half matrix as a result

			=============== ========= =========================
			**Parameters**   **Type**   **Description**
			*ratio*          float      The ratio of resizing
			=============== ========= =========================

			Returns
			-------
			Matrix
				The proportionnaly resized matrix.

			Examples
			--------
			>>> from matrix import *
			>>> t=rand(8)
			>>> Print(t)
			| +40.000 | +17.000 | +61.000 | +56.000 | +60.000 | +4.000 | +52.000 | +55.000 |
			| +27.000 | +12.000 | +27.000 | +29.000 | +9.000 | +22.000 | +50.000 | +57.000 |
			| +45.000 | +32.000 | +24.000 | +40.000 | +29.000 | +16.000 | +10.000 | +12.000 |
			| +13.000 | +28.000 | +27.000 | +46.000 | +1.000 | +57.000 | +34.000 | +25.000 |
			| +63.000 | +22.000 | +39.000 | +55.000 | +2.000 | +22.000 | +26.000 | +15.000 |
			| +1.000 | +11.000 | +25.000 | +3.000 | +15.000 | +43.000 | +14.000 | +6.000 |
			| +54.000 | +42.000 | +59.000 | +53.000 | +23.000 | +35.000 | +54.000 | +13.000 |
			| +44.000 | +38.000 | +31.000 | +64.000 | +47.000 | +32.000 | +5.000 | +44.000 |
			printed
			>>> Print(t.resize(0.5))
			| +40.000 | +61.000 | +60.000 | +52.000 |
			| +45.000 | +24.000 | +29.000 | +10.000 |
			| +63.000 | +39.000 | +2.000 | +26.000 |
			| +54.000 | +59.000 | +23.000 | +54.000 |
			printed

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`set_ij`
			:func:`get_ij`
		"""
		cdef int i
		cdef int j
		cdef int k
		cdef int l
		cdef int ind
		cdef int size_r
		cdef int size_c
		cdef int step_r
		cdef int step_c
		cdef list interpolate
		cdef Matrix res

		i=0
		j=0
		k=0
		size_r=int(self.size_r()*ratio)
		size_c=int(self.size_c()*ratio)
		res=Matrix(size_r,size_c)
		step_r=int(self.size_r()/size_r)
		step_c=int(self.size_c()/size_c)
		l=0
		ind=0
		if(ratio<=1):
			# Assert validity of ratio
			k=0
			l=0
			for k in range(0,size_r):
				for j in range(0,self.size_c()):
					if(j%step_c==0):
						res.set_ij(k,l,self.get_ij(k*step_r,j))
						l+=1
				l=0
			res.size_raw=size_r
			res.size_column=size_c
		else:
			# To test
			interpolate=[]
			ind=0
			for i in range(0,size_r):
				for j in range(0,size_c):
					if(i%step_r==0):
						res.set_ij(i,j,self.get_ij(k,l))
						k+=1
					elif(j%step_c==0):
						res.set_ij(i,j,self.get_ij(k,l))
						l+=1 
						interpolate=[(k*(self.get_ij(i,k)-self.get_ij(i,k-1))/(int(res.size_r()/self.size_r())+1)+self.get_ij(i,k-1)) for k in range(0,int(res.size_r()/self.size_r())+1)]
						# interpolate=[(k*(b-a)/nb_step)+a for k in range(0,nb_step)]
						ind=0
					else:
						# interpolated values assignement
						res.set_ij(i,j,interpolate[ind])
						ind+=1
		return res

	cpdef Matrix accumulate(self,int mode):
		"""
			Sum accumulator function ruled by mode argument.
			Realize the cummulated sum depending on direction.

			============== ==========  ===================================
			**Parameters**   **Type**   **Description**
			*mode*           int        Switch the mode between :
											* 0 => vectorized horizontal
											* 1 => vectorized vertical
											* 2 => matrix vertical
											* 3 => matrix horizontal
			============== ==========  ===================================

			Returns
			-------
			Matrix
				The accumulated matrix

			Examples
			--------
			>>> from matrix import *
			>>> t=rand(4)
			>>> Print(t)
			| +2.000 | +3.000 | +3.000 | +2.000 |
			| +5.000 | +6.000 | +0.000 | +15.000 |
			| +10.000 | +6.000 | +1.000 | +1.000 |
			| +14.000 | +10.000 | +9.000 | +16.000 |
			printed
			>>> print(t.accumulate(0).data)
			[10, 26, 18, 49]
			>>> print(t.accumulate(1).data)
			[31, 25, 13, 34]
			>>> Print(t.accumulate(2))
			| +2.000 | +3.000 | +3.000 | +2.000 |
			| +7.000 | +9.000 | +3.000 | +17.000 |
			| +17.000 | +15.000 | +4.000 | +18.000 |
			| +31.000 | +25.000 | +13.000 | +34.000 |
			printed
			>>> Print(t.accumulate(3))
			| +2.000 | +5.000 | +8.000 | +10.000 |
			| +5.000 | +11.000 | +11.000 | +26.000 |
			| +10.000 | +16.000 | +17.000 | +18.000 |
			| +14.000 | +24.000 | +33.000 | +49.000 |
			printed

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`get_ij`
			:func:`set_ij`
		"""
		cdef int i
		cdef int j
		cdef double tmp
		cdef Matrix res

		tmp=0
		if(mode==0):
			res=Matrix(self.size_r(),1,0)
		elif(mode==1):
			res=Matrix(1,self.size_c(),0)
		elif(mode==2 or mode==3):
			res=Matrix(self.size_r(),self.size_c(),0)
		if(mode==0):
			i=0
			while(i!=self.size_r()):
				for j in range(0,self.size_c()):
					tmp+=self.get_ij(i,j)
				res.set_ij(i,0,tmp)
				tmp=0
				i+=1
		elif(mode==1):
			j=0
			while(j!=self.size_c()):
				for i in range(0,self.size_r()):
					tmp+=self.get_ij(i,j)
				res.set_ij(0,j,tmp)
				tmp=0
				j+=1
		elif(mode==2):
			for j in range(0,self.size_c()):
				for i in range(1,self.size_r()+1):
					tmp+=self.get_ij(i-1,j)
					res.set_ij(i-1,j,tmp)
				tmp=0
		elif(mode==3):
			for i in range(0,self.size_r()):
				for j in range(1,self.size_c()+1):
					tmp+=self.get_ij(i,j-1)
					res.set_ij(i,j-1,tmp)
				tmp=0
		return res

# #%%

# ######################################
# ########### Matrix algebra ###########
# ######################################

	cpdef bint square(self):
		"""
			Test the square propriety of the matrix.

			Returns
			-------
			int
				1 mean square matrix
				0 mean not square matrix

			Examples
			--------
			>>> mat.get_coef()
			0.0625
			>>> mat=unit(3)
			>>> mat.square()
			True
			>>> mat=Matrix(1,3,0.3)
			>>> mat.square()
			False
		"""
		return(self.size_raw==self.size_column)

	cpdef Matrix transpose (self):
		"""
			Transpose the self Matrix.

			Returns
			-------
				Matrix
				The transposed matrix

			Examples
			--------
			>>> t=Matrix(3,3,0)
			>>> for i in range(0,3):
			...     for j in range(0,3):
			...             t.set_ij(i,j,i*j+i)
			...
			>>> Print(t)
			| +0.000 | +0.000 | +0.000 |
			| +1.000 | +2.000 | +3.000 |
			| +2.000 | +4.000 | +6.000 |
			printed
			>>> tr=t.transpose()
			>>> Print(tr)
			| +0.000 | +1.000 | +2.000 |
			| +0.000 | +2.000 | +4.000 |
			| +0.000 | +3.000 | +6.000 |
			printed

			See Also
			--------
			:func:`size_c`
			:func:`size_r`
			:func:`set_ij`
			:func:`get_ij`
		"""
		cdef Matrix res 
		cdef int i 
		cdef int j

		res=Matrix(self.size_c(),self.size_r())
		for i in range(0,self.size_c()):
			for j in range(0,self.size_r()):
				res.set_ij(i,j,self.get_ij(j,i))
		return res

	cpdef Matrix permut(self,list permut,int mode=0):
		"""
			Do the permutation of the self matrix with the given signed permutation.

			=============== ========== ============================================
			**Parameters**   **type**   **Description**
			*Permut*         int list   list representing the signed permutation
										([2,0,1] mean [a,b,c] become [c,a,b])
			*mode*           int        Algorithm mode :
											* O mean vertical permutation
											* 1 mean horizontal permutation
			=============== ========== ============================================

			Returns
			-------
				Matrix
					The permuted matrix from the given signed permutation (as vector)

			Examples
			--------
			>>> m=rand(4)
			>>> print(m)
			| +13.000 | +14.000 | +12.000 | +0.000 |
			| +7.000 | +7.000 | +13.000 | +10.000 |
			| +10.000 | +4.000 | +2.000 | +16.000 |
			| +6.000 | +12.000 | +7.000 | +11.000 |
			printed
			>>> permut=[1,0,3,2]
			>>> print(m.permut(permut,0))
			| +14.000 | +7.000 | +4.000 | +12.000 |
			| +13.000 | +7.000 | +10.000 | +6.000 |
			| +0.000 | +10.000 | +16.000 | +11.000 |
			| +12.000 | +13.000 | +2.000 | +7.000 |
			printed
			>>> print(m.permut(permut,1))
			| +7.000 | +13.000 | +6.000 | +10.000 |
			| +7.000 | +14.000 | +12.000 | +4.000 |
			| +13.000 | +12.000 | +7.000 | +2.000 |
			| +10.000 | +0.000 | +11.000 | +16.000 |
			printed

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`square`
			:func:`transpose`
		"""
		cdef int length
		cdef int i
		cdef Matrix permut_mat	
		cdef Matrix res
		cdef Matrix tmp

		res=Matrix(self.size_r(),self.size_c())	
		length=self.size_r()
		if((len(permut)==length) and (self.square())):
			permut_mat=Matrix(length,length)
			for i in range(0,length):
				permut_mat[i,permut[i]]=1
			if(not mode):
				res=permut_mat.transpose()*self
				return res.transpose()
			else:
				self=self.transpose()
				res=permut_mat.transpose()*self 
				return res

	cpdef Matrix triangle(self,int mode):
		"""
			Get the triangle (respectively up or down) of the self matrix

			=============== ========== ==========================
			**Parameters**   **type**   **Description**
			*mode*           int        Mode mean : 1 sup, 0 inf
			=============== ========== ==========================

			Returns
			-------
				Matrix
					The triangle matrix from self matrix

			Examples
			--------
			>>> t=gaussian(5,0,0)
			>>> t.triangle(0) # inferior profile
			>>> Print(t)
			| +1.000 | +0.000 | +0.000 | +0.000 | +0.000 |
			| +4.000 | +16.000 | +0.000 | +0.000 | +0.000 |
			| +6.000 | +24.000 | +36.000 | +0.000 | +0.000 |
			| +4.000 | +16.000 | +24.000 | +16.000 | +0.000 |
			| +1.000 | +4.000 | +6.000 | +4.000 | +1.000 |
			printed
			>>> t=gaussian(5,0,0)
			>>> t.triangle(1) # superior profile
			>>> Print(t)
			| +0.000 | +4.000 | +6.000 | +4.000 | +1.000 |
			| +0.000 | +0.000 | +24.000 | +16.000 | +4.000 |
			| +0.000 | +0.000 | +0.000 | +24.000 | +6.000 |
			| +0.000 | +0.000 | +0.000 | +0.000 | +4.000 |
			| +0.000 | +0.000 | +0.000 | +0.000 | +0.000 |
			printed
			
			See Also
			--------
			:func:`clone`
			:func:`set_ij`
		"""
		cdef int i
		cdef int j
		cdef Matrix res

		res=self.clone()
		for i in range(0,res.size_raw):
			for j in range(0,res.size_column):
				if (mode):
					if(j<=i):
						res.set_ij(i,j,0)
				else:
					if(j>i):
						res.set_ij(i,j,0)
		return res

	cpdef Matrix strassen(self,Matrix m2):
		"""
			Compute the multiply using the Strassen algorithm to get faster multiplication(not necessary on small matrix).

			Strassen algorithm is evaluate in 6 steps :
				* Split the self matrix into 4 equal-length submatrix
				* Split the second term matrix into 4 equal-length submatrix
				* Allocating memory for temporary computing
				* Apply the Strassen multiplication rules (M matrix)
				* Compute the C matrix from M Matrix
				* Rebuild the final matrix with temporary matrix

			=============== ========== ==========================================
			**Parameters**   **type**   **Description**
			*m2*             Matrix     The second member of the multiplication
			=============== ========== ==========================================

			Returns
			-------
				Matrix
					The computed multiplication.

			Examples
			--------
			>>> m=rand(4)
			>>> u=unit(4)
			>>> print(m)
			| +14.000 | +12.000 | +12.000 | +1.000 |
			| +7.000 | +16.000 | +8.000 | +8.000 |
			| +9.000 | +6.000 | +8.000 | +2.000 |
			| +11.000 | +1.000 | +8.000 | +7.000 |
			printed
			>>> print(u)
			| +1.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +1.000 |
			printed
			>>> print(m.strassen(u))
			| +14.000 | +12.000 | +12.000 | +1.000 |
			| +7.000 | +16.000 | +8.000 | +8.000 |
			| +9.000 | +6.000 | +8.000 | +2.000 |
			| +11.000 | +1.000 | +8.000 | +7.000 |
			printed

			See Also
			--------
			:func:`square`
			:func:`size_r`
			:func:`xtract_sub_matrix`
			:func:`set_ij`
			:func:`get_ij`
		"""
		cdef int local_length
		cdef Matrix a_11
		cdef Matrix a_12
		cdef Matrix a_21
		cdef Matrix a_22
		cdef Matrix b_11
		cdef Matrix b_12
		cdef Matrix b_21
		cdef Matrix b_22
		cdef Matrix m_1
		cdef Matrix m_2
		cdef Matrix m_3
		cdef Matrix m_4
		cdef Matrix m_5
		cdef Matrix m_6
		cdef Matrix m_7
		cdef Matrix c_11
		cdef Matrix c_12
		cdef Matrix c_21
		cdef Matrix c_22
		cdef Matrix res

		if(self.square() and self.size_r() % 2==0 ):
			local_length=int(self.size_r()/2)

			#Representing the self splitted matrix                                       
			a_11=self.xtract_sub_matrix((0,0),(local_length,local_length))
			a_12=self.xtract_sub_matrix((0,local_length),(local_length,self.size_r()))
			a_21=self.xtract_sub_matrix((local_length,0),(self.size_r(),local_length))
			a_22=self.xtract_sub_matrix((local_length,local_length),(self.size_r(),self.size_r()))

			#Representing the m2 splitted matrix
			b_11=m2.xtract_sub_matrix((0,0),(local_length,local_length))
			b_12=m2.xtract_sub_matrix((0,local_length),(local_length,self.size_r()))
			b_21=m2.xtract_sub_matrix((local_length,0),(self.size_r(),local_length))
			b_22=m2.xtract_sub_matrix((local_length,local_length),(self.size_r(),self.size_r()))

			#temp matrix sub-computing memory allocation
			m_1=Matrix(local_length,local_length)
			m_2=Matrix(local_length,local_length)
			m_3=Matrix(local_length,local_length)
			m_4=Matrix(local_length,local_length)
			m_5=Matrix(local_length,local_length)
			m_6=Matrix(local_length,local_length)
			m_7=Matrix(local_length,local_length)

			#Strassen apply
			m_1=(a_11+a_22)*(b_11+b_22)
			m_2=(a_21+a_22)*b_11
			m_3=a_11*(b_12-b_22)
			m_4=a_22*(b_21-b_11)
			m_5=(a_11+a_12)*b_22
			m_6=(a_21-a_11)*(b_11+b_12)
			m_7=(a_12-a_22)*(b_21+b_22)

			#Strassen assembly
			c_11=m_1+m_4-m_5+m_7
			c_12=m_3+m_5
			c_21=m_2+m_4
			c_22=m_1-m_2+m_3+m_6

			#matrix reconstruction
			res=Matrix(self.size_r(),self.size_r())
			for i in range(0,local_length):
				for j in range(0,local_length):
					res.set_ij(i,j,c_11.get_ij(i,j))
					res.set_ij(i,j+local_length,c_12.get_ij(i,j))
					res.set_ij(i+local_length,j,c_21.get_ij(i,j))
					res.set_ij(i+local_length,j+local_length,c_22.get_ij(i,j))

			return res

	cpdef Matrix tensorial_product(self,Matrix mat):
		"""
			Compute the tensorial product between self Matrix and the mat argument.

			===============  =========== ===========================
			**Parameters**    **type**   **Description**
			*mat*            Matrix       The second operand matrix
			===============  =========== ===========================

			Returns
			-------
				Matrix
					The double sized matrix result of the tenso product

			Examples
			--------
			>>> #Matrix Tensor Profile
			>>> m=rand(4)
			>>> tensor=Matrix(2,2)
			>>> tensor[0,0]=1
			>>> tensor[0,1]=1
			>>> tensor[1,0]=2
			>>> tensor[1,1]=2
			>>> print(m)
			| +14.000 | +5.000 | +4.000 | +2.000 |
			| +10.000 | +0.000 | +9.000 | +3.000 |
			| +14.000 | +1.000 | +3.000 | +13.000 |
			| +5.000 | +0.000 | +3.000 | +3.000 |
			printed
			>>> print(tensor)
			| +1.000 | +1.000 |
			| +2.000 | +2.000 |
			printed
			>>> print(m.tensorial_product(tensor))
			| +14.000 | +5.000 | +4.000 | +2.000 | +14.000 | +5.000 | +4.000 | +2.000 |
			| +20.000 | +0.000 | +18.000 | +6.000 | +20.000 | +0.000 | +18.000 | +6.000 |
			| +14.000 | +1.000 | +3.000 | +13.000 | +14.000 | +1.000 | +3.000 | +13.000 |
			| +10.000 | +0.000 | +6.000 | +6.000 | +10.000 | +0.000 | +6.000 | +6.000 |
			| +14.000 | +5.000 | +4.000 | +2.000 | +14.000 | +5.000 | +4.000 | +2.000 |
			| +20.000 | +0.000 | +18.000 | +6.000 | +20.000 | +0.000 | +18.000 | +6.000 |
			| +14.000 | +1.000 | +3.000 | +13.000 | +14.000 | +1.000 | +3.000 | +13.000 |
			| +10.000 | +0.000 | +6.000 | +6.000 | +10.000 | +0.000 | +6.000 | +6.000 |
			printed
			>>> #Vector Tensor Profile
			>>> m=rand(4)
			>>> print(m)
			| +8.000 | +2.000 | +15.000 | +16.000 |
			| +2.000 | +9.000 | +6.000 | +13.000 |
			| +7.000 | +5.000 | +3.000 | +7.000 |
			| +7.000 | +15.000 | +5.000 | +0.000 |
			printed
			>>> tensor=Matrix(2,1)
			>>> tensor[0,0]=1
			>>> tensor[1,0]=2
			>>> print(m.tensorial_product(tensor))
			| +8.000 | +2.000 | +15.000 | +16.000 |
			| +16.000 | +4.000 | +30.000 | +32.000 |
			| +8.000 | +2.000 | +15.000 | +16.000 |
			| +16.000 | +4.000 | +30.000 | +32.000 |
			| +2.000 | +9.000 | +6.000 | +13.000 |
			| +4.000 | +18.000 | +12.000 | +26.000 |
			| +2.000 | +9.000 | +6.000 | +13.000 |
			| +4.000 | +18.000 | +12.000 | +26.000 |
			printed

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`set_ij`
			:func:`get_ij`
			:func:`transpose`
		"""

		cdef int i
		cdef int j
		cdef int k
		cdef int l
		cdef int m
		cdef int n
		cdef Matrix res 
		cdef Matrix tmp

		#Matrix profile
		if(self.size_r()>1 and self.size_c()>1): 
			k=self.size_r() 
			l=self.size_c() 
			m=mat.size_r() 	
			n=mat.size_c() 

			res=Matrix(k*m,l*n,0.0)
			
			if(self.size_c()==res.size_c() and self.size_r()<res.size_r()):
				mode=2
			elif(self.size_r()==res.size_r() and self.size_c()<res.size_c()):
				mode=1
			else:
				mode=0

			for i in range(0,res.size_r()):
				for j in range(0,res.size_c()):
					# res.set_ij(i,j,self.get_ij(int(i/k),int(j/l))*mat.get_ij(i%mat.size_r(),j%mat.size_c()))
					if mode==1:
						res.set_ij(i,j,self.get_ij(int(i%k),int(j/l))*mat.get_ij(i%mat.size_r(),j%mat.size_c()))
					elif mode==2:
						res.set_ij(i,j,self.get_ij(int(i/k),int(j%l))*mat.get_ij(i%mat.size_r(),j%mat.size_c()))
					else:
						res.set_ij(i,j,self.get_ij(int(i%k),int(j%l))*mat.get_ij(i%mat.size_r(),j%mat.size_c()))

			return res
		#Vectorial profile
		else:                 
			tmp=self
			if(self.size_r()==1):
				tmp=self.transpose()
			if(mat.size_c()==1):
				mat=mat.transpose()
			res=Matrix(tmp.size_r(),mat.size_c())
			for i in range(tmp.size_r()):
				for j in range(mat.size_c()):
					res.set_ij(i,j,tmp.get_ij(i,0)*mat.get_ij(0,j))
			return res


	cpdef double trace(self):
		"""
			Trace the current matrix

			Returns
			-------
				double
					The computed trace of the matrix

			Examples
			--------
			>>> m=rand(4)
			>>> print(m)
			| +0.000 | +6.000 | +8.000 | +4.000 |
			| +8.000 | +11.000 | +13.000 | +0.000 |
			| +15.000 | +10.000 | +15.000 | +4.000 |
			| +11.000 | +2.000 | +1.000 | +10.000 |
			printed
			>>> print(m.trace())
			36.0

			See Also
			--------
			:func:`size_r`
			:func:`get_ij`
		"""
		cdef int i
		cdef double res
		res=0
		for i in range(0,self.size_r()):
			res+=self.get_ij(i,i)
		return res

	cpdef Matrix convolve(self,Matrix mask):
		"""
			Convolve filtering data matrix using the given mask.

			=============== =========== ==================================
			**Parameters**    **Type**   **Description**
			*mask*            Matrix     The convolution mask as a matrix
			=============== =========== ==================================

			Returns
			-------
				Matrix
					The convolution product result between self matrix and the given mask

			Examples
			--------
			>>> mask=gaussian(3,0,1)
			>>> print(mask)
			| +0.062 | +0.125 | +0.062 |
			| +0.125 | +0.250 | +0.125 |
			| +0.062 | +0.125 | +0.062 |
			printed
			>>> m=rand(5)
			>>> print(m)
			| +11.000 | +11.000 | +11.000 | +24.000 | +4.000 |
			| +2.000 | +17.000 | +2.000 | +11.000 | +17.000 |
			| +1.000 | +19.000 | +22.000 | +14.000 | +14.000 |
			| +7.000 | +20.000 | +18.000 | +17.000 | +15.000 |
			| +19.000 | +1.000 | +1.000 | +5.000 | +18.000 |
			printed
			>>> print(m.convolve(mask))
			| +9.625 | +15.625 | +14.438 | +11.562 | +6.750 |
			| +10.625 | +15.875 | +14.938 | +11.188 | +6.875 |
			| +11.688 | +14.062 | +14.188 | +10.500 | +8.000 |
			| +9.000 | +9.750 | +10.188 | +7.875 | +6.688 |
			| +11.312 | +10.438 | +8.938 | +5.438 | +6.938 |
			printed

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`insert_sub_matrix`
		"""
		cdef int ind 
		cdef int d
		cdef int e
		cdef int i
		cdef int j
		cdef int k
		cdef int l
		cdef double tmp 
		cdef Matrix ret 
		cdef Matrix res 

		ind=0
		d = int(mask.size_r()/2) +1
		e = int(mask.size_c()/2) +1
		ret=Matrix(self.size_r()+d,self.size_c()+e)
		ret.insert_sub_matrix((1,1),self)
		res=Matrix(self.size_r(),self.size_c())
		for i in range(d-1,self.size_r()+d-1):
			for j in range(e-1,self.size_c()+e-1):
				tmp=0
				k=i+d-1
				while(k!=i-e):
					l=j+e-1
					while(l!=j-e):
						tmp+=ret.get_ij(k,l)*mask.get_ij(mask.size_r()-(k%mask.size_r())-1,mask.size_c()-(l%mask.size_c())-1)
						l-=1
					k-=1
				res.set_ij(i-d,j-e,tmp)
		# return res.xtract_sub_matrix([d,e],[res.size_r()-d,res.size_c()-e])
		return res

# TODO : CATCH set_ij error
	cpdef Matrix convolve_signal(self,Matrix convolution_mask,int mode=0):
		"""
			Convolve self object (as a 1D signal) with given convolution mask (also as 1D signal)

			===================  ========= ================================================
			**Parameters**       **Type**   **Description**
			*convolution_mask*   Matrix     1D Matrix representing the convolution mask
			*mode*               Int        Define the algorithme profile between
												* 0 => full convolution algorithm
												* 1 => convolution algorithm preservng time
			===================  ========= ================================================

			Returns
			-------
			Matrix
				The 1D matrix containing the convolved signal.

			Examples
			--------
			>>> m=Matrix(1,8)
			>>> import random as r
			>>> for i in range(0,8):
			...     m[0,i]=r.randint(0,50)
			...
			>>> mask=Matrix(1,3)
			>>> for i in range(0,3):
			...     mask[0,i]=r.randint(0,10)
			...
			>>> print(m)
			| +25.000 | +8.000 | +41.000 | +20.000 | +28.000 | +23.000 | +17.000 | +45.000 |
			printed
			>>> print(mask)
			| +1.000 | +5.000 | +9.000 |
			printed
			>>> print(m.convolve_signal(mask))
			| +25.000 | +133.000 | +306.000 | +297.000 | +497.000 | +343.000 | +384.000 | +337.000 | +378.000 | +405.000 | +0.000 | +0.000 | +0.000 | +0.000 |
			printed

			See Also
			--------
			:func:`size_c`
			:func:`set_ij`
			:func:`get_ij`
			:func:`size_r`
			:func:`nth_diagonal`
		"""
		cdef Matrix swap 
		cdef Matrix tmp 
		cdef Matrix res 
		cdef Matrix Mres
		cdef list diag 
		cdef int i
		cdef int ind
		cdef int step
		cdef double summ

		# Packing matrix to optimise fast convolution computing
		if(self.size_c()!=convolution_mask.size_c()):
			swap=convolution_mask
			convolution_mask=Matrix(1,self.size_c())
			for i in range(0,convolution_mask.size_c()):
				if(i<swap.size_c()):
					convolution_mask.set_ij(0,i,swap.get_ij(0,i))
				else:
					convolution_mask.set_ij(0,i,0)

		# Convolution algorithm
		tmp=Matrix(self.size_c(),convolution_mask.size_c(),0.0)
		diag=[]
		for i in range(0,tmp.size_r()):
			for j in range(0,tmp.size_c()):
				tmp.set_ij(i,j,self.get_ij(0,self.size_c()-i-1)*convolution_mask.get_ij(0,j))


		res=Matrix(1,self.size_c()+convolution_mask.size_c()-2)
		for i in range(0,res.size_c()):
			summ=0
			diag=[]
			diag=tmp.nth_diagonal(i,1)
			for j in range(0,len(diag)):
				summ+=diag[j]
			res.set_ij(0,i,summ)

		if (mode):
			step=round(res.size_c()/self.size_c(),0)
			ind = 0
			Mres=Matrix(1,self.size_c(),0.0)
			for i in range(0,res.size_c()):
				if(i%step==0):
					Mres.set_ij(0,ind,res.get_ij(0,i))
					ind+=1
			if(Mres.get_ij(0,Mres.size_c()-1)==0.0):
				Mres.set_ij(0,Mres.size_c()-1,res.get_ij(0,res.size_c()-1))
			del res
			return Mres
		else:
			return res

	cpdef AtoB(self,Matrix mat,double ratio=0.5):
		"""
			Compute the meaned matrix between self and given mat.
			Can be used to generate mutants matrix derivative/interpolated from self and mat.

			=============== ========== ================================
			**Parameters**   **Type**   **Description**
			*mat*            Matrix     The matrix to mean with self
			*ratio*          float      The balace ratio between matrix
										Must be in [0,1]
			=============== ========== ================================

			Returns
			-------
				Matrix
					The linear interpolated matrix computed from the mat parameter and the ratio
					The ratio determine the multiplicative coefficient.

			Examples
			--------
			>>> Print(t)
			| +1.000 | +4.000 | +6.000 | +4.000 | +1.000 |
			| +4.000 | +16.000 | +24.000 | +16.000 | +4.000 |
			| +6.000 | +24.000 | +36.000 | +24.000 | +6.000 |
			| +4.000 | +16.000 | +24.000 | +16.000 | +4.000 |
			| +1.000 | +4.000 | +6.000 | +4.000 | +1.000 |
			printed
			>>> Print(u)
			| +1.000 | +0.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +1.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +1.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +0.000 | +1.000 |
			printed
			>>> v=t.AtoB(u) # 0.5 ration as default
			>>> Print(v)
			| +1.000 | +2.000 | +3.000 | +2.000 | +0.500 |
			| +2.000 | +8.500 | +12.000 | +8.000 | +2.000 |
			| +3.000 | +12.000 | +18.500 | +12.000 | +3.000 |
			| +2.000 | +8.000 | +12.000 | +8.500 | +2.000 |
			| +0.500 | +2.000 | +3.000 | +2.000 | +1.000 |
			printed
			>>> v=t.AtoB(u,0.1) # Personalize ratio as the last arg
			>>> Print(v)
			| +1.000 | +0.400 | +0.600 | +0.400 | +0.100 |
			| +0.400 | +2.500 | +2.400 | +1.600 | +0.400 |
			| +0.600 | +2.400 | +4.500 | +2.400 | +0.600 |
			| +0.400 | +1.600 | +2.400 | +2.500 | +0.400 |
			| +0.100 | +0.400 | +0.600 | +0.400 | +1.000 |
			printed

			See Also
			--------
			:func:`same_size`
			:func:`size_r`
			:func:`size_c`
			:func:`set_ij`
			:func:`get_ij`
		"""
		cdef Matrix mean 
		cdef int i
		cdef int j

		if(self.same_size(mat)):
			mean=Matrix(self.size_r(),self.size_c())
			for i in range(0,self.size_r()):
				for j in range(0,self.size_c()):
					mean.set_ij(i,j,self.get_ij(i,j)*ratio+mat.get_ij(i,j)*(1-ratio))
		return mean

	cpdef Matrix gap(self,Matrix mat,int mode):
		"""
			Compute the absolute gap between self matrix and given mat.
			Can be used to compare probabilities matrix.

			=============== ========== ==================================
			**Parameters**   **Type**   **Description**
			*mat*            Matrix     The matrix to gap with self
			*mode*           int        Get the absolute or relative gap
											* 0 mean absolute
											* 1 mean relative
			=============== ========== ==================================

			Returns
			-------
				Matrix
				The absolute gap matrix between self matrix and mat.

			Examples
			--------
			>>> m=rand(3)
			>>> n=rand(3)
			>>> print(m)
			| +9.000 | +3.000 | +8.000 |
			| +8.000 | +3.000 | +3.000 |
			| +3.000 | +5.000 | +3.000 |
			printed
			>>> print(n)
			| +7.000 | +8.000 | +6.000 |
			| +4.000 | +0.000 | +2.000 |
			| +3.000 | +7.000 | +6.000 |
			printed
			>>> print(m.gap(n,0))
			| +2.000 | +5.000 | +2.000 |
			| +4.000 | +3.000 | +1.000 |
			| +0.000 | +2.000 | +3.000 |
			printed
			>>> print(m.gap(n,1))
			| +0.091 | +0.227 | +0.091 |
			| +0.182 | +0.136 | +0.045 |
			| +0.000 | +0.091 | +0.136 |
			printed

			See Also
			--------
			:func:`same_size`
			:func:`size_r`
			:func:`size_c`
			:func:`normalize`
		"""
		cdef Matrix gap
		cdef int i
		cdef int j

		if(self.same_size(mat)):
			gap=Matrix(self.size_r(),self.size_c())
			for i in range(0,self.size_r()):
				for j in range(0,self.size_c()):
					gap.set_ij(i,j,abs(self.get_ij(i,j)-mat.get_ij(i,j)))
		if mode:
			gap=gap.normalize()
		return gap

	def map(self,fun):
		"""
			Map a function (as parameter) to each element of the self matrix

			Examples
			--------
			>>> def Coef(x):
			...     return x*10
			...
			>>> m=rand(4)
			>>> print(m)
			| +14.000 | +9.000 | +5.000 | +2.000 |
			| +0.000 | +7.000 | +5.000 | +10.000 |
			| +2.000 | +10.000 | +0.000 | +2.000 |
			| +10.000 | +6.000 | +8.000 | +3.000 |
			printed
			>>> m.map(Coef)
			>>> print(m)
			| +140.000 | +90.000 | +50.000 | +20.000 |
			| +0.000 | +70.000 | +50.000 | +100.000 |
			| +20.000 | +100.000 | +0.000 | +20.000 |
			| +100.000 | +60.000 | +80.000 | +30.000 |
			printed

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`set_ij`
			:func:`get_ij`
		"""
		for i in range(0,self.size_r()):
			for j in range(0,self.size_c()):
				self.set_ij(i,j,fun(self.get_ij(i,j)))	

	cpdef Matrix normalize(self):
		"""
			Normalize the self matrix. (the sum of each element is equal to 1)

			Returns
			-------
				Matrix
					The normalized matrix

			Examples
			--------
			>>> t=gaussian(5,0,0)
			>>> Print(t)
			| +1.000 | +4.000 | +6.000 | +4.000 | +1.000 |
			| +4.000 | +16.000 | +24.000 | +16.000 | +4.000 |
			| +6.000 | +24.000 | +36.000 | +24.000 | +6.000 |
			| +4.000 | +16.000 | +24.000 | +16.000 | +4.000 |
			| +1.000 | +4.000 | +6.000 | +4.000 | +1.000 |
			printed
			>>> t.normalize()
			>>> Print(t)
			| +0.004 | +0.016 | +0.023 | +0.016 | +0.004 |
			| +0.016 | +0.062 | +0.094 | +0.062 | +0.016 |
			| +0.023 | +0.094 | +0.141 | +0.094 | +0.023 |
			| +0.016 | +0.062 | +0.094 | +0.062 | +0.016 |
			| +0.004 | +0.016 | +0.023 | +0.016 | +0.004 |
			printed
			>>> sum=0
			>>> for i in range(0,5):
			...     for j in range(0,5):
			...             sum+=t[[i,j]]
			...
			>>> Print(sum)
			1.0

			See Also
			--------
			:func:`clone`
			:func:`get_coef`
			:func:`map`
		"""
		cdef Matrix res
		res=self.clone()
		res.get_coef()
		res.map(res.mul_coef)
		return res

	def UX_B(self,U,B):
		"""
			Compute the UX=B system wher U is an upper matrix and B the result matrix.
			The system is solved by gauss.

			=============== ========= ===============================
			**Parameters**  **type**  **Description**
			*U*              Matrix   The upper matrix of the system
			*B*              Matrix   The result matrix of the system
			=============== ========= ===============================

			Returns
			-------
				Matrix
					1D Matrix representing the solution of the Upper X system

			Examples
			--------
			>>> m=Matrix(3,3)
			>>> m[0,0]=1
			>>> m[0,1]=3
			>>> m[0,2]=9
			>>> m[1,1]=2
			>>> m[1,2]=4
			>>> m[2,2]=1
			>>> b=Matrix(3,1)
			>>> b[0,0]=1
			>>> b[1,0]=2
			>>> b[2,0]=-1
			>>> print(m)
			| +1.000 | +3.000 | +9.000 |
			| +0.000 | +2.000 | +4.000 |
			| +0.000 | +0.000 | +1.000 |
			printed
			>>> print(b)
			| +1.000 |
			| +2.000 |
			| -1.000 |
			printed
			>>> print(m.UX_B(m,b))
			| +1.000 |
			| +3.000 |
			| -1.000 |
			printed

			See Also
			--------
			:func:`square`
			:func:`size_r`
			:func:`size_c`
			:func:`zeros`
		"""
		# Realize the UX=B resolution where U is an upper matrix
		def summ(A,X,i,N):
			z=0
			for j in range(i,N):
				z+=A[i-1,j]*X[j,0]
			return z 

		if(U.square() and B.size_r()==U.size_c()):
			N=len(B)
			X=zeros(len(B),1)
			X[N-1,0]=B[N-1,0]/U[N-1,N-1]
			for i in range(N-1,0,-1):
				X[i-1,0]=(1/U[i-1,i-1])*(B[i-1,0]-summ(U,X,i,N))
			return X
		else:
			return 0

	def LX_B(self,L,B):
		"""
			Compute the LX=B system wher L is a lower matrix and B the result matrix.
			The system is solved by gauss.
			
			=============== ========= ===============================
			**Parameters**  **type**  **Description**
			*L*              Matrix   The lower matrix of the system
			*B*              Matrix   The result matrix of the system
			=============== ========= ===============================

			Returns
			-------
				Matrix
					1D Matrix representing the solution of the Lower X system

			Examples
			--------
			>>> m[0,0]=1
			>>> m[1,0]=4
			>>> m[1,1]=2
			>>> m[2,0]=1
			>>> m[2,1]=3
			>>> m[2,1]=3
			>>> m[2,2]=9
			>>> b=Matrix(3,1)
			>>> b[0,0]=-1
			>>> b[1,0]=3
			>>> b[2,0]=1
			>>> print(m)
			| +1.000 | +0.000 | +0.000 |
			| +4.000 | +2.000 | +0.000 |
			| +1.000 | +3.000 | +9.000 |
			printed
			>>> print(b)
			| -1.000 |
			| +3.000 |
			| +1.000 |
			printed
			>>> print(m.LX_B(m,b))
			| -1.000 |
			| +3.500 |
			| -0.944 |
			printed

			See Also
			--------
			:func:`square`
			:func:`size_r`
			:func:`size_c`
			:func:`zeros`
		"""
		# Realize the LX=B resolution where L is a lower matrix
		def summ(A,X,i):
			z=0
			for j in range(0,i-1):
				z+=A[i-1,j]*X[j,0]
			return z

		if(L.square() and B.size_r()==L.size_c()):
			N=len(B)
			X=zeros(len(B),1)
			X[0,0]=B[0,0]/L[0,0]
			for i in range(1,N):
				X[i,0]=(1/L[i,i])*(B[i,0]-summ(L,X,i+1))
			return X 
		else:
			return 0

	cpdef void replace_zeros(self):
		"""
			Utilitary function to replace the null values with 1.
			It is used for LU computing genericity.

			Examples
			--------
			>>> m=rand_perm(4)
			>>> print(m)
			| +0.000 | +0.000 | +0.000 | +1.000 |
			| +0.000 | +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 | +0.000 |
			| +1.000 | +0.000 | +0.000 | +0.000 |
			printed
			>>> m.replace_zeros()
			>>> print(m)
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			| +1.000 | +1.000 | +1.000 | +1.000 |
			printed

			Returns
			-------
				Matrix
					The non-zeros matrix
		"""
		cdef int i

		for i in range(len(self)):
			if(self.data[i]==0):
				self.data[i]=1

	def LU(self):
		"""
			Realize a LU decomposition from the self Matrix.
			If the self matrix contain some 0, they are automatiquely replaced with 1

			Examples
			--------
			>>> m=rand(6)
			>>> print(m)
			| +19.000 | +8.000 | +18.000 | +6.000 | +4.000 | +30.000 |
			| +1.000 | +28.000 | +12.000 | +32.000 | +33.000 | +35.000 |
			| +0.000 | +7.000 | +16.000 | +35.000 | +10.000 | +28.000 |
			| +25.000 | +11.000 | +16.000 | +17.000 | +30.000 | +30.000 |
			| +27.000 | +4.000 | +18.000 | +6.000 | +2.000 | +31.000 |
			| +6.000 | +34.000 | +16.000 | +11.000 | +9.000 | +22.000 |
			printed
			>>> L,U=m.LU()
			>>> print(L)
			| +1.000 | +0.000 | +0.000 | +0.000 | +0.000 | +0.000 |
			| +0.053 | +1.000 | +0.000 | +0.000 | +0.000 | +0.000 |
			| +0.053 | +0.239 | +1.000 | +0.000 | +0.000 | +0.000 |
			| +1.316 | +0.017 | -0.634 | +1.000 | +0.000 | +0.000 |
			| +1.421 | -0.267 | -0.373 | +0.623 | +1.000 | +0.000 |
			| +0.316 | +1.141 | -0.185 | -0.855 | +0.756 | +1.000 |
			printed
			>>> print(U)
			| +19.000 | +8.000 | +18.000 | +6.000 | +4.000 | +30.000 |
			| +0.000 | +27.579 | +11.053 | +31.684 | +32.789 | +33.421 |
			| +0.000 | +0.000 | +12.416 | +27.126 | +1.968 | +18.448 |
			| +0.000 | +0.000 | +0.000 | +25.764 | +25.421 | +1.652 |
			| +0.000 | +0.000 | +0.000 | +0.000 | -10.023 | +3.142 |
			| +0.000 | +0.000 | +0.000 | +0.000 | +0.000 | -23.164 |
			printed
			>>> print(U*L)
			| +19.000 | +8.000 | +18.000 | +6.000 | +4.000 | +30.000 |
			| +1.000 | +28.000 | +12.000 | +32.000 | +33.000 | +35.000 |
			| +1.000 | +7.000 | +16.000 | +35.000 | +10.000 | +28.000 |
			| +25.000 | +11.000 | +16.000 | +17.000 | +30.000 | +30.000 |
			| +27.000 | +4.000 | +18.000 | +6.000 | +2.000 | +31.000 |
			| +6.000 | +34.000 | +16.000 | +11.000 | +9.000 | +22.000 |	

			Returns
			-------
				tuple Matrix
					A tuple containing the Lower and Upper matrix computed.
					To restore the origial self matrix, compute U*L

			See Also
			--------
			:func:`count_zero`
			:func:`replace_zeros`
			:func:`square`
			:func:`size_r`
			:func:`get_ij`
		"""
		if(self.count_zero()>=1):
			self.replace_zeros()
	#Factorisation Lower Upper
		if(self.square() and self.count_zero()==0):
			def summLU(L,U,p,i,j):
				z=0
				for k in range(1,p):
					z+=L[i-1,k-1]*U[k-1,j-1]
				return z
			N=self.size_r()
			L=unit(N)
			U=zeros(N,N)
			for i in range(1,N):
				for j in range(i,N+1):
					U[i-1,j-1]=self.get_ij(i-1,j-1)-summLU(L,U,i,i,j)
				for j in range((i+1),N+1):
					L[j-1,i-1]=(1/U[i-1,i-1])*(self.get_ij(j-1,i-1)-summLU(L,U,i,j,i))
			U[N-1,N-1]=self.get_ij(N-1,N-1)-summLU(L,U,N,N,N)

			return L,U
		else:
			print("not factorisable")
			return 0

	# def AX_B(self,A,B):
	# 	# Realize the AX=B resolution where A is an any matrix
	# 	L,U=A.LU()
	# 	Y=L.LX_B(L,B)
	# 	X=U.UX_B(U,B)
	# 	return X

	#TODO : verifier erreurs
	def det(self):
		"""
			Compute the associated determinant of the self matrix.
			To realize it, I decompose the self Matrix into from LU method and compute the associated determinant independantly.
			Teproduct of the Lower and Upper determinant give the det of the self matrix.

			Examples
			--------
			>>> m=rand(3)
			>>> print(m)
			| +3.000 | +9.000 | +3.000 |
			| +5.000 | +3.000 | +5.000 |
			| +8.000 | +8.000 | +2.000 |
			printed
			>>> print(m.det())
			215.99999999999994

			Returns
			-------
				double
					The compute determinant

			See Also
			--------
			:func:`LU`
			:func:`size_r`
			:func:`get_ij`
		"""
	#Calcul du determinant de a (= det L*det U)

		res=()
		res=self.LU()
		detl=1
		detu=1
		for i in range(0,self.size_r()):
			detl*=res[0].get_ij(i,i)
			detu*=res[1].get_ij(i,i)
		return (detl*detu)

	cpdef bint orthogonal(self):
		"""
			Boolean test to verify orthogonality

			Returns
			-------
				bint
					Test the orthogonality of the self matrix.

			Examples
			--------
			>>> m=rand_perm(3)
			>>> print(m)
			| +0.000 | +1.000 | +0.000 |
			| +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 |
			printed
			>>> print(m.orthogonal())
			True

			See Also
			--------
			:func:`transpose`
			:func:`size_r`
			:func:`size_c`
		"""
		cdef bint res 

		res=((self.transpose()*self==unit(self.size_r()) and (self.size_r()==self.size_c())))
		return res

	cpdef bint symmetric(self):
		"""
			Boolean test to verify symmetricity

			Returns
			-------
				bint
					Test the symmetry of the self matrix.

			Examples
			--------
			>>> m=Matrix(3,3)
			>>> m[0,0]=2
			>>> m[0,1]=7
			>>> m[0,2]=3
			>>> m[1,0]=7
			>>> m[1,1]=9
			>>> m[1,2]=4
			>>> m[2,0]=3
			>>> m[2,1]=4
			>>> m[2,2]=7
			>>> print(m)
			| +2.000 | +7.000 | +3.000 |
			| +7.000 | +9.000 | +4.000 |
			| +3.000 | +4.000 | +7.000 |
			printed
			>>> print(m.symmetric())
			True                        

			See Also
			--------
			:func:`size_c`
			:func:`size_r`
			:func:`get_ij`
		"""
		cdef bint res 
		cdef int i
		cdef int j

		res=True
		for i in range(0,self.size_c()):
			for j in range(0,self.size_r()):
				res&=(self.get_ij(i,j)==self.get_ij(j,i))
		return res

	cpdef bint hermitian(self):
		"""
			Boolean test to verify if the matrix is hermitian

			Returns
			-------
				bint
					Test if the matrix is hermitian.

			Examples
			--------
			>>> m=Matrix(3,3)
			>>> m[0,0]=1
			>>> m[1,2]=1
			>>> m[2,1]=1
			>>> print(m)
			| +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 |
			| +0.000 | +1.000 | +0.000 |
			printed
			>>> print(m.hermitian())
			True

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`transpose`
			:func:`set_ij`
			:func:`get_ij`
		"""
		cdef Matrix tmp 
		cdef bint res 
		cdef int i
		cdef int j

		tmp=Matrix(self.size_r(),self.size_c())
		tmp=self.transpose()
		res=True 
		for i in range(0,self.size_r()):
			for j in range(0,self.size_c()):
				if (i!=j) and (i+j)<self.size_r():
					tmp.set_ij(i,j,-tmp.get_ij(i,j))
				res=(self.get_ij(i,j)==tmp.get_ij(i,j) and res)
		return res

	cpdef bint reversal(self):
		"""
			Boolean test to verify the reversability

			Returns
			-------
				bint
					Test the reversality of the self matrix.

			Examples
			--------
			>>> m=rand(3)
			>>> print(m)
			| +0.000 | +0.000 | +8.000 |
			| +2.000 | +7.000 | +8.000 |
			| +8.000 | +7.000 | +2.000 |
			printed
			>>> print(m.reversal())
			True

			See Also
			--------
			:func:`square`
			:func:`det`
		"""
		cdef bint res

		res=(self.square() and self.det()!=0)
		return res

	cpdef int count_zero(self):
		"""
			Count the number of zeros in the self Matrix

			Returns
			-------
				int
					Count number of zeros containes in the self matrix.

			Examples
			--------
			>>> m=rand_perm(4)
			>>> print(m)
			| +0.000 | +1.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +1.000 | +0.000 |
			| +1.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +1.000 |
			printed
			>>> print(m.count_zero())
			12

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`get_ij`
		"""
		cdef int counter 
		cdef int i
		cdef int j

		counter=0
		for i in range(0,self.size_r()):
			for j in range(0,self.size_c()):
				if (self.get_ij(i,j)==0):
					counter+=1
		return counter

	cpdef bint nilpotent(self):
		"""
			Boolean test to verify the nilpotence.

			Returns
			-------
				bint
					Test the nilpotence of the self matrix.

			Examples
			--------
			>>> m=rand(4)
			>>> m=m.triangle(1)
			>>> print(m)
			| +0.000 | +12.000 | +16.000 | +11.000 |
			| +0.000 | +0.000 | +13.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +4.000 |
			| +0.000 | +0.000 | +0.000 | +0.000 |
			printed
			>>> print(m.nilpotent())
			True

			See Also
			--------
			:func:`count_zero`
			:func:`size_r`
			:func:`size_c`
		"""
		cdef int count 

		count=0
		while(self.count_zero()!=self.size_r()*self.size_c()):
			self*=self
			count+=1
			if(count>100):
				return False
		return True
		# return (self.count_zero()<(self*self).count_zero())

	cpdef bint diagonal(self):
		"""
			Test if the matrix have a diagonal profile.

			Returns
			-------
				bint
					Test if the self matrix is diagonal.

			Examples
			--------
			>>> m=rand(4)
			>>> for i in range(0,4):
			...     for j in range(0,4):
			...             if(i!=j):
			...                     m[i,j]=0
			...
			>>> print(m)
			| +4.000 | +0.000 | +0.000 | +0.000 |
			| +0.000 | +12.000 | +0.000 | +0.000 |
			| +0.000 | +0.000 | +13.000 | +0.000 |
			| +0.000 | +0.000 | +0.000 | +6.000 |
			printed
			>>> print(m.diagonal())
			True
		"""
		cdef int i
		cdef int j
		cdef bint res

		res=True
		for i in range(0,self.size_r()):
			for j in range(0,self.size_c()):
				if(i!=j):
					res&=(self.get_ij(i,j)==0)
		return res 

	cpdef int triangular(self):
		"""
			Test if the matrix have a triangulare profile.

			Returns
			-------
				int
					Test if the self matrix is triangular.

					In case of, returns code are given :

                        * 0 => no triangular
                        * 1 => inf triangular                        
                        * 2 => sup triangular

            Examples
            --------
            >>> m=rand(4)
			>>> n=m.triangle(0)
			>>> o=m.triangle(1)
			>>> print(n)
			| +7.000 | +0.000 | +0.000 | +0.000 |
			| +15.000 | +10.000 | +0.000 | +0.000 |
			| +5.000 | +9.000 | +13.000 | +0.000 |
			| +15.000 | +9.000 | +5.000 | +10.000 |
			printed
			>>> print(o)
			| +0.000 | +12.000 | +0.000 | +10.000 |
			| +0.000 | +0.000 | +2.000 | +1.000 |
			| +0.000 | +0.000 | +0.000 | +9.000 |
			| +0.000 | +0.000 | +0.000 | +0.000 |
			printed
			>>> print(m.triangular())
			0
			>>> print(n.triangular())
			1
			>>> print(o.triangular())
			2

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`get_ij`
		"""
		cdef int res 
		cdef int i
		cdef int j
		cdef bint sup
		cdef bint inf

		res=0
		sup=True
		inf=True
		for i in range(0,self.size_r()):
			for j in range(i+1,self.size_c()):
				sup=sup and (self.get_ij(i,j)==0) # sup tri
			for j in range(0,i):
				inf= inf and (self.get_ij(i,j)==0) # inf tri
		if sup:
			res=1
		if inf:
			res=2
		return res

	cpdef bint read_from_file(self,str pathname):
		"""
			Read and convert a matrix from extern file.
			The file format must respect the writing convention
			(See write_in_file function).

			=============== ========= ========================
			**Parameters**   **Type**   **Description**
			*pathname*        string    The file name to open
			=============== ========= ========================

			Returns
			-------
				bint
				* True => file readed
				* False => Error occured

			Examples
			--------
			>>>  # Rebuild the matrix since test file, generated from write_in_file func
			>>> m=Matrix(4,4)
			>>> m.read_from_file("./test")
			True
			>>> print(m)
			| +16.000 | +10.000 | +6.000 | +2.000 |
			| +9.000 | +10.000 | +3.000 | +2.000 |
			| +1.000 | +1.000 | +5.000 | +16.000 |
			| +11.000 | +15.000 | +13.000 | +6.000 |
			printed

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`ind_2_ij`
			:func:`set_ij`
		"""
		cdef bint done
		cdef int i
		cdef int ind
		cdef int loc_s     # Local size
		cdef double loc_v  # Local value
		cdef str content
		cdef int indP 
		cdef int x
		cdef int y

		try:
			done=False
			i=0
			ind=0
			loc_s=0
			loc_v=0.0
			file=open(pathname,"r")
			content=file.read()
			while(i!=len(content)):
				# print("str[i] = "+content[i]+" | i = "+str(i))
				if(content[i]=="#"):
					while(not isalpha(content[i])):
						i+=1
					while(content[i]!='\n'):
						loc_s*=10
						loc_s+=int(content[i])
						i+=1
					if(not done):
						self.size_raw=loc_s
						loc_s=0
						done=True
					else:
						self.size_column=loc_s
						self.data=[0]*self.size_r()*self.size_c()
				else:
					if(isalpha(content[i])):
						indP=1
						while(True):
							if(content[i]=='\n' or content[i]==" "):
								break
							if(content[i]!="."):
								loc_v*=10
								loc_v+=float(content[i])
								i+=1
							else:
								i+=1
								while(content[i]!=" "):
										loc_v+=(float(content[i])/10**indP)
										indP+=1
										i+=1
						x,y=self.ind_2_ij(ind,self.size_c())
						self.set_ij(x,y,loc_v)
						loc_v=0
						ind+=1
				i+=1
			return True
		except:
			return False

	cpdef bint write_in_file(self,str pathname):
		"""
			Write the current object to file (re-openable in any other Matrix object instance)

			=============== ========= =============================
			**Parameters**   **Type**   **Description**
			*pathname*       String     The name of the saved file
			=============== ========= =============================

			Returns
			-------
				bint
				* True => file saved
				* False => error occured

			Examples
			--------
			>>> m=rand(4)
			>>> print(m)
			| +16.000 | +10.000 | +6.000 | +2.000 |
			| +9.000 | +10.000 | +3.000 | +2.000 |
			| +1.000 | +1.000 | +5.000 | +16.000 |
			| +11.000 | +15.000 | +13.000 | +6.000 |
			printed
			>>> m.write_in_file("test")
			True

			See Also
			--------
			:func:`size_r`
			:func:`size_c`
			:func:`get_ij`
			:func:`pack`
		"""
		cdef str to_write
		cdef int i
		cdef int j

		try:
			file=open(pathname,"x")
			to_write="#size_r = "+str(self.size_r())+"\n#size_c = "+str(self.size_c())+"\n"
			for i in range(0,self.size_r()):
				for j in range(0,self.size_c()):
					to_write+=str(self.get_ij(i,j))+" "
					if(j==(self.size_c()-1)):
						to_write+="\n"
			file.write(to_write)
			self.pack()
			return True
		except:
			return False

	cpdef pack(self):
		"""
			Pack the current matrix to 64bit regular float.

			Examples
			--------
			>>> m=rand(4)
			>>> m.pack()

			See Also
			--------
			:func:`write_in_file`
			:func:`read_from_file`
		"""
		self.write_in_file("tmp")
		self.read_from_file("tmp")
# #%% 

# ######################################
# ####### Usual matrix generator #######
# ######################################

cpdef Matrix unit(int size):
	"""
		Generate the unit matrix.

		=============== ========== ===============================
		**Parameters**   **Type**   **Description**
		*size*           int        the size of the square matrix
		=============== ========== ===============================

		Returns
		-------
			Matrix
				The unit matrix

		Examples
		--------
		>>> u=unit(4)
		>>> print(u)
		| +1.000 | +0.000 | +0.000 | +0.000 |
		| +0.000 | +1.000 | +0.000 | +0.000 |
		| +0.000 | +0.000 | +1.000 | +0.000 |
		| +0.000 | +0.000 | +0.000 | +1.000 |
		printed

		See Also
		--------
		:func:`set_ij`
	"""
	cdef Matrix res 
	cdef int i 

	res=Matrix(size,size)
	for i in range(0,size):
		res.set_ij(i,i,1)
	return res

# def ones(size_r,size_c):
# 	return Matrix(size_r,size_c,1)

cpdef Matrix zeros(int size_r,int size_c):
	"""
		Generate the zeros matrix.

		=============== ========== ==================
		**Parameters**   **type**   **Description**
		*size_r*         int        the row size
		*size_c*         int        the columns size
		=============== ========== ==================

		Returns
		-------
			Matrix
				The zeros matrix

		Examples
		--------
		>>> m=zeros(4,4)
		>>> print(m)
		| +0.000 | +0.000 | +0.000 | +0.000 |
		| +0.000 | +0.000 | +0.000 | +0.000 |
		| +0.000 | +0.000 | +0.000 | +0.000 |
		| +0.000 | +0.000 | +0.000 | +0.000 |
		printed
	"""
	return Matrix(size_r,size_c)

cpdef Matrix rand_perm(int size):
	"""
		Generate a random permutation matrix size x size

		==============   ========   ==============================
		**Parameters**   **Type**   **Description**
		*size*           int        The size of the square matrix
		==============   ========   ==============================

		Returns
		-------
			1/0 Matrix
				A random-generated permutation matrix

		Examples
		--------
		>>> m=rand_perm(4)
		>>> print(m)
		| +0.000 | +0.000 | +0.000 | +1.000 |
		| +0.000 | +1.000 | +0.000 | +0.000 |
		| +0.000 | +0.000 | +1.000 | +0.000 |
		| +1.000 | +0.000 | +0.000 | +0.000 |
		printed

		See Also
		--------
		:func:`set_ij`
	"""
	cdef Matrix res 
	cdef list done 
	cdef int i 
	cdef int y 

	res=Matrix(size,size)
	done=[]
	for i in range(0,size):
		y=r.randint(0,size-1)
		while(y in done):
			y=r.randint(0,size-1)
		done.append(y)
		res.set_ij(i,y,1)
	return res

cpdef Matrix rand(int size):
	"""
		Generate a random matrix size x size

		==============   ========   ==============================
		**Parameters**   **Type**   **Description**
		*size*           int        The size of the square matrix
		==============   ========   ==============================

		Returns
		-------
			Matrix
				The generated random matrix

		Examples
		--------
		>>> m=rand(4)
		>>> print(m)
		| +9.000 | +6.000 | +13.000 | +13.000 |
		| +2.000 | +8.000 | +7.000 | +15.000 |
		| +4.000 | +14.000 | +5.000 | +3.000 |
		| +10.000 | +1.000 | +4.000 | +3.000 |
		printed

		See Also
		--------
		:func:`set_ij`
	"""
	cdef Matrix res 
	cdef int i 
	cdef int j

	res=Matrix(size,size)
	for i in range(0,size):
		for j in range(0,size):
			res.set_ij(i,j,r.randint(0,size*size))
	return res

cpdef list mirror(list array,int dim):
	"""
		Local util mirror constructor to Pascal triangle generator.

		=============== ========== ========================================================================
		**Parameters**   **Type**   **Description**
		*array*          int list    The list containing the first half of the binomial coefficients suit.
		*dim*            int         The dimension of the binomial coefficients suit.
		=============== ========== ========================================================================
		
		Returns
		-------
			list
				Pascal triangle mirror line from an half size one

		Examples
		--------
		>>> mirror([1,3],4)
		[1, 3, 3, 1]
	"""
	cdef int i

	for i in range(len(array),dim):
		array.append(array[dim-(1+i)])
	return array

cpdef list Pascal_triangle(int dim):
	"""
		Pascal triangle generator of dimension dim.

		=============== ========== ===========================
		**Parameters**   **Type**   **Description**
		*dim*            int        Dimension of the triangle
		=============== ========== ===========================

		Returns
		-------
		int list
			Binomial coefficients computed.

		Examples
		--------
		>>> for i in range(0,10):
		...     print(Pascal_triangle(i))
		...
		[1]
		[1, 1]
		[1, 1]
		[1, 2, 1]
		[1, 3, 3, 1]
		[1, 4, 6, 4, 1]
		[1, 5, 10, 10, 5, 1]
		[1, 6, 15, 20, 15, 6, 1]
		[1, 7, 21, 35, 35, 21, 7, 1]
		[1, 8, 28, 56, 70, 56, 28, 8, 1]

		See Also
		--------
		:func:`mirror`
	"""
	cdef list ret 
	cdef list tmp
	cdef list tmp2 
	cdef int local_dim
	cdef int i

	ret=[1]
	if (dim==0):
		return ret 
	elif (dim==1):
		ret.append(1)
		return ret
	else:
		ret.append(1)
		tmp=ret
		tmp2=[1]
		local_dim=2
		while(local_dim<dim):
			for i in range(1,len(tmp)):
				tmp2.append(tmp[i-1]+tmp[i])
			tmp2=mirror(tmp2,local_dim+1)
			tmp=tmp2
			tmp2=[1]
			local_dim+=1
		ret=tmp
	return ret

cpdef Matrix gaussian(int size,int mode,int norm):
	"""
		Generate Gaussian square base matrix.

		Can be used as a generator of differents gaussian "filter type" matrix using an additionnal function mapped to each value (to convolve self matrix for example).
		
		Two mode are avaible :

            * 0 => binomial distribution
            * 1 => regular distribution

        In case of regular distribution, you have to instance an odd sized matrix 

		=============== ========== ===========================================
		**Parameters**   **Type**   **Description**
		*size*           int        the size of the square gaussain generated

		*mode*           int        * 1 : regular distribution
		                            * 0 : binomial distribution

		*norm*           int        * 1 : normalize the filter mask
		                            * 0 : don't normalize
		=============== ========== ===========================================

		Returns
		-------
			Matrix
				The generated gaussian matrix

		Examples
		--------
		>>> print(gaussian(3,0,0))
		| +1.000 | +2.000 | +1.000 |
		| +2.000 | +4.000 | +2.000 |
		| +1.000 | +2.000 | +1.000 |
		printed
		>>> print(gaussian(3,1,0))
		| +1.000 | +2.000 | +1.000 |
		| +2.000 | +4.000 | +2.000 |
		| +1.000 | +2.000 | +1.000 |
		printed
		>>> print(gaussian(3,0,1))
		| +0.062 | +0.125 | +0.062 |
		| +0.125 | +0.250 | +0.125 |
		| +0.062 | +0.125 | +0.062 |
		printed
		>>> print(gaussian(3,1,1))
		| +0.062 | +0.125 | +0.062 |
		| +0.125 | +0.250 | +0.125 |
		| +0.062 | +0.125 | +0.062 |
		printed								

		See Also
		--------
		:func:`Pascal_triangle`
		:func:`set_ij`
		:func:`get_coef`
		:func:`size_r`
		:func:`size_c`
		:func:`set_ij`
		:func:`get_ij`
	"""
	cdef list base 
	cdef int ind
	cdef int i
	cdef int j
	cdef double coef
	cdef Matrix ret 

	base=[1]
	ind=1
	#Compute base line (a [1,2,4,2,1] like list)
	if(mode):
		if(size%2!=0):
			while(ind!=size):
				if(ind<=size/2):
					base.append(2*base[ind-1])
				else:
					base.append(int(base[ind-1]/2))
				ind+=1
	else:
		base=Pascal_triangle(size)
	#Populate matrix
	ret=Matrix(size,size)
	for i in range(0,len(base)):
		for j in range(0,len(base)):
			ret.set_ij(i,j,(base[i]*base[j]))

	if(norm):
		coef=ret.get_coef()
		for i in range(0,ret.size_r()):
			for j in range(0,ret.size_c()):
				ret.set_ij(i,j,ret.get_ij(i,j)*coef)
	return ret

cpdef Laplacian_mean(int order):
	"""
		Laplacian mean matrix generator.
		The order have been programmed until 3.

		=============== =========== =======================================
		**Parameters**    **type**    **Description**
		*order*            int         the order of the computed laplacian
		=============== =========== =======================================

		Returns
		-------
			Matrix
				The laplacian mean matrix

		Examples
		--------
		>>> print(Laplacian_mean(3))
		| -0.004 | -0.008 | -0.016 | -0.008 | -0.004 |
		| -0.008 | -0.016 | -0.031 | -0.016 | -0.008 |
		| -0.016 | -0.031 | +0.062 | -0.031 | -0.016 |
		| -0.008 | -0.016 | -0.031 | -0.016 | -0.008 |
		| -0.004 | -0.008 | -0.016 | -0.008 | -0.004 |
		printed

		See Also
		--------
		:func:`set_ij`
		:func:`size_r`
		:func:`size_c`
		:func:`get_ij`
	"""
	# Compute the center matrix of a pseudo-Laplacian filter
	cdef list Base 
	cdef Matrix center_mat

	if order==1:
		return [1]
	elif order==2:
		Base=[0.25,0.5,0.25]
		center_mat=Matrix(3,3)
		for i in range(0,3):
			for j in range(0,3):
				center_mat.set_ij(i,j,Base[i]*Base[j])
		center_mat/=3
		center_mat.set_ij(int(center_mat.size_r()/2),int(center_mat.size_c()/2),-center_mat.get_ij(int(center_mat.size_r()/2),int(center_mat.size_c()/2)))				
		return center_mat*(-1)
	elif order==3:
		Base= [0.0625,0.125,0.25,0.125,0.0625]
		center_mat=Matrix(5,5)
		for i in range(0,5):
			for j in range(0,5):
				center_mat.set_ij(i,j,Base[i]*Base[j])
	# elif(To be continued):
		center_mat.set_ij(int(center_mat.size_r()/2),int(center_mat.size_c()/2),-center_mat.get_ij(int(center_mat.size_r()/2),int(center_mat.size_c()/2)))	
		return center_mat*(-1)

cpdef Matrix mean_filter(int size,int mode,int order=1):
	"""
		Generate a mean filter matrix.

		Can be used in two mode :
			* 0 => laplacian-like mean first order
			* 1 => regular mean matrix

		=============== ========= =================================================================
		**Parameters**   **Type**   **Description**
		*size*           int        The size of the filter
		*mode*           int        Int value representing two mean mode :
		                             * 0 => laplacian-like mean first order
		                             * 1 => regular mean matrix
		*order*          int        In case of Laplacian-like mean, define the order of the filter
		=============== ========= =================================================================

		Returns
		-------
		Matrix
			The computed mean filter matrix

		Examples
		--------
		>>> print(mean_filter(3,0))
		| -0.125 | -0.125 | -0.125 |
		| -0.125 | +1.000 | -0.125 |
		| -0.125 | -0.125 | -0.125 |
		printed
		>>> print(mean_filter(3,0,2))
		| -0.021 | -0.042 | -0.021 |
		| -0.042 | +0.083 | -0.042 |
		| -0.021 | -0.042 | -0.021 |
		printed
		>>> print(mean_filter(3,0,3))
		| +0.062 | +0.062 | +0.062 |
		| +0.062 | +0.062 | +0.062 |
		| +0.062 | +0.062 | +0.062 |
		printed

		See Also
		--------
		:func:`set_ij`
		:func:`insert_sub_matrix`
		:func:`abs`
	"""
	cdef list init_sub
	cdef double init_value
	cdef Matrix ret 
	cdef Matrix center_mat

	init_sub=[1,9,25]
	try:
		init_value=-1/((size**2)-init_sub[order-1])
	except:
		init_value=0

	ret=Matrix(size,size,init_value)
	if(mode): # Regular profile
		init_value=1/size**2
		return Matrix(size,size,init_value)
	else:     # Laplacian profile
		Center_mat=Laplacian_mean(order)
		if(size%2==1):
			if(order==1):
				ret.set_ij(int(size/2),int(size/2),1)
			elif(order==2 and size>=3):
				if(size>3):
					ret.insert_sub_matrix((abs(int(size/2)-1),abs(int(size/2)-1)),Center_mat)
				else:
					ret=Center_mat
			elif(order==3 and size>=5):
				if(size>5):
					ret.insert_sub_matrix((abs(int(size/2)-2),abs(int(size/2)-2)),Center_mat)
				else:
					ret=Center_mat
		else:
			print("Laplacian mean matrix must be instanced with odd size")
	return ret
# #  -   -
# #    u 
# # \_____/
# #  \|||/