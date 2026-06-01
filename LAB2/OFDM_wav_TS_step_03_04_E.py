#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: OFDM_wav_TS_step_03_04_E

# GNU Radio version: 3.10.9.2

from PyQt5 import Qt
from gnuradio import qtgui
from PyQt5 import QtCore
from gnuradio import analog
from gnuradio import blocks
from gnuradio import channels
from gnuradio.filter import firdes
from gnuradio import digital
from gnuradio import gr
from gnuradio.fft import window
import sys
import signal
from PyQt5 import Qt
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
import math
import sip



class OFDM_wav_TS_step_03_04_E(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "OFDM_wav_TS_step_03_04_E", catch_exceptions=True)
        Qt.QWidget.__init__(self)
        self.setWindowTitle("OFDM_wav_TS_step_03_04_E")
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

        self.settings = Qt.QSettings("GNU Radio", "OFDM_wav_TS_step_03_04_E")

        try:
            geometry = self.settings.value("geometry")
            if geometry:
                self.restoreGeometry(geometry)
        except BaseException as exc:
            print(f"Qt GUI: Could not restore geometry: {str(exc)}", file=sys.stderr)

        ##################################################
        # Variables
        ##################################################
        self.subCarr_K = subCarr_K = 4
        self.samp_rate = samp_rate = 2048000
        self.noise_volt = noise_volt = 0.1
        self.my_const_2 = my_const_2 = digital.constellation_calcdist([-1-1j, -1+1j, 1+1j, 1-1j], [0, 1, 3, 2],
        4, 1, digital.constellation.NO_NORMALIZATION).base()
        self.my_const_2.set_npwr(1.0)
        self.my_const_1 = my_const_1 = digital.constellation_calcdist([-1-1j, -1+1j, 1+1j, 1-1j], [0, 1, 3, 2],
        4, 1, digital.constellation.NO_NORMALIZATION).base()
        self.my_const_1.set_npwr(1.0)

        ##################################################
        # Blocks
        ##################################################

        self.qtgui_time_sink_x_0 = qtgui.time_sink_f(
            32, #size
            samp_rate, #samp_rate
            "", #name
            2, #number of inputs
            None # parent
        )
        self.qtgui_time_sink_x_0.set_update_time(0.10)
        self.qtgui_time_sink_x_0.set_y_axis(-4, 4)

        self.qtgui_time_sink_x_0.set_y_label('Angle [pi/4]', "")

        self.qtgui_time_sink_x_0.enable_tags(True)
        self.qtgui_time_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_TAG, qtgui.TRIG_SLOPE_POS, 0.0, 0, 0, "packet_len")
        self.qtgui_time_sink_x_0.enable_autoscale(False)
        self.qtgui_time_sink_x_0.enable_grid(True)
        self.qtgui_time_sink_x_0.enable_axis_labels(True)
        self.qtgui_time_sink_x_0.enable_control_panel(True)
        self.qtgui_time_sink_x_0.enable_stem_plot(False)


        labels = ['pi/4-DQPSK bruite', 'QPSK ref', 'Signal 3', 'Signal 4', 'Signal 5',
            'Signal 6', 'Signal 7', 'Signal 8', 'Signal 9', 'Signal 10']
        widths = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        colors = ['blue', 'red', 'green', 'black', 'cyan',
            'magenta', 'yellow', 'dark red', 'dark green', 'dark blue']
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, 1.0]
        styles = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        markers = [1, 1, -1, -1, -1,
            -1, -1, -1, -1, -1]


        for i in range(2):
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
            3, #number of inputs
            None # parent
        )
        self.qtgui_const_sink_x_0.set_update_time(0.10)
        self.qtgui_const_sink_x_0.set_y_axis((-2), 2)
        self.qtgui_const_sink_x_0.set_x_axis((-2), 2)
        self.qtgui_const_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, qtgui.TRIG_SLOPE_POS, 0.0, 0, "")
        self.qtgui_const_sink_x_0.enable_autoscale(False)
        self.qtgui_const_sink_x_0.enable_grid(False)
        self.qtgui_const_sink_x_0.enable_axis_labels(True)


        labels = ['pi/4-DQPSK bruite', 'QPSK ref', 'pi/4-QPSK ref', '', '',
            '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
            "magenta", "yellow", "dark red", "dark green", "dark blue"]
        styles = [1, 1, 1, 0, 0,
            0, 0, 0, 0, 0]
        markers = [0, 0, 0, 0, 0,
            0, 0, 0, 0, 0]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, 1.0]

        for i in range(3):
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
        self._noise_volt_range = qtgui.Range(0, 2, 0.001, 0.1, 200)
        self._noise_volt_win = qtgui.RangeWidget(self._noise_volt_range, self.set_noise_volt, "noise_volt", "counter_slider", float, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._noise_volt_win)
        self.digital_constellation_encoder_bc_ref = digital.constellation_encoder_bc(my_const_2)
        self.digital_constellation_encoder_bc_0 = digital.constellation_encoder_bc(my_const_1)
        self.channels_channel_model_0 = channels.channel_model(
            noise_voltage=0.03,
            frequency_offset=0.0,
            epsilon=1.0,
            taps=[math.cos(math.pi/10) + 1j*math.sin(math.pi/10)],
            noise_seed=0,
            block_tags=False)
        self.blocks_vector_source_x_0_0 = blocks.vector_source_b([0, 1, 2, 3], True, 1, [])
        self.blocks_vector_source_x_0 = blocks.vector_source_b([0, 1, 2, 3], True, 1, [])
        self.blocks_throttle2_0 = blocks.throttle( gr.sizeof_char*1, samp_rate, True, 0 if "auto" == "auto" else max( int(float(0.1) * samp_rate) if "auto" == "time" else int(0.1), 1) )
        self.blocks_stream_to_tagged_stream_0 = blocks.stream_to_tagged_stream(gr.sizeof_gr_complex, 1, 4, 'packet_len')
        self.blocks_stream_mux_0 = blocks.stream_mux(gr.sizeof_gr_complex*1, (1, 4))
        self.blocks_stream_demux_0 = blocks.stream_demux(gr.sizeof_gr_complex*1, (1, 4))
        self.blocks_null_sink_0 = blocks.null_sink(gr.sizeof_gr_complex*1)
        self.blocks_multiply_xx_1 = blocks.multiply_vcc(1)
        self.blocks_multiply_xx_0 = blocks.multiply_vcc(1)
        self.blocks_multiply_const_vxx_3 = blocks.multiply_const_cc(0.707106781+0.707106781j)
        self.blocks_multiply_const_vxx_2 = blocks.multiply_const_ff(1.27324)
        self.blocks_multiply_const_vxx_1 = blocks.multiply_const_ff(1.27324)
        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_cc(0.707106781+0.707106781j)
        self.blocks_delay_1 = blocks.delay(gr.sizeof_gr_complex*1, 3)
        self.blocks_delay_0 = blocks.delay(gr.sizeof_gr_complex*1, 1)
        self.blocks_complex_to_arg_1 = blocks.complex_to_arg(1)
        self.blocks_complex_to_arg_0 = blocks.complex_to_arg(1)
        self.analog_const_source_x_0 = analog.sig_source_c(0, analog.GR_CONST_WAVE, 0, 0, 0.707106781+0.707106781j)


        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_const_source_x_0, 0), (self.blocks_stream_mux_0, 0))
        self.connect((self.blocks_complex_to_arg_0, 0), (self.blocks_multiply_const_vxx_1, 0))
        self.connect((self.blocks_complex_to_arg_1, 0), (self.blocks_multiply_const_vxx_2, 0))
        self.connect((self.blocks_delay_0, 0), (self.blocks_multiply_xx_0, 1))
        self.connect((self.blocks_delay_1, 0), (self.blocks_multiply_xx_1, 1))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.blocks_stream_mux_0, 1))
        self.connect((self.blocks_multiply_const_vxx_1, 0), (self.qtgui_time_sink_x_0, 0))
        self.connect((self.blocks_multiply_const_vxx_2, 0), (self.qtgui_time_sink_x_0, 1))
        self.connect((self.blocks_multiply_const_vxx_3, 0), (self.qtgui_const_sink_x_0, 2))
        self.connect((self.blocks_multiply_xx_0, 0), (self.channels_channel_model_0, 0))
        self.connect((self.blocks_multiply_xx_1, 0), (self.blocks_stream_demux_0, 0))
        self.connect((self.blocks_stream_demux_0, 1), (self.blocks_complex_to_arg_0, 0))
        self.connect((self.blocks_stream_demux_0, 0), (self.blocks_null_sink_0, 0))
        self.connect((self.blocks_stream_mux_0, 0), (self.blocks_delay_0, 0))
        self.connect((self.blocks_stream_mux_0, 0), (self.blocks_multiply_xx_0, 0))
        self.connect((self.blocks_stream_to_tagged_stream_0, 0), (self.blocks_delay_1, 0))
        self.connect((self.blocks_stream_to_tagged_stream_0, 0), (self.blocks_multiply_const_vxx_0, 0))
        self.connect((self.blocks_throttle2_0, 0), (self.digital_constellation_encoder_bc_0, 0))
        self.connect((self.blocks_vector_source_x_0, 0), (self.blocks_throttle2_0, 0))
        self.connect((self.blocks_vector_source_x_0_0, 0), (self.digital_constellation_encoder_bc_ref, 0))
        self.connect((self.channels_channel_model_0, 0), (self.blocks_multiply_xx_1, 0))
        self.connect((self.channels_channel_model_0, 0), (self.qtgui_const_sink_x_0, 0))
        self.connect((self.digital_constellation_encoder_bc_0, 0), (self.blocks_stream_to_tagged_stream_0, 0))
        self.connect((self.digital_constellation_encoder_bc_ref, 0), (self.blocks_complex_to_arg_1, 0))
        self.connect((self.digital_constellation_encoder_bc_ref, 0), (self.blocks_multiply_const_vxx_3, 0))
        self.connect((self.digital_constellation_encoder_bc_ref, 0), (self.qtgui_const_sink_x_0, 1))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "OFDM_wav_TS_step_03_04_E")
        self.settings.setValue("geometry", self.saveGeometry())
        self.stop()
        self.wait()

        event.accept()

    def get_subCarr_K(self):
        return self.subCarr_K

    def set_subCarr_K(self, subCarr_K):
        self.subCarr_K = subCarr_K

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.blocks_throttle2_0.set_sample_rate(self.samp_rate)
        self.qtgui_time_sink_x_0.set_samp_rate(self.samp_rate)

    def get_noise_volt(self):
        return self.noise_volt

    def set_noise_volt(self, noise_volt):
        self.noise_volt = noise_volt

    def get_my_const_2(self):
        return self.my_const_2

    def set_my_const_2(self, my_const_2):
        self.my_const_2 = my_const_2
        self.digital_constellation_encoder_bc_ref.set_constellation(self.my_const_2)

    def get_my_const_1(self):
        return self.my_const_1

    def set_my_const_1(self, my_const_1):
        self.my_const_1 = my_const_1
        self.digital_constellation_encoder_bc_0.set_constellation(self.my_const_1)




def main(top_block_cls=OFDM_wav_TS_step_03_04_E, options=None):

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
