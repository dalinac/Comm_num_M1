import numpy as np
from gnuradio import gr

class blk(gr.sync_block):
    def __init__(self):
        gr.sync_block.__init__(
            self,
            name='my_short_to_char_unpack',
            in_sig=[np.int16],       # Entrée : 1 mot de 16 bits (short)
            out_sig=[(np.uint8, 2)]  # Sortie : vecteur de 2 octets (bytes)
        )

    def work(self, input_items, output_items):
        in_data = input_items[0]
        out_data = output_items[0]
        
        # Masque bit-à-bit pour récupérer le LSB (Octet de poids faible) en premier
        out_data[:, 0] = (in_data & 0xFF).astype(np.uint8) 
        
        # Décalage de 8 bits vers la droite puis masque pour le MSB (Octet de poids fort)
        out_data[:, 1] = ((in_data >> 8) & 0xFF).astype(np.uint8)
        
        return len(out_data)
