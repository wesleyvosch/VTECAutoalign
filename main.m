function main(state)
display('MAIN: started');

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

switch state
    case 0 % Build
        display('MAIN: Build');
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
        display('MAIN: Run');
        set_param(mode_obj{1},'Value','1'); % simulink -> run
%         set_param('Autoalign_system','SimulationCommand','start');
        display('MAIN: Run, after start command');
        % define time limit
        [min,sec]=calcTime();
        cnt_time=50*(min*60+sec);
        counter=0; % reset counter
    case 2 % Pause
        display('MAIN: Pause');
        set_param(mode_obj{1},'Value','2'); % simulink -> pause
    case 3 % Unpause
        display('MAIN: Unpause');
        set_param(mode_obj{1},'Value','1'); % simulink -> run
        if centerx==centerx_sim && centery==centery_sim &&...
                diameter==diameter_sim && loops==loops_sim &&...
                cycles==cycles_sim && delay==delay_sim && read_time==read_time_sim
            % no changes
            display('MAIN: Unpause, No changes');
        else
            display('MAIN: Unpause, Changes');
            main(1);
            % something changed
            % update values
            centerx_sim =centerx;
            centery_sim =centery;
            diameter_sim =diameter;
            loops_sim =loops;
            cycles_sim=cycles;
            delay_sim =delay;
            read_time_sim=read_time;
            set_param('Autoalign_system','SimulationCommand','stop');
        end
    otherwise
        display('MAIN: unknown mode');
        % do nothing
end

display('MAIN: Starting while...');
while strcmp(get_param('Autoalign_system','SimulationStatus'),'stopped')==0&&...
        strcmp(get_param('Autoalign_system','SimulationStatus'),'paused')==0
    if counter>cnt_time
        display('MAIN: Time limit reached!');
        break;
    end
    pause(.1);
    counter=counter+1;
end
if state==2
    display('MAIN: end while, unpause state');
    if centerx~=centerx_sim || centery~=centery_sim ||...
            diameter~=diameter_sim || loops~=loops_sim ||...
            cycles~=cycles_sim || delay~=delay_sim || read_time~=read_time_sim
        display('MAIN: end while, Unpause: restart');
        main(0);
    end
end
display('MAIN: END');