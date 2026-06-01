import numpy as np
from gnuradio import gr

class blk(gr.sync_block):
    def __init__(self):
        gr.sync_block.__init__(
            self,
            name='my_short_to_char_pack',
            in_sig=[(np.uint8, 2)],
            out_sig=[np.int16]
        )

    def work(self, input_items, output_items):
        input_chars = input_items[0]
        output = output_items[0]
        low_byte = input_chars[:, 0].astype(np.int16)
        high_byte = input_chars[:, 1].astype(np.int16)
        output[:] = (high_byte << 8) | low_byte
        return len(output)
