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

% Last Modified by GUIDE v2.5 10-Apr-2017 10:09:18

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

%ensure butons and indicators have the right value
set(handles.btn_on,'Value',0);
set(handles.ind_ena,'String','OFF');
set(handles.ind_status,'String','IDLE');
set(handles.ind_status,'ForegroundColor','black');
set(handles.ind_stop,'String','');

load_system('Autoalign_system.mdl');

% plot location layout
title(handles.plt_xypos,'Location matrix');
axis(handles.plt_xypos,[-100 1100 -100 1100]);
grid(handles.plt_xypos,'on');
grid(handles.plt_xypos,'minor');
xlabel(handles.plt_xypos,'X position');
ylabel(handles.plt_xypos,'Y position');

% plot power layout
title(handles.plt_time,'Power readings');
axis(handles.plt_time,[0 15 0 3]);
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');
xlabel(handles.plt_time,'time [seconds]');
ylabel(handles.plt_time,'Power [uW]');

% UIWAIT makes UserInterface wait for user response (see UIRESUME)
% uiwait(handles.fig_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = UserInterface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_stop.
function btn_stop_Callback(hObject, eventdata, handles)
% hObject    handle to btn_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ind_stop,'String','STOPPING');
set(handles.btn_on,'Enable','off');
set(handles.btn_stop,'Enable','off');
set(handles.btn_export,'Enable','off');
if strcmp(get_param('Autoalign_system','SimulationStatus'),'running')
    set(handles.ind_stop,'ForegroundColor',[0.85 0.33 0.1]);
    on_obj=find_system('Autoalign_system','BlockType','Constant','Name','on');
    set_param(on_obj{1},'Value','0');
else
    set(handles.ind_stop,'ForegroundColor',[0.64 0.08 0.18]);
    set_param('Autoalign_system','SimulationCommand','stop');
end
while (strcmp(get_param('Autoalign_system','SimulationStatus'),'terminated')==0)
    % wait for simulation to finish
    pause(.1); % pause 0.1 second
    if cnt<1200 % check time limit (2 minutes)
        cnt=cnt+1;
    else
        break; % time limit reached
    end
end
set(handles.ind_stop,'String','STOPPED!');
if cnt>=1200
    set(handles.ind_stop,'ForegroundColor',[0.85 0.33 0.1]);
else
    set(handles.ind_stop,'ForegroundColor',[0.64 0.08 0.18]);
end
% enable inputs
set(handles.val_startx,'Enable','on');
set(handles.val_starty,'Enable','on');
set(handles.val_lengthx,'Enable','on');
set(handles.val_lengthy,'Enable','on');
set(handles.val_loops,'Enable','on');
set(handles.val_delay,'Enable','on');
set(handles.btn_on,'Enable','on');
set(handles.btn_stop,'Enable','on');
set(handles.btn_export,'Enable','on');
% --- end of btn_stop_callback

% --- Executes on button press in btn_on. ---
function btn_on_Callback(hObject, eventdata, handles)
% hObject    handle to btn_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btn_on
state=get(hObject,'Value');

switch state
    case 1 % first run (no pauses occured)
        main(state)
    case 2 % pause (still running)
        
    case 3 % resume (pause has occured)
        
    otherwise % unknown state/stop 
        
end

if state==1 % START RUNNING
    set(handles.ind_ena,'String','ON');
%     set(handles.ind_status,'String','PREPARING');
%     set(handles.ind_status,'ForegroundColor','black');
    set(handles.txt_err,'Visible','off');
    set(handles.btn_export,'Enable','off');
    
    startx_str=get(handles.val_startx,'String');
    starty_str=get(handles.val_starty,'String');
    lengthx_str=get(handles.val_lengthx,'String');
    lengthy_str=get(handles.val_lengthy,'String');
    loops_str=get(handles.val_loops,'String');
    delay_str=get(handles.val_delay,'String');
    
    % check for input errors
    error=[0 0 0 0 0 0];
    if contains(startx_str,' ')||contains(startx_str,',')||isempty(startx_str)||isnan(str2double(startx_str))
        set(handles.val_startx,'BackgroundColor','red');
        error(1:1)=1;
    end
    if contains(starty_str,' ')||contains(starty_str,',')||isempty(starty_str)||isnan(str2double(starty_str))
        set(handles.val_starty,'BackgroundColor','red');
        error(1,2)=1;
    end
    if contains(lengthx_str,' ')||contains(lengthx_str,',')||contains(lengthx_str,'.')||contains(lengthx_str,'-')||isempty(lengthx_str)||isnan(str2double(lengthx_str))
        set(handles.val_lengthx,'BackgroundColor','red');
        error(1,3)=1;
    end
    if contains(lengthy_str,' ')||contains(lengthy_str,',')||contains(lengthy_str,'.')||contains(lengthy_str,'-')||isempty(lengthy_str)||isnan(str2double(lengthy_str))
        set(handles.val_lengthy,'BackgroundColor','red');
        error(1,4)=1;
    end
    if contains(loops_str,' ')||contains(loops_str,',')||contains(loops_str,'.')||contains(loops_str,'-')||isempty(loops_str)||isnan(str2double(loops_str))
        set(handles.val_loops,'BackgroundColor','red');
        error(1,5)=1;
    end
    if contains(delay_str,' ')||contains(delay_str,',')||contains(delay_str,'.')||contains(delay_str,'-')||isempty(delay_str)||isnan(str2double(delay_str))
        set(handles.val_delay,'BackgroundColor','red');
        error(1,6)=1;
    end
    if error(1,3)==0&&error(1,4)==0&&error(1,5)==0
        limit=floor(str2double(lengthx_str)+str2double(lengthy_str))/(4*str2double(loops_str))-floor((str2double(lengthx_str)+str2double(lengthy_str))/(4*str2double(loops_str)));
        if limit~=0
            set(handles.val_lengthx,'BackgroundColor',[0.93 0.69 0.13]);
            set(handles.val_lengthy,'BackgroundColor',[0.93 0.69 0.13]);
            set(handles.val_loops,'BackgroundColor',[0.93 0.69 0.13]);
        end
    end
    if any(error)
        set(handles.txt_err,'Visible','on');
        set(handles.txt_err,'String','One or more parameters are incorrect');
        set(handles.ind_ena,'String','OFF');
        set(handles.ind_status,'String','IDLE');
        set(handles.ind_status,'ForegroundColor','green');
        set(handles.btn_on,'Value',0);
        return;
    end
    % make sure all input fields have their normal color (white)
    set(handles.val_startx,'BackgroundColor','white');
    set(handles.val_starty,'BackgroundColor','white');
    set(handles.val_lengthx,'BackgroundColor','white');
    set(handles.val_lengthy,'BackgroundColor','white');
    set(handles.val_loops,'BackgroundColor','white');
    set(handles.val_delay,'BackgroundColor','white');
    
    
    % convert string to doubles
    startx=str2double(startx_str);
    starty=str2double(starty_str);
    lengthx=str2double(lengthx_str);
    lengthy=str2double(lengthy_str);
    loops=str2double(loops_str);
    delay=str2double(delay_str);
    
    % save data to appdata
    setappdata(0,'startx',startx);
    setappdata(0,'starty',starty);
    setappdata(0,'lengthx',lengthx);
    setappdata(0,'lengthy',lengthy);
    setappdata(0,'loops',loops);
    setappdata(0,'delay',delay);
    
    % find simulink inputs
    startx_obj=find_system('Autoalign_system','BlockType','Constant','Name','start_x');
    starty_obj=find_system('Autoalign_system','BlockType','Constant','Name','start_y');
    lengthx_obj=find_system('Autoalign_system','BlockType','Constant','Name','length_x');
    lengthy_obj=find_system('Autoalign_system','BlockType','Constant','Name','length_y');
    loops_obj=find_system('Autoalign_system','BlockType','Constant','Name','loops');
    delay_obj=find_system('Autoalign_system','BlockType','Constant','Name','stepsize');
    on_obj=find_system('Autoalign_system','BlockType','Constant','Name','on');
    
    % update simulink inputs
    set_param(startx_obj{1},'Value',startx_str);
    set_param(starty_obj{1},'Value',starty_str);
    set_param(lengthx_obj{1},'Value',lengthx_str);
    set_param(lengthy_obj{1},'Value',lengthy_str);
    set_param(loops_obj{1},'Value',loops_str);
    set_param(delay_obj{1},'Value',delay_str);
    set_param(on_obj{1},'Value','1');
    
    % update accuracy
    acc=(lengthx+lengthy)/(4*loops);
    set(handles.val_acc,'String',num2str(acc));
    
    % temporary disable inputs
    set(handles.val_startx,'Enable','off');
    set(handles.val_starty,'Enable','off');
    set(handles.val_lengthx,'Enable','off');
    set(handles.val_lengthy,'Enable','off');
    set(handles.val_loops,'Enable','off');
    set(handles.val_delay,'Enable','off');
    
    % start/build/run simulink
%     set_param('Autoalign_system','SimulationMode','normal');
    set_param('Autoalign_system','SimulationMode','external');
    set(handles.ind_status,'String','CONNECTING');
    set(handles.ind_status,'ForegroundColor',[0 0 1]);
    set_param('Autoalign_system','SimulationCommand','connect');
    set(handles.ind_status,'String','BUILDING');
    set(handles.ind_status,'ForegroundColor',[0 0.33 0.67]);
    set_param('Autoalign_system','SimulationCommand','start');
    set(handles.ind_status,'String','RUNNING');
    set(handles.ind_status,'ForegroundColor',[0 0.67 0.33]);
    cnt=0;
    while (strcmp(get_param('Autoalign_system','SimulationStatus'),'stopped')==0)
        % wait for simulation to finish
        pause(.1); % pause 0.1 second
        if cnt<1200 % check time limit (2 minutes)
            cnt=cnt+1;
            set(handles.val_time,'String',num2str(cnt/10));
        else
            break; % time limit reached
        end
    end
    set(handles.ind_status,'String','FINISHED');
    set(handles.ind_status,'ForegroundColor',[0 1 0])
    if cnt>=1200
        % show timelimit is reached (2 minutes)
        set(handles.txt_err,'String','Time limit is reached');
        set(handles.txt_err,'Visible','on');
        set(handles.ind_ena,'String','OFF');
        set(handles.ind_status,'String','IDLE');
        set(handles.ind_status,'ForegroundColor','black');
        set(handles.btn_on,'Value',0);
        return;
    elseif strcmp(get_param('Autoalign_system','SimulationStatus'),'terminating')
        % show error in simulation has occured
        set(handles.txt_err,'String','An error occured while trying to run simulink');
        set(handles.txt_err,'Visible','on');
        set(handles.ind_ena,'String','OFF');
        set(handles.ind_status,'String','IDLE');
        set(handles.ind_status,'ForegroundColor','green');
        set(handles.btn_on,'Value',0);
        return;
    end
    % enable inputs
    set(handles.val_startx,'Enable','on');
    set(handles.val_starty,'Enable','on');
    set(handles.val_lengthx,'Enable','on');
    set(handles.val_lengthy,'Enable','on');
    set(handles.val_loops,'Enable','on');
    set(handles.val_delay,'Enable','on');
    
    % check output data
    error=[0 0 0 0 0 0];
    errortxt=['' '' '' '' '' ''];
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
                    error(1,1)=1;
%                     errortxt(1,1)='t';
                end
            else
                error(1,2)=1;
%                 errortxt(1,2)='p';
            end
        else
            error(1,3)=1;
%             errortxt(1,3)='y';
        end
    else
        error(1,4)=1;
%         errortxt(1,4)='x';
    end
    if ~isequal(size(x),size(y))
        error(1,5)=1;
%         errortxt(1,5)='size_xy';
    end
    if ~isequal(size(t),size(p))
        error(1,6)=1;
%         errortxt(1,6)='size_tp';
    end
    
    % plot position
    if error(1,3)==0&&error(1,4)==0&&error(1,5)==0
        % appdata y & appdata x = filled, xy are same size
        % set boundaries
        xmin=startx-lengthx/2;
        xmax=startx+lengthx/2+lengthx/loops;
        ymin=starty-lengthy/2;
        ymax=starty+lengthy/2+lengthy/loops;
        % create plot
        plot(handles.plt_xypos,x,y);
        title(handles.plt_xypos,'Location matrix');
        axis(handles.plt_xypos,[xmin xmax ymin ymax]);
        grid(handles.plt_xypos,'on');
        grid(handles.plt_xypos,'minor');
        xlabel(handles.plt_xypos,'X position');
        ylabel(handles.plt_xypos,'Y position');
    else
        set(handles.txt_err,'String','Unable to plot position');
        set(handles.txt_err,'Visible','on');
    end
    
    % plot power
    if error(1,1)==0&&error(1,2)==0&&error(1,6)==0
        % appdata t & appdata p = filled, tp are same size
        % set boundaries
        tmin=0;
        tmax=max(t);
        pmin=0;
        if max(p)==0 % make sure range of P > 0
            pmax=0.1;
        else
            pmax=max(p);
        end
        % create plot
        plot(handles.plt_time,t,p);
        title(handles.plt_time,'Power readings');
        axis(handles.plt_time,[tmin tmax pmin pmax]);
        grid(handles.plt_time,'on');
        grid(handles.plt_time,'minor');
        xlabel(handles.plt_time,'time [seconds]');
        ylabel(handles.plt_time,'Power [uW]');
    else
%         txt=strcat('Unable to plot position because of: ',errortxt(1,1),'/',errortxt(1,2),'/',errortxt(1,6));
        set(handles.txt_err,'String','Unable to plot power');
        set(handles.txt_err,'Visible','on');
    end
    % find highest power reading
    high_pow=max(p);
    index=find(high_pow==p,1);
    xloc=x(index,1);
    yloc=y(index,1);
    
    % save locations
    setappdata(0,'t_high',index);
    
    % view location
    set(handles.val_pow,'Value',high_pow);
    set(handles.val_xi,'Value',xloc);
    set(handles.val_yi,'Value',yloc);
    set(handles.val_ti,'Value',index);
    
    % finishing touches
    set(handles.btn_on,'Value',0);
    set(handles.ind_ena,'String','OFF');
    set(handles.ind_status,'String','IDLE');
    set(handles.ind_status,'ForegroundColor','black');

elseif state==0
    % disable system
    set(handles.ind_ena,'String','OFF');
    obj=find_system('Autoalign_system','BlockType','Constant','Name','on');
    set_param(obj{1},'Value','0');
    pause(1);
    if strcmp(get_param('Autoalign_system','SimulationStatus'),'stopped')==0
        set_param('Autoalign_system','SimulationCommand','stop');
        cnt=0;
        while(strcmp(get_param('Autoalign_system','SimulationStatus'),'stopped')==0)
            if cnt<1200
                pause(.1);
                cnt=cnt+1;
                set(handles.ind_status,'String','STOPPING');
            else
                break;
            end
        end
        if cnt>=1200
            set(handles.txt_err,'String','Time limit is reached');
            set(handles.ind_status,'ForegroundColor',[0.5 0.5 0.5]);
            return;
        end
    end
    set(handles.ind_status,'String','STOPPED');
    set(handles.ind_status,'ForegroundColor',[1 0 0]);
    % enable inputs
    set(handles.val_startx,'Enable','on');
    set(handles.val_starty,'Enable','on');
    set(handles.val_lengthx,'Enable','on');
    set(handles.val_lengthy,'Enable','on');
    set(handles.val_loops,'Enable','on');
    set(handles.val_delay,'Enable','on');
    % make sure all input fields have their normal color (white)
    set(handles.val_startx,'BackgroundColor','white');
    set(handles.val_starty,'BackgroundColor','white');
    set(handles.val_lengthx,'BackgroundColor','white');
    set(handles.val_lengthy,'BackgroundColor','white');
    set(handles.val_loops,'BackgroundColor','white');
    set(handles.val_delay,'BackgroundColor','white');
    % reset buttons & texts
    set(handles.txt_err,'String','Simulation intterrupted, no data is plotted');
    set(handles.txt_err,'Visible','on');
    set(handles.ind_status,'String','IDLE');
    set(handles.ind_status,'ForegroundColor','green');
else
    set(handles.txt_err,'String','unknown state (run button)');
    set(handles.txt_err,'Visible','on');
end
% --- end of btn_on_callback ---

% --- Executes on button press in btn_export. ---
function btn_export_Callback(hObject, eventdata, handles)
% hObject    handle to btn_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.txt_err,'Visible','off');
% check output data
error=[0 0 0 0 0];
errortxt=['' '' '' '' ''];
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
                error(1,1)=1;
                errortxt(1,1)='t';
            end
        else
            error(1,2)=1;
            errortxt(1,2)='p';
        end
    else
        error(1,3)=1;
        errortxt(1,3)='y';
    end
else
    error(1,4)=1;
    errortxt(1,4)='x';
end
if ~isequal(size(x),size(y),size(p),size(t))
    error(1,5)=1;
    errortxt(1,5)='size';
end

if any(error)
    txt=strcat('Failed to import: ',errortxt(1,1),'/',errortxt(1,2),'/',errortxt(1,3),'/',errortxt(1,4),'/',errortxt(1,5));
    set(handles.txt_err,'String',txt);
    set(handles.txt_err,'Visible','on');
    return;
end

x=getappdata(0,'x_data');
y=getappdata(0,'y_data');
p=getappdata(0,'p_data');
t=getappdata(0,'clk');
% header={'Time','X','Y','Power'};
[filename,pathname,filter]=uiputfile({'*.xlsx','Excel-Workbook';'*.csv','CSV (Comma-Seperated Value)';'*.*','All Files'},'Export data','Alignment Data.xlsx');
if isequal(filename,0)||isequal(pathname,0)
    set(handles.txt_err,'String','Export is cancelled');
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
        set(handles.ind_stop,'String','To *.xlsx');
    case 2 % *.csv
        full=fullfile(pathname,[fname,'.csv']);
        mat=[header;num2cell(m)];
        csvwrite(full,mat);
        set(handles.ind_stop,'String','To *.csv');
    otherwise % *.*
        if fext=='.xlsx'
            xlswrite(full,header,'Sheet1','A1');
            xlswrite(full,m,'Sheet1','A2');
            set(handles.ind_stop,'String','To *.xlsx');
        elseif fext=='.csv'
            full=fullfile(pathname,[fname,'.csv']);
            csvwrite(full,mat);
            set(handles.ind_stop,'String','To *.csv');
        else
            set(handles.txt_err,'String','Unable to save with current extension');
            set(handles.txt_err,'Visible','on');
            return;
        end
end
% --- end of btn_export_callback ---

% --- Executes on value change in val_startx. ---
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
% --- end of val_startx_callback ---

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
% --- end of val_startx_createfcn ---

% --- Executes on value change in val_starty. ---
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
% --- end of val_starty_callback ---

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
% --- end of val_starty_createfcn ---

% --- Executes on value change in val_lengthx. ---
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
% --- end of val_lengthx_callback ---

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
% --- end of val_lengthx_createfcn ---

% --- Executes on value change in val_lengthy. ---
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
% --- end of val_lengthy_callback ---

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
% --- end of val_lengthy_createfcn ---

% --- Executes on value change in val_loops. ---
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
% --- end of val_loops_callback ---

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
% --- end of val_loops_createfcn ---

% --- Executes on value change in val_delay. ---
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
% --- end of val_delay_callback ---

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
% --- end of val_delay_createfcn ---

function val_acc_Callback(hObject, eventdata, handles)
% hObject    handle to val_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_acc as text
%        str2double(get(hObject,'String')) returns contents of val_acc as a double


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

function val_time_Callback(hObject, eventdata, handles)
% hObject    handle to val_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_time as text
%        str2double(get(hObject,'String')) returns contents of val_time as a double


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



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function val_pow_Callback(hObject, eventdata, handles)
% hObject    handle to val_pow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_pow as text
%        str2double(get(hObject,'String')) returns contents of val_pow as a double


% --- Executes during object creation, after setting all properties.
function val_pow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_pow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function val_ti_Callback(hObject, eventdata, handles)
% hObject    handle to val_ti (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_ti as text
%        str2double(get(hObject,'String')) returns contents of val_ti as a double


% --- Executes during object creation, after setting all properties.
function val_ti_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_ti (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function val_xi_Callback(hObject, eventdata, handles)
% hObject    handle to val_xi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_xi as text
%        str2double(get(hObject,'String')) returns contents of val_xi as a double


% --- Executes during object creation, after setting all properties.
function val_xi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_xi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function val_yi_Callback(hObject, eventdata, handles)
% hObject    handle to val_yi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_yi as text
%        str2double(get(hObject,'String')) returns contents of val_yi as a double


% --- Executes during object creation, after setting all properties.
function val_yi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_yi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
