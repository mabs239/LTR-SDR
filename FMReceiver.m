CenterFrequency = 94.6e6;
EnableTunerAGC = 0;
FrequencyCorrection = 0;
frontEndSampleRate = 228e3;

Duration = 5;
isSourceRadio = 1
FrequencyDeviation = 75e3; % Hz
FilterTimeConstant = 75e-6; % Seconds
AudioSampleRate = 228000/5; % Hz, make sure rate is friendly with default BB 
%%
sigSrc = comm.SDRRTLReceiver('0',...
                  'CenterFrequency',CenterFrequency,...
                  'EnableTunerAGC',EnableTunerAGC,...
                  'SampleRate',frontEndSampleRate,...
                  'OutputDataType','single',...
                  'FrequencyCorrection',FrequencyCorrection ...
              );

%% Create FM broadcast receiver object and configure based on user input
fmBroadcastDemod = comm.FMBroadcastDemodulator(...
                                        'SampleRate', frontEndSampleRate, ...
                                        'FrequencyDeviation', FrequencyDeviation, ...
                                        'FilterTimeConstant', FilterTimeConstant, ...
                                        'AudioSampleRate', AudioSampleRate, ...
                                        'Stereo', false, ...
                                        'RBDS',true, ...
                                        'RBDSSamplesPerSymbol',12 ...
                                   );
fmInfo = info(fmBroadcastDemod);
N = 1600; % N = 3840; 
frontEndSamplesPerFrame = N*fmInfo.AudioDecimationFactor; 
FrontEndFrameTime = frontEndSamplesPerFrame / frontEndSampleRate;
sigSrc.SamplesPerFrame = frontEndSamplesPerFrame;
rbds=[];
player = audioDeviceWriter('SampleRate', AudioSampleRate);
radioTime = 0;
while radioTime < Duration
    [rcv,~,lost,late] = sigSrc();
    [audioSig, rbdsRcv] = fmBroadcastDemod(rcv);
    rbds = [rbds; rbdsRcv];
    player(audioSig);
    radioTime = radioTime + FrontEndFrameTime + double(lost)/frontEndSampleRate;
end

release(sigSrc)
release(fmBroadcastDemod)
release(player)
displayEndOfDemoMessage(mfilename)
