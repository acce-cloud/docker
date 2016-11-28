# Python script that simulates a single PGE:
# - reads one file
# - allocates some memory 
# - does some computation
# - writes one file

# Input/output files are located in the directory $DATA_DIR, or the current directory if $DATA_DIR is not set.
# All arguments are optional, some have defaults.
#
# Usage:
# python pge.py [--in <input_file_name> [--out <output_file_name>] [--size <output_file_size_in_mb>] [--heap <heap_size_in_mb>] [--time <exec_time_in_secs>]
#
# Example:
# python pge.py --in input.txt --out output.txt --size 100 --heap 10 --time 5

import sys
import os
import time
from array import array
import argparse
import logging

# Optional module to print heap usage
# Must be installed with: pip install guppy
#from guppy import hpy

# set log level
logging.basicConfig(level=logging.DEBUG,
                    format='[%(levelname)s] (%(threadName)-10s) %(message)s',
                    )

# method taht reads 1MB at a time
def read_in_chunks(file_object, chunk_size=1024*1024): # 1024 bytes x 1024 bytes = 1 MB
    while True:
        data = file_object.read(chunk_size)
        if not data:
            break
        yield data

# main execution method
def execute(input_file_name=None, output_file_name=None, output_size_in_mb=1, heap_size_in_mb=0, exec_time_in_secs=0):

  #h = hpy()
  #print h.heap()

  # data directory, defaults to current directory
  data_dir = os.environ.get("DATA_DIR", os.environ["PWD"])

  # optional input
  if input_file_name is not None:
    input_file_path = os.path.join(data_dir, input_file_name)
    logging.info("Reading input file: %s" % input_file_path)
    input_file = open(input_file_path, 'rb')
   
    input_array = array('d')
    for data in read_in_chunks(input_file):
      input_array.fromstring( data )

  # optional (additional) heap allocation
  if heap_size_in_mb > 0:
     num_bytes = heap_size_in_mb*1024*1024
     num_doubles = num_bytes/8 # each double is 8 bytes
     logging.info("Allocating heap array of: %s doubles" % num_doubles)
     heap_array = array('d', range(num_doubles) ) # array of doubles with total size = num_bytes
     #print h.heap()

  # optional processing
  if exec_time_in_secs > 0:
     i=0
     while (i < exec_time_in_secs):
        i += 1
        if heap_size_in_mb > 0:
           for idx, val in enumerate(heap_array):
               heap_array[idx] += 1
        time.sleep(1) # sleep 1 second each time
        logging.debug("Working... slept: %s secs" % i)

  # optional output
  if output_file_name is not None:
     output_file_path = os.path.join(data_dir, output_file_name)
     logging.info("Writing output file: %s" % output_file_path)

     # use Unix utility to write file of given size (1048576 = 1024*1024 = 1MB)
     os.system("dd if=/dev/urandom of=%s bs=1048576 count=%s" % (output_file_path, output_size_in_mb))

     # each loop iteration will write out 1 KB of data
     #output_file = open(output_file_path, 'wb')
     #for i in range(output_size_in_mb*1024): # loop over KB
     #   # array of 128 doubles = 128x8 bytes = 1024 bytes = 1 KB
     #   data = range(1024/8)
     #   float_array = array('d', data) # array of 'double' - each double is 8 bytes
     #   float_array.tofile(output_file)
     #output_file.close()

if __name__ == '__main__':
    
    # parse command line arguments
    parser = argparse.ArgumentParser(description="Python Script simulating a single PGE")
    parser.add_argument('--in', type=str, help="Input file name (optional, default: none)",  default=None)
    parser.add_argument('--out', type=str, help="Output file name (optional, default: none)",  default=None)
    parser.add_argument('--size', type=int, help="Output file size in MB (optional, default: 1)",  default=1)
    parser.add_argument('--heap', type=int, help="Additional allocated heap size in MB (optional, default: 0)",  default=0)
    parser.add_argument('--time', type=int, help="Sleep time in seconds (optional, default: 0)",  default=0)
    args_dict = vars( parser.parse_args() )

    execute(input_file_name=args_dict['in'], output_file_name=args_dict['out'], output_size_in_mb=args_dict['size'],\
            heap_size_in_mb=args_dict['heap'], exec_time_in_secs=args_dict['time'])
