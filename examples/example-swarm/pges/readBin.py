# Python program that reads a binary file of given name.
# The input file is read from the directory $INPUT_DIR if defined,
# otherwise from the current directory where the program is executed

from array import array
import os
import sys

# method taht reads 1MB at a time
def read_in_chunks(file_object, chunk_size=1024*1024): # 1024 bytes x 1024 bytes = 1 MB
    while True:
        data = file_object.read(chunk_size)
        if not data:
            break
        yield data

# parse command line arguments
file_name   = sys.argv[1]

# input directory, defaults to current directory
input_dir = os.environ.get("INPUT_DIR", os.environ["PWD"])

input_file = open(os.path.join(input_dir, file_name), 'rb')
float_array = array('d')
for data in read_in_chunks(input_file):
   float_array.fromstring( data )
   #print float_array
