function CSRTT5_1_func
%CSRTT5_1_func handles all the steps of the training session, post-trial
%analysis, automatic stage-changing and saves the sessiondata for mouse-1.
%
%   Set session parameters for mouse-1 before the main session loop,
%   set trial parameters (parameters for the stages, bpod states and output
%   actions) in the main session loop, so they may change with each trial.
%   The main session loop containes the state matrix, which determines the
%   actions of the Bpod behavior control unit.
%   Perform some basic analysis after the each trial to determine if an
%   advancement in stage is necessary.
%   Check if the session should end or not and save the session data.
%
%   See also Pipeline.

%   Eszter Birtalan and Diána Balázsfi
%   Institute of Experimental Medicine, Budapest
%   hangya.balazs@koki.mta.hu
%   last modified 15.02.2020

global BpodSystem
global SetStage1
global correct1
global incorrect1
global Numomission1
global premature1
global TrialNumber1
global Water1
global SessionNum1

SessionNum1 = SessionNum1 + 1;
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

% Add the amount of free water recieved, based on the settings in the Pipeline function
if SetStage1 >= 3 
    Water1 = Water1 + 50;
    BpodSystem.Data.Water1 = BpodSystem.Data.Water1 + 50;
else
    Water1 = Water1 + 100;
    BpodSystem.Data.Water1 = BpodSystem.Data.Water1 + 100;
end
%% Define trial parameters
MaxTrials = 200; % max number of trials in a session
rng('shuffle')   % Reset pseudorandom seed
ITITypes = nan(1,MaxTrials); % preallocate ITI types (chnages between 2s or 3-5s, see below)
TrialTypes = nan(1,MaxTrials);
TrialTypes = ceil(rand(1,MaxTrials)*5); % randomly interleaved trial types (where will the stimulus be presented)
counter = 0; % trial number for this session
startofsession = BpodSystem.Data.nTrials+1; % trialnumber when session started
EndCriteria = 1; % while 1 the session continues

% Clear variables before the session starts
if SetStage1 > 2
    correct1 = 0;
    incorrect1 = 0;
    Numomission1 = 0;
end
%% Main session loop
fprintf('Mouse-1 started on Stage %d.\n', SetStage1);
date1 = datetime('now'); % save the starting time, because the session end is time bound
disp(datestr(now(),'dd-mmm-yyyy HH:MM:SS.FFF'));

while EndCriteria == 1
    
    TrialNumber1 = TrialNumber1+1; % Overall trial number
    counter = counter + 1; % trial number for this session
    
    %Define stages
    if SetStage1 == 1;
        StimulusDuration = 30;
        InterTrialInterval = 2;
        LimitedHoldTime = 30;
        ITITypes(1,counter) = InterTrialInterval;
        S.GUI.RewardAmount = 6;
        BpodParameterGUI('init', S);
    elseif SetStage1 == 2;
        StimulusDuration = 20;
        InterTrialInterval = 2;
        LimitedHoldTime = 20;
        ITITypes(1,counter) = InterTrialInterval;
        S.GUI.RewardAmount = 5;
        BpodParameterGUI('init', S);
    elseif SetStage1 == 3;
        StimulusDuration = 10;
        InterTrialInterval = 5;
        LimitedHoldTime = 10;
        ITITypes(1,counter) = randi([3,InterTrialInterval],1);
        S.GUI.RewardAmount = 6;
        BpodParameterGUI('init', S);
    elseif SetStage1 == 4;
        StimulusDuration = 5;
        InterTrialInterval = 5;
        LimitedHoldTime = 5;
        ITITypes(1,counter) = randi([3,InterTrialInterval],1);
        S.GUI.RewardAmount = 4;
        BpodParameterGUI('init', S);
    elseif SetStage1 == 5;
        StimulusDuration = 2.5;
        InterTrialInterval = 5;
        LimitedHoldTime = 5;
        ITITypes(1,counter) = randi([3,InterTrialInterval],1);
        S.GUI.RewardAmount = 4;
        BpodParameterGUI('init', S);
    elseif SetStage1 == 6;
        StimulusDuration = 1.25;
        InterTrialInterval = 5;
        LimitedHoldTime = 5;
        ITITypes(1,counter) = randi([3,InterTrialInterval],1);
        S.GUI.RewardAmount = 4;
        BpodParameterGUI('init', S);
    elseif SetStage1 == 7
        StimulusDuration = 1;
        InterTrialInterval = 5;
        LimitedHoldTime = 5;
        ITITypes(1,counter) = randi([3,InterTrialInterval],1);
        S.GUI.RewardAmount = 4;
        BpodParameterGUI('init', S);
    elseif SetStage1 == 8;
        StimulusDuration = 0.9;
        InterTrialInterval = 5;
        LimitedHoldTime = 5;
        ITITypes(1,counter) = randi([3,InterTrialInterval],1);
        S.GUI.RewardAmount = 4;
        BpodParameterGUI('init', S);
    elseif SetStage1 == 9;
        StimulusDuration = 0.8;
        InterTrialInterval = 5;
        LimitedHoldTime = 5;
        ITITypes(1,counter) = randi([3,InterTrialInterval],1);
        S.GUI.RewardAmount = 4;
        BpodParameterGUI('init', S);
    elseif SetStage1 == 10;
        StimulusDuration = 0.7;
        InterTrialInterval = 5;
        LimitedHoldTime = 5;
        ITITypes(1,counter) = randi([3,InterTrialInterval],1);
        S.GUI.RewardAmount = 4;
        BpodParameterGUI('init', S);
    elseif SetStage1 == 11;
        StimulusDuration = 0.6;
        InterTrialInterval = 5;
        LimitedHoldTime = 5;
        ITITypes(1,counter) = randi([3,InterTrialInterval],1);
        S.GUI.RewardAmount = 4;
        BpodParameterGUI('init', S);
    else %Stage12
        StimulusDuration = 0.5;
        InterTrialInterval = 5;
        LimitedHoldTime = 5;
        ITITypes(1,counter) = randi([3,InterTrialInterval],1);
        S.GUI.RewardAmount = 4;
        BpodParameterGUI('init', S);
    end
    
    R = GetValveTimes(S.GUI.RewardAmount, [1 2 3 4 5]);   % Update reward amounts
    
    % Trial parameters (for sma)
    cTT = TrialTypes(counter); % Current trial type
    cITI = ITITypes(counter); % Current ITI type
    PortsIn = {'Port1In' 'Port2In' 'Port3In' 'Port4In' 'Port5In'};
    PortsOut = {'Port1Out' 'Port2Out' 'Port3Out' 'Port4Out' 'Port5Out'};
    
    % Defined actions (in sma)
    StimulusOutputActions = {'LED', cTT,'LED', 8};
    PokeIn = PortsIn{cTT}; % Poke in the correct port
    PokeOut = PortsOut{cTT};
    RewardOutputActions = {'ValveState', 2^(cTT-1),'LED', 8};
    ValveTime = R(cTT);
    
    % Determine current wrong ports
    WP = [1 2 3 4 5];
    WP(cTT) = [];
    WrongPorts = cell(1,8);
    WrongPortOuts = cell(1,8);
    for l = 1:4
        if isempty(WP(l))
            WP(l)=WP(l+1);
        end
        WrongPorts{1,l*2} = 'WaitforPokeOutError';
        WrongPorts{1,l*2-1} = strcat('Port',num2str(WP(l)),'In');
        WrongPortOuts{1,l*2} = 'TimeOut';
        WrongPortOuts{1,l*2-1} = strcat('Port',num2str(WP(l)),'Out');
    end
    
    sma = NewStateMatrix(); % Assemble state matrix for Bpod
    
    sma = AddState(sma, 'Name', 'ITI', ...  % intertrial interval
        'Timer', cITI,...
        'StateChangeConditions', {'Port1In', 'PunishTime', 'Port2In', 'PunishTime', 'Port3In', 'PunishTime', 'Port4In', 'PunishTime', 'Port5In', 'PunishTime' 'Tup', 'LightOn'}, ...
        'OutputActions', {'LED', 8});
    
    sma = AddState(sma, 'Name', 'LightOn', ...  % waiting for poke with light on
        'Timer', StimulusDuration,...
        'StateChangeConditions', {'Tup', 'LimitedHold', PokeIn, 'Reward', WrongPorts{1},WrongPorts{2},WrongPorts{3},WrongPorts{4},WrongPorts{5},WrongPorts{6},WrongPorts{7},WrongPorts{8}},...
        'OutputActions', StimulusOutputActions);
    
    sma = AddState(sma, 'Name', 'Reward', ...  % delivering reward
        'Timer', ValveTime,...
        'StateChangeConditions', {'Tup', 'WaitforPokeOut'},...
        'OutputActions', RewardOutputActions);
    
    sma = AddState(sma, 'Name', 'LimitedHold', ...  % waiting for poke with light off
        'Timer', LimitedHoldTime,...
        'StateChangeConditions', {'Tup', 'OM', PokeIn, 'Reward', WrongPorts{1},WrongPorts{2},WrongPorts{3},WrongPorts{4},WrongPorts{5},WrongPorts{6},WrongPorts{7},WrongPorts{8}}, ...
        'OutputActions', {'LED', 8});
    
    sma = AddState(sma, 'Name', 'WaitforPokeOut', ...  % waiting for poke out after reward (poke out or 5s)
        'Timer', 5,...
        'StateChangeConditions', {PokeOut, 'exit', 'Tup', 'exit'}, ... 
        'OutputActions', {'LED', 8});
    
    sma = AddState(sma, 'Name', 'WaitforPokeOutError', ...  % waiting for poke out after NO reward (poke out or 3s)
        'Timer', 3,...
        'StateChangeConditions', {WrongPortOuts{1},WrongPortOuts{2},WrongPortOuts{3},WrongPortOuts{4},WrongPortOuts{5},WrongPortOuts{6},WrongPortOuts{7},WrongPortOuts{8}, 'Tup', 'ITI'}, ... %%?? maradjon e?'Tup','ITI', 5s
        'OutputActions', {'LED', 8});
    
    sma = AddState(sma, 'Name', 'TimeOut', ...  % punish time after NO reward
        'Timer', 5,...
        'StateChangeConditions', {'Tup' 'exit'}, ... 
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'PunishTime', ...  % punish time for poke during ITI
        'Timer', 5,...
        'StateChangeConditions', {'Tup', 'exit'}, ...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'OM', ...  % punish time for no poke
        'Timer', 5,...
        'StateChangeConditions', {'Tup' 'exit'}, ...
        'OutputActions', {});
    
    
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); 
        BpodSystem.Data.TrialSettings(TrialNumber1) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
    %% Analysis
    DataNumber = BpodSystem.Data.nTrials; % current trial's number for analysis
    if isnan(BpodSystem.Data.RawEvents.Trial{1, DataNumber}.States.Reward(1,1))
    else
        correct1 = correct1 + 1;
        Water1 = Water1 + S.GUI.RewardAmount; % water consumption during the day
        BpodSystem.Data.Water1 = BpodSystem.Data.Water1 + S.GUI.RewardAmount; % overall water consumption
    end
    
    if isnan(BpodSystem.Data.RawEvents.Trial{1, DataNumber}.States.WaitforPokeOutError)
    else incorrect1 = incorrect1+1;
    end
    
    if isnan(BpodSystem.Data.RawEvents.Trial{1, DataNumber}.States.PunishTime)
    else premature1 = premature1 +1;
    end
    
    if isnan(BpodSystem.Data.RawEvents.Trial{1, DataNumber}.States.OM)
    else Numomission1 = Numomission1 +1;
    end
    
    Accuracy = correct1 / (correct1+incorrect1);
    Omission = Numomission1 / (correct1+incorrect1+Numomission1);
        
    fprintf('TN:%d C:%d I:%d O:%d P:%d W:%d Stage:%d  \n',TrialNumber1,correct1,incorrect1,Numomission1,premature1,Water1,SetStage1);
    %% Set Stage
    
    if (SetStage1 == 1 && correct1 == 30);
        SetStage1 = SetStage1+1; % if the conditions above are met the mouse can advance to the next stage
        correct1 = 0;
        incorrect1 = 0;
        Numomission1 = 0;
        TrialNumber1 = 0;
        fprintf('Mouse-1 is now on Stage %d.\n', SetStage1);
    end
    
    if (SetStage1 == 2 && correct1 == 50);
        SetStage1 = SetStage1+1;
        correct1 = 0;
        incorrect1 = 0;
        Numomission1 = 0;
        TrialNumber1 = 0;
        fprintf('Mouse-1 is now on Stage %d.\n', SetStage1);
    end
    if (SetStage1 == 3 && correct1 >= 50 && Accuracy > 0.8);
        SetStage1 = SetStage1+1;
        correct1 = 0;
        incorrect1 = 0;
        Numomission1 = 0;
        TrialNumber1 = 0;
        fprintf('Mouse-1 is now on Stage %d.\n', SetStage1);
    end
    
    if (SetStage1 >= 4 && SetStage1 <12 && correct1 >= 50 && Accuracy > 0.8 && Omission < 0.2);
        SetStage1 = SetStage1+1;
        correct1 = 0;
        incorrect1 = 0;
        Numomission1 = 0;
        TrialNumber1 = 0;
        fprintf('Mouse-1 is now on Stage %d.\n', SetStage1);
    end
    
    % Save trial parameters       
    BpodSystem.Data.RawEvents.Trial{1, DataNumber}.TrialType = TrialTypes(counter);
    BpodSystem.Data.RawEvents.Trial{1, DataNumber}.ITIType = ITITypes(counter);
        
    % Check if session needs to end
    date2 = datetime('now');
    Elapsed = etime(datevec(date2),datevec(date1)); % Difference between session start and current time in seconds
    if Elapsed >=900 || counter == MaxTrials % stops the session if 15 minutes elapsed or the animal has performed 200 trials 
        % Stop the session
        EndCriteria = 0; 
        % Save session parameters
        endofsession = BpodSystem.Data.nTrials; % Trialnumber when session stopped
        sessionresult = [startofsession endofsession SessionNum1 SetStage1 Water1];
        dates = {date1  date2}; % Date of session start and end
        BpodSystem.Data.sessdata.a = vertcat(BpodSystem.Data.sessdata.a,sessionresult); % Saves some of the trial data
        BpodSystem.Data.sessdata.b = [BpodSystem.Data.sessdata.b; dates]; % Saves some of the trial data
        BpodSystem.Data.SetStage1 = SetStage1; 
        
        fprintf('Mouse-1 finished on Stage %d.\n', SetStage1);
        disp(datestr(now(),'dd-mmm-yyyy HH:MM:SS.FFF'))
    end
    SaveBpodSessionData; % Saves trial data
    
end
end