function varargout = UserInterface_V1(varargin)
% USERINTERFACE_V1 MATLAB code for UserInterface_V1.fig
%      USERINTERFACE_V1, by itself, creates a new USERINTERFACE_V1 or raises the existing
%      singleton*.
%
%      H = USERINTERFACE_V1 returns the handle to a new USERINTERFACE_V1 or the handle to
%      the existing singleton*.
%
%      USERINTERFACE_V1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in USERINTERFACE_V1.M with the given input arguments.
%
%      USERINTERFACE_V1('Property','Value',...) creates a new USERINTERFACE_V1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UserInterface_V1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UserInterface_V1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UserInterface_V1

% Last Modified by GUIDE v2.5 10-Apr-2017 14:53:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UserInterface_V1_OpeningFcn, ...
                   'gui_OutputFcn',  @UserInterface_V1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before UserInterface_V1 is made visible.
function UserInterface_V1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UserInterface_V1 (see VARARGIN)

% Choose default command line output for UserInterface_V1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UserInterface_V1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%%%%%%%%%%%%%%%%% STARTUP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ensure butons and indicators have the right value
set(handles.ind_sim,'String','OFF');
set(handles.ind_status,'String','IDLE');
set(handles.ind_status,'ForegroundColor','black');
set(handles.txt_err,'Visible','off');

% Enable all buttons
set(handles.btn_on,'Enable','on');
set(handles.btn_on,'Value',1);
set(handles.btn_on,'String','Run');
set(handles.btn_export,'Enable','off');
set(handles.btn_stop,'Enable','on');
% Enable all boxes
set(handles.val_startx,'Enable','on');
set(handles.val_starty,'Enable','on');
set(handles.val_lengthx,'Enable','on');
set(handles.val_lengthy,'Enable','on');
set(handles.val_loops,'Enable','on');
set(handles.val_delay,'Enable','on');
% make all boxes white
set(handles.val_startx,'foregroundColor','white');
set(handles.val_starty,'foregroundColor','white');
set(handles.val_lengthx,'foregroundColor','white');
set(handles.val_lengthy,'foregroundColor','white');
set(handles.val_loops,'foregroundColor','white');
set(handles.val_delay,'foregroundColor','white');

load_system('Autoalign_system.mdl');
set_param('Autoalign_system','SimulationMode','external');

% plot location layout
title(handles.plt_pos,'Location matrix');
axis(handles.plt_pos,[-100 1100 -100 1100]);
grid(handles.plt_pos,'on');
grid(handles.plt_pos,'minor');
xlabel(handles.plt_pos,'X [um]');
ylabel(handles.plt_pos,'Y [um]');

% plot power layout
title(handles.plt_pow,'Power readings');
axis(handles.plt_pow,[0 15 0 3]);
grid(handles.plt_pow,'on');
xlabel(handles.plt_pow,'time [sec]');
ylabel(handles.plt_pow,'Power [uW]');

% --- Outputs from this function are returned to the command line.
function varargout = UserInterface_V1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%% BUTTONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in btn_on.
function btn_on_Callback(hObject, eventdata, handles)
% hObject    handle to btn_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% state=str2double(get(hObject,'Value'));
state=get(hObject,'Value');
display(state);
%% declare local variables
startx_obj=find_system('Autoalign_system','BlockType','Constant','Name','start_x');
starty_obj=find_system('Autoalign_system','BlockType','Constant','Name','start_y');
lengthx_obj=find_system('Autoalign_system','BlockType','Constant','Name','length_x');
lengthy_obj=find_system('Autoalign_system','BlockType','Constant','Name','length_y');
loops_obj=find_system('Autoalign_system','BlockType','Constant','Name','loops');
delay_obj=find_system('Autoalign_system','BlockType','Constant','Name','stepsize');
on_obj=find_system('Autoalign_system','BlockType','Constant','Name','on');
switch state
    case 0 % Current: Stop
        set(handles.btn_on,'String','Run');
    case 1 % Current: Run
        set(handles.btn_on,'String','Pause');
    case 2 % Current: Pause 
        set(handles.btn_on,'String','Unpause');
    case 3 % Current: Unpause
        set(handles.btn_on,'String','Pause');
end
%% run function
if state==0 % stop simulation
    display('Stopping (state=0)');
    set(handles.btn_on,'Enable','on');
    set_param(on_obj{1},'Value','0');
    set(handles.ind_status,'String','STOPPING');
    set(handles.ind_status,'foregroundColor','red');
    set(handles.txt_err,'String','manually stopped, risk for incorrect data [line 143]');
    set(handles.txt_err,'Visible','on');
    % enable input boxes
    set(handles.val_startx,'Enable','on');
    set(handles.val_starty,'Enable','on');
    set(handles.val_lengthx,'Enable','on');
    set(handles.val_lengthy,'Enable','on');
    set(handles.val_loops,'Enable','on');
    set(handles.val_delay,'Enable','on');
    % make input boxes white
    set(handles.val_startx,'BackgroundColor','white');
    set(handles.val_starty,'BackgroundColor','white');
    set(handles.val_lengthx,'BackgroundColor','white');
    set(handles.val_lengthy,'BackgroundColor','white');
    set(handles.val_loops,'BackgroundColor','white');
    set(handles.val_delay,'BackgroundColor','white');
    set(handles.ind_sim,'String','OFF');
elseif state==2 % PAUSE state
    display('Pausing (state=2)');
%     set(handles.ind_status,'String','ON');
    set_param('Autoalign_system','SimulationCommand','pause');
    % enable input boxes
    set(handles.val_startx,'Enable','on');
    set(handles.val_starty,'Enable','on');
    set(handles.val_lengthx,'Enable','on');
    set(handles.val_lengthy,'Enable','on');
    set(handles.val_loops,'Enable','on');
    set(handles.val_delay,'Enable','on');
    % make input boxes white
    set(handles.val_startx,'BackgroundColor','white');
    set(handles.val_starty,'BackgroundColor','white');
    set(handles.val_lengthx,'BackgroundColor','white');
    set(handles.val_lengthy,'BackgroundColor','white');
    set(handles.val_loops,'BackgroundColor','white');
    set(handles.val_delay,'BackgroundColor','white');
else
    display('Run/resume (state= 1 or 3?');
    set(handles.ind_sim,'String','ON');
    % disable input boxes
    set(handles.val_startx,'Enable','off');
    set(handles.val_starty,'Enable','off');
    set(handles.val_lengthx,'Enable','off');
    set(handles.val_lengthy,'Enable','off');
    set(handles.val_loops,'Enable','off');
    set(handles.val_delay,'Enable','off');
    % load parameters (string)
    startx_str=get(handles.val_startx,'String');
    starty_str=get(handles.val_starty,'String');
    lengthx_str=get(handles.val_lengthx,'String');
    lengthy_str=get(handles.val_lengthy,'String');
    loops_str=get(handles.val_loops,'String');
    delay_str=get(handles.val_delay,'String');

    % convert parameters to double
    startx=str2double(startx_str);
    starty=str2double(starty_str);
    lengthx=str2double(lengthx_str);
    lengthy=str2double(lengthy_str);
    loops=str2double(loops_str);
    delay=str2double(delay_str);

    % check parameters for errors
    errorind=0;
    if contains(startx_str,' ')||contains(startx_str,',')||isempty(startx_str)||isnan(startx)
        set(handles.val_startx,'BackgroundColor','red');
        display('Error in Startx');
        errorind=1;
    end
    if contains(starty_str,' ')||contains(starty_str,',')||isempty(starty_str)||isnan(starty)
        set(handles.val_starty,'BackgroundColor','red');
        display('Error in Starty');
        errorind=1;
    end
    if contains(lengthx_str,' ')||contains(lengthx_str,',')||contains(lengthx_str,'.')||contains(lengthx_str,'-')||isempty(lengthx_str)||isnan(lengthx)
        set(handles.val_lengthx,'BackgroundColor','red');
        display('Error in Lengthx');
        errorind=1;
    end
    if contains(lengthy_str,' ')||contains(lengthy_str,',')||contains(lengthy_str,'.')||contains(lengthy_str,'-')||isempty(lengthy_str)||isnan(lengthy)
        set(handles.val_lengthy,'BackgroundColor','red');
        display('Error in Lengthy');
        errorind=1;
    end
    if contains(loops_str,' ')||contains(loops_str,',')||contains(loops_str,'.')||contains(loops_str,'-')||isempty(loops_str)||isnan(loops)
        set(handles.val_loops,'BackgroundColor','red');
        display('Error in Loops');
        errorind=1;
    end
    if contains(delay_str,' ')||contains(delay_str,',')||contains(delay_str,'.')||contains(delay_str,'-')||isempty(delay_str)||isnan(delay)
        set(handles.val_delay,'BackgroundColor','red');
        display('Error in Delay');
        errorind=1;
    end
    if errorind==0
        limit=floor(lengthx+lengthy)/(4*loops)-floor((lengthx+lengthy)/(4*loops));
        if limit ~=0
            set(handles.val_lengthx,'BackgroundColor',[0.93 0.69 0.13]);
            set(handles.val_lengthy,'BackgroundColor',[0.93 0.69 0.13]);
            set(handles.val_loops,'BackgroundColor',[0.93 0.69 0.13]);
            display('Error in Minlength');
            set(handles.txt_err,'String','Length too short, should be > length/(2*loops)! [line 231]');
            set(handles.txt_err,'Visible','on');
            % enable inputs
            set(handles.val_startx,'Enable','on');
            set(handles.val_starty,'Enable','on');
            set(handles.val_lengthx,'Enable','on');
            set(handles.val_lengthy,'Enable','on');
            set(handles.val_loops,'Enable','on');
            set(handles.val_delay,'Enable','on');
            set(handles.ind_sim,'String','OFF');
            return; % stop simulation
        end
    else
        display('Error handler');
        set(handles.txt_err,'String','One or more parameters are incorrect! [line 243]');
        set(handles.txt_err,'Visible','on');
        % enable inputs
        set(handles.val_startx,'Enable','on');
        set(handles.val_starty,'Enable','on');
        set(handles.val_lengthx,'Enable','on');
        set(handles.val_lengthy,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.ind_sim,'String','OFF');
        return; % stop simulation
    end
    display('No error found (yet)');
    % load sim_inputs
    startx_sim=get_param(startx_obj{1},'Value');
    starty_sim=get_param(starty_obj{1},'Value');
    lengthx_sim=get_param(lengthx_obj{1},'Value');
    lengthy_sim=get_param(lengthy_obj{1},'Value');
    loops_sim=get_param(loops_obj{1},'Value');
    delay_sim=get_param(delay_obj{1},'Value');
    
    % compare sim_in with param
    check=[0 0 0 0 0 0];
    check(1)=isequal(startx,startx_sim);
    check(2)=isequal(starty,starty_sim);
    check(3)=isequal(lengthx,lengthx_sim);
    check(4)=isequal(lengthy,lengthy_sim);
    check(5)=isequal(loops,loops_sim);
    check(6)=isequal(delay,delay_sim);
    if any(check) % changes (RE-)RUN
        display('changes are made (state= 1 or 3?)');
        % update simulink inputs
        set_param(startx_obj{1},'Value',startx_str);
        set_param(starty_obj{1},'Value',starty_str);
        set_param(lengthx_obj{1},'Value',lengthx_str);
        set_param(lengthy_obj{1},'Value',lengthy_str);
        set_param(loops_obj{1},'Value',loops_str);
        set_param(delay_obj{1},'Value',delay_str);
        set_param(on_obj{1},'Value','1');

        % save to appdata
        setappdata(0,'startx',startx);
        setappdata(0,'starty',starty);
        setappdata(0,'lengthx',lengthx);
        setappdata(0,'lengthy',lengthy);
        setappdata(0,'loops',loops);
        setappdata(0,'delay',delay);
        
        % update accuracy
        acc=(lengthx+lengthy)/(4*loops);
        set(handles.val_acc,'String',num2str(acc));
        display('Building...part1');
        % build simulation
        set(handles.btn_on,'Enable','off');
        set(handles.ind_status,'String','CONNECT');
        set(handles.ind_status,'ForegroundColor',[0 0 1]);
        set_param('Autoalign_system','SimulationCommand','connect');
        display('Building...part2');
        set(handles.ind_status,'String','BUILD');
        set(handles.ind_status,'ForegroundColor',[0 0.33 0.67]);
        % start simulation
        set_param('Autoalign_system','SimulationCommand','start');
        set(handles.btn_on,'Enable','on');
        display('Running sim');
        set(handles.ind_status,'String','RUN');
        set(handles.ind_status,'ForegroundColor',[0 0.67 0.33]);
    elseif state==1 % 1st RUN
        display('1st run (state=1)');
        % build simulation
        display('building...part1');
        set(handles.btn_on,'Enable','off');
        set(handles.ind_status,'String','CONNECT');
        set(handles.ind_status,'ForegroundColor',[0 0 1]);
        set_param('Autoalign_system','SimulationCommand','connect');
        display('building...part2');
        set(handles.ind_status,'String','BUILD');
        set(handles.ind_status,'ForegroundColor',[0 0.33 0.67]);
        % start simulation
        set_param('Autoalign_system','SimulationCommand','start');
        display('running sim');
        set(handles.btn_on,'Enable','on');
        set(handles.ind_status,'String','RUN');
        set(handles.ind_status,'ForegroundColor',[0 0.67 0.33]);
    elseif state==3 % no changes, UNPAUSE
        display('nothing changed,unpause (state=3)');
        set_param('Autoalign_system','SimulationCommand','resume');
        display('resuming...');
        set(handles.ind_status,'String','RUN');
        set(handles.ind_status,'ForegroundColor',[0 0.67 0.33]);
    else % unknown state, STOP
        display('What state is this??');
        set_param(on_obj{1},'Value','0');
        set(handles.txt_err,'String','Unknown state reached, simulation is stopping [line 317]');
        set(handles.txt_err,'Visible','on');
        set(handles.ind_sim,'String','OFF');
        return;
    end
end
cnt=0;
display('while not stopped will begin...');
while (strcmp(get_param('Autoalign_system','SimulationStatus'),'stopped')==0)
    % wait for simulation to finish
    pause(.1);
    if cnt<1200 % check for time limit (2 minutes)
        cnt=cnt+1;
        display('.');
        set(handles.val_time,'String',num2str(cnt/10));
    else
        display('I want to BREAK free');
        break;
    end
end
display('END of while');
set(handles.ind_sim,'String','OFF');
set(handles.ind_status,'String','FINISH');
set(handles.ind_status,'ForegroundColor',[0 1 0])
% enable inputs
set(handles.val_startx,'Enable','on');
set(handles.val_starty,'Enable','on');
set(handles.val_lengthx,'Enable','on');
set(handles.val_lengthy,'Enable','on');
set(handles.val_loops,'Enable','on');
set(handles.val_delay,'Enable','on');

if cnt>=1200 % timelimit reached (2 minutes)
    display('Timeout');
    set(handles.txt_err,'String','Time limit is reached [line 343]');
    set(handles.txt_err,'Visible','on');
    set(handles.ind_status,'String','IDLE');
    set(handles.ind_status,'ForegroundColor','black');
    set(handles.btn_on,'Value',1);
    
    return;
elseif strcmp(get_param('Autoalign_system','SimulationStatus'),'terminating')
    % show error in simulation has occured
    display('Error, Error');
    set(handles.txt_err,'String','An error occured while trying to run simulink [line 353]');
    set(handles.txt_err,'Visible','on');
    set(handles.ind_status,'String','IDLE');
    set(handles.ind_status,'ForegroundColor','black');
    set(handles.btn_on,'Value',1);
    return;
end
set(handles.btn_on,'Value',state+1);
display('state+1');
% check output data
errorind=0;
err_sizexy=0;
err_sizept=0;
if isappdata(0,'x_data')
    if isappdata(0,'y_data')
        if isappdata(0,'p_data')
            if isappdata(0,'clk')
                % extract data
                display('all output data OK');
                x=getappdata(0,'x_data');
                y=getappdata(0,'y_data');
                p=getappdata(0,'p_data');
                t=getappdata(0,'clk');
                if ~isequal(size(x),size(y))
                    err_sizexy=1;
                    display('size mismatch [XY]');
                end
                if ~isequal(size(p),size(t))
                    err_sizept=1;
                    display('size mismatch [Pt]');
                end
            else
                errorind=1;
                display('Error clk data');
            end
        else
            errorind=2;
            display('Error P_data');
        end
    else
        errorind=3;
        display('Error Y_data');
    end
else
    errorind=4;
    display('Error X_data');
end
if errorind>0 % error(s) occured
    display('Another error handler');
    set(handles.txt_err,'String','Unable to load output data [line 395]');
    set(handles.txt_err,'Visible','on');
    return;
end
set(handles.btn_export,'Enable','on');
% plot position
skip=0;
if err_sizexy==1 % mismatched size for xy plot
    display('not gonna plot positions');
    set(handles.txt_err,'String','Unable to plot position, size mismatch [x/y] [line 403]');
    set(handles.txt_err,'Visible','on');
    skip=1;
else
    display('gonna plot positions');
    xmin=startx-lengthx/2;
    xmax=startx+lengthx/2+lengthx/loops;
    ymin=starty-lengthy/2;
    ymax=starty+lengthy/2+lengthy/loops;
    plot(handles.plt_pos,x,y);
    axis(handles.plt_pos,[xmin xmax ymin ymax]);
end
% plot power
if err_sizept==1 % mismatched size for pt plot
    display('not gonna plot power');
    set(handles.txt_err,'String','Unable to plot power, size mismatch [p/t] [line 416]');
    set(handles.txt_err,'Visible','on');
    skip=1;
else
    display('gonna plot power');
    plot(handles.plt_pow,t,p);
%     axis(handles.plt_pow,[0 tmax pmin pmax]);
end
% set(handles.btn_export,'Visible','on');
% find highest power location
if skip==1 % skip rest of calculations
    display('skip determine highest power');
    return;
end
display('Determine highest power');
P_high=max(p);
index=find(P_high==p,1);
xindex=x(index,1);
yindex=y(index,1);
setappdata(0,'P_high_time',index);

display('and here the results:...');
% display result
set(handles.val_phigh,'Value',P_high);
set(handles.val_xhigh,'Value',xindex);
set(handles.val_yhigh,'Value',yindex);
set(handles.val_thigh,'Value',index);

% --- Executes on button press in btn_export.
function btn_export_Callback(hObject, eventdata, handles)
% hObject    handle to btn_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display('Export');
display(hObject);
% check output data
err_cnt=0;
if isappdata(0,'x_data')
    if isappdata(0,'y_data')
        if isappdata(0,'p_data')
            if isappdata(0,'clk')
                % extract data
                x=getappdata(0,'x_data');
                y=getappdata(0,'y_data');
                p=getappdata(0,'p_data');
                t=getappdata(0,'clk');
            else
                err_cnt=err_cnt+1;
            end
        else
            err_cnt=err_cnt+1;
        end
    else
        err_cnt=err_cnt+1;
    end
else
    err_cnt=err_cnt+1;
end

if err_cnt>0
    set(handles.txt_err,'String','Failed to import all data');
    set(handles.txt_err,'Visible','on');
    return;
end

[filename,pathname,filter]=uiputfile({'*.xlsx','Excel-Workbook';'*.csv','CSV (Comma-Seperated Value)';'*.*','All Files'},'Export data','Alignment Data.xlsx');
if isequal(filename,0)||isequal(pathname,0)
    set(handles.txt_err,'String','Export cancelled');
    set(handles.txt_err,'Visible','on');
    return;
end
[f,fname,fext]=fileparts(filename);
m=[t,x,y,p];
header={'Time','X-value','Y-value','Power'};
switch filter
    case 1 % *.xlsx
        full=fullfile(pathname,[fname,'.xlsx']);
        xlswrite(full,header,'Sheet1','A1');
        xlswrite(full,m,'Sheet1','A2');
        set(handles.ind_status,'String','To *.xlsx');
    case 2 % *.csv
        full=fullfile(pathname,[fname,'.csv']);
        mat=[header;num2cell(m)];
        csvwrite(full,mat);
        set(handles.ind_status,'String','To *.csv');
    otherwise % *.*
        if fext=='.xlsx'
            xlswrite(full,header,'Sheet1','A1');
            xlswrite(full,m,'Sheet1','A2');
            set(handles.ind_status,'String','To *.xlsx');
        elseif fext=='.csv'
            full=fullfile(pathname,[fname,'.csv']);
            csvwrite(full,mat);
            set(handles.ind_status,'String','To *.csv');
        else
            set(handles.txt_err,'String','Unable to save with current extension');
            set(handles.txt_err,'Visible','on');
            return;
        end
end

% --- Executes on button press in btn_stop.
function btn_stop_Callback(hObject, eventdata, handles)
% hObject    handle to btn_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% display(hObject);
display('STOP STOP STOP');
set(handles.ind_status,'String','STOPPING');
set(handles.ind_status,'ForegroundColor',[0.5 0.5 0.5]);
% set(handles.btn_stop,'Enable','off');
btn_on_Callback(0,'','');
if strcmp(get_param('Autoalign_system','SimulationStatus'),'building')
    set(handles.txt_err,'String','Simulation can''t be stopped when building, it will stop as soon as possible, please wait.');
else
    set(handles.txt_err,'String','Simulation is manually stopped!');
end

%%%%%%%%%%%%%%%%% SETTING VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function val_startx_Callback(hObject, eventdata, handles)
% hObject    handle to val_startx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_startx as text
%        str2double(get(hObject,'String')) returns contents of val_startx as a double
val=get(hObject,'String');
check=str2double(val);
if ~isnan(check)
    setappdata(0,'startx',check); % Update value in appdata
end
display('new startx');
function val_starty_Callback(hObject, eventdata, handles)
% hObject    handle to val_starty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_starty as text
%        str2double(get(hObject,'String')) returns contents of val_starty as a double
val=get(hObject,'String');
check=str2double(val);
if ~isnan(check)
    setappdata(0,'starty',check); % Update value in appdata
end
display('new starty');
function val_lengthx_Callback(hObject, eventdata, handles)
% hObject    handle to val_lengthx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_lengthx as text
%        str2double(get(hObject,'String')) returns contents of val_lengthx as a double
val=get(hObject,'String');
check=str2double(val);
if ~isnan(check)
    setappdata(0,'lengthx',check); % Update value in appdata
end
display('new lengthx');
function val_lengthy_Callback(hObject, eventdata, handles)
% hObject    handle to val_lengthy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_lengthy as text
%        str2double(get(hObject,'String')) returns contents of val_lengthy as a double
val=get(hObject,'String');
check=str2double(val);
if ~isnan(check)
    setappdata(0,'lengthy',check); % Update value in appdata
end
display('new lengthy');
function val_loops_Callback(hObject, eventdata, handles)
% hObject    handle to val_loops (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_loops as text
%        str2double(get(hObject,'String')) returns contents of val_loops as a double
val=get(hObject,'String');
check=str2double(val);
if ~isnan(check)
    setappdata(0,'loops',check); % Update value in appdata
end
display('new loops');
function val_delay_Callback(hObject, eventdata, handles)
% hObject    handle to val_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_delay as text
%        str2double(get(hObject,'String')) returns contents of val_delay as a double
val=get(hObject,'String');
check=str2double(val);
if ~isnan(check)
    setappdata(0,'delay',check); % Update value in appdata
end
display('new delay');
%%%%%%%%%%%%%%%%% SHOWING VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function val_acc_Callback(hObject, eventdata, handles)
% hObject    handle to val_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_acc as text
%        str2double(get(hObject,'String')) returns contents of val_acc as a double
display('acc?');
function val_time_Callback(hObject, eventdata, handles)
% hObject    handle to val_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_time as text
%        str2double(get(hObject,'String')) returns contents of val_time as a double
display('time?');
function val_sample_Callback(hObject, eventdata, handles)
% hObject    handle to val_sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_sample as text
%        str2double(get(hObject,'String')) returns contents of val_sample as a double
display('sample?');
function val_phigh_Callback(hObject, eventdata, handles)
% hObject    handle to val_phigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display('pHigh?');
% Hints: get(hObject,'String') returns contents of val_phigh as text
%        str2double(get(hObject,'String')) returns contents of val_phigh as a double

function val_thigh_Callback(hObject, eventdata, handles)
% hObject    handle to val_thigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display('tHigh?');
% Hints: get(hObject,'String') returns contents of val_thigh as text
%        str2double(get(hObject,'String')) returns contents of val_thigh as a double

function val_xhigh_Callback(hObject, eventdata, handles)
% hObject    handle to val_xhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display('xHigh');
% Hints: get(hObject,'String') returns contents of val_xhigh as text
%        str2double(get(hObject,'String')) returns contents of val_xhigh as a double

function val_yhigh_Callback(hObject, eventdata, handles)
% hObject    handle to val_yhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display('yHigh');
% Hints: get(hObject,'String') returns contents of val_yhigh as text
%        str2double(get(hObject,'String')) returns contents of val_yhigh as a double

%%%%%%%%%%%%%%%%%% VAL_CREATEFCN'S %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function val_startx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_startx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_starty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_starty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_lengthx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_lengthx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_lengthy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_lengthy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_loops_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_loops (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_acc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_sample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_phigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_phigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_thigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_thigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_xhigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_xhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_yhigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_yhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
