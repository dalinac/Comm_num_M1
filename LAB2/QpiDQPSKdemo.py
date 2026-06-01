# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: pi/4-DQPSK demod
# GNU Radio version: 3.10.9.2

from gnuradio import blocks
from gnuradio import digital
from gnuradio import gr
from gnuradio.filter import firdes
from gnuradio.fft import window
import sys
import signal
import QpiDQPSKdemo_epy_block_1_0 as epy_block_1_0  # embedded python block
import math







class QpiDQPSKdemo(gr.hier_block2):
    def __init__(self):
        gr.hier_block2.__init__(
            self, "pi/4-DQPSK demod",
                gr.io_signature(1, 1, gr.sizeof_gr_complex*1),
                gr.io_signature(1, 1, gr.sizeof_gr_complex*1),
        )

        ##################################################
        # Variables
        ##################################################
        self.subCarr_K = subCarr_K = 4
        self.my_const_1 = my_const_1 = digital.constellation_calcdist([1, (1+1j)/math.sqrt(2)], [0, 1],
        2, 1, digital.constellation.NO_NORMALIZATION).base()
        self.my_const_1.set_npwr(0)

        ##################################################
        # Blocks
        ##################################################

        self.epy_block_1_0 = epy_block_1_0.blk(vsize=subCarr_K+1)
        self.digital_constellation_encoder_bc_0_0_0_0_0 = digital.constellation_encoder_bc(my_const_1)
        self.blocks_vector_to_stream_0_0 = blocks.vector_to_stream(gr.sizeof_gr_complex*1, (subCarr_K+1))
        self.blocks_vector_source_x_1_0_0 = blocks.vector_source_b((0,1,)*(subCarr_K//2)+(0,), True, 1, [])
        self.blocks_stream_to_vector_0_0 = blocks.stream_to_vector(gr.sizeof_gr_complex*1, (subCarr_K+1))
        self.blocks_stream_demux_0 = blocks.stream_demux(gr.sizeof_gr_complex*1, (1, subCarr_K))
        self.blocks_null_sink_0 = blocks.null_sink(gr.sizeof_gr_complex*1)
        self.blocks_multiply_conjugate_cc_0_0_0 = blocks.multiply_conjugate_cc(1)


        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_multiply_conjugate_cc_0_0_0, 0), (self.blocks_stream_to_vector_0_0, 0))
        self.connect((self.blocks_stream_demux_0, 0), (self.blocks_null_sink_0, 0))
        self.connect((self.blocks_stream_demux_0, 1), (self, 0))
        self.connect((self.blocks_stream_to_vector_0_0, 0), (self.epy_block_1_0, 0))
        self.connect((self.blocks_vector_source_x_1_0_0, 0), (self.digital_constellation_encoder_bc_0_0_0_0_0, 0))
        self.connect((self.blocks_vector_to_stream_0_0, 0), (self.blocks_stream_demux_0, 0))
        self.connect((self.digital_constellation_encoder_bc_0_0_0_0_0, 0), (self.blocks_multiply_conjugate_cc_0_0_0, 1))
        self.connect((self.epy_block_1_0, 0), (self.blocks_vector_to_stream_0_0, 0))
        self.connect((self, 0), (self.blocks_multiply_conjugate_cc_0_0_0, 0))


    def get_subCarr_K(self):
        return self.subCarr_K

    def set_subCarr_K(self, subCarr_K):
        self.subCarr_K = subCarr_K
        self.blocks_vector_source_x_1_0_0.set_data((0,1,)*(self.subCarr_K//2)+(0,), [])
        self.epy_block_1_0.vsize = self.subCarr_K+1

    def get_my_const_1(self):
        return self.my_const_1

    def set_my_const_1(self, my_const_1):
        self.my_const_1 = my_const_1
        self.digital_constellation_encoder_bc_0_0_0_0_0.set_constellation(self.my_const_1)

