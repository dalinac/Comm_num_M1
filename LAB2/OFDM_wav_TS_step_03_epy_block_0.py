import numpy as np
from gnuradio import gr

class blk(gr.sync_block):

    def __init__(self):
        gr.sync_block.__init__(
            self,
            name='my_short_to_char_unpack',  
            in_sig=[np.int16],
            out_sig=[(np.uint8,2)]
        )

    def work(self, input_items, output_items):
        input_shorts = input_items[0]
        output = output_items[0]        
        for i in range(len(input_shorts)):
            val = input_shorts[i]
            output[i][0] = (val >> 8) & 0xFF   # octet de PpF
            output[i][1] = val & 0xFF          # octet de PmF
        return len(input_shorts)
