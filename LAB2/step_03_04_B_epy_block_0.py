import numpy as np
from gnuradio import gr

class blk(gr.sync_block):
    def __init__(self):
        gr.sync_block.__init__(
            self,
            name='pi4_dqpsk_mod',
            in_sig=[np.uint8],      # Entrée : mots de 2 bits (0 à 3)
            out_sig=[np.complex64]  # Sortie : points de la constellation
        )
        self.phase = 0.0 # Mémoire de la phase précédente

    def work(self, input_items, output_items):
        in_data = input_items[0]
        
        # Tableau des 4 sauts de phase possibles (pi/4, 3pi/4, -pi/4, -3pi/4)
        phases_jumps = np.array([np.pi/4, 3*np.pi/4, -np.pi/4, -3*np.pi/4])
        
        # On récupère les sauts correspondants aux données d'entrée
        current_jumps = phases_jumps[in_data]
        
        # On accumule les sauts de phase avec la fonction cumulative sum (cumsum)
        accumulated_phases = np.cumsum(current_jumps) + self.phase
        
        # On sauvegarde la toute dernière phase pour le prochain bloc de données
        self.phase = accumulated_phases[-1] % (2*np.pi)
        
        # On convertit ces angles en nombres complexes (coordonnées In-phase/Quadrature)
        output_items[0][:] = np.exp(1j * accumulated_phases)
        
        return len(output_items[0])
