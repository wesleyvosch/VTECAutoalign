function [action,changes]=main(state)

% get input values from Simulink
changes=0;
startx_obj=find_system('Autoalign_system','BlockType','Constant','Name','start_x');
starty_obj=find_system('Autoalign_system','BlockType','Constant','Name','start_y');
lengthx_obj=find_system('Autoalign_system','BlockType','Constant','Name','length_x');
lengthy_obj=find_system('Autoalign_system','BlockType','Constant','Name','length_y');
loops_obj=find_system('Autoalign_system','BlockType','Constant','Name','loops');
delay_obj=find_system('Autoalign_system','BlockType','Constant','Name','stepsize');
on_obj=find_system('Autoalign_system','BlockType','Constant','Name','on');

% load sim_inputs
startx_sim=get_param(startx_obj{1},'Value');
starty_sim=get_param(starty_obj{1},'Value');
lengthx_sim=get_param(lengthx_obj{1},'Value');
lengthy_sim=get_param(lengthy_obj{1},'Value');
loops_sim=get_param(loops_obj{1},'Value');
delay_sim=get_param(delay_obj{1},'Value');

% get locally saved data
startx=getappdata(0,'startx');
starty=getappdata(0,'starty');
lengthx=getappdata(0,'lengthx');
lengthy=getappdata(0,'lengthy');
loops=getappdata(0,'loops');
delay=getappdata(0,'delay');

% transform appdata to string
startx_str=num2str(startx);
starty_str=num2str(starty);
lengthx_str=num2str(lengthx);
lengthy_str=num2str(lengthy);
loops_str=num2str(loops);
delay_str=num2str(delay);

switch state
    case 0 % Stop
        if strcmp(get_param('Autoalign_system','SimulationStatus'),'paused')
            % Forced stop            
            set_param('Autoalign_system','SimulationCommand','stop');
        else
            % Normal stop
            set_param(on_obj{1},'Value','0'); % put simulink in off state
        end
    case 1 % Build
        % update values
        set_param(startx_obj{1},'Value',startx_str);
        set_param(starty_obj{1},'Value',starty_str);
        set_param(lengthx_obj{1},'Value',lengthx_str);
        set_param(lengthy_obj{1},'Value',lengthy_str);
        set_param(loops_obj{1},'Value',loops_str);
        set_param(delay_obj{1},'Value',delay_str);
        set_param(on_obj{1},'Value','1'); % put simulink in run state
        % start building simulink
        set_param('Autoalign_system','SimulationCommand','start');
    case 2 % run
        set_param(on_obj{1},'Value','1'); % put simulink in run state
    case 3 % Pause 
        set_param(on_obj{1},'Value','2'); % put simulink in pause state
        set_param('Autoalign_system','SimulationCommand','pause');
    case 4 % Unpause
        % compare appdata with current data
        if isequal(startx_sim,startx_str)&&isequal(starty_sim,starty_str)...
                &&isequal(lengthx_sim,lengthx_str)&&isequal(lengthy_sim,lengthy_str)...
                &&isequal(loops_sim,loops_str)&&isequal(delay_sim,delay_str)
            % no changes
            changes=0;
            set_param(on_obj{1},'Value','1'); % put simulink in run state
            set_param('Autoalign_system','SimulationCommand','continue');
        else
            changes=1;
        end
    otherwise
        set_param(on_obj{1},'Value','0'); % put simulink in off state
end

cnt=0;
if state==1 % skip 'while' in build mode
    action='build';
    return;
end
while (strcmp(get_param('Autoalign_system','SimulationStatus'),'stopped')==0)
    if strcmp(get_param('Autoalign_system','SimulationStatus'),'paused')
       % Simulink is paused
       if state>0%&&changes==0 % set state = pause, except for stop or changes
           if changes==1
               set_param('Autoalign_system','SimulationCommand','stop');
           else
               state=3;
               break;
           end
       end
    end
    if cnt>1200
        % time limit reached (2 minutes)
        break;
    end
    % Simuling is running
%     time=get_param('Autoalign_system','SimulationTime');
    cnt=cnt+1;
    pause(0.1);
end
if cnt>1200
    % timeout
    action='time';
    return;
end
switch state
    case 0 % stop
        changes=0;
        action='stopped';
    case 1% build
        changes=0;
        return;
    case 2% run
        changes=0;
        action='finished';
    case 3% pause
        changes=0;
        action='paused';
    case 4% unpause
        if changes==0
            action='finished';
        else
            action='build';
        end
    otherwise % unknown
        action='stopped';
end