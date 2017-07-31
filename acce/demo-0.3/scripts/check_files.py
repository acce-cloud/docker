# script to check output files in given directory
import glob

njobs=2000
ntasks=2
root_dir = '/ecostress_data/oodt03-demo/archive/test-workflow'
#all_files = glob.glob('%s/*.out' % root_dir)

# loop over jobs, tasks
num_failed_jobs = 0
for i in range(1,njobs+1):
  failed = False
  for j in range(1,ntasks+1):
    files = glob.glob('%s/output_Run_%s_Task_%s_*.out' % (root_dir, i, j))
    if files:
      pass
    else:
      print 'Missing file for job=%s task=%s' % (i,j)
      if not failed:
        failed = True
        num_failed_jobs += 1

print "Total Number of failed jobs=%s" % num_failed_jobs
