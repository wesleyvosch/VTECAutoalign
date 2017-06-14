function main(state)
global counter;
global changes;
global doPause;
% get input handles of Simulink model
mode_obj=find_system('Autoalign_system','BlockType','Constant','Name','mode');
centerx_obj=find_system('Autoalign_system','BlockType','Constant','Name','center_x');
centery_obj=find_system('Autoalign_system','BlockType','Constant','Name','center_y');
diameter_obj=find_system('Autoalign_system','BlockType','Constant','Name','diameter');
loops_obj=find_system('Autoalign_system','BlockType','Constant','Name','loops');
cycles_obj=find_system('Autoalign_system','BlockType','Constant','Name','cycles');
delay_obj=find_system('Autoalign_system','BlockType','Constant','Name','delay');
read_time_obj=find_system('Autoalign_system','BlockType','Constant','Name','read_time');

% get simulink model inputs
centerx_sim=str2double(get_param(centerx_obj{1},'Value'));
centery_sim=str2double(get_param(centery_obj{1},'Value'));
diameter_sim=str2double(get_param(diameter_obj{1},'Value'));
loops_sim=str2double(get_param(loops_obj{1},'Value'));
cycles_sim=str2double(get_param(cycles_obj{1},'Value'));
delay_sim=str2double(get_param(delay_obj{1},'Value'));
read_time_sim=str2double(get_param(read_time_obj{1},'Value'));

% get stored appdata
centerx=getappdata(0,'centerx');
centery=getappdata(0,'centery');
diameter=getappdata(0,'diameter');
loops=getappdata(0,'loops');
cycles=getappdata(0,'cycles');
delay=getappdata(0,'delay');
read_time=getappdata(0,'read_time');

% transform appdata to string
centerx_str=num2str(centerx);
centery_str=num2str(centery);
diameter_str=num2str(diameter);
loops_str=num2str(loops);
cycles_str=num2str(cycles);
delay_str=num2str(delay);
read_time_str=num2str(read_time);

[min,sec]=calcTime();
cnt_time=50*(min*60+sec);
switch state
    case -1 % stop
        if doPause>0
            % simulink paused, order stop with command
            set_param('Autoalign_system','SimulationCommand','stop');
        else
            % simulink running, order stop in simulink
            set_param(mode_obj{1},'Value','-1'); % simulink -> stop
        end
    case 0 % Build
        % update values
        set_param(centerx_obj{1},'Value',centerx_str);
        set_param(centery_obj{1},'Value',centery_str);
        set_param(diameter_obj{1},'Value',diameter_str);
        set_param(loops_obj{1},'Value',loops_str);
        set_param(cycles_obj{1},'Value',cycles_str);
        set_param(delay_obj{1},'Value',delay_str);
        set_param(read_time_obj{1},'Value',read_time_str);
        set_param(mode_obj{1},'Value','0');
        set_param('Autoalign_system','SimulationCommand','start');
        return;
    case 1 % Run
        set_param(mode_obj{1},'Value','1'); % simulink -> run
        counter=0; % reset counter
    case 2 % unpause
        set_param(mode_obj{1},'Value','1'); % simulink -> pause
        set_param('Autoalign_system','SimulationCommand','continue');
    otherwise
        % do nothing
end
if doPause==2 % unpause
    set_param(mode_obj{1},'Value','1'); % simulink -> run
    if centerx==centerx_sim && centery==centery_sim &&...
            diameter==diameter_sim && loops==loops_sim &&...
            cycles==cycles_sim && delay==delay_sim && read_time==read_time_sim
        % no changes, continue
        set_param('Autoalign_system','SimulationCommand','continue');
        changes=0;
    else
        % changes, restart
        counter=0;
        changes=1;
        set_param('Autoalign_system','SimulationCommand','stop');
        % update values
        centerx_sim =centerx;
        centery_sim =centery;
        diameter_sim =diameter;
        loops_sim =loops;
        cycles_sim=cycles;
        delay_sim =delay;
        read_time_sim=read_time;
    end
    doPause=0;
end
while strcmp(get_param('Autoalign_system','SimulationStatus'),'stopped')==0
    if doPause==1 % pause
        set_param('Autoalign_system','SimulationCommand','pause');
    elseif doPause==2
        break;
    end
    if counter>cnt_time
        break;
    end
    pause(.1);
    counter=counter+1;
end
if state==3
    if centerx~=centerx_sim || centery~=centery_sim ||...
            diameter~=diameter_sim || loops~=loops_sim ||...
            cycles~=cycles_sim || delay~=delay_sim || read_time~=read_time_sim
        main(0);
    end
end