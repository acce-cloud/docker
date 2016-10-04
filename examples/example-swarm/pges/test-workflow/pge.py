# Python script that simulates a PGE:
# - reads one or more files
# - allocates some memory, does some computation
# - writes one or more files
# Input/outout files are loacted in the directory $DATA_DIR, or the current directory
# All arguments are optional. Output file size defaults to 1 MB.
#
# Usage:
# python pge.py [--in <input_file_name> [--out <output_file_name>] [--size <output_file_name_size_in_mb>]
#
# Example:
# python pge.py --in input.txt --out output.txt --size 100

import sys
import os
from array import array
import argparse

# method taht reads 1MB at a time
def read_in_chunks(file_object, chunk_size=1024*1024): # 1024 bytes x 1024 bytes = 1 MB
    while True:
        data = file_object.read(chunk_size)
        if not data:
            break
        yield data

def execute(input_file_name=None, output_file_name=None, output_size_in_mb=1):

  # data directory, defaults to current directory
  data_dir = os.environ.get("DATA_DIR", os.environ["PWD"])

  # optional input
  if input_file_name is not None:
    input_file = open(os.path.join(data_dir, input_file_name), 'rb')
   
    float_array = array('d')
    for data in read_in_chunks(input_file):
      float_array.fromstring( data )
     #print float_array


  # optional output
  if output_file_name is not None:
     output_file = open(os.path.join(data_dir, output_file_name), 'wb')

     # each loop iteration will write out 1 KB of data
     for i in range(output_size_in_mb*1024): # loop over KB

        # array of 128 doubles = 128x8 bytes = 1024 bytes = 1 KB
        data = range(1024/8)
        float_array = array('d', data) # array of 'double' - each double is 8 bytes
        float_array.tofile(output_file)

     output_file.close()

if __name__ == '__main__':
    
    # parse command line arguments
    parser = argparse.ArgumentParser(description="Python Script simulating a generic PGE")
    parser.add_argument('--in', type=str, help="Input file name (optional, default: none)",  default=None)
    parser.add_argument('--out', type=str, help="Output file name (optional, default: none)",  default=None)
    parser.add_argument('--size', type=int, help="Output file size in MB (optional, default: 1)",  default=1)
    args_dict = vars( parser.parse_args() )

    execute(input_file_name=args_dict['in'], output_file_name=args_dict['out'], output_size_in_mb=args_dict['size']) 
