from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules=[
		Extension("cmatrix",
				sources=["cmatrix.pyx"],
				extra_compile_args=['-fopenmp'],
				extra_link_args=['-fopenmp'])]

setup(
	name="cmatrix",
	cmdclass = {'build_ext' : build_ext},
	ext_modules=ext_modules
	
	)

# python3 setup.py build_ext --inplace
#num_threads=os.cpu_count()
#for i in prange(100, nogil=True, num_threads):
