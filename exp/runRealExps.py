import subprocess
import threading
import re
import os
import multiprocessing

def nonExistentDFT(dft, expNum, dprefix=''):
	for (d,f,t) in 	dft:
		dat = os.path.basename(d).replace('.mat', '')
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
		myCmd = "cd exp%d ; exp%d( '%s', %s, %d) " % (expNum, expNum, d,  f, t)
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

	
	if len(sys.argv) < 4:
		print "USAGE: %s #machines #part #exp" % sys.argv[0]
		sys.exit(1)
	
	machines = int(sys.argv[1])
	part = int(sys.argv[2])
	expNum = int(sys.argv[3])
	
	mainPath = '/home/nuke/matlab_code/expr/dlsmi'	
	
	# for 4 features	
	#sets = ['abalone', 'breastcancer', 'cpuact', 'diabetes', 'flaresolar', 'german', 'glass', 'heart', 'housing', 'image', 'ionosphere', 'segment', 'vehicle', 'vowel', 'wine']
	
	# for 10 features
	#sets = ['msd', 'satimage','senseval2', 'sonar', 'spectf', 'speech']
	
	# for 20 features
	#sets = ['musk1', 'musk2', 'ctslices', 'isolet']
	#sets = ['musk1', 'musk2',  'isolet']
	
	# all
	#sets = ['abalone', 'breastcancer', 'cpuact', 'diabetes', 'flaresolar', 'german', 'glass', 'heart', 'housing', 'image', 'ionosphere', 'segment', 'vehicle', 'vowel', 'wine', 'msd', 'satimage', 'senseval2', 'sonar', 'spectf', 'speech', 'musk1', 'musk2', 'ctslices', 'isolet']
	
	# good sets + relatively large enough
	sets = ['abalone','breastcancer','ctslices', 'cpuact', 'german', 'glass', 'housing', 'image', 'ionosphere', 'isolet', 'musk1', 'musk2','msd', 'satimage', 'segment','senseval2', 'sonar', 'spectf', 'speech', 'vehicle', 'vowel',  'wine']
	# for vark

	
	# small datasets
	#sets = ['abalone', 'breastcancer', 'diabetes', 'flaresolar', 'german', 'glass', 'heart']
	
	# Large datasets
	#sets = ['PCMAC', 'TOX_171', 'BASEHOCK', 'warpPIE10P']
	
	#sets = ['TOX_171', 'BASEHOCK', 'warpPIE10P', 'CLL_SUB_111', 'SMK_CAN_187']
	#sets = ['TOX_171', 'BASEHOCK', 'warpPIE10P', 'CLL_SUB_111', 'SMK_CAN_187', 'PCMAC', 'madelon', 'olivetti', 'usps', 'amazon']

	# Extremely large (more than 10000) features
	#sets = ['CLL_SUB_111', 'GLI_85', 'SMK_CAN_187', 'amazon']
	
	#sets = ['PCMAC', 'TOX_171', 'BASEHOCK', 'warpPIE10P', 'CLL_SUB_111', 'GLI_85', 'SMK_CAN_187', 'amazon' ]
	
	dsets = map(lambda x: "/home/nuke/matlab_code/expr/dlsmi/real/" + x +".mat", sets)
	
	#methods = ['@fs_rhsic', '@fs_rlsmi']
	#methods = ['@fs_pc']
	#methods = ['@fs_pglsmi']
	#methods = ['@fs_mrmr']
	#methods = ['@fs_relief']
	#methods = ['@fs_pghsic']
	#methods = ['@fs_fohsic', '@fs_bahsic', '@fs_folsmi', '@fs_balsmi', '@fs_pc', '@fs_rhsic', '@fs_rlsmi', '@fs_mrmr', '@fs_relief', '@fs_pglsmi', '@fs_pghsic']
	#methods = ['@fs_fohsic', '@fs_bahsic', '@fs_folsmi', '@fs_balsmi', '@fs_pc', '@fs_mrmr', '@fs_relief', '@fs_pglsmi', '@fs_pghsic']
	
	# no BA
	#methods = ['@fs_pc', '@fs_mrmr', '@fs_relief', '@fs_pglsmi', '@fs_pghsic']

	#methods = ['@fs_fohsic', '@fs_folsmi', '@fs_pc', '@fs_mrmr', '@fs_mrmrq', '@fs_relief']
	#methods = [ '@fs_pglsmi']
	#methods = [ '@fs_pghsic']
	methods = ['@fs_pc', '@fs_mrmr', '@fs_relief', '@fs_pglsmi', '@fs_pghsic', '@fs_lasso', '@fs_qpfs', '@fs_folsmi', '@fs_fohsic']
	#methods = ['@fs_lasso']
	#methods = ['@fs_pc', '@fs_mrmr', '@fs_relief']
	#methods = ['@fs_pglsmi', '@fs_pghsic']
	
	#trials = range(6,11) # 5 trials
	#trials = range(1,3) 
	#trials = range(1, 21)
	#trials = range(1,6) # 5 trials
	#trials = range(1,51) # 50 trials
	trials = range(1, 101)
	#trials = range(1,11) # 10 trials

	#trials = range(1,21) # 20 trials
	#trials = range(1,31) # 30 trials
	#trials = range(31, 51)
	#trials = range(11,31) # trial 11-30
	#trials = range(11,51)
	#trials = range(11,21) # trial 11-20
	#trials = range(21,51) # trial 21-50
	
	dft = [( d,f,t) for d in dsets for f in methods for t in trials]

	# exclude trial files which already exist
	dprefix = ''
	dft = list(nonExistentDFT(dft, expNum, dprefix))

	random.seed(322)
	random.shuffle(dft)
	random.seed(2397)
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
		while os.getloadavg()[0]/ncpu >= 1.3:
			#time.sleep(random.uniform(20, 40))
			time.sleep(8)
			
		d,f,t = dft[i]
		myThread = Exp(mainPath,  d, f, t,  expNum, name = 'thread-%s' % d)
		myThread.start()	
		time.sleep(17)
		j = j+1

if __name__ == '__main__':
	main()	


