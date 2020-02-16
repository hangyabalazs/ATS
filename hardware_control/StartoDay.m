function StartoDay()
%StartoDay   Starts the Pipeline function every two hours for each mouse.
%   This funcion starts once at the beginning of the day and clears some
%   variables; here you can set the mouse with which training will begin,
%   and also how many times a day they will have a chance to initiate a
%   session.
%
%   IMPORTANT: stopping the ATS protocol through Bpod will NOT stop the
%   timers as they are a built-in Matlab function and run seperately from
%   all other functions; if you wish to end the protocol prematurely,
%   please remember to stop or delete all running timers. To read more
%   about timers. consult the webpage:
%   https://www.mathworks.com/help/matlab/ref/timer-class.html
%
%   See also ATS.

%   Eszter Birtalan
%   Institute of Experimental Medicine, Budapest
%   hangya.balazs@koki.mta.hu
%   last modified 15.02.2020

global correct1
global incorrect1
global Numomission1
global premature1
global TrialNumber1
global Water1
global SessionNum1
global correct2
global incorrect2
global Numomission2
global premature2
global TrialNumber2
global Water2
global SessionNum2
global Rgate;
global Lgate;

% Clear all daily variables
Water1 = 0; %counts the amount of water consumed in a day for mouse-1
correct1 = 0; %counts the number of correct responses performed in a day for mouse-1
incorrect1 = 0; %counts the number of incorrect responses performed in a day for mouse-1
Numomission1 = 0; %counts the number of omissions performed in a day for mouse-1
premature1 = 0; %counts the number of premature responses performed in a day for mouse-1
TrialNumber1 = 0; %counts the number of trials performed in a day for mouse-1
SessionNum1 = 0; %counts the number of sessions in a day (both initiated and not initiated) for mouse-1

Water2 = 0;
correct2 = 0;
incorrect2 = 0;
Numomission2 = 0;
premature2 = 0;
TrialNumber2 = 0;
SessionNum2 = 0;

% Start the timers
    % Mouse-1
t2 = timer;
t2.StartFcn = @(~,thisEvent)disp([thisEvent.Type ' executed ,pipeline start for mouse-1 '...
    datestr(thisEvent.Data.time,' dd-mmm-yyyy HH:MM:SS.FFF')]); % the function set here will run when the timer is first started
t2.TimerFcn = @(~,thisEvent) Pipeline('cycleAnimals', Rgate); % the function set here will run at the given time periods, based on parameters given below
t2.StopFcn = @(~,thisEvent) delete(t2); % the function set here will run when the last iteration of the timer starts
t2.Period = 7200; % the t2.TimerFcn function will run in the given intervals (given in seconds)
t2.TasksToExecute = 12; % set how many times the t2.TimerFcn function will run (here how many training session the mouse can have in a day)
t2.ExecutionMode = 'fixedRate';
t2.BusyMode  = 'drop';
start(t2)

    % Mouse-2
t3 = timer;
t3.StartFcn = @(~,thisEvent)disp([thisEvent.Type ' executed ,pipeline start for mouse-2 '...
    datestr(thisEvent.Data.time,' dd-mmm-yyyy HH:MM:SS.FFF')]);
t3.TimerFcn = @(~,thisEvent) Pipeline('cycleAnimals', Lgate);
t3.StopFcn = @(~,thisEvent) delete(t3);
t3.Period = 7200;
t3.StartDelay = 3600; % this timer will start after the start of the t2 timer (time given in seconds)
t3.TasksToExecute = 12;
t3.ExecutionMode = 'fixedRate';
t3.BusyMode = 'drop';
start(t3)
end
