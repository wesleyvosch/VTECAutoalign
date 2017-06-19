function main(state)
global counter;
global changes;
global doPause;
global wasPaused;

% get input handles of Simulink model
mode_obj=find_system('Autoalign_system','BlockType','Constant','Name','mode');
centerx_obj=find_system('Autoalign_system','BlockType','Constant','Name','center_x');
centery_obj=find_system('Autoalign_system','BlockType','Constant','Name','center_y');
diameter_obj=find_system('Autoalign_system','BlockType','Constant','Name','diameter');
loops_obj=find_system('Autoalign_system','BlockType','Constant','Name','loops');
cycles_obj=find_system('Autoalign_system','BlockType','Constant','Name','cycles');
delay_obj=find_system('Autoalign_system','BlockType','Constant','Name','delay');
read_time_obj=find_system('Autoalign_system','BlockType','Constant','Name','read_time');
%temp
p_set_obj=find_system('Autoalign_system','BlockType','Constant','Name','PSet');
px_set_obj=find_system('Autoalign_system','BlockType','Constant','Name','PxSet');
py_set_obj=find_system('Autoalign_system','BlockType','Constant','Name','PySet');
pfactor_obj=find_system('Autoalign_system','BlockType','Constant','Name','Pfactor');


% get simulink model inputs
centerx_sim=str2double(get_param(centerx_obj{1},'Value'));
centery_sim=str2double(get_param(centery_obj{1},'Value'));
diameter_sim=str2double(get_param(diameter_obj{1},'Value'));
loops_sim=str2double(get_param(loops_obj{1},'Value'));
cycles_sim=str2double(get_param(cycles_obj{1},'Value'));
delay_sim=str2double(get_param(delay_obj{1},'Value'));
read_time_sim=str2double(get_param(read_time_obj{1},'Value'));
%temp
p_set_sim=str2double(get_param(read_time_obj{1},'Value'));
px_set_sim=str2double(get_param(read_time_obj{1},'Value'));
py_set_sim=str2double(get_param(read_time_obj{1},'Value'));
pfactor_sim=str2double(get_param(read_time_obj{1},'Value'));

% get stored appdata
centerx=getappdata(0,'centerx');
centery=getappdata(0,'centery');
diameter=getappdata(0,'diameter');
loops=getappdata(0,'loops');
cycles=getappdata(0,'cycles');
delay=getappdata(0,'delay');
read_time=getappdata(0,'read_time');
%temp
p_set=getappdata(0,'p_set');
px_set=getappdata(0,'px_set');
py_set=getappdata(0,'py_set');
pfactor=getappdata(0,'pfactor');

% transform appdata to string
centerx_str=num2str(centerx);
centery_str=num2str(centery);
diameter_str=num2str(diameter);
loops_str=num2str(loops);
cycles_str=num2str(cycles);
delay_str=num2str(delay);
read_time_str=num2str(read_time);
p_set_str=num2str(p_set);
px_set_str=num2str(px_set);
py_set_str=num2str(py_set);
pfactor_str=num2str(pfactor);

[min,sec]=calcTime();
cnt_time=50*(min*60+sec);
switch state
    case -1 % stop
        if doPause>0
            % simulink paused, order stop with command
            display('main: stop while paused');
            set_param('Autoalign_system','SimulationCommand','stop');
        else
            display('main: stop normally');
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
        set_param(p_set_obj{1},'Value',p_set_str);
        set_param(px_set_obj{1},'Value',px_set_str);
        set_param(py_set_obj{1},'Value',py_set_str);
        set_param(pfactor_obj{1},'Value',pfactor_str);
        set_param(mode_obj{1},'Value','0');
        set_param('Autoalign_system','SimulationCommand','start');
        return;
    case 1 % Run
        set_param(mode_obj{1},'Value','1');
        display('main: run (cnt=0)');
        counter=0; % reset counter
    case 2 % unpause
        display('main: state 2 (cnt unchanged)');
        set_param(mode_obj{1},'Value','1');
        set_param('Autoalign_system','SimulationCommand','continue');
    otherwise
        % do nothing
end
if doPause==2 % unpause
    display('main: doPause 2: Unpause');
    set_param(mode_obj{1},'Value','1'); % simulink -> run
    if centerx==centerx_sim && centery==centery_sim &&...
            diameter==diameter_sim && loops==loops_sim &&...
            cycles==cycles_sim && delay==delay_sim && read_time==read_time_sim
        % no changes, continue
        display('main: doPause 2: continue (cnt unchanged)');
        set_param('Autoalign_system','SimulationCommand','continue');
        changes=0;
    else
        % changes, restart
        counter=0;
        changes=1;
        wasPaused=0;
        display('main: doPause 2: restart (cnt=0)');
        set_param('Autoalign_system','SimulationCommand','stop');
        % update values
        centerx_sim =centerx;
        centery_sim =centery;
        diameter_sim =diameter;
        loops_sim =loops;
        cycles_sim=cycles;
        delay_sim =delay;
        read_time_sim=read_time;
        p_set_sim=p_set;
        px_set_sim=px_set;
        py_set_sim=py_set;
        pfactor_sim=pfactor;
    end
    doPause=0;
end
while strcmp(get_param('Autoalign_system','SimulationStatus'),'stopped')==0
    if doPause==1 % pause
        display('main: while, doPause=1');
        set_param('Autoalign_system','SimulationCommand','pause');
        break
    elseif doPause==2
        display('main: while, doPause=2, (cnt=unchanged');
        break;
    elseif counter>cnt_time
        break;
    else
        pause(.1);
        counter=counter+1;
        m=floor(counter/600);
        s=floor(counter/10-m*60);
        t=strcat(num2str(m,'%02i'),':',num2str(s,'%02i'));
        set(findobj('tag','val_time_exp'),'String',t);
    end
end
if state==3
    if centerx~=centerx_sim || centery~=centery_sim ||...
            diameter~=diameter_sim || loops~=loops_sim ||...
            cycles~=cycles_sim || delay~=delay_sim || read_time~=read_time_sim
        display('main: state=3');
        main(0);
    end
end