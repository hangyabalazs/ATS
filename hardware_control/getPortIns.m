function portIns = getPortIns(trial)
%getPortIns function returns 1 if there was a poke-in in either of the
%ports.
%   Syntax: getPortIns(A), where A is the trial number on which this short
%   analysis is to be performed; ports is a configurable parameter.
%
%   See also CSRTT5_1_func and CSRTT5_2_func.

%   Peter Reveland, modified by 
%   Eszter Birtalan
%   hangya.balazs@koki.mta.hu
%   last modified 15.02.2020

ports = {'Port1In' 'Port2In' 'Port3In' 'Port4In' 'Port5In'};
events = trial.Events;
portIns = [];

for port = ports
    if(isfield(events, port));
        portIns = 1;
    end
end

end