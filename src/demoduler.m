function sortie = demoduler(signal)
    Fe = 48000;         % Fréquence d'échantillonnage
    debit = 300;        % Débit de la transmission
    F0 = 1180;          % Fréquence codant les 0
    Te = 1/Fe;                          % Période d'échantillonnage
    Ts = 1/debit;                       % Durée de codage d'un bit
    F1 = 980;           % Fréquence codant les 1
    
    
    Ns = fix (Ts/Te);                   % Nombres d'échantillons sur une durée Ts

    N_bits = length(signal)/Ns;        % Nombre de bits à transmettre
    

    T = [0 : Te : (N_bits*Ns-1)*Te];    % Échelle temporelle
   
    theta0 = rand*2*pi;
    theta1 = rand*2*pi;
    
    
    x_cos_0 = sum(reshape(signal.*cos(2*pi*F0*T+theta0),Ns,N_bits)).^2;
    
    x_sin_0 = sum(reshape(signal.*sin(2*pi*F0*T+theta0),Ns,N_bits)).^2;
    
    x_cos_1 = sum(reshape(signal.*cos(2*pi*F1*T+theta1),Ns,N_bits)).^2;
    
    x_sin_1 = sum(reshape(signal.*sin(2*pi*F1*T+theta1),Ns,N_bits)).^2;
    
    H = x_cos_1 + x_sin_1 - x_cos_0 - x_sin_0;
    bits_estimes_1 = H > 0;

    sortie = bits_estimes_1;
end
