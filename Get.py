from matrix import *

# Matrix utility reader from raw files
# Accepted files are .txt, raw (decimal values), .pdb LibreOffice Tab


# Assert the line is empty
def isempty(line):
	res=True
	for l in line:
		res=res and (l==" ")
	return res

# Test alphabetics char
def alpha(c):
	return c in ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','_']

# Packing matrix to a standard readable file
def packing(path):
	res=""
	content=""
	ind=False
	file=open(path,"r")
	lines=file.readlines()
	try:
		flag=(path.split(".")[2]=="pdb")               # Put the flag for LibreOffice pdb files
	except:
		flag=False
	for l in lines:                                        # Standard raw matrix reader algorithm
		for item in l:
			if not alpha(item):
				res+=item
	if flag :                                              # Adapt the pdb file to the matrix recept                      
		for l in res.splitlines():
			if not ind:
				ind=True
			else:
				content+=(l+str("\n"))	       # Rebuilding content
	else:			
		for l in res.splitlines():
			if not isempty(l):
				content+=(l+str("\n"))
	if flag:
		content=content[:-1] 
	file2=open(path+str("_packed"),"w")                    # Defining the new packed file
	file2.write(content)                                   # Writing formated content to the file
	file.close()                                           # Closing unused files
	file2.close()
	

#Testing the given char, returning True if numeric, False else
def isalpha(char):
	"""
		Test if the given arguments is alphanum.
		Returns
		-------
		Bool
			The tested condition
	"""
	return (char in ['0','1','2','3','4','5','6','7','8','9'])

#Building Matrix from a given linear Vector and Matrix size n x p
def build_Matrix(vector,n,p):
	ind=0
	res=Matrix(n,p)
	for i in range(res.size_r()):
		for j in range(res.size_c()):
			res[i,j]=(vector[ind])                  # Assign values from lin ear data vector
			ind+=1
	return res

# Get the matrix object since the relative path to the txt containing a float Matrix
def get_Matrix(path):
	res=[]
	div=False
	done=False
	ind=1
	packing(path)                                           # Packing matrix
	file=open(path+"_packed","r")                           # Get the raw ontent as string
	content=file.read()  #
	sig=1                                                   # Sign as multiplicative coef
	ind=1                                                   # Divider indice (10E-indice)
	tmp=0.0                                                 # Tmp reconstruction float value
	div=False
	size_line=0
	size_column=0
	for c in content:                                       # I read the raw content char by char
		print(c)		
		if(c!=" "):
			if(c=='-'):
				sig=-1.0                        # Sign update as multiplicative coef
			elif(c=='.'):
				div=True                        # Decimal assertion
			if(isalpha(c)):
				if div :
					tmp+=float(c)/10**ind   # Decimal float reconstruction
					ind+=1
				else:
					tmp*=10                 # Integer reconstruction (Horner's)
					tmp+=float(c)
			done=True
			if(c=='\n'):                            # Get number of lines
				size_line+=1
		else:	
			if done:
				res.append(sig*tmp)             # Apply the sign coef
			sig=1   
			ind=1
			tmp=0.0
			div=False
			done=False
		print("sizeline = "+str(size_line))
	res.append(sig*tmp)
	size_column=len(res)/size_line                          # Get column size
	res=build_Matrix(res,int(size_line),int(size_column))   # Building Matrix since https://github.com/matthieucabos/Python-utils
	file.close()
	print(res)
	return res

def means(mat):
	columns=[]
	means=[]
	tmp=0
	for i in range(mat.size_c()):                     
		columns.append(mat.column(i))                   # Get columns from Matrix
	for c in columns:
		tmp=0
		for e in c:
			tmp+=e
		means.append(tmp/mat.size_r())                  # Computing means
	print("means = "+str(means))
