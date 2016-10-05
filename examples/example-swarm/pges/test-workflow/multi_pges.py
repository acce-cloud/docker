# Python script that submits multiple PGEs as independent parallel threads.
# The main program waits for all PGE to terminate before exiting.
#
# Usage:
# python multi_pges.py --task <task_number> --pges <number_of_pges>
#
# Example:
# python multi_pges.py
# python multi_pges.py --task 1 --pges 10
# python multi_pges.py --task 2 --pges 10
#
# Note: if task_number>1: it is assumed that as many input files already exist from the previous task,
# to be read at the beginning of this task

import os
import sys
import argparse
import multiprocessing

SIZE_IN_MB = 10
HEAP_IN_MB = 1
EXEC_TIME = 5
DIR_PATH = os.path.dirname(os.path.realpath(__file__))

def worker(output_file_name=None, input_file_name=None):
    """thread worker function"""

    pge_file_path = os.path.join(DIR_PATH, "pge.py")
    command = "python %s --heap %s --time %s" % (pge_file_path, HEAP_IN_MB, EXEC_TIME)

    if input_file_name is not None:
       command += " --in %s" % input_file_name

    if output_file_name is not None:
       command += " --out %s --size %s" % (output_file_name, SIZE_IN_MB)
 
    print command
    os.system(command)
    return

if __name__ == '__main__':

    # parse command line arguments
    parser = argparse.ArgumentParser(description="Python Script that submits multiple simulated PGEs")
    parser.add_argument('--task', type=int, help="Task number (optional, default: 1)",  default=1)
    parser.add_argument('--pges', type=int, help="Number of PGEs (optional, default: 1)",  default=1)
    args_dict = vars( parser.parse_args() )
    task_number = int(args_dict['task'])
    number_pges = int(args_dict['pges'])

    jobs = []
    for i in range(1, number_pges+1):
        
        # default arguments
        output_file_name = 'output%s_%s.out' % (task_number, i)
        input_file_name = None
        if task_number>1:
           input_file_name = 'output%s_%s.out' % (task_number-1, i)

        p = multiprocessing.Process(target=worker, args=(output_file_name, input_file_name))
        jobs.append(p)
        p.start()
