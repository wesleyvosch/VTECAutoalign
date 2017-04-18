function [action,changes]=main(state)

% get input values from Simulink
changes=0;
centerx_obj=find_system('Autoalign_system','BlockType','Constant','Name','center_x');
centery_obj=find_system('Autoalign_system','BlockType','Constant','Name','center_y');
diameter_obj=find_system('Autoalign_system','BlockType','Constant','Name','diameter');
loops_obj=find_system('Autoalign_system','BlockType','Constant','Name','loops');
delay_obj=find_system('Autoalign_system','BlockType','Constant','Name','stepsize');
on_obj=find_system('Autoalign_system','BlockType','Constant','Name','on');

% load sim_inputs
centerx_sim=get_param(centerx_obj{1},'Value');
centery_sim=get_param(centery_obj{1},'Value');
diameter_sim=get_param(diameter_obj{1},'Value');
loops_sim=get_param(loops_obj{1},'Value');
delay_sim=get_param(delay_obj{1},'Value');

% get locally saved data
centerx=getappdata(0,'centerx');
centery=getappdata(0,'centery');
diameter=getappdata(0,'diameter');
loops=getappdata(0,'loops');
delay=getappdata(0,'delay');

% transform appdata to string
centerx_str=num2str(centerx);
centery_str=num2str(centery);
diameter_str=num2str(diameter);
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
        set_param(centerx_obj{1},'Value',centerx_str);
        set_param(centery_obj{1},'Value',centery_str);
        set_param(diameter_obj{1},'Value',diameter_str);
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
        if isequal(centerx_sim,centerx_str)&&isequal(centery_sim,centery_str)...
                &&isequal(diameter_sim,diameter_str)&&isequal(loops_sim,loops_str)&&isequal(delay_sim,delay_str)
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