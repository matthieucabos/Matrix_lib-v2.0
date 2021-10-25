#!/bin/bash

# Author : CABOS Matthieu
# Date : 25/10/2021

ext="numpy pandas pyexcel openpyxl array_to_latex"
for e in $ext
do
	pip3 install $e
done
sudo apt install tesseract-ocr libtesseract-dev tesseract-ocr-eng