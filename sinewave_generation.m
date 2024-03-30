sw = dsp.SineWave;
sw.Amplitude = 1;
sw.Frequency = FreqStart + 0.1e9;
sw.ComplexOutput = true;
sw.SampleRate = Fs;
sw.SamplesPerFrame = 1000; % to meet waveform size requirements
tx_waveform = sw();

radio = sdrtx('Pluto');
radio.CenterFrequency = 2.415e9;
radio.BasebandSampleRate = fs;
radio.Gain = 0;

runtime = tic;
while toc(runtime) < 10
    transmitRepeat(radio,tx_waveform);
end

release(radio);