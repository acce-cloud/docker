# Python script that submits multiple PGEs as independent parallel sub-processes.
# Each PGE is executed within a separate Python interpreter.
# The main program waits for all PGE to terminate before exiting.
#
# Usage:
# python multi_pges.py --run <run_number> --task <task_number> --pges <number_of_pges>
#
# Example:
# python multi_pges.py
# python multi_pges.py --run 1 --task 1 --pges 10
# python multi_pges.py --run 1 --task 2 --pges 10
#
# Note: if task_number>1: it is assumed that as many input files already exist from the previous task,
# to be read at the beginning of this task

import os
import sys
import argparse
import logging
import multiprocessing

SIZE_IN_MB = 10
HEAP_IN_MB = 1
EXEC_TIME = 5
DIR_PATH = os.path.dirname(os.path.realpath(__file__))

# set log level
logging.basicConfig(level=logging.DEBUG,
                    format='[%(levelname)s] (%(threadName)-10s) %(message)s',
                    )


def worker(output_file_name, input_file_name):
    """sub-process worker function"""

    logging.info("Starting worker: %s" % multiprocessing.current_process().name)

    pge_file_path = os.path.join(DIR_PATH, "pge.py")
    command = "python %s --heap %s --time %s" % (pge_file_path, HEAP_IN_MB, EXEC_TIME)

    if input_file_name is not None:
       command += " --in %s" % input_file_name

    if output_file_name is not None:
       command += " --out %s --size %s" % (output_file_name, SIZE_IN_MB)
 
    # execute command in a subshell, wait for command return status
    logging.info("Executing system command: %s" % command)
    status = os.system(command)

    logging.info("Worker: %s ended, return status: %s" % (multiprocessing.current_process().name, status))

    return

if __name__ == '__main__':

    # parse command line arguments
    parser = argparse.ArgumentParser(description="Python Script that submits multiple simulated PGEs")
    parser.add_argument('--pges', type=int, help="Number of PGEs (optional, default: 1)",  default=1)
    parser.add_argument('--run', type=int, help="Number number (optional, default: 1)",  default=1)
    parser.add_argument('--task', type=int, help="Task number (optional, default: 1)",  default=1)
    args_dict = vars( parser.parse_args() )
    run_number = int(args_dict['run'])
    task_number = int(args_dict['task'])
    number_pges = int(args_dict['pges'])

    jobs = []
    # start all sub-processes
    # main program will wait for all sub-processes to end before exiting itself
    for i in range(1, number_pges+1):
        
        # default arguments
        output_file_name = 'output_run%s_task%s_pge%s.out' % (run_number, task_number, i)
        input_file_name = None
        if task_number>1:
           input_file_name = 'output_run%s_task%s_pge%s.out' % (run_number, task_number-1, i)

        pname = "Process_run%s_task%s_pge%s" % (run_number, task_number, i)
        p = multiprocessing.Process(target=worker, args=(output_file_name, input_file_name), name=pname)
        #p.daemon = True # run as daemon, main program may exit before sub-process is over
        jobs.append(p)
        p.start()

    # wait for sub-processes to terminate
    # (not strictly necessary as it happens anyway for non-daemon sub-processes)
    for p in jobs:
        p.join()
        logging.debug("Sub-process: %s exit code=%s" % (p.name, p.exitcode))
