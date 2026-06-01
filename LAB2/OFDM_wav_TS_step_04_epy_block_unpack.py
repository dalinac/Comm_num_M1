import numpy as np
from gnuradio import gr

class blk(gr.sync_block):
    def __init__(self):
        gr.sync_block.__init__(
            self,
            name='my_short_to_char_unpack',
            in_sig=[np.int16],
            out_sig=[(np.uint8, 2)]
        )

    def work(self, input_items, output_items):
        in_data = input_items[0]
        out_data = output_items[0]
        out_data[:, 0] = (in_data & 0xFF).astype(np.uint8)
        out_data[:, 1] = ((in_data >> 8) & 0xFF).astype(np.uint8)
        return len(out_data)
