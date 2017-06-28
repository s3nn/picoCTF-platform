from hacksport.problem import Challenge,File,Forensics,Pregen
import os,random
from shutil import copyfile

class Problem(Pregen):
		
	def pick_challenge_id(self):
		self.challenge_id = os.path.splitext(random.choice(os.listdir("./data/pdf/")))[0][-2:]
		return
		
	def get_ans(self):
		with open("./data/ans/ans.txt",'r') as f:
			data = f.readlines()
			
		return data[int(self.challenge_id) - 1].strip()
		
	def get_challenge_files(self):
		copyfile("./data/pdf/cat" + self.challenge_id + ".pdf", "./cat.pdf")
		
		return [File ("./cat.pdf")]