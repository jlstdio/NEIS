fs = 1e6;
sw = dsp.SineWave;
sw.Amplitude = 0.5;
sw.Frequency = 100e3;
sw.ComplexOutput = true;
sw.SampleRate = fs;
sw.SamplesPerFrame = 5000; % to meet waveform size requirements
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