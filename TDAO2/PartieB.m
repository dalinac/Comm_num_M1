clc; clear; close all;

function basebandSignal = genererBasebandBPSK(binarySequence, samplesPerSymbol)
    % Codage NRZ bipolaire (0-> -1, 1-> +1) avec suréchantillonnage
    % Construit le signal en bande de base avec maintien du symbole (mise en forme rectangulaire)
    numBits = length(binarySequence);
    basebandSignal = zeros(1, numBits * samplesPerSymbol);
    for i = 1:numBits
        idxStart = (i-1) * samplesPerSymbol + 1;
        idxEnd = i * samplesPerSymbol;
        if binarySequence(i) == 1
            basebandSignal(idxStart:idxEnd) = 1;
        else
            basebandSignal(idxStart:idxEnd) = -1;
        end
    end
end

function recoveredSequence = demodulerBPSK(receivedSignal, carrierSignal, filterB, filterA, numSymbols, samplesPerSymbol)
    % Démodulation cohérente:
    % 1. Multiplication par la porteuse locale
    % 2. Filtrage passe-bas pour éliminer la composante double-fréquence (2fc)
    % 3. Décision par échantillonnage au centre du symbole (point de stabilité maximale)
    demodulated = receivedSignal .* carrierSignal;
    filtered = filtfilt(filterB, filterA, demodulated); % Filtrage à phase nulle
    recoveredSequence = zeros(1, numSymbols);
    for k = 1:numSymbols
        samplePoint = round((k - 0.5) * samplesPerSymbol);
        if filtered(samplePoint) > 0
            recoveredSequence(k) = 1;
        else
            recoveredSequence(k) = 0;
        end
    end
end

function errorCount = compterErreursBinaires(originalBits, receivedBits)
    % Évaluation de la distance de Hamming entre l'émission et la réception
    errorCount = 0;
    for i = 1:length(originalBits)
        if originalBits(i) ~= receivedBits(i)
            errorCount = errorCount + 1;
        end
    end
end

% Filtre de réception et de mise en forme (Butterworth d'ordre 5)
% Fréquence de coupure normalisée de 0.1 adaptée à la largeur de bande du signal de base
[filterB, filterA] = butter(5, 0.1, 'low');

% Question 1 : Scintillation sur une porteuse
samplingFrequency = 1000;
signalDuration = 2;
carrierFrequency = 50;
carrierAmplitude = 0.5;
varianceScintillation = 0.3;

timeVector1 = 0:1/samplingFrequency:signalDuration-1/samplingFrequency;
numberOfSamples1 = length(timeVector1);

% Modélisation de la porteuse pure
carrierSignal1 = carrierAmplitude * sin(2 * pi * carrierFrequency * timeVector1);

% Bruit de scintillation (perturbation multiplicative basse fréquence)
% Le terme (1 + n_s(t)) modélise l'enveloppe fluctuante du canal (fading lent)
flickerNoise = 1 + sqrt(varianceScintillation) * randn(1, numberOfSamples1);
noisySignal1 = carrierSignal1 .* flickerNoise;

figure(1);
plot(timeVector1, carrierSignal1, 'r'); hold on;
plot(timeVector1, flickerNoise, 'b');
title('Porteuse et enveloppe de scintillation (Domaine temporel)');
xlabel('Temps (s)'); ylabel('Amplitude');
legend('Porteuse', 'Bruit de scintillation');
xlim([0 0.4]); grid on;

figure(2);
plot(timeVector1, noisySignal1, 'k');
title('Signal altéré par la scintillation (évanouissements d''amplitude)');
xlabel('Temps (s)'); ylabel('Amplitude');
legend('Signal scintillé');
xlim([0 0.4]); grid on;

% Analyse spectrale (FFT normalisée en amplitude)
% Mise en évidence du produit de convolution spectral (élargissement de la raie)
fftCarrier = fft(carrierSignal1) / numberOfSamples1;
fftFlicker = fft(flickerNoise) / numberOfSamples1;
fftNoisySignal = fft(noisySignal1) / numberOfSamples1;
frequencyAxis = linspace(0, samplingFrequency, numberOfSamples1);

figure(3);
semilogy(frequencyAxis, abs(fftCarrier), 'r'); hold on;
semilogy(frequencyAxis, abs(fftFlicker), 'b');
title('Densité spectrale : Porteuse pure et Bruit basse fréquence');
xlabel('Fréquence (Hz)'); ylabel('Magnitude (Log)');
legend('Porteuse', 'Bruit de scintillation');
xlim([0, 100]); grid on;

figure(4);
semilogy(frequencyAxis, abs(fftNoisySignal), 'k');
title('Spectre du signal scintillé (élargissement)');
xlabel('Fréquence (Hz)'); ylabel('Magnitude (Log)');
legend('Signal scintillé');
xlim([0, 100]); grid on;


% Question 2 : Modulation BPSK et canal AWGN
symbolDuration = 0.01;
numberOfSymbols = 30;
totalDuration2 = numberOfSymbols * symbolDuration;
carrierAmplitude2 = 1;
samplesPerSymbol = samplingFrequency * symbolDuration;
timeVector2 = 0:1/samplingFrequency:totalDuration2-1/samplingFrequency;

carrierSignal2 = carrierAmplitude2 * sin(2 * pi * carrierFrequency * timeVector2);

% Chaîne d'émission BPSK
binarySequence = randi([0 1], 1, numberOfSymbols);
basebandSignal = genererBasebandBPSK(binarySequence, samplesPerSymbol);
transmittedSignal = basebandSignal .* carrierSignal2;

% Canal de transmission : ajout exclusif d'un bruit blanc (AWGN)
SNR_dB = 3;
receivedSignal = awgn(transmittedSignal, SNR_dB, 'measured');

% Chaîne de réception
recoveredSequence = demodulerBPSK(receivedSignal, carrierSignal2, filterB, filterA, numberOfSymbols, samplesPerSymbol);

% Reformatage NRZ pour superposition visuelle des trames
binarySquare = genererBasebandBPSK(binarySequence, samplesPerSymbol);
recoveredSquare = genererBasebandBPSK(recoveredSequence, samplesPerSymbol);
binarySquare(binarySquare == -1) = 0;
recoveredSquare(recoveredSquare == -1) = 0;

figure(5);
plot(timeVector2, transmittedSignal + 3, 'b'); hold on;
plot(timeVector2, receivedSignal, 'r');
title('Transmission BPSK en canal AWGN (SNR = 3dB)');
xlabel('Temps (s)'); ylabel('Amplitude');
legend('Signal émis (offset +3)', 'Signal reçu bruité');
grid on;

figure(6);
plot(timeVector2, binarySquare + 1.5, 'b', 'LineWidth', 2); hold on;
plot(timeVector2, recoveredSquare, 'r', 'LineWidth', 2);
title('Comparaison de la trame source et de la décision');
xlabel('Temps (s)'); ylabel('Bit');
legend('Séquence originale (offset +1.5)', 'Séquence décodée');
ylim([-0.5 3]); grid on;


% Question 3 : Calcul du BER (Canal AWGN)
% Simulation de Monte-Carlo pour évaluer les performances statistiques
SNR_Range = -15:1;
numberOfTransmissions = 5; % Nombre de réalisations indépendantes du canal
numBitsBER = 1000; % Échantillon suffisant pour stabiliser la mesure du BER
symbolDurationBER = 0.1;
samplesPerSymbolBER = samplingFrequency * symbolDurationBER;
timeVectorBER = 0:1/samplingFrequency:(numBitsBER * symbolDurationBER) - 1/samplingFrequency;
carrierSignalBER = carrierAmplitude2 * sin(2 * pi * carrierFrequency * timeVectorBER);
BER_AWGN = zeros(numberOfTransmissions, length(SNR_Range));

for trans = 1:numberOfTransmissions
    bitsTransmitted = randi([0 1], 1, numBitsBER);
    signalBaseband = genererBasebandBPSK(bitsTransmitted, samplesPerSymbolBER);
    signalModulated = signalBaseband .* carrierSignalBER;
    
    for s = 1:length(SNR_Range)
        currentSNR = SNR_Range(s);
        signalReceived = awgn(signalModulated, currentSNR, 'measured');
        bitsRecovered = demodulerBPSK(signalReceived, carrierSignalBER, filterB, filterA, numBitsBER, samplesPerSymbolBER);
        errors = compterErreursBinaires(bitsTransmitted, bitsRecovered);
        % Ajout d'un epsilon (1e-6) pour éviter log(0) sur les graphiques si BER = 0
        BER_AWGN(trans, s) = (errors / numBitsBER) + 1e-6;
    end
end

figure(7);
semilogy(SNR_Range, BER_AWGN', 'o-', 'LineWidth', 1.2);
grid on;
title('Chute caractéristique du BER en canal AWGN (Modulation BPSK)');
xlabel('SNR (dB)'); ylabel('Bit Error Rate (BER)');
legend('Trame 1', 'Trame 2', 'Trame 3', 'Trame 4', 'Trame 5');


% Question 4 : Influence de la variance de scintillation
% Cette section évalue l'impact critique des évanouissements profonds (deep fades)

% 4.1. Visualisation temporelle des rafales d'erreurs potentielles
fixedVarianceVisu = 0.5;
numberOfSymbolsVisu = 15;
samplesPerSymbolVisu = samplesPerSymbol;
timeVectorVisu = 0:1/samplingFrequency:(numberOfSymbolsVisu * symbolDuration) - 1/samplingFrequency;
carrierSignalVisu = carrierAmplitude2 * sin(2 * pi * carrierFrequency * timeVectorVisu);

bitsVisualisation = randi([0 1], 1, numberOfSymbolsVisu);
signalBasebandVisu = genererBasebandBPSK(bitsVisualisation, samplesPerSymbolVisu);
signalEmittedVisu = signalBasebandVisu .* carrierSignalVisu;

% Le canal est ici purement multiplicatif (pas de bruit AWGN additif)
bruitScintillationVisu = 1 + sqrt(fixedVarianceVisu) * randn(1, length(timeVectorVisu));
signalReceivedVisu = signalEmittedVisu .* bruitScintillationVisu;

figure(8);
plot(timeVectorVisu, signalEmittedVisu + 3, 'b', 'LineWidth', 1.2); hold on;
plot(timeVectorVisu, signalReceivedVisu, 'r'); hold off;
title(['Altération par scintillation (Fading \sigma^2 = ' num2str(fixedVarianceVisu) ')']);
xlabel('Temps (s)'); ylabel('Amplitude');
legend('Signal émis propre (offset +3)', 'Signal reçu scintillé');
grid on;

% 4.2. Caractéristique du BER vs Variance du fading
varianceRange = logspace(-0.5, 0.3, 20);
BER_Scintillation = zeros(numberOfTransmissions, length(varianceRange));

for trans = 1:numberOfTransmissions
    bitsTransmitted = randi([0 1], 1, numBitsBER);
    signalBaseband = genererBasebandBPSK(bitsTransmitted, samplesPerSymbolBER);
    signalModulated = signalBaseband .* carrierSignalBER;
    
    for v = 1:length(varianceRange)
        currentVariance = varianceRange(v);
        flickerEffect = 1 + sqrt(currentVariance) * randn(1, length(timeVectorBER));
        signalReceived = signalModulated .* flickerEffect;
        bitsRecovered = demodulerBPSK(signalReceived, carrierSignalBER, filterB, filterA, numBitsBER, samplesPerSymbolBER);
        errors = compterErreursBinaires(bitsTransmitted, bitsRecovered);
        BER_Scintillation(trans, v) = (errors / numBitsBER) + 1e-9;
    end
end

figure(9);
loglog(varianceRange, BER_Scintillation', 'x-', 'LineWidth', 1.2);
grid on;
title('Dégradation du BER en présence de fading multiplicatif');
xlabel('Variance de la scintillation (\sigma^2)'); ylabel('Bit Error Rate (BER)');
legend('Trame 1', 'Trame 2', 'Trame 3', 'Trame 4', 'Trame 5', 'Location', 'northwest');