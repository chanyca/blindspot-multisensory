%% cleanup
try
PsychPortAudio('Stop', env.audio_handle, 1);
end

try
    PsychPortAudio('Stop', pahandle1, 1);
    Snd('Close', 1);
end

if ~dummymode && ~makeMovie
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.05);

    %stop writing data to file
    Eyelink('StopRecording')
    Eyelink('CloseFile'); %finalize edf file on host computer.

    %get edf file from eyelink computer, store locally as "localTestFilename"
    date = datestr(datetime('now'), 'dd-mm-yyyy HH_MM_SS');
    status=Eyelink('ReceiveFile', EyelinkFilename, fullfile(d.edfDir, [EyelinkFilename, '_', date, '.edf']));
    %display outcome/error.  Positive number is successfully written file size.
    %0 means cancelled.  Negative is error code.
    disp(status)
    Eyelink('Shutdown')
end

%% save data
if ~strcmp(Answer.sid, 'debug')
    save([fileName, '.mat'], 'Data');
end
% disp(['Save Complete, fileName is ', [fileName, '.mat']])

%% end everything
clear a % clear arduino object
if makeMovie
    Screen('FinalizeMovie', moviePtr);
end
close all;
sca;