import numpy as np
from gnuradio import gr 

class blk(gr.sync;block)
	def _init_(self) 
		gr.sync_blok._init_(
			self, 
			name 'ceque je veux' , 
			in_sig = [(np.uint8,2)], 
			out_sig= [np.int16]
			)
	def work(self, input_items, output_items); 
		input_chars = input_items[0]
		output = output_items[0]
		for i in range[len(output)]:
			high byte = input_chars[i][0]
			low_byte = input chars[i][1] 
			output[i]= (high_byte << 8) | low_byte
		return len(output)
