import numpy as np
from gnuradio import gr

class blk(gr.sync_block):
    def __init__(self):
        gr.sync_block.__init__(
            self,
            name='pi4_DQPSK_mod',
            in_sig=[np.complex64],
            out_sig=[np.complex64]
        )
        self.prev = complex(0.707106781, 0.707106781)

    def work(self, input_items, output_items):
        in_data = input_items[0]
        out_data = output_items[0]
        N = len(in_data)
        for i in range(N):
            out_data[i] = in_data[i] * self.prev
            self.prev = out_data[i]
        return N
