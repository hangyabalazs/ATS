function varargout = PipelineDoor(op, varargin)
%PipelineDoor Initiates and controlls the connected DC motor and motion
%sensor. Code modified from https://github.com/sanworks/Pipeline_Gate from
%Josh Sanders, Sanworks LLC.
%   Syntax: PipelineDoor('op', A), where op is the case name and A is the
%   COM port of the gate when the case is 'init', and 1 in other cases.
%
%   case 'init' sets the serial port communication between the arduino of the
%   gate and matlab 
%   case 'open' opens the gate fully 
%   case 'clean' opens the gate half-way
%   case 'endclean' closes the gate after it was open half-way
%   case 'close' closes the gate after it was fully open
%   case 'cycle' opens the gate then waits for a signal from the motion
%   sensor; if the sensor detected motion, the gate closes; otherwise it
%   will close after a given time (here 600 seconds) 
%   case 'infcycle' does the same as above, except waits longer for motion
%   to be detected (here 1 hour) and optionally sends an email if there was
%   no motion
%   case 'readsensor' reads the motion sensor, returns 0 for no movement
%   and 1 for movement
%   case 'end' disconnects the motor
%
%   See also Pipeline.

%   Written by Josh Sanders, Sanworks LLC, modified by 
%   Eszter Birtalan
%   Institute of Experimental Medicine, Budapest hangya.balazs@koki.mta.hu
%   last modified 15.02.2020

global PipelineSystem
switch op
    case 'init'
        s = num2str(varargin{1});
        Port = strcat('COM',s);
        if ispc
           PipelineSystem.SerialPort = serial(Port, 'BaudRate', 9600, 'Timeout', 1, 'DataTerminalReady', 'on');
        else
           PipelineSystem.SerialPort = serial(Port, 'BaudRate', 9600, 'Timeout', 1, 'DataTerminalReady', 'off');
        end
        fopen(PipelineSystem.SerialPort);
    case 'open'
        GateID = varargin{1};
        fwrite(PipelineSystem.SerialPort, ['L' GateID]);
        
       
    case 'clean'
        GateID = varargin{1};
        fwrite(PipelineSystem.SerialPort, ['O' GateID]);
        
    case 'endClean'
        GateID = varargin{1};
        fwrite(PipelineSystem.SerialPort, ['C', GateID]);
        Result = WaitForDoorClose;
        varargout{1} = Result;
       
    case 'close'
        GateID = varargin{1};
        fwrite(PipelineSystem.SerialPort, ['E' GateID]);
        
         
    case 'cycle'
         date1 = datetime('now');
         PipelineDoor('open',1);
         while PipelineDoor('readSensor',1) == 0 
           if etime(datevec(datetime('now')),datevec(date1)) >= 600 % if 600 s has passed stop reading from sensor and close the gate
               break
           end

         end
            PipelineDoor('close',1);
           if etime(datevec(datetime('now')),datevec(date1)) < 3
               disp('gate closed too soon'); % the gate closing soon may be a sign of the motion sensor malfunctioning
           end
    case 'infcycle' 
           date1 = datetime('now');
           disp('door opened at: ');
           disp(date1);
           PipelineDoor('open',1);
         while PipelineDoor('readSensor',1) == 0
               if etime(datevec(datetime('now')),datevec(date1)) >= 3600 % if 3600 s has passed stop reading from sensor and close the gate
                   disp('Timeup for infcycle');
                   disp(datetime('now'));
            % Sending an email at this point is optional
            % please consult the webpage
            % https://www.mathworks.com/help/matlab/ref/sendmail.html?s_tid=doc_ta
            % for further information on the sendmail function
%             try
%                 sendmail(recipients,subject,message)
%             catch
%                 disp('there was an error with sending an email');
%             end
                  break
               end
               
         end
         disp('door closed at: ');
         disp(datetime('now'));
           PipelineDoor('close',1);
           if etime(datevec(datetime('now')),datevec(date1)) < 3
               disp('gate closed soon'); % the gate closing soon may be a sign of the motion sensor malfunctioning
           end
        
    case 'readSensor'
        SensorID = varargin{1};
        fwrite(PipelineSystem.SerialPort, ['R' SensorID], 'uint8');
        SensorValue = fread(PipelineSystem.SerialPort, 1);
        varargout{1} = SensorValue;
        
    case 'end'
        fclose(PipelineSystem.SerialPort);
        delete(PipelineSystem.SerialPort);
end

function Result = WaitForDoorClose
global PipelineSystem
tic
while PipelineSystem.SerialPort.BytesAvailable == 0
    pause(.001);
    if toc > 1
        error('Error: Door close failure detected.')
    end
end
Result = fread(PipelineSystem.SerialPort, PipelineSystem.SerialPort.BytesAvailable);