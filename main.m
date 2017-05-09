function [action,changes]=main(state)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% This function communicatates between the GUI and the simulink model. It
% gets the state from the user interface and returns the correct action.
% For some states is for the GUI important to know if changes are made to
% the parameters.
% 
% PARAMETERS:
% input: 
%   state - number between 0 and 5 to select the required state
% output: 
%   action - indicator to know which state is finished
%   changes - inducator to check for changes between saved data and 
%             kwnown parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global counter;
global state_on;
display('MAIN');
% get input values from Simulink
changes=-1;
centerx_obj=find_system('Autoalign_system','BlockType','Constant','Name','center_x');
centery_obj=find_system('Autoalign_system','BlockType','Constant','Name','center_y');
diameter_obj=find_system('Autoalign_system','BlockType','Constant','Name','diameter');
loops_obj=find_system('Autoalign_system','BlockType','Constant','Name','loops');
delay_obj=find_system('Autoalign_system','BlockType','Constant','Name','delay');
read_time_obj=find_system('Autoalign_system','BlockType','Constant','Name','read_time');
on_obj=find_system('Autoalign_system','BlockType','Constant','Name','on');

% load sim_inputs
centerx_sim=str2double(get_param(centerx_obj{1},'Value'));
centery_sim=str2double(get_param(centery_obj{1},'Value'));
diameter_sim=str2double(get_param(diameter_obj{1},'Value'));
loops_sim=str2double(get_param(loops_obj{1},'Value'));
delay_sim=str2double(get_param(delay_obj{1},'Value'));
read_time_sim=str2double(get_param(read_time_obj{1},'Value'));

% get local data
centerx=getappdata(0,'centerx');
centery=getappdata(0,'centery');
diameter=getappdata(0,'diameter');
loops=getappdata(0,'loops');
delay=getappdata(0,'delay');
read_time=getappdata(0,'read_time');

% transform appdata to string
centerx_str=num2str(centerx);
centery_str=num2str(centery);
diameter_str=num2str(diameter);
loops_str=num2str(loops);
delay_str=num2str(delay);
read_time_str=num2str(read_time);
% calc time limit

% ci=0;
% for i=1:loops
%    ci=ci+(2*i-1)*diameter*4096/((2*loops-1)*50);
% end
% ct=4*ci+diameter*4096/((2*loops-1)*50);
% start_diff=abs(centerx-centerx_sim)+abs(centery-centery_sim);
% cto=ct+start_diff*4096/50;
% time=cto*(1+16/delay)/800;
% 
% setappdata(0,'approx_time',time);
% cnt_time=20*time;
cnt_time=20*calcTime();
display(state);
switch state
    case -1 % EXIT
        display('MAIN: exit');
        set_param(on_obj{1},'Value','-1'); % turn off simulink
    case 0 % Stop
        set_param(on_obj{1},'Value','0');
        if strcmp(get_param('Autoalign_system','SimulationStatus'),'paused')
            % Forced stop
            display('MAIN: unpause & set to idle');
            set_param('Autoalign_system','SimulationCommand','continue');
        else
            % Normal stop
            display('MAIN: set to idle');
%             set_param(on_obj{1},'Value','0'); % put simulink in idle state
        end
    case 1 % Build
        if centerx==centerx_sim && centery == centery_sim
            % start position unchanged
            display('MAIN: build, search');
            set_param(on_obj{1},'Value','2'); % simulink -> run: search fcn
            state_on=2;
            changes=0;
        else
            % start position changed
            display('MAIN: build, move');
            set_param(on_obj{1},'Value','1'); % simulink -> run: move fcn
            state_on=1;
            changes=1;
        end
        
        % update values
        set_param(centerx_obj{1},'Value',centerx_str);
        set_param(centery_obj{1},'Value',centery_str);
        set_param(diameter_obj{1},'Value',diameter_str);
        set_param(loops_obj{1},'Value',loops_str);
        set_param(delay_obj{1},'Value',delay_str);
        set_param(read_time_obj{1},'Value',read_time_str);
        set_param(on_obj{1},'Value','0');
        % start building simulink
        if strcmp(get_param('Autoalign_system','SimulationStatus'),'stopped')
            display('MAIN: BUILD, start');
            set_param('Autoalign_system','SimulationCommand','start');
        else
            display('MAIN: BUILD, sim still running');
            set(handles.ind_error,'string','Unable to build, simulation is still running');
            action='stopped';
        end
    case 2 % run (move or search)
        % update parameters
        set_param(centerx_obj{1},'Value',centerx_str);
        set_param(centery_obj{1},'Value',centery_str);
        set_param(diameter_obj{1},'Value',diameter_str);
        set_param(loops_obj{1},'Value',loops_str);
        set_param(delay_obj{1},'Value',delay_str);
        set_param(read_time_obj{1},'Value',read_time_str);
        if (centerx==centerx_sim) && (centery == centery_sim)
            % search mode
            display('MAIN: run search');
            set_param(on_obj{1},'Value','2'); % simulink -> run: search fcn
            set_param('Autoalign_system','SimulationCommand','start');
%             if strcmp(get_param('Autoalign_system','SimulationStatus'),'paused')
%                 set_param('Autoalign_system','SimulationCommand','continue');
%             end
            changes=0;
        else
            display('MAIN: run move');
            % move mode
            set_param(on_obj{1},'Value','1'); % simulink -> run: move fcn
            set_param('Autoalign_system','SimulationCommand','start');
%             if strcmp(get_param('Autoalign_system','SimulationStatus'),'paused')
%                 set_param('Autoalign_system','SimulationCommand','continue');
%             end
            changes=1;
        end
    case 3 % Pause 
        display('MAIN: pause');
        set_param(on_obj{1},'Value','3'); % put simulink in pause state
        set_param('Autoalign_system','SimulationCommand','Pause');
        display(get_param('Autoalign_system','SimulationStatus'));
    case 4 % Unpause
        % compare parameters with previous data
        if isequal(centerx_sim,centerx_str)&&isequal(centery_sim,centery_str)...
                &&isequal(diameter_sim,diameter_str)&&isequal(loops_sim,loops_str)...
                &&isequal(delay_sim,delay_str)&&isequal(read_time_sim,read_time_str)
            % nothing changed
            display('MAIN: resume');
            changes=0;
            state=4;
            set_param(on_obj{1},'Value','2'); % put simulink in run state
            set_param('Autoalign_system','SimulationCommand','continue');
        else
            display('MAIN: restart');
            changes=1;
        end
    otherwise
        display('MAIN: unknown');
        set_param(on_obj{1},'Value','0'); % put simulink in off state
        if strcmp(get_param('Autoalign_system','SimulationStatus'),'paused')
            set_param('Autoalign_system','SimulationCommand','continue');
        end
        return;
end

if state==1 % skip 'while' in build mode
    display('MAIN: build, skip while');
    action='build';
    return;
end
% display(get_param('Autoalign_system','SimulationStatus'));
if state==3
    display('skip while,paused');
    state=4;
    set_param('Autoalign_system', 'SimulationCommand', 'Pause');
    action='paused';
    return;
end
if state==2
    display('resetting counter');
    counter=0; % reset when running (not when pausing, etc.)
end

display('start while...');
display(get_param('Autoalign_system','SimulationStatus'));
display(state);

while strcmp(get_param('Autoalign_system','SimulationStatus'),'stopped')==0
    % check for pause command
    if counter>cnt_time||state==-1
        display('MAIN: while, descrepency detected!');
        break;
    end
    pause(.1);
    display(counter);
    counter=counter+1;

%    if getappdata(0,'setpause')>0
%        display('MAIN: while detected setpause (appdata)');
%         break;
%    end
%    if sum(getappdata(0,'finish'))>0
%        display('MAIN: while detected finish (appdata)');
%         break;
%    end
%    set_param('Autoalign_system', 'SimulationCommand', 'continue');
end

display('MAIN: end while');
display(counter);
% display('MAIN: sum setpause=');
% display(sum(getappdata(0,'setpause')));
% display('MAIN: sum of finish=');
% display(sum(getappdata(0,'finish')));
% display('MAIN: length of finish=');
% display(length(getappdata(0,'finish')));
if counter>cnt_time
    display('MAIN: Time limit');
    action='time';
    changes=0;
    return;
end
display(state);

% if getappdata(0,'setpause')~=0
%     display('MAIN: handle pause request');
%     changes=0;
%     switch getappdata(0,'setpause')
%         case 1
%             action='finished';
%         case 2
%             action='moved';
%         case 3
%             action='paused';
%         otherwise
%             action='stopped';
%     end
%     return;
% end

switch state
    case -1 % exit
        display('MAIN: show:exit');
        changes=0;
        action='exit';
    case 0 % stop
        display('MAIN: show:stop');
        set_param(on_obj{1},'Value','0'); % simulink -> idle
%         set_param('Autoalign_system','SimulationCommand','start');
        changes=0;
        action='stopped';
    case 2% run
        if strcmp(get_param('Autoalign_system','SimulationStatus'),'paused')
            display('MAIN: show:pause');
            action='paused';
        else
            if changes==0
                display('MAIN: show:finish');
                set_param(on_obj{1},'Value','0'); % simulink -> idle
%             set_param('Autoalign_system','SimulationCommand','start');
                action='finished';
            else
                display('MAIN: show:move');
                set_param(on_obj{1},'Value','0'); % simulink -> idle
    %             set_param('Autoalign_system','SimulationCommand','start');
                action='moved';
            end
        end
    case 3% pause
        display('MAIN: show:pause');
        changes=0;
        action='paused';
    case 4% unpause
        if changes==0
            display('MAIN: show:unpause,finish');
            set_param(on_obj{1},'Value','0'); % simulink -> idle
%             set_param('Autoalign_system','SimulationCommand','start');
            action='finished';
        else
            display('MAIN: show:unpause,build');
%             set_param(on_obj{1},'Value','0'); % simulink -> idle
%             set_param('Autoalign_system','SimulationCommand','start');
            action='build';
        end
    otherwise % unknown
        display('MAIN: show:unknown,stop');
        set_param(on_obj{1},'Value','0'); % simulink -> idle
%         set_param('Autoalign_system','SimulationCommand','start');
        action='stopped';
end