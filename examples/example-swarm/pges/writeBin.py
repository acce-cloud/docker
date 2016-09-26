# Python program that writes a binary file of N number of MB
# The output file is written to the directory $OUTPUT_DIR if defined,
# otherwise in the current directory where the program is executed.
#
# Usage:
# python writeBin.py day# orbit# scene#

import sys
import os
from array import array

size_in_mb = 10

# parse command line arguments
day   = sys.argv[1]
orbit = sys.argv[2]
scene = sys.argv[3]

# output directory, defaults to current directory
output_dir = os.environ.get("OUTPUT_DIR", os.environ["PWD"])

# output file
file_name = "output_d%s_o%s_s%s.out" % (day, orbit, scene)
output_file = open(os.path.join(output_dir, file_name), 'wb')

# each loop iteration will write out 1 KB of data
for i in range(size_in_mb*1024): # loop over KB

  # array of 128 doubles = 128x8 bytes = 1024 bytes = 1 KB
  data = range(1024/8)
  float_array = array('d', data) # array of 'double' - each double is 8 bytes
  float_array.tofile(output_file)

output_file.close()
