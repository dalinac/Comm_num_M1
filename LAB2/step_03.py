#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Step 03
# GNU Radio version: 3.10.9.2

from PyQt5 import Qt
from gnuradio import qtgui
from gnuradio import audio
from gnuradio import blocks
from gnuradio import digital
from gnuradio import gr
from gnuradio.filter import firdes
from gnuradio.fft import window
import sys
import signal
from PyQt5 import Qt
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
import step_03_epy_block_0 as epy_block_0  # embedded python block
import step_03_epy_block_1 as epy_block_1  # embedded python block



class step_03(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "Step 03", catch_exceptions=True)
        Qt.QWidget.__init__(self)
        self.setWindowTitle("Step 03")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except BaseException as exc:
            print(f"Qt GUI: Could not set Icon: {str(exc)}", file=sys.stderr)
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "step_03")

        try:
            geometry = self.settings.value("geometry")
            if geometry:
                self.restoreGeometry(geometry)
        except BaseException as exc:
            print(f"Qt GUI: Could not restore geometry: {str(exc)}", file=sys.stderr)

        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = 2048000
        self.my_const = my_const = digital.constellation_calcdist([-1-1j, -1+1j, 1+1j, 1-1j], [0, 1, 3, 2],
        4, 1, digital.constellation.AMPLITUDE_NORMALIZATION).base()
        self.my_const.set_npwr(1.0)

        ##################################################
        # Blocks
        ##################################################

        self.epy_block_1 = epy_block_1.blk()
        self.epy_block_0 = epy_block_0.blk()
        self.digital_constellation_encoder_bc_0 = digital.constellation_encoder_bc(my_const)
        self.digital_constellation_decoder_cb_0 = digital.constellation_decoder_cb(my_const)
        self.blocks_wavfile_source_0 = blocks.wavfile_source('/home/bida/Downloads/LAB2-20260323/vivaldi_domaine_public.wav', True)
        self.blocks_vector_to_stream_0 = blocks.vector_to_stream(gr.sizeof_char*1, 2)
        self.blocks_throttle2_1 = blocks.throttle( gr.sizeof_short*1, samp_rate, True, 0 if "auto" == "auto" else max( int(float(0.1) * samp_rate) if "auto" == "time" else int(0.1), 1) )
        self.blocks_stream_to_vector_0 = blocks.stream_to_vector(gr.sizeof_char*1, 2)
        self.blocks_short_to_float_0_0_0 = blocks.short_to_float(1, 32768)
        self.blocks_short_to_float_0_0 = blocks.short_to_float(1, 32768)
        self.blocks_repack_bits_bb_0_0 = blocks.repack_bits_bb(8, 2, "", False, gr.GR_LSB_FIRST)
        self.blocks_repack_bits_bb_0 = blocks.repack_bits_bb(2, 8, "", False, gr.GR_LSB_FIRST)
        self.blocks_interleave_0 = blocks.interleave(gr.sizeof_short*1, 1)
        self.blocks_float_to_short_1 = blocks.float_to_short(1, 32768)
        self.blocks_float_to_short_0 = blocks.float_to_short(1, 32768)
        self.blocks_deinterleave_0 = blocks.deinterleave(gr.sizeof_short*1, 1)
        self.audio_sink_0 = audio.sink(48000, '', True)


        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_deinterleave_0, 0), (self.blocks_short_to_float_0_0, 0))
        self.connect((self.blocks_deinterleave_0, 1), (self.blocks_short_to_float_0_0_0, 0))
        self.connect((self.blocks_float_to_short_0, 0), (self.blocks_interleave_0, 0))
        self.connect((self.blocks_float_to_short_1, 0), (self.blocks_interleave_0, 1))
        self.connect((self.blocks_interleave_0, 0), (self.blocks_throttle2_1, 0))
        self.connect((self.blocks_repack_bits_bb_0, 0), (self.blocks_stream_to_vector_0, 0))
        self.connect((self.blocks_repack_bits_bb_0_0, 0), (self.digital_constellation_encoder_bc_0, 0))
        self.connect((self.blocks_short_to_float_0_0, 0), (self.audio_sink_0, 0))
        self.connect((self.blocks_short_to_float_0_0_0, 0), (self.audio_sink_0, 1))
        self.connect((self.blocks_stream_to_vector_0, 0), (self.epy_block_0, 0))
        self.connect((self.blocks_throttle2_1, 0), (self.epy_block_1, 0))
        self.connect((self.blocks_vector_to_stream_0, 0), (self.blocks_repack_bits_bb_0_0, 0))
        self.connect((self.blocks_wavfile_source_0, 0), (self.blocks_float_to_short_0, 0))
        self.connect((self.blocks_wavfile_source_0, 1), (self.blocks_float_to_short_1, 0))
        self.connect((self.digital_constellation_decoder_cb_0, 0), (self.blocks_repack_bits_bb_0, 0))
        self.connect((self.digital_constellation_encoder_bc_0, 0), (self.digital_constellation_decoder_cb_0, 0))
        self.connect((self.epy_block_0, 0), (self.blocks_deinterleave_0, 0))
        self.connect((self.epy_block_1, 0), (self.blocks_vector_to_stream_0, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "step_03")
        self.settings.setValue("geometry", self.saveGeometry())
        self.stop()
        self.wait()

        event.accept()

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.blocks_throttle2_1.set_sample_rate(self.samp_rate)

    def get_my_const(self):
        return self.my_const

    def set_my_const(self, my_const):
        self.my_const = my_const
        self.digital_constellation_decoder_cb_0.set_constellation(self.my_const)
        self.digital_constellation_encoder_bc_0.set_constellation(self.my_const)




def main(top_block_cls=step_03, options=None):

    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()

    tb.start()

    tb.show()

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        Qt.QApplication.quit()

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    timer = Qt.QTimer()
    timer.start(500)
    timer.timeout.connect(lambda: None)

    qapp.exec_()

if __name__ == '__main__':
    main()
