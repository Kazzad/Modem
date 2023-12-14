# Modem
Modem de fréquence suivant la norme V21 de l'UIT  
Projet de télécommunications réalisé en 1ère année de formation à l'ENSEEIHT  

Liste des fichiers : 
- `filtrage.m` :			        Fichier principal affichant les différents graphiques dans une seule fenêtre pour la modulation/démodulation par filtrage
- `v21.m` :				            Fichier illustrant la modulation/démodulation selon la réglementation V21 sans l'erreur de synchronisation de phase porteuse
- `v21phase.m` :			        Fichier illustrant la modulation/démodulation selon la réglementation V21 avec l'erreur de synchronisation de phase porteuse
- `demoduler.m` :			        Fonction servant à démoduler les images
- `reconstituerimage.m` :		  Fichier permettant de reconstituer les 6 images dans l'ordre
- `reconstitution_image.m` :	Fonction fournie dans le sujet

Paramètres des fichiers : 
- `Fe` : Fréquence d'échantillonnage
- `debit` : Débit de la transmission
- `F0` : Fréquence codant les 0
- `F1` : Fréquence codant les 1
- `N_bits` : Nombre de bits à transmettre
- `nb_coeffs` : Nombre de coefficients du filtre
- `Te` : Période d'échantillonnage
- `Ts` : Durée de codage d'un bit
- `Ns` : Nombres d'échantillons sur une durée Ts
- `bits` : Message binaire aléatoire codé sur N_bits bits
