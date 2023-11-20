clear all;


%% Constantes du projet
Fe = 48000;         % Fréquence d'échantillonnage
debit = 300;        % Débit de la transmission
F0 = 1180;          % Fréquence codant les 0
F1 = 980;          % Fréquence codant les 1
N_bits = 10000;        % Nombre de bits à transmettre
nb_coeffs = 61;     % Nombre de coefficients du filtre

Te = 1/Fe;                          % Période d'échantillonnage
Ts = 1/debit;                       % Durée de codage d'un bit
Ns = fix (Ts/Te);                   % Nombres d'échantillons sur une durée Ts
bits = randi ([0, 1], 1, N_bits);   % Message binaire aléatoire codé sur N_bits bits

%% 3.1 Génération du signal NRZ
T = [0 : Te : (N_bits*Ns-1)*Te];    % Échelle temporelle
NRZ = repelem (bits, 1, Ns);        % Signal NRZ généré à partir de la suite de bits à transmettre


%% 3.2 Signal modulé en fréquence x(t)
% Calcul de x(t) selon l'équation (1)
phi0 = rand*2*pi;   % VA indépendantes uniformément ...
phi1 = rand*2*pi;   % ... réparties sur [0,2pi]
theta0 = rand*2*pi;
theta1 = rand*2*pi;

X = (1-NRZ) .* cos (2*pi*F0*T + phi0) + NRZ .* cos (2*pi*F1*T + phi1);


%% 4 Canal de transmission à bruit additif, blanc et Gaussien
SNR_dB = -15;                                % Rapport signal sur bruit
P_X = mean (abs(X).^2);                     % Puissance de x
P_b = P_X / (10^(SNR_dB/10));               % Puissance du bruit ajouté
bruit = sqrt (P_b) * randn (1, length(X));  % Bruit
X_bruite = X + bruit;                       % Bruitage de x

x_temp_0 = reshape(X_bruite.*cos(2*pi*F0*T+phi0),Ns,N_bits);
x_00 = sum(x_temp_0);

x_temp_1 = reshape(X_bruite.*cos(2*pi*F1*T+phi1),Ns,N_bits);
x_11 = sum(x_temp_1);

H = x_11 - x_00;
bits_estimes_1 = H > 0;
bits_erreurs = abs(bits_estimes_1 - bits);
taux_erreur = sum(bits_erreurs)/N_bits

