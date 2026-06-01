"""
Embedded Python Blocks:

Each time this file is saved, GRC will instantiate the first class it finds
to get ports and parameters of your block. The arguments to __init__  will
be the parameters. All of them are required to have default values!
"""

import numpy as np
from gnuradio import gr

class blk(gr.sync_block):
    def __init__(self):
        gr.sync_block.__init__(
            self,
            name='my_short_to_char_pack', 
            in_sig=[(np.uint8, 2)], # Entrée : vecteur de 2 octets (bytes)
            out_sig=[np.int16]      # Sortie : 1 mot de 16 bits (short)
        )

    def work(self, input_items, output_items):
        input_chars = input_items[0]
        output = output_items[0]
        
        # On convertit d'abord en int16 pour éviter les débordements (overflow) lors du décalage
        low_byte = input_chars[:, 0].astype(np.int16)  # LSB en premier d'après le TP
        high_byte = input_chars[:, 1].astype(np.int16) # MSB en second
        
        # Recomposition du mot de 16 bits
        output[:] = (high_byte << 8) | low_byte
        
        return len(output)
