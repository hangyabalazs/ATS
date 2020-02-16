function varargout = Pipeline(op, varargin)
%Pipeline handles events leading up to the beginning of a session, code
%modified from https://github.com/sanworks/Pipeline_Gate from Josh Sanders,
%Sanworks LLC.
%
%   Syntax: Pipeline('op', A), where 'op' is the case name and A is the COM
%   port of the gate. The case 'newSession' closes figures and notebooks
%   that might have been left open and establishes some variables that
%   accumulate data during the whole training session. The case
%   'cycleAnimals' initiates and opens the gates, delivers free water at
%   the start of sessions and starts a session if the mouse initiated it.
%   It is also responsible for ensuring that the mouse is not in the
%   training chamber when the other gate opens.
%
%   See also PipelineDoor and StartoDay.

%   Written by Josh Sanders, Sanworks LLC, modified by 
%   Eszter Birtalan
%   Institute of Experimental Medicine, Budapest
%   hangya.balazs@koki.mta.hu
%   last modified 15.02.2020

global BpodSystem
global PipelineSystem
global SessionNum1;
global SessionNum2;
global SetStage1;
global SetStage2;
global Rgate;
global Lgate;


switch op
    case 'newSession'
        
        % Close all protocol figures
        try
            Figs = fields(BpodSystem.ProtocolFigures);
            nFigs = length(Figs);
            for x = 1:nFigs
                try
                    close(eval(['BpodSystem.ProtocolFigures.' Figs{x}]));
                catch
                    
                end
            end
            try
                close(BpodNotebook)
            catch
            end
        catch
        end
        
        % Preallocate a struct that will store vital information about sessions for analysis
        BpodSystem.Data = struct;       
        BpodSystem.Data.sessdata.a=[]; % this will store the data regarding when the sessions of mouse-1 started and finished
        BpodSystem.Data.sessdata.b={}; % this will store the data regarding when the sessions of mouse-1 started and finished
        BpodSystem.Data.Water1 = 0; % total amount of water consumed for mouse-1
        BpodSystem.Data.sessdata.c=[]; % this will store the data regarding when the sessions of mouse-2 started and finished
        BpodSystem.Data.sessdata.d={}; % this will store the data regarding when the sessions of mouse-2 started and finished
        BpodSystem.Data.Water2 = 0; % total amount of water consumed for mouse-2
        
        if BpodSystem.BeingUsed == 0
            PipelineSystem.run = 0;
        end
        
    case 'cycleAnimals'
        SerialPort = varargin{1};
        % Close the connection with the previously used gate before trying to connect a new one
        try
            if isfield(PipelineSystem,'SerialPort')
                PipelineDoor('end');
                disp ('Previous port still in cache, you must delete it in order to connect a different gate');
            else
            end
            
        catch
        end
        
        % Initialize the gate
        PipelineDoor('init', SerialPort); 
        
        % Set parameters for Bpod (code by Josh Sanders, Sanworks LLC)
        S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
                
        if SerialPort == Rgate && SetStage1 > 3 % set the amount of free water recieved from each port at the start of sessions
            S.GUI.RewardAmount = 10; %ul
        elseif SerialPort == Lgate && SetStage2 > 3
            S.GUI.RewardAmount = 10; %ul
        else  S.GUI.RewardAmount = 20; %ul
        end
                
        BpodParameterGUI('init', S); % Initialize parameter GUI plugin
        R = GetValveTimes(S.GUI.RewardAmount, [1 2 3 4 5]); % Update reward amounts
        
        % Open the gate
        PipelineDoor('open', 1); 
        
        % Deliver free water to each port, and wait 10 minutes for session initiation (nose poke)
        sma = NewStateMatrix();
        
        sma = AddState(sma, 'Name', 'FreeWater1', ...
            'Timer', R(1),...
            'StateChangeConditions', {'Tup', 'FreeWater2'},...
            'OutputActions', {'ValveState', 2^0} );
        
        sma = AddState(sma, 'Name', 'FreeWater2', ...
            'Timer', R(2),...
            'StateChangeConditions', {'Tup', 'FreeWater3'},...
            'OutputActions', {'ValveState', 2^1});
        
        sma = AddState(sma, 'Name', 'FreeWater3', ...
            'Timer', R(3),...
            'StateChangeConditions', {'Tup', 'FreeWater4'},...
            'OutputActions', {'ValveState', 2^(3-1)});
        
        sma = AddState(sma, 'Name', 'FreeWater4', ...
            'Timer', R(4),...
            'StateChangeConditions', {'Tup', 'FreeWater5'},...
            'OutputActions', {'ValveState', 2^(4-1)});
        
        sma = AddState(sma, 'Name', 'FreeWater5', ...
            'Timer', R(5),...
            'StateChangeConditions', {'Tup', 'WaitForGateClose'},...
            'OutputActions', {'ValveState', 2^(5-1)});
        
        
        sma = AddState(sma, 'Name', 'WaitForGateClose', ...
            'Timer', 600,...
            'StateChangeConditions', {'Port1In', 'exit','Port2In', 'exit','Port3In', 'exit','Port4In', 'exit','Port5In', 'exit' 'Tup', 'exit' },...
            'OutputActions', {});
        
        
        SendStateMatrix(sma);
        RawEvents = RunStateMatrix;
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        
        % Check for nose poke, if the mouse didn't initiate a session, the door closes if the mouse is not inside the training chamber
        % If the mouse initiated a session then it starts for the corresponding mouse
        tn = BpodSystem.Data.nTrials;
               
        if isempty(getPortIns(BpodSystem.Data.RawEvents.Trial{1, tn})) 
            PipelineDoor('cycle',1);
            if SerialPort == Rgate
                SessionNum1 = SessionNum1 + 1;
            elseif SerialPort == Lgate
                SessionNum2 = SessionNum2 + 1;
            end
            disp('The mouse did not initiate a session');
            
        else PipelineDoor('close',1); 
            pause(30); % wait half a minute for the mouse to collect the free water
            if SerialPort == Rgate
                CSRTT5_1_func(); % start the session for mouse-1
            elseif SerialPort == Lgate
                CSRTT5_2_func(); % start the session for mouse-2
            end
            
            PipelineDoor('infcycle',1); % once the session is over, wait for the animal to get back to its homecage, then close the door
            disp('The mouse finished the session and got back to its cage');
        end
        
        
        % Failsafe-1 in case the mouse stayed in the training chamber, but
        % the gate closed anyway, the middle port lights up for 5 minutes,
        % if there was a nose-poke in any of the ports during this time,
        % the gate opens again
        pause(300);
        sma = NewStateMatrix();
        
        sma = AddState(sma, 'Name', 'WaitForPoke3', ...
            'Timer', 300,...
            'StateChangeConditions', {'Port1In', 'exit','Port2In', 'exit','Port3In', 'exit', 'Port4In', 'exit','Port5In', 'exit','Tup', 'exit' },...
            'OutputActions', {'LED', 3,'LED', 8});
        
        
        SendStateMatrix(sma);
        RawEvents = RunStateMatrix;
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        tn = BpodSystem.Data.nTrials;
        
        if isempty(getPortIns(BpodSystem.Data.RawEvents.Trial{1, tn}))
            disp('The mouse is in its cage');
        else PipelineDoor('infcycle',1); disp('The mouse got back to its cage');
        end
                     
        % Failsafe-2 in case the mouse stayed in the training chamber, but the gate closed anyway
        pause(300);
        sma = NewStateMatrix();
        
        
        sma = AddState(sma, 'Name', 'WaitForPoke4', ...
            'Timer', 300,...
            'StateChangeConditions', {'Port1In', 'exit','Port2In', 'exit','Port3In', 'exit', 'Port4In', 'exit','Port5In', 'exit','Tup', 'exit' },...
            'OutputActions', {'LED', 3,'LED', 8});
        
        
        SendStateMatrix(sma);
        RawEvents = RunStateMatrix;
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        tn = BpodSystem.Data.nTrials;
        
        if isempty(getPortIns(BpodSystem.Data.RawEvents.Trial{1, tn}))
            disp('The mouse is in its cage, second time');
        else PipelineDoor('infcycle',1); disp('The mouse got back to its cage second time');
            % Sending an email at this point is optional, as it
            % can be a sign of the motion sensor malfunctioning if the
            % mouse was able to do a nose-poke during failsafe-2
            % please consult the webpage
            % https://www.mathworks.com/help/matlab/ref/sendmail.html?s_tid=doc_ta
            % for further information on the sendmail function
%             try
%                 sendmail(recipients,subject,message)
%             catch
%                 disp('there was an error with sending an email');
%             end
            pause(300); % a 5 minute pause in order for the experimenter to
            % have time to investigate the cause of the animal still being
            % in the training chamber during failsafe-2
        end
        
        % Disconnect and clear the data of the current gate from cache in order for the other gate to connect
        PipelineDoor('end'); 
        s = num2str(varargin{1});
        previousport = strcat('Serial-COM',s);
        out = instrfind('Name',previousport);
        delete(out);       
        
end
end

function Result = WaitForDoorClose
global PipelineSystem
while PipelineSystem.SerialPort.BytesAvailable == 0
end
Result = fread(PipelineSystem.SerialPort, PipelineSystem.SerialPort.BytesAvailable);
end