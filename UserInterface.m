function varargout = UserInterface(varargin)
% USERINTERFACE MATLAB code for UserInterface.fig
%      USERINTERFACE, by itself, creates a new USERINTERFACE or raises the existing
%      singleton*.
%
%      H = USERINTERFACE returns the handle to a new USERINTERFACE or the handle to
%      the existing singleton*.
%
%      USERINTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in USERINTERFACE.M with the given input arguments.
%
%      USERINTERFACE('Property','Value',...) creates a new USERINTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UserInterface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UserInterface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UserInterface

% Last Modified by GUIDE v2.5 13-Apr-2017 14:22:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UserInterface_OpeningFcn, ...
                   'gui_OutputFcn',  @UserInterface_OutputFcn, ...
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


% --- Executes just before UserInterface is made visible.
function UserInterface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UserInterface (see VARARGIN)

% Choose default command line output for UserInterface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UserInterface wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global state_on;
%%%%%%%%%%%%%%%%% STARTUP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ensure butons and indicators have the right value
set(handles.ind_sim,'String','OFF');
set(handles.ind_status,'String','IDLE');
set(handles.ind_status,'ForegroundColor',[0 0 0]);% black
set(handles.txt_err,'Visible','off');

% init BTN'S
set(handles.btn_on,'String','Run');
set(handles.btn_on,'Enable','on');
set(handles.btn_export,'Enable','off');
set(handles.btn_stop,'Enable','on');
% init BOXES
set(handles.val_startx,'Enable','on');
set(handles.val_starty,'Enable','on');
set(handles.val_lengthx,'Enable','on');
set(handles.val_lengthy,'Enable','on');
set(handles.val_loops,'Enable','on');
set(handles.val_delay,'Enable','on');

set(handles.val_startx,'backgroundColor','white');
set(handles.val_starty,'backgroundColor','white');
set(handles.val_lengthx,'backgroundColor','white');
set(handles.val_lengthy,'backgroundColor','white');
set(handles.val_loops,'backgroundColor','white');
set(handles.val_delay,'backgroundColor','white');

% init TEXTS
set(handles.txt_err,'Visible','off');
set(handles.ind_sim,'String','OFF');
set(handles.ind_status,'String','IDLE');
set(handles.ind_status,'Foregroundcolor','black');

% DEFAULT DATA
setappdata(0,'startx',400);
setappdata(0,'starty',400);
setappdata(0,'lengthx',1000);
setappdata(0,'lengthy',1000);
setappdata(0,'loops',5);
setappdata(0,'delay',16);
state_on=1;

% prepare Simulink
load_system('Autoalign_system.mdl');
% set_param('Autoalign_system','SimulationMode','external');
set_param('Autoalign_system','SimulationMode','normal'); % TEMP settings

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
function varargout = UserInterface_OutputFcn(hObject, eventdata, handles) 
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
global state_on;
% disable all
set(handles.btn_on,'Enable','off');
set(handles.btn_export,'Enable','off');
set(handles.val_startx,'Enable','off');
set(handles.val_starty,'Enable','off');
set(handles.val_lengthx,'Enable','off');
set(handles.val_lengthy,'Enable','off');
set(handles.val_loops,'Enable','off');
set(handles.val_delay,'Enable','off');
set(handles.txt_err,'Visible','off');
switch state_on
    case 0 % Stopping
        % show that stop is in progress
        set(handles.ind_status,'String','STOPPING');
        set(handles.ind_status,'foregroundColor',[0.5 0 0]);
        [result,changes]=main(0);
        state_on=1;
    case 1 % Building
        display('state=building');
        set(handles.btn_on,'Enable','off');
        set(handles.btn_on,'String','Wait...');
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
            set(handles.val_startx,'BackgroundColor',[1 0 0]);% red
            errorind=1;
        end
        if contains(starty_str,' ')||contains(starty_str,',')||isempty(starty_str)||isnan(starty)
            set(handles.val_starty,'BackgroundColor',[1 0 0]);% red
            errorind=1;
        end
        if contains(lengthx_str,' ')||contains(lengthx_str,',')||contains(lengthx_str,'.')||contains(lengthx_str,'-')||isempty(lengthx_str)||isnan(lengthx)
            set(handles.val_lengthx,'BackgroundColor',[1 0 0]);% red
            errorind=1;
        end
        if contains(lengthy_str,' ')||contains(lengthy_str,',')||contains(lengthy_str,'.')||contains(lengthy_str,'-')||isempty(lengthy_str)||isnan(lengthy)
            set(handles.val_lengthy,'BackgroundColor',[1 0 0]);% red
            errorind=1;
        end
        if contains(loops_str,' ')||contains(loops_str,',')||contains(loops_str,'.')||contains(loops_str,'-')||isempty(loops_str)||isnan(loops)
            set(handles.val_loops,'BackgroundColor',[1 0 0]);% red
            errorind=1;
        end
        if contains(delay_str,' ')||contains(delay_str,',')||contains(delay_str,'.')||contains(delay_str,'-')||isempty(delay_str)||isnan(delay)
            set(handles.val_delay,'BackgroundColor',[1 0 0]);% red
            errorind=1;
        end
        if errorind==0 % no errors for input
            limit=floor(lengthx+lengthy)/(4*loops)-floor((lengthx+lengthy)/(4*loops));
            if limit ~= 0 % error in minimum length
                set(handles.val_lengthx,'BackgroundColor',[0.93 0.69 0.13]);% orange
                set(handles.val_lengthy,'BackgroundColor',[0.93 0.69 0.13]);% orange
                set(handles.val_loops,'BackgroundColor',[0.93 0.69 0.13]);% orange
                set(handles.txt_err,'String','Length too short, should be > length/(2*loops)! [line 231]');
                set(handles.txt_err,'Visible','on');
                % enable inputs
                set(handles.val_startx,'Enable','on');
                set(handles.val_starty,'Enable','on');
                set(handles.val_lengthx,'Enable','on');
                set(handles.val_lengthy,'Enable','on');
                set(handles.val_loops,'Enable','on');
                set(handles.val_delay,'Enable','on');
                % reset buttons/text
                set(handles.ind_sim,'String','OFF');
                set(handles.btn_on,'String','Run');
                set(handles.btn_on,'Enable','on');
                state_on=1;
                return; % stop simulation
            end
        else
            set(handles.txt_err,'String','One or more parameters are incorrect! [line 243]');
            set(handles.txt_err,'Visible','on');
            % enable inputs
            set(handles.val_startx,'Enable','on');
            set(handles.val_starty,'Enable','on');
            set(handles.val_lengthx,'Enable','on');
            set(handles.val_lengthy,'Enable','on');
            set(handles.val_loops,'Enable','on');
            set(handles.val_delay,'Enable','on');
            % reset buttons/text
            set(handles.ind_sim,'String','OFF');
            set(handles.btn_on,'String','Run');
            set(handles.btn_on,'Enable','on');
            state_on=1;
            return; % stop simulation
        end
        display('data OK');
        % save data to appdata
        setappdata(0,'startx',startx);
        setappdata(0,'starty',starty);
        setappdata(0,'lengthx',lengthx);
        setappdata(0,'lengthy',lengthy);
        setappdata(0,'loops',loops);
        setappdata(0,'delay',delay);
        
        set(handles.ind_sim,'String','ON');
        set(handles.ind_status,'String','BUILD');
        set(handles.ind_status,'ForegroundColor',[0 0.33 0.67]);
        state_on=2;
        [result,changes]=main(1);
    case 2 % Running
        set(handles.btn_on,'String','Pause');
        set(handles.btn_on,'Enable','on');
        set(handles.ind_status,'String','RUN');
        set(handles.ind_status,'ForegroundColor',[0 0.67 0.33]);
        state_on=3;
        [result,changes]=main(2);
    case 3 % Pause
        display('state=pausing');
        set(handles.ind_status,'String','PAUSE');
        set(handles.ind_status,'ForegroundColor',[0.33 0.67 0]);
        [result,changes]=main(3);
        state_on=4;
    case 4 % Unpause
        display('state=unpausing');
        set(handles.btn_on,'String','Pause');
        set(handles.btn_on,'Enable','on');
        set(handles.ind_status,'String','UNPAUSE');
        set(handles.ind_status,'ForegroundColor',[0.33 0.67 0]);
        state_on=3;
        [result,changes]=main(4);
        if changes==1 % changes occured, re-building
            state_on=1;
            [result,changes1]=main(1);
        end
    otherwise
        % make input boxes white
        set(handles.val_startx,'BackgroundColor','white');
        set(handles.val_starty,'BackgroundColor','white');
        set(handles.val_lengthx,'BackgroundColor','white');
        set(handles.val_lengthy,'BackgroundColor','white');
        set(handles.val_loops,'BackgroundColor','white');
        set(handles.val_delay,'BackgroundColor','white');
        [result,changes]=main(0);
        state_on=1;
end
switch result
    case 'build'
        display('result=build');
        state_on=2;
        btn_on_Callback(hObject,eventdata,handles);
        return;
    case 'stopped'
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.btn_export,'Enable','off');
        set(handles.val_startx,'Enable','on');
        set(handles.val_starty,'Enable','on');
        set(handles.val_lengthx,'Enable','on');
        set(handles.val_lengthy,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_status,'String','IDLE');
        set(handles.ind_status,'Foregroundcolor',[0 0 0]);%black
        set(handles.txt_err,'String','Simulation succesfully stopped');
        set(handles.txt_err,'Visible','on');
        moveon=0;
    case 'paused'
        display('result=paused');
        set(handles.btn_on,'Enable','on');
        set(handles.btn_on,'String','Unpause');
        set(handles.val_startx,'Enable','on');
        set(handles.val_starty,'Enable','on');
        set(handles.val_lengthx,'Enable','on');
        set(handles.val_lengthy,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.ind_sim,'String','ON');
        set(handles.ind_status,'String','PAUSED');
        set(handles.ind_status,'Foregroundcolor',[0.33 0.67 0]);
        moveon=1;
    case 'resumed'
        display('result=resumed');
        % end of resume
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.val_startx,'Enable','on');
        set(handles.val_starty,'Enable','on');
        set(handles.val_lengthx,'Enable','on');
        set(handles.val_lengthy,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_status,'String','IDLE');
        set(handles.ind_status,'Foregroundcolor',[0 0 0]);%black
        moveon=1;
    case 'finished'
        display('result=finished');
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.val_startx,'Enable','on');
        set(handles.val_starty,'Enable','on');
        set(handles.val_lengthx,'Enable','on');
        set(handles.val_lengthy,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_status,'String','IDLE');
        set(handles.ind_status,'Foregroundcolor',[0 0 0]);%black
        moveon=1;
    case 'time'
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.btn_export,'Enable','off');
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_status,'String','ERROR');
        set(handles.ind_status,'Foregroundcolor',[1 0 0]);%red
        set(handles.txt_err,'String','Time limit reached, possible that simulation is still running');
        set(handles.txt_err,'Visible','on');
        moveon=0;
    otherwise
        display('result=error');
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.btn_export,'Enable','off');
        set(handles.val_startx,'Enable','on');
        set(handles.val_starty,'Enable','on');
        set(handles.val_lengthx,'Enable','on');
        set(handles.val_lengthy,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_status,'String','IDLE');
        set(handles.ind_status,'Foregroundcolor',[0 0 0]);%black
        set(handles.txt_err,'String','Unexpected result, risk of unreliable data');
        set(handles.txt_err,'Visible','on');
        moveon=0;
end

if moveon==1
    % check output data
    if ~isappdata(0,'x_data')||~isappdata(0,'y_data')||~isappdata(0,'p_data')...
            ||~isappdata(0,'clk')||~isappdata(0,'startx')||~isappdata(0,'starty')...
            ||~isappdata(0,'lengthx')||~isappdata(0,'lengthy')||~isappdata(0,'loops')
        set(handles.txt_err,'String','Unable to load output data');
        set(handles.txt_err,'Visible','on');
        return;
    end
    % extract data
    err_sizexy=0;
    err_sizept=0;
    xdev=getappdata(0,'x_data');
    ydev=getappdata(0,'y_data');
    p=getappdata(0,'p_data');
    t=getappdata(0,'clk');
    startx=getappdata(0,'startx');
    starty=getappdata(0,'starty');
    lengthx=getappdata(0,'lengthx');
    lengthy=getappdata(0,'lengthy');
    loops=getappdata(0,'loops');
    if ~isequal(size(xdev),size(ydev))
        err_sizexy=1;
    end
    if ~isequal(size(p),size(t))
        err_sizept=1;
    end
    skip=0;
    if err_sizexy==1 % size mismatch
        set(handles.txt_err,'String','Unable to plot position, size mismatch [x/y]');
        set(handles.txt_err,'Visible','on');
        skip=1;
    else
        % plot position
        factor=100/4098;
        xpos=xdev.*factor;
        x(:,1)=xpos(:,1)+startx;
        ypos=ydev.*factor;
        y(:,1)=ypos(:,1)+starty;
        xmin=startx-lengthx/2;
        xmax=startx+lengthx/2+lengthx/loops;
        ymin=starty-lengthy/2;
        ymax=starty+lengthy/2+lengthy/loops;
        plot(handles.plt_pos,x,y);
        axis(handles.plt_pos,[xmin xmax ymin ymax]);
    end
    if err_sizept==1 % size mismatch
        set(handles.txt_err,'String','Unable to plot power, size mismatch [p/t]');
        set(handles.txt_err,'Visible','on');
        skip=1;
    else
        % plot power
        plot(handles.plt_pow,t,p);
%         axis(handles.plt_pow,[tmin tmax pmin pmax]);
    end
    set(handles.btn_export,'Visible','on');
    % find highest power location
    if skip==1 % skip rest of calculations
        return;
    end
    P_high=max(p);
    index=find(P_high==p,1);
    xindex=x(index,1);
    yindex=y(index,1);
    setappdata(0,'P_high_time',index);
    % display result
    set(handles.val_phigh,'String',num2str(P_high));
    set(handles.val_xhigh,'String',num2str(xindex));
    set(handles.val_yhigh,'String',num2str(yindex));
    set(handles.val_thigh,'String',num2str(index));
end

% --- Executes on button press in btn_export.
function btn_export_Callback(hObject, eventdata, handles)
% hObject    handle to btn_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check output data
if ~isappdata(0,'x_data')||~isappdata(0,'y_data')||~isappdata(0,'p_data')...
        ||~isappdata(0,'clk')||~isappdata(0,'startx')||~isappdata(0,'starty')...
        ||~isappdata(0,'lengthx')||~isappdata(0,'lengthy')||~isappdata(0,'loops')
    set(handles.txt_err,'String','Unable to load output data');
    set(handles.txt_err,'Visible','on');
    return;
end

[filename,pathname,filter]=uiputfile({'*.xlsx','Excel-Workbook';'*.csv','CSV (Comma-Seperated Value)';'*.*','All Files'},'Export data','Alignment Data.xlsx');
if isequal(filename,0)||isequal(pathname,0)
    % check for cancel
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
            full=fullfile(pathname,[fname,'.xlsx']);
            xlswrite(full,header,'Sheet1','A1');
            xlswrite(full,m,'Sheet1','A2');
            set(handles.ind_status,'String','To *.xlsx');
        elseif fext=='.csv'
            full=fullfile(pathname,[fname,'.csv']);
            mat=[header;num2cell(m)];
            csvwrite(full,mat);
            set(handles.ind_status,'String','To *.csv');
        else
            set(handles.txt_err,'String','Unable to save with current extension');
            set(handles.txt_err,'Visible','on');
        end
end

% --- Executes on button press in btn_stop.
function btn_stop_Callback(hObject, eventdata, handles)
% hObject    handle to btn_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state_on;
set(handles.ind_status,'String','STOPPING');
set(handles.ind_status,'ForegroundColor',[0.5 0.5 0.5]);
% set(handles.btn_stop,'Enable','off');
if strcmp(get_param('Autoalign_system','SimulationStatus'),'building')
    set(handles.txt_err,'String','Simulation is in building mode, please wait until building is finished. The simulaton will stop when possible.');
end
state_on=0;
h=findobj('Tag','btn_on');
btn_on_Callback(h,eventdata,handles);

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
    set(hObject,'backgroundColor',[.5 .5 .5]);% grey
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end

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
    set(hObject,'backgroundColor',[.5 .5 .5]);% grey
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end

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
    set(hObject,'backgroundColor',[.5 .5 .5]);% grey
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end

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
    set(hObject,'backgroundColor',[.5 .5 .5]);% grey
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end

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
    set(hObject,'backgroundColor',[.5 .5 .5]);% grey
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end

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
    set(hObject,'backgroundColor',[.5 .5 .5]);% grey
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end

%%%%%%%%%%%%%%%%% SHOWING VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function val_acc_Callback(hObject, eventdata, handles)
% hObject    handle to val_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_acc as text
%        str2double(get(hObject,'String')) returns contents of val_acc as a double

function val_time_Callback(hObject, eventdata, handles)
% hObject    handle to val_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_time as text
%        str2double(get(hObject,'String')) returns contents of val_time as a double

function val_sample_Callback(hObject, eventdata, handles)
% hObject    handle to val_sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_sample as text
%        str2double(get(hObject,'String')) returns contents of val_sample as a double

function val_phigh_Callback(hObject, eventdata, handles)
% hObject    handle to val_phigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_phigh as text
%        str2double(get(hObject,'String')) returns contents of val_phigh as a double

function val_thigh_Callback(hObject, eventdata, handles)
% hObject    handle to val_thigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_thigh as text
%        str2double(get(hObject,'String')) returns contents of val_thigh as a double

function val_xhigh_Callback(hObject, eventdata, handles)
% hObject    handle to val_xhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_xhigh as text
%        str2double(get(hObject,'String')) returns contents of val_xhigh as a double

function val_yhigh_Callback(hObject, eventdata, handles)
% hObject    handle to val_yhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
