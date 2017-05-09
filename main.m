function main(state)
display('MAIN');
% get input values from Simulink

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

cnt_time=20*calcTime();
switch state
    case 0 % Build
        display('MAIN: build mode');
        % update values
        set_param(centerx_obj{1},'Value',centerx_str);
        set_param(centery_obj{1},'Value',centery_str);
        set_param(diameter_obj{1},'Value',diameter_str);
        set_param(loops_obj{1},'Value',loops_str);
        set_param(delay_obj{1},'Value',delay_str);
        set_param(read_time_obj{1},'Value',read_time_str);
        set_param(on_obj{1},'Value','0');
        return;
    case 1 % move mode
        display('MAIN: move mode');
        % update parameters
        set_param(centerx_obj{1},'Value',centerx_str);
        set_param(centery_obj{1},'Value',centery_str);
        set_param(diameter_obj{1},'Value',diameter_str);
        set_param(loops_obj{1},'Value',loops_str);
        set_param(delay_obj{1},'Value',delay_str);
        set_param(read_time_obj{1},'Value',read_time_str);
        set_param(on_obj{1},'Value','1'); % simulink -> run: move fcn
        set_param('Autoalign_system','SimulationCommand','start');
    case 2 % search mode
        display('MAIN: search mode');
        set_param(on_obj{1},'Value','2'); % simulink -> run: search fcn
        set_param('Autoalign_system','SimulationCommand','start');
    otherwise
        display('MAIN: unknown mode');
        % update values
        set_param(centerx_obj{1},'Value',centerx_str);
        set_param(centery_obj{1},'Value',centery_str);
        set_param(diameter_obj{1},'Value',diameter_str);
        set_param(loops_obj{1},'Value',loops_str);
        set_param(delay_obj{1},'Value',delay_str);
        set_param(read_time_obj{1},'Value',read_time_str);
        set_param(on_obj{1},'Value','0');
end

if state==0 % skip 'while' in build mode
    display('MAIN: build, skip while');
    return;
end

counter=0; % reset when running (not when pausing, etc.)
display('start while...');
display(get_param('Autoalign_system','SimulationStatus'));

while strcmp(get_param('Autoalign_system','SimulationStatus'),'stopped')==0
    % check for pause command
    if counter>cnt_time
        display('MAIN: time limit reached!');
        break;
    end
    pause(.1);
    counter=counter+1;
end
display('MAIN: END');