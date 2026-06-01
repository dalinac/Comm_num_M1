#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: OFDM_wav_TS_step_03
# GNU Radio version: 3.10.9.2

from PyQt5 import Qt
from gnuradio import qtgui
import os
import sys
sys.path.append(os.environ.get('GRC_HIER_PATH', os.path.expanduser('~/.grc_gnuradio')))

from QpiDQPSKdemo import QpiDQPSKdemo  # grc-generated hier_block
from QpiDQPSKmod import QpiDQPSKmod  # grc-generated hier_block
from gnuradio import audio
from gnuradio import blocks
from gnuradio import digital
from gnuradio import gr
from gnuradio.filter import firdes
from gnuradio.fft import window
import signal
from PyQt5 import Qt
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
import OFDM_wav_TS_step_03_epy_block_0 as epy_block_0  # embedded python block
import OFDM_wav_TS_step_03_epy_block_1 as epy_block_1  # embedded python block
import sip



class OFDM_wav_TS_step_03(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "OFDM_wav_TS_step_03", catch_exceptions=True)
        Qt.QWidget.__init__(self)
        self.setWindowTitle("OFDM_wav_TS_step_03")
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

        self.settings = Qt.QSettings("GNU Radio", "OFDM_wav_TS_step_03")

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
        4, 1, digital.constellation.NO_NORMALIZATION).base()
        self.my_const.set_npwr(1.0)
        self.audio_Fs = audio_Fs = 48000

        ##################################################
        # Blocks
        ##################################################

        self.qtgui_time_sink_x_0 = qtgui.time_sink_f(
            64, #size
            samp_rate, #samp_rate
            "", #name
            1, #number of inputs
            None # parent
        )
        self.qtgui_time_sink_x_0.set_update_time(0.010)
        self.qtgui_time_sink_x_0.set_y_axis(-35000, 35000)

        self.qtgui_time_sink_x_0.set_y_label('Amplitude', "")

        self.qtgui_time_sink_x_0.enable_tags(False)
        self.qtgui_time_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, qtgui.TRIG_SLOPE_POS, 0.0, 0, 0, "")
        self.qtgui_time_sink_x_0.enable_autoscale(True)
        self.qtgui_time_sink_x_0.enable_grid(False)
        self.qtgui_time_sink_x_0.enable_axis_labels(True)
        self.qtgui_time_sink_x_0.enable_control_panel(False)
        self.qtgui_time_sink_x_0.enable_stem_plot(False)


        labels = ['Signal 1', 'Signal 2', 'Signal 3', 'Signal 4', 'Signal 5',
            'Signal 6', 'Signal 7', 'Signal 8', 'Signal 9', 'Signal 10']
        widths = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        colors = ['blue', 'red', 'green', 'black', 'cyan',
            'magenta', 'yellow', 'dark red', 'dark green', 'dark blue']
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, 1.0]
        styles = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        markers = [-1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1]


        for i in range(1):
            if len(labels[i]) == 0:
                self.qtgui_time_sink_x_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_time_sink_x_0.set_line_label(i, labels[i])
            self.qtgui_time_sink_x_0.set_line_width(i, widths[i])
            self.qtgui_time_sink_x_0.set_line_color(i, colors[i])
            self.qtgui_time_sink_x_0.set_line_style(i, styles[i])
            self.qtgui_time_sink_x_0.set_line_marker(i, markers[i])
            self.qtgui_time_sink_x_0.set_line_alpha(i, alphas[i])

        self._qtgui_time_sink_x_0_win = sip.wrapinstance(self.qtgui_time_sink_x_0.qwidget(), Qt.QWidget)
        self.top_layout.addWidget(self._qtgui_time_sink_x_0_win)
        self.qtgui_const_sink_x_0 = qtgui.const_sink_c(
            1024, #size
            "", #name
            2, #number of inputs
            None # parent
        )
        self.qtgui_const_sink_x_0.set_update_time(0.10)
        self.qtgui_const_sink_x_0.set_y_axis((-2), 2)
        self.qtgui_const_sink_x_0.set_x_axis((-2), 2)
        self.qtgui_const_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, qtgui.TRIG_SLOPE_POS, 0.0, 0, "")
        self.qtgui_const_sink_x_0.enable_autoscale(True)
        self.qtgui_const_sink_x_0.enable_grid(True)
        self.qtgui_const_sink_x_0.enable_axis_labels(True)


        labels = ['', '', '', '', '',
            '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
            "magenta", "yellow", "dark red", "dark green", "dark blue"]
        styles = [0, 0, 0, 0, 0,
            0, 0, 0, 0, 0]
        markers = [0, 0, 0, 0, 0,
            0, 0, 0, 0, 0]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, 1.0]

        for i in range(2):
            if len(labels[i]) == 0:
                self.qtgui_const_sink_x_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_const_sink_x_0.set_line_label(i, labels[i])
            self.qtgui_const_sink_x_0.set_line_width(i, widths[i])
            self.qtgui_const_sink_x_0.set_line_color(i, colors[i])
            self.qtgui_const_sink_x_0.set_line_style(i, styles[i])
            self.qtgui_const_sink_x_0.set_line_marker(i, markers[i])
            self.qtgui_const_sink_x_0.set_line_alpha(i, alphas[i])

        self._qtgui_const_sink_x_0_win = sip.wrapinstance(self.qtgui_const_sink_x_0.qwidget(), Qt.QWidget)
        self.top_layout.addWidget(self._qtgui_const_sink_x_0_win)
        self.epy_block_1 = epy_block_1.blk()
        self.epy_block_0 = epy_block_0.blk()
        self.digital_constellation_encoder_bc_0 = digital.constellation_encoder_bc(my_const)
        self.digital_constellation_decoder_cb_0 = digital.constellation_decoder_cb(my_const)
        self.blocks_wavfile_source_0 = blocks.wavfile_source('shortVivaldi.wav', True)
        self.blocks_vector_to_stream_0 = blocks.vector_to_stream(gr.sizeof_char*1, 2)
        self.blocks_throttle2_0 = blocks.throttle( gr.sizeof_short*1, samp_rate, True, 0 if "auto" == "auto" else max( int(float(0.1) * samp_rate) if "auto" == "time" else int(0.1), 1) )
        self.blocks_stream_to_vector_0 = blocks.stream_to_vector(gr.sizeof_char*1, 2)
        self.blocks_short_to_float_1 = blocks.short_to_float(1, 1)
        self.blocks_short_to_float_0_0_0_1_0 = blocks.short_to_float(1, (65536/2))
        self.blocks_short_to_float_0_0_0_1 = blocks.short_to_float(1, (65536/2))
        self.blocks_repack_bits_bb_0_0 = blocks.repack_bits_bb(2, 8, "", False, gr.GR_LSB_FIRST)
        self.blocks_repack_bits_bb_0 = blocks.repack_bits_bb(8, 2, "", False, gr.GR_LSB_FIRST)
        self.blocks_interleave_0 = blocks.interleave(gr.sizeof_short*1, 1)
        self.blocks_float_to_short_0_0 = blocks.float_to_short(1, (65536/2))
        self.blocks_float_to_short_0 = blocks.float_to_short(1, (65536/2))
        self.blocks_deinterleave_0 = blocks.deinterleave(gr.sizeof_short*1, 1)
        self.audio_sink_0 = audio.sink(audio_Fs, '', True)
        self.QpiDQPSKmod_0 = QpiDQPSKmod()
        self.QpiDQPSKdemo_0 = QpiDQPSKdemo()


        ##################################################
        # Connections
        ##################################################
        self.connect((self.QpiDQPSKdemo_0, 0), (self.digital_constellation_decoder_cb_0, 0))
        self.connect((self.QpiDQPSKmod_0, 0), (self.QpiDQPSKdemo_0, 0))
        self.connect((self.QpiDQPSKmod_0, 0), (self.qtgui_const_sink_x_0, 1))
        self.connect((self.blocks_deinterleave_0, 0), (self.blocks_short_to_float_0_0_0_1, 0))
        self.connect((self.blocks_deinterleave_0, 1), (self.blocks_short_to_float_0_0_0_1_0, 0))
        self.connect((self.blocks_float_to_short_0, 0), (self.blocks_interleave_0, 0))
        self.connect((self.blocks_float_to_short_0_0, 0), (self.blocks_interleave_0, 1))
        self.connect((self.blocks_interleave_0, 0), (self.blocks_throttle2_0, 0))
        self.connect((self.blocks_repack_bits_bb_0, 0), (self.digital_constellation_encoder_bc_0, 0))
        self.connect((self.blocks_repack_bits_bb_0_0, 0), (self.blocks_stream_to_vector_0, 0))
        self.connect((self.blocks_short_to_float_0_0_0_1, 0), (self.audio_sink_0, 0))
        self.connect((self.blocks_short_to_float_0_0_0_1_0, 0), (self.audio_sink_0, 1))
        self.connect((self.blocks_short_to_float_1, 0), (self.qtgui_time_sink_x_0, 0))
        self.connect((self.blocks_stream_to_vector_0, 0), (self.epy_block_1, 0))
        self.connect((self.blocks_throttle2_0, 0), (self.epy_block_0, 0))
        self.connect((self.blocks_vector_to_stream_0, 0), (self.blocks_repack_bits_bb_0, 0))
        self.connect((self.blocks_wavfile_source_0, 0), (self.blocks_float_to_short_0, 0))
        self.connect((self.blocks_wavfile_source_0, 1), (self.blocks_float_to_short_0_0, 0))
        self.connect((self.digital_constellation_decoder_cb_0, 0), (self.blocks_repack_bits_bb_0_0, 0))
        self.connect((self.digital_constellation_encoder_bc_0, 0), (self.QpiDQPSKmod_0, 0))
        self.connect((self.digital_constellation_encoder_bc_0, 0), (self.qtgui_const_sink_x_0, 0))
        self.connect((self.epy_block_0, 0), (self.blocks_vector_to_stream_0, 0))
        self.connect((self.epy_block_1, 0), (self.blocks_deinterleave_0, 0))
        self.connect((self.epy_block_1, 0), (self.blocks_short_to_float_1, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "OFDM_wav_TS_step_03")
        self.settings.setValue("geometry", self.saveGeometry())
        self.stop()
        self.wait()

        event.accept()

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.blocks_throttle2_0.set_sample_rate(self.samp_rate)
        self.qtgui_time_sink_x_0.set_samp_rate(self.samp_rate)

    def get_my_const(self):
        return self.my_const

    def set_my_const(self, my_const):
        self.my_const = my_const
        self.digital_constellation_decoder_cb_0.set_constellation(self.my_const)
        self.digital_constellation_encoder_bc_0.set_constellation(self.my_const)

    def get_audio_Fs(self):
        return self.audio_Fs

    def set_audio_Fs(self, audio_Fs):
        self.audio_Fs = audio_Fs




def main(top_block_cls=OFDM_wav_TS_step_03, options=None):

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
