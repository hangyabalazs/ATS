function AnalTable = ATS_analyze(varargin)
%ATS_analyze   Analysis of the SessionData from ATS training.
%   This function calculates data from the SessionData struct saved by
%   Bpod (Josh Sanders, Sanworks LLC).
%
%   AnalTable = ATS_analyze(A) where A is the animalID (1 for mouse-1, 2
%   for mouse-2) returns the following data organised into a matrix. The
%   columns contain the number of correct answers, incorrect answers,
%   premature responses, omissions; accuracy%, omission%, reaction times,
%   sessionIDs, stages, date-day, date-hour, date-minute. The rows contain
%   seperate sessions.
%
%   The outputs of this function can be customized.

%   Eszter Birtalan
%   Institute of Experimental Medicine, Budapest
%   hangya.balazs@koki.mta.hu
%   last modified 13.02.2020

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load data
load A3_A4_Homecage2_Feb01_2019_Session1.mat % load example struct

% Define the output table for the analysis
AnalTable = NaN(1,12);

% Define analysis parameter
if varargin{1} == 1
    numofsessions = length(SessionData.sessdata.a(:,1)); % get the number of sessions from the sessiondata for mouse-1
else
    numofsessions = length(SessionData.sessdata.c(:,1)); % get the number of sessions from the sessiondata for mouse-2
end

% Analysis
for sessionnum = 1:numofsessions
    
    if varargin{1} == 1
        startofsession = SessionData.sessdata.a(sessionnum,1); % this will be the first trial of the current session for mouse-1
        endofsession = SessionData.sessdata.a(sessionnum,2); % this will be the last trial of the current session for mouse-1
    else
        startofsession = SessionData.sessdata.c(sessionnum,1); % this will be the first trial of the current session for mouse-2
        endofsession = SessionData.sessdata.c(sessionnum,2); % this will be the last trial of the current session for mouse-2
    end
    
    % Clear the variables between sessions
    correct = 0;
    incorrect = 0;
    premature = 0;
    Numomission = 0; % number of omissions
    ReactionMatrix = zeros(1,SessionData.nTrials); % table to count the reaction time in case of correct answers
    
    for trial = startofsession:endofsession
        
        if ~isnan(SessionData.RawEvents.Trial{1, trial}.States.Reward(1,1)) % if the trial outcome was correct the Reward state is not empty
            correct = correct + 1;
            
            % Count the reaction time for correct answer as the time difference between the Light On and Reward delivery
            ReactionMatrix(trial) = SessionData.RawEvents.Trial{1, trial}.States.Reward(1) - SessionData.RawEvents.Trial{1, trial}.States.LightOn(1);
        end
        
        if ~isnan(SessionData.RawEvents.Trial{1, trial}.States.WaitforPokeOutError) % if the trial outcome was incorrect the WaitforPokeOutError state is not empty
            incorrect = incorrect+1;
        end
        
        
        if ~isnan(SessionData.RawEvents.Trial{1, trial}.States.PunishTime) % if the trial outcome was premature the PunishTime state is not empty
            premature = premature +1;
        end
        
        
        if ~isnan(SessionData.RawEvents.Trial{1, trial}.States.OM) % if the trial outcome was omission the OM state is not empty
        	Numomission = Numomission +1;
        end
        
        
    end
    
    Accuracy = correct / (correct+incorrect);
    Omission = Numomission / (correct+incorrect+Numomission);
    AvgReaction = sum(ReactionMatrix(startofsession:end)) / correct;
    
    % Add the variables of the session to the corresponding line in the AnalTable
    AnalTable(sessionnum,1) = correct;
    AnalTable(sessionnum,2) = incorrect;
    AnalTable(sessionnum,3) = premature;
    AnalTable(sessionnum,4) = Numomission;
    AnalTable(sessionnum,5) = Accuracy;
    AnalTable(sessionnum,6) = Omission;
    AnalTable(sessionnum,7) = AvgReaction;
    if varargin{1} == 1
        AnalTable(sessionnum,10) = SessionData.sessdata.b{sessionnum,1}.Day;  % adds the date of the current session for mouse-1
        AnalTable(sessionnum,11) = SessionData.sessdata.b{sessionnum,1}.Hour;
        AnalTable(sessionnum,12) = SessionData.sessdata.b{sessionnum,1}.Minute;
    else
        AnalTable(sessionnum,10) = SessionData.sessdata.d{sessionnum,1}.Day;  % adds the date of the current session for mouse-2
        AnalTable(sessionnum,11) = SessionData.sessdata.d{sessionnum,1}.Hour;
        AnalTable(sessionnum,12) = SessionData.sessdata.d{sessionnum,1}.Minute;
    end
    
end

% Assemble the rest of the output AnalTable
if varargin{1} == 1
    AnalTable(:,8) = SessionData.sessdata.a(:,3); % adds the stage the animal was in at the end of the session to the AnalTable for mouse-1
    AnalTable(:,9) = SessionData.sessdata.a(:,4); % adds the amount of water consumed since the start of the day to the AnalTable for mouse-1
else
    AnalTable(:,8) = SessionData.sessdata.c(:,3); % adds the stage the animal was in at the end of the session to the AnalTable for mouse-2
    AnalTable(:,9) = SessionData.sessdata.c(:,4); % adds the amount of water consumed since the start of the day to the AnalTable for mouse-2
end

end