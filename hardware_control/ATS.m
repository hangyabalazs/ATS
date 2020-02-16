%ATS   Autotrainer main script.
%   ATS is the script that starts all the other subfunctions for the ATS
%   system. It is to be started from the Bpod software (code by Josh
%   Sanders, Sanworks LLC). Here you can set the basic parameters of
%   training, like the starting stage, length of the experiment and COM
%   ports of the gates.
%
%   IMPORTANT: stopping the ATS protocol through Bpod will NOT stop the
%   timers as they are a built-in Matlab functions and run seperately from
%   all other functions. If you wish to end the protocol prematurely,
%   please remember to stop or delete all running timers. To read more
%   about timers, consult the webpage:
%   https://www.mathworks.com/help/matlab/ref/timer-class.html
%
%   See also StartoDay.

%   Eszter Birtalan
%   Institute of Experimental Medicine, Budapest
%   hangya.balazs@koki.mta.hu
%   last modified 15.02.2020

global SetStage1
global SetStage2
global Lgate;
global Rgate;

% Define basic parameters
SetStage1 = 1; % define starting stage for mouse-1
SetStage2 = 1; % define starting stage for mouse-2
Rgate = 11; % define the COM number of the right gate
Lgate = 10; % define the COM number of the left gate
Pipeline('newSession', 1);

% If the COMs given above have an 'open' status in matlab these lines can be used to clear it
s = num2str(Rgate); 
previousport = strcat('Serial-COM',s);
out = instrfind('Name',previousport);
delete(out);

s = num2str(Lgate);
previousport = strcat('Serial-COM',s);
out = instrfind('Name',previousport);
delete(out);

% Check that Rgate is truly the right gate,
% This is purely optional, it opens the right gate, then, after motion is
% detected, closes it, and opens the left the same way

% Rgate = 11;
% Lgate = 10;

% PipelineDoor('init',Rgate);
% PipelineDoor('cycle',1);
% PipelineDoor('end');
% s = num2str(Rgate);
% previousport = strcat('Serial-COM',s);
% out = instrfind('Name',previousport);
% delete(out);
% pause(2)
% PipelineDoor('init',Lgate);
% PipelineDoor('cycle',1);
% PipelineDoor('end');
% s = num2str(Lgate);
% previousport = strcat('Serial-COM',s);
% out = instrfind('Name',previousport);
% delete(out);

% Make a log of everything printed to te command window, this is optional
% cd('C:\...\MATLAB'); % add save directory
% date = now();
% date = datestr(date);
% segments = strsplit(date,' ');
% datename = segments{1};
% diary(datename);

% Start the main timer
t1 = timer;
t1.StartFcn = @(~,thisEvent)disp([thisEvent.Type ' executed ,day start '...
    datestr(thisEvent.Data.time,' dd-mmm-yyyy HH:MM:SS.FFF')]); % the function set here will run when the timer is first started
t1.TimerFcn = @(~,thisEvent)StartoDay(); % the function set here will run at the given time periods, based on parameters given below
t1.StopFcn = @(~,thisEvent) disp('The homecage program started its last 24 hour cycle'); % the function set here will run when the last iteration of the timer starts
t1.Period = 86400; % the t1.TimerFcn function will run in the given intervals (given in seconds)
t1.TasksToExecute = 7; % set how many times the t2.TimerFcn function will run ( here the length of the training in days)
t1.ExecutionMode = 'fixedRate';
startat(t1,2020, 02, 11, 11, 00, 00) % define the date of the start of the timer in the following format: yyyy,mm,dd,hh,mm,ss
