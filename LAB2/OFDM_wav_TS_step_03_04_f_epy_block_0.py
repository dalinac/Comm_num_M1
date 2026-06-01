import numpy as np
from gnuradio import gr

class blk(gr.sync_block):
    def __init__(self):
        gr.sync_block.__init__(
            self,
            name='pi4_dqpsk_demod',
            in_sig=[np.complex64],
            out_sig=[np.uint8]
        )
        self.prev_sample = complex(1, 0)

    def work(self, input_items, output_items):
        in_data = input_items[0]
        out_data = output_items[0]
        N = len(in_data)
        samples = np.concatenate([[self.prev_sample], in_data])
        delta_phi = np.angle(samples[1:] * np.conj(samples[:-1]))
        self.prev_sample = in_data[-1]
        possible_phases = np.array([np.pi/4, 3*np.pi/4, -np.pi/4, -3*np.pi/4])
        symbol_map = np.array([0, 1, 2, 3])
        for i in range(N):
            diffs = np.abs(np.angle(np.exp(1j * (delta_phi[i] - possible_phases))))
            out_data[i] = symbol_map[np.argmin(diffs)]
        return N
