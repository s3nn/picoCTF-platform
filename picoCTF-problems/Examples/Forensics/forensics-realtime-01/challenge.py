from hacksport.problem import Challenge,File,Forensics,Realtime
from shutil import copyfile

class Problem(Realtime):
		
	def generate_challenge(self):
		copyfile("./data.png" , "./data-secret.png")
		
		with open("./data-secret.png","a") as f:
			f.write(self.flag)
		
		return [File ("./data-secret.png")]