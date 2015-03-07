import subprocess
import threading
import re
import os
import multiprocessing

def nonExistentDFT(dft, expNum, dprefix=''):
	for (d,f,t) in 	dft:
		dat = os.path.basename(d).replace('.mat', '').replace('@gen_', '')
		
		met = f.replace('@fs_', '')
		p = 'exp%d/%s-%s/%s-%s-%d.mat'%(expNum,  dprefix+dat, met, dprefix+dat, met, t) 
		if not os.path.exists(p):
			#print p
			yield (d,f,t)

class Exp(threading.Thread):
	def __init__(self , mainPath , dataset, func,trial, expNum, **kwargs):
		threading.Thread.__init__(self, kwargs = kwargs)
		self.mainPath = mainPath
		self.dataset = dataset
		self.trial = trial
		self.func = func
		self.expNum = expNum
	
	def run(self):
		expNum = self.expNum
		d = self.dataset
		mainPath = self.mainPath
		f = self.func
		t = self.trial
		# exp1(data_gen_func, fs_func, trial)
		myCmd = "cd exp%d ; exp%d( %s, %s, %d) " % (expNum, expNum, d,  f, t)
		matlabCmd = "cd %s ; startup(); cd exp; %s ; exit() " % (mainPath , myCmd )
		print matlabCmd

		# Run Matlabs
		
		#process = subprocess.Popen(['matlab', '-nosplash', '-nodesktop' ,'-r' , matlabCmd], shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		process = subprocess.Popen(['matlab', '-nosplash', '-nodesktop' ,'-r' , matlabCmd], shell=False)
		#inlog, errlog =  process.communicate()
		
		"""
		fname = mainPath  + '/exp%d/'%(expNum) +  '$(basename %s .mat)_'%(d) + f
		inf = open( fname + '.log' , 'w')
		inf.write(inlog)
		inf.close()
		
		if errlog.strip() != '':			
			errf = open( fname + '.err' , 'w')
			errf.write(errlog)
			errf.close()
		"""
	

def main():
	import sys
	import random
	import math
	import time
	import os
	
	if len(sys.argv) < 4:
		print "USAGE: %s #machines #part #exp" % sys.argv[0]
		sys.exit(1)
	
	machines = int(sys.argv[1])
	part = int(sys.argv[2])
	expNum = int(sys.argv[3])
	
	mainPath = '/home/nuke/matlab_code/expr/dlsmi'	
	

	#dsets = ['@gen_plus',  '@gen_sca3', '@gen_log3', '@gen_xor5',  '@gen_sin5', '@gen_plusc', '@gen_3clusters', '@gen_exp2_6', '@gen_poly2', '@gen_exp5_15', '@gen_fvm', '@gen_xor']
	#dsets = ['@gen_plus',  '@gen_sca3', '@gen_sin5', '@gen_plusc', '@gen_3clusters', '@gen_exp2_6',  '@gen_xor']
	#dsets = ['@gen_sca3', '@gen_sin5', '@gen_3clusters1', '@gen_3clusters2', '@gen_exp2_6', '@gen_xor', '@gen_xor5', '@gen_plus5', '@gen_fvm']
	#dsets = ['@gen_3clusters1', '@gen_3clusters2']
	dsets = ['@gen_andor', '@gen_sca3', '@gen_xor']
	
	#dsets = ['@gen_plusc']
	
	#methods = ['@fs_fohsic', '@fs_bahsic', '@fs_dhsic_reprseq', '@fs_folsmi', '@fs_balsmi', '@fs_pc', '@fs_wlsmi_reprseq', '@fs_dhsic_nms_reprseq' ]
	#methods = ['@fs_wlsmi_reprseq']
	#methods = [ '@fs_bahsic', '@fs_dhsic_reprseq', '@fs_balsmi', '@fs_dlsmi_reprseq', '@fs_pc' ]
	#methods = [ '@fs_folsmi']
	#methods = [ '@fs_dhsic_nms_reprseq', '@fs_dlsmi_nms_reprseq']
	#methods = [ '@fs_bahsic', '@fs_dhsic_reprseq', '@fs_balsmi', '@fs_dlsmi_reprseq', '@fs_pc' ]
	#methods = [ '@fs_folsmi', '@fs_balsmi', '@fs_dlsmi_reprseq', '@fs_dlsmi_reprseq_e0', '@fs_dlsmi_reprseq_e0r1', '@fs_dhsic_reprseq', '@fs_dhsic_reprseq_e0', '@fs_dhsic_reprseq_e0r1' ]	
	#methods = ['@fs_dlsmi_reprseq_e1',  '@fs_dlsmi_reprseq', '@fs_dlsmi_reprseq_e0', '@fs_dlsmi_reprseq_e1f',  '@fs_dlsmi_reprseq_f', '@fs_dlsmi_reprseq_e0f']	   
	#methods = ['@fs_wlsmi_reprseq']
	#methods = ['@fs_fohsic', '@fs_bahsic', '@fs_folsmi', '@fs_balsmi', '@fs_pc', '@fs_dlsmi_reprseq_e0f', '@fs_dlsmi_reprseq_e0', '@fs_dlsmi_reprseq', '@fs_dlsmi_reprseq_f', '@fs_rhsic', '@fs_rlsmi', '@fs_dhsic_reprseq_e0']
	
	# e0
	#methods = ['@fs_fohsic', '@fs_bahsic', '@fs_folsmi', '@fs_balsmi', '@fs_pc', '@fs_dlsmi_reprseq_e0f', '@fs_dlsmi_reprseq_e0', '@fs_rhsic', '@fs_rlsmi', '@fs_dhsic_reprseq_e0']
	#methods = ['@fs_fohsic', '@fs_bahsic', '@fs_folsmi', '@fs_balsmi', '@fs_pc', '@fs_dlsmi_reprseq_e0f', '@fs_dlsmi_reprseq_e0', '@fs_dhsic_reprseq_e0']
	methods = ['@fs_fohsic', '@fs_bahsic', '@fs_folsmi', '@fs_balsmi', '@fs_pc', '@fs_mrmr', '@fs_relief', '@fs_pglsmi', '@fs_pghsic', '@fs_lasso', '@fs_qpfs']

	#methods = ['@fs_folsmi', '@fs_rlsmi', '@fs_pglsmi', '@fs_pghsic']
	
	trials = range(1, 51)
	#trials = range(1,11) # 10 trials
	#trials = range(1,21) # 20 trials
	#trials = range(21,51) # 21-50
	#trials = range(11,31) # trial 11-30
	#trials = range(1,31) # trial 1-30
	
	dft = [( d,f,t) for d in dsets for f in methods for t in trials]
	# exclude trial files which already exist
	dprefix = ''
	dft = list(nonExistentDFT(dft, expNum, dprefix))

	random.seed(148)
	random.shuffle(dft)
	random.seed(993)
	random.shuffle(dft)
	
	# Calculate from and to index for #part 
	interv = int(math.ceil(len(dft) / machines ))
	fromi = (part - 1)*interv
	toi =  part*interv - 1 if part < machines else len(dft)  - 1
	
	print "datasets: %s" % dsets
	print "trials: %d" % len(trials)
	print "total combinations: %d" % len(dft)
	print "from: %d to: %d" % (fromi, toi)

	j = 1
	ncpu = multiprocessing.cpu_count()
	for i in range(fromi, toi+1):
		# wait if the load is too high
		while os.getloadavg()[0]/ncpu >= 1.5:
			#time.sleep(random.uniform(20, 40))
			time.sleep(4)
			
		d,f,t = dft[i]
		myThread = Exp(mainPath,  d, f, t,  expNum, name = 'thread-%s' % d)
		myThread.start()	
		time.sleep(9)
		j = j+1
		
if __name__ == '__main__':
	main()	

