"""
Embedded Python Blocks:

Each time this file is saved, GRC will instantiate the first class it finds
to get ports and parameters of your block. The arguments to __init__  will
be the parameters. All of them are required to have default values!
"""

from gnuradio import gr
import numpy as np
import cmath
import math


class blk(gr.sync_block):  # other base classes are basic_block, decim_block, interp_block
    """Embedded Python Block example - a simple multiply const"""

    def __init__(self,vsize=5):  # only default arguments here
        """arguments to this function show up as parameters in GRC"""
        gr.sync_block.__init__(
            self,
            name='DQPSK_mod',   # will show up in GRC
            in_sig=[(np.complex64,vsize)],
            out_sig=[(np.complex64,vsize)]
        )
        self.vsize = vsize

    def work(self, input_items, output_items):
        # Récupération des vecteurs en entrée et en sortie
        in_vector = input_items[0]
        out_vector = output_items[0]
        
        # Application du filtre IIR sur chaque ligne du vecteur
        for i in range(in_vector.shape[0]):
#            out_vector[i][0] = cmath.exp(1j * math.pi / 4)
            out_vector[i][0] = in_vector[i][0]
            for j in range(self.vsize-1):                
                out_vector[i][j+1] = in_vector[i][j+1] * in_vector[i][j]
            #out_vector[i] = np.pi/4.0-out_vector[i][::-1]
            #out_vector[i]= in_vector[i]
        
        # Retourne le nombre d'éléments traités
        return len(out_vector)
