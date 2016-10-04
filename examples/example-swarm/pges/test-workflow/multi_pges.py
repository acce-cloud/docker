# Python script that submits multiple PGEs
# Usage:
# python multi_pges.py <task_number>
# Example:
# python multi_pges.py 1
# python multi_pges.py 2

import os
import sys
import multiprocessing

SIZE_IN_MB = 10
DIR_PATH = os.path.dirname(os.path.realpath(__file__))

def worker(output_file_name=None, input_file_name=None):
    """thread worker function"""

    pge_file_path = os.path.join(DIR_PATH, "pge.py")
    command = "python %s" % pge_file_path

    if input_file_name is not None:
       command += " --in %s" % input_file_name

    if output_file_name is not None:
       command += " --out %s --size %s" % (output_file_name, SIZE_IN_MB)
 
    print command
    os.system(command)
    return

if __name__ == '__main__':

    # parse command line argument
    task_number = int(sys.argv[1])

    jobs = []
    for i in range(1, 6):
        
        # default arguments
        output_file_name = 'output%s_%s.out' % (task_number, i)
        input_file_name = None
        if task_number>1:
           input_file_name = 'output%s_%s.out' % (task_number-1, i)

        p = multiprocessing.Process(target=worker, args=(output_file_name, input_file_name))
        jobs.append(p)
        p.start()
