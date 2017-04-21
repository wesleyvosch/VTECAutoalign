function [action,changes]=main(state)
% get input values from Simulink
changes=0;
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

% get locally saved data
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
ci=0;
for i=1:loops
   ci=ci+(2*i-1)*diameter*4096/((2*loops-1)*50);
end
ct=4*ci+diameter*4096/((2*loops-1)*50);
start_diff=abs(centerx-centerx_sim)+abs(centery-centery_sim);
cto=ct+start_diff*4096/50;
time=cto*(1+16/delay)/800;

setappdata(0,'approx_time',time);
cnt_time=15*time;
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
        if centerx==centerx_sim && centery == centery_sim
            % start position unchanged
            set_param(on_obj{1},'Value','1'); % simulink -> run: search fcn
            changes=0;
        else
            % start position changed
            set_param(on_obj{1},'Value','3'); % simulink -> run: move fcn
            changes=2;
        end
        
        % update values
        set_param(centerx_obj{1},'Value',centerx_str);
        set_param(centery_obj{1},'Value',centery_str);
        set_param(diameter_obj{1},'Value',diameter_str);
        set_param(loops_obj{1},'Value',loops_str);
        set_param(delay_obj{1},'Value',delay_str);
        set_param(read_time_obj{1},'Value',read_time_str);
        set_param(on_obj{1},'Value','1'); % simulink -> run: search fcn
        % start building simulink
        if strcmp(get_param('Autoalign_system','SimulationStatus'),'stopped')
            set_param('Autoalign_system','SimulationCommand','start');
        end
    case 2 % run
        set_param(on_obj{1},'Value','1'); % put simulink in run state
    case 3 % Pause 
        set_param(on_obj{1},'Value','2'); % put simulink in pause state
        set_param('Autoalign_system','SimulationCommand','pause');
    case 4 % Unpause
        % compare appdata with current data
        if isequal(centerx_sim,centerx_str)&&isequal(centery_sim,centery_str)...
                &&isequal(diameter_sim,diameter_str)&&isequal(loops_sim,loops_str)...
                &&isequal(delay_sim,delay_str)&&isequal(read_time_sim,read_time_str)
            % no changes
            changes=0;
            set_param(on_obj{1},'Value','1'); % put simulink in run state
            set_param('Autoalign_system','SimulationCommand','continue');
        else
            changes=1;
        end
    case 5 % move
        set_param(on_obj{1},'Value','3'); % put simulink in move state
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
       if state>0
           if changes==1
               set_param('Autoalign_system','SimulationCommand','stop');
           else
               state=3;
               break;
           end
       end
    end
    if cnt>cnt_time
        % time limit reached (2 minutes)
        break;
    end
    % Simuling is running
    cnt=cnt+1;
    pause(0.1);
end
if cnt>cnt_time
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
    case 5% moved
        action='moved';
    otherwise % unknown
        action='stopped';
end