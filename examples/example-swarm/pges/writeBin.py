# Python program that writes a binary file of N number of MB
# The output file is written to the directory $OUTPUT_DIR if defined,
# otherwise in the current directory where the program is executed.

from array import array
import os

size_in_mb = 10

# output directory, defaults to current directory
output_dir = os.environ.get("OUTPUT_DIR", os.environ["PWD"])

# output file
output_file = open(os.path.join(output_dir,'file.out'), 'wb')

# each loop iteration will write out 1 KB of data
for i in range(size_in_mb*1024): # loop over KB

  # array of 128 doubles = 128x8 bytes = 1024 bytes = 1 KB
  data = range(1024/8)
  float_array = array('d', data) # array of 'double' - each double is 8 bytes
  float_array.tofile(output_file)

output_file.close()
