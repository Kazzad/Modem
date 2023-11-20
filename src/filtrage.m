clear all;
close all;

subplotX = 4;
subplotY = 5;

%% Constantes du projet
Fe = 48000;         % Fréquence d'échantillonnage
debit = 300;        % Débit de la transmission
F0 = 1180;          % Fréquence codant les 0
F1 = 980;          % Fréquence codant les 1
N_bits = 50;        % Nombre de bits à transmettre
nb_coeffs = 61;     % Nombre de coefficients du filtre

Te = 1/Fe;                          % Période d'échantillonnage
Ts = 1/debit;                       % Durée de codage d'un bit
Ns = fix (Ts/Te);                   % Nombres d'échantillons sur une durée Ts
bits = randi ([0, 1], 1, N_bits);   % Message binaire aléatoire codé sur N_bits bits
echelle_coeff = -fix ((nb_coeffs - 1) / 2) : 1 : fix ((nb_coeffs - 1) / 2); 

%% 3.1.2 Génération du signal NRZ
T = [0 : Te : (N_bits*Ns-1)*Te];    % Échelle temporelle
NRZ = repelem (bits, 1, Ns);        % Signal NRZ généré à partir de la suite de bits à transmettre

subplot (subplotX, subplotY, 1);
plot (T, NRZ);
title ("Signal NRZ");
xlabel ("Temps (s)");
ylabel ("Bit");
yticks ([0 1]);


%% 3.1.3 DSP estimée du signal NRZ
[DSP_NRZ_estimee, F] = pwelch (NRZ, [], [], [], Fe, 'twosided');  % Périodogramme de Welch pour calculer la DSP

subplot (subplotX, subplotY, 2);
semilogy (F, DSP_NRZ_estimee);
title ("DSP de NRZ");
xlabel ("Fréquence (Hz)");
ylabel ("DSP");
xlim ([0 Fe]);


%% 3.1.4 DSP estimée VS DSP théorique du signal NRZ
DSP_NRZ_theorique = 1/4 * Ts * (sinc (F*Ts)).^2 + 1/4 * dirac (F);  % S(f) = 1/4 * [Ts*sinc²(pi*f*Ts) + dirac(f)]

subplot (subplotX, subplotY, 3);
semilogy (F, DSP_NRZ_estimee);
hold on;
semilogy (F, DSP_NRZ_theorique);
hold off;
title ("DSP estimée et théorique de NRZ");
xlabel ("Fréquence (Hz)");
ylabel ("DSP");
legend ("Estimée", "Théorique");
xlim ([0 Fe]);


%% 3.2.2 Signal modulé en fréquence x(t)
% Calcul de x(t) selon l'équation (1)
phi0 = rand*2*pi;   % VA indépendantes uniformément ...
phi1 = rand*2*pi;   % ... réparties sur [0,2pi]
X = (1-NRZ) .* cos (2*pi*F0*T + phi0) + NRZ .* cos (2*pi*F1*T + phi1);

subplot (subplotX, subplotY, 4);
plot (T, X);
title ("Signal modulé en fréquence");
xlabel ("Temps (s)");
ylabel ("Amplitude");


%% 3.2.4 DSP du signal modulé en fréquence
[S_X_estime, F_X] = pwelch (X, [], [], [], Fe, 'twosided'); % Périodogramme de Welch pour calculer la DSP

subplot (subplotX, subplotY, 5);
plot (F_X, S_X_estime);
title ("DSP du signal modulé");
xlabel ("Fréquence (Hz)");
ylabel ("DSP");
xlim ([0 Fe]);


%% 4 Canal de transmission à bruit additif, blanc et Gaussien
SNR_dB = 20;                                % Rapport signal sur bruit
P_X = mean (abs(X).^2);                     % Puissance de x
P_b = P_X / (10^(SNR_dB/10));               % Puissance du bruit ajouté
bruit = sqrt (P_b) * randn (1, length(X));  % Bruit
X_bruite = X + bruit;                       % Bruitage de x

subplot (subplotX, subplotY, 6);
plot (T, X_bruite);
title ("Signal bruité");
xlabel ("Temps (s)");
ylabel ("Amplitude");


%% 4 Taux d'erreur binaire
seuil = 0.2;
S = find (bruit >= seuil);
I = find (bruit < seuil);
bruit (S) = 1;
bruit (I) = 0;
Taux_erreur = sum (bruit) / (N_bits * Ns); 

%% 5.4.1 Synthèse du filtre passe-bas
B = (F0 + F1) / 2;
Rep_i_passe_bas = 2*B*Te * sinc (2*B*Te*echelle_coeff);     % Réponse impulsionnelle (ici, un sinus cardinal)
Rep_f_passe_bas = fftshift (abs (fft (Rep_i_passe_bas)));   % Réponse en fréquence (ici, une porte)

%% 5.2 Synthèse du filtre passe-haut
dirac_en_0 = zeros (1, nb_coeffs);
dirac_en_0 (fix ((nb_coeffs + 1) / 2)) = 1;
Rep_i_passe_haut = dirac_en_0 - Rep_i_passe_bas;        % Réponse impulsionelle
Rep_f_passe_haut = 1 - Rep_f_passe_bas;                 % Réponse en fréquence

subplot (subplotX, subplotY, 10);
plot (linspace (-Fe/2, Fe/2, length(Rep_f_passe_haut)), Rep_f_passe_haut);
title ("Réponse en fréquence du filtre passe-haut");
xlabel ("Fréquence");
ylabel ("Amplitude");


subplot (subplotX, subplotY, 11);
plot (echelle_coeff, Rep_i_passe_haut);
title ("Réponse impulsionelle du filtre passe-haut");
xlabel ("Points");
ylabel ("Amplitude");



%% 5.3 Filtrage
X_Passe_Bas = filter (Rep_i_passe_bas, 1, X_bruite);    % Signal x(t) en sortie du passe-bas
X_Passe_Haut = filter (Rep_i_passe_haut, 1, X_bruite);  % Signal x(t) en sortie du passe-haut

%% 5.4.1 Réponses impulsionnelles et en fréquence des filtres
subplot (subplotX, subplotY, 7);
plot (echelle_coeff, Rep_i_passe_bas);
title ("Réponse impulsionelle du filtre passe-bas");
xlabel ("Points");
ylabel ("Amplitude");


subplot (subplotX, subplotY, 8);
plot (linspace (-Fe/2, Fe/2, length(Rep_f_passe_bas)), Rep_f_passe_bas);
title ("Réponse en fréquence du filtre passe-bas");
xlabel ("Fréquence");
ylabel ("Amplitude");


%% 5.4.2 DSP du signal modulé et réponse en fréquence des filtres
[S_X_B, F_B] = pwelch (X_bruite, [], [], [], Fe, 'onesided');   % Périodogramme de Welch pour calculer la DSP

subplot (subplotX, subplotY, 13);
plot (linspace (-Fe/2, Fe/2, nb_coeffs), Rep_f_passe_bas);
hold on
semilogy (F_B, S_X_B / max (S_X_B));
hold off
title ("DSP du signal et réponse en fréquence du passe-bas");
xlabel ("Fréquence (Hz)");
ylabel ("Amplitude");
legend ("Réponse fréquentielle", "DSP");


subplot (subplotX, subplotY, 14);
plot (linspace (-Fe/2, Fe/2, nb_coeffs), Rep_f_passe_haut);
hold on
semilogy (F_B, S_X_B / max (S_X_B));
hold off
title ("DSP du signal et réponse en fréquence du passe-haut");
xlabel ("Fréquence (Hz)");
ylabel ("Amplitude");
legend ("Réponse fréquentielle", "DSP");


%% 5.4.3 Signal et DSP en sortie des filtres
[S_X_PB, F_PB] = pwelch (X_Passe_Bas, [], [], [], Fe, 'onesided');  % Périodogrammes de Welch pour calculer les DSP
[S_X_PH, F_PH] = pwelch (X_Passe_Haut, [], [], [], Fe, 'onesided');

subplot (subplotX, subplotY, 9);
plot (T, X_Passe_Bas);
title ("Signal filtré par le passe-bas");
xlabel ("Temps (s)");
ylabel ("Amplitude");


subplot (subplotX, subplotY, 15);
%plot (linspace (-Fe/2, Fe/2, nb_coeffs), Rep_f_passe_bas);
plot (F_PB, S_X_PB);
title ("DSP du signal filtré par le basse-bas");
xlabel ("Fréquence (Hz)");
ylabel ("Amplitude");


subplot (subplotX, subplotY, 12);
plot (T, X_Passe_Haut);
title ("Signal filtré par le passe-haut");
xlabel ("Temps (s)");
ylabel ("Amplitude");


subplot (subplotX, subplotY, 16);
%plot (linspace (-Fe/2, Fe/2, nb_coeffs), Rep_f_passe_haut);*
plot (F_PH, S_X_PH);
title ("DSP du signal filtré par le basse-haut");
xlabel ("Fréquence (Hz)");
ylabel ("Amplitude");


%% 5.6 Gestion du retard
X_bruite = [X_bruite zeros(1, (nb_coeffs - 1)/2)];
X_Passe_Bas = filter (Rep_i_passe_bas, 1, X_bruite);
X_Passe_Bas = X_Passe_Bas (1, (nb_coeffs-1)/2+1 : end);

%% 5.5.1 Reconstruction du message binaire
% Passe-bas
X_PB_2 = X_Passe_Bas .^ 2;                          % x_bas(t) .^ 2
X_PB_2 = reshape (X_PB_2, Ns, N_bits);              % On réarrange X_PB_2 sur N_bits colonnes correspondant à des tranches de durée Ts et de Ns échantillons
energies_PB = sum (X_PB_2, 1);                      % Pour chaque tranche on calcule somme (x_n²)

K = (max (energies_PB) + min (energies_PB)) / 2;    % On estime le seuil K (jai fais un truc au pif ptdr)
indices_bits_1_PB = find (energies_PB > K);         % Les indices des sommes dépassant le seuil K

binaire_reconstruit_PB = zeros (1, N_bits);
binaire_reconstruit_PB (indices_bits_1_PB) = 1;     % On reconstruit le message binaire
% Passe-haut
X_PH_2 = X_Passe_Bas .^ 2;                          % x_haut(t) .^ 2
X_PH_2 = reshape (X_PH_2, Ns, N_bits);              % On réarrange X_PH_2 sur N_bits colonnes correspondant à des tranches de durée Ts et de Ns échantillons
energies_PH = sum (X_PH_2, 1);                      % Pour chaque tranche on calcule somme (x_n²)

K = (max (energies_PH) + min (energies_PH)) / 2;    % On estime le seuil K (jai fais un truc au pif ptdr)
indices_bits_1_PH = find (energies_PH > K);         % Les indices des sommes dépassant le seuil K
    
binaire_reconstruit_PH = zeros (1, N_bits);
binaire_reconstruit_PH (indices_bits_1_PH) = 1;     % On reconstruit le message binaire

%% 5.5.2 Reconstruction du message binaire pour le passe-haut
% Passe-bas
indices_bits_corrects_PB = find (binaire_reconstruit_PB == bits);   % Le nombre de sommes au dessus du seuil
taux_erreur_PB = 1 - length (indices_bits_corrects_PB) / N_bits     % Le taux d'erreur binaire pour le passe-bas
% Passe-haut
indices_bits_corrects_PH = find (binaire_reconstruit_PH == bits);   % Le nombre de sommes au dessus du seuil
taux_erreur_PH = 1 - length (indices_bits_corrects_PH) / N_bits     % Le taux d'erreur binaire pour le passe-haut








