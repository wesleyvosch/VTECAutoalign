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

% Last Modified by GUIDE v2.5 19-Apr-2017 15:04:13

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

%% %% %% %% %% INITIALIZATION %% %% %% %% %%

% clear: DATA
if isappdata(0,'x_data')
    rmappdata(0,'x_data');
end
if isappdata(0,'y_data')
    rmappdata(0,'y_data');
end
if isappdata(0,'p_data')
    rmappdata(0,'p_data');
end
if isappdata(0,'clk')
    rmappdata(0,'clk');
end
if isappdata(0,'x_pos')
    rmappdata(0,'x_pos');
end
if isappdata(0,'y_pos')
    rmappdata(0,'y_pos');
end
if isappdata(0,'centerx')
    rmappdata(0,'centerx');
end
if isappdata(0,'centery')
    rmappdata(0,'centery');
end
if isappdata(0,'diameter')
    rmappdata(0,'diameter');
end
if isappdata(0,'loops')
    rmappdata(0,'loops');
end
if isappdata(0,'delay')
    rmappdata(0,'delay');
end
if isappdata(0,'read_time')
    rmappdata(0,'read_time');
end
if isappdata(0,'approx_time')
    rmappdata(0,'approx_time');
end
if isappdata(0,'Pmax_time')
    rmappdata(0,'Pmax_time');
end

% set text: IND
set(handles.ind_sim,'String','OFF');
set(handles.ind_status,'String','IDLE');
set(handles.ind_status,'ForegroundColor',[0 0 0]);% black
set(handles.txt_err,'Visible','off');

% enable: BTN'S
set(handles.btn_on,'String','Run');
set(handles.btn_on,'Enable','on');
set(handles.btn_export,'Enable','off');
set(handles.btn_stop,'Enable','on');

% enable: BOXES
set(handles.val_centerx,'Enable','on');
set(handles.val_centery,'Enable','on');
set(handles.val_diameter,'Enable','on');
set(handles.val_loops,'Enable','on');
set(handles.val_delay,'Enable','on');
set(handles.val_tRead,'Enable','on');

% set bg: BOXES
set(handles.val_centerx,'backgroundColor','white');
set(handles.val_centery,'backgroundColor','white');
set(handles.val_diameter,'backgroundColor','white');
set(handles.val_loops,'backgroundColor','white');
set(handles.val_delay,'backgroundColor','white');
set(handles.val_tRead,'backgroundColor','white');

% set value: BOXES
set(handles.val_centerx,'String','0');
set(handles.val_centery,'String','0');
set(handles.val_diameter,'String','50');
set(handles.val_loops,'String','3');
set(handles.val_delay,'String','16');
set(handles.val_tRead,'String','16');

set(handles.val_acc,'String','...');
set(handles.val_min,'String','...');
set(handles.val_max,'String','...');
set(handles.val_phigh,'String','...');
set(handles.val_xhigh,'String','...');
set(handles.val_yhigh,'String','...');
set(handles.val_thigh,'String','...');

% set value: DATA
setappdata(0,'centerx',0);
setappdata(0,'centery',0);
setappdata(0,'diameter',50);
setappdata(0,'loops',3);
setappdata(0,'delay',16);
setappdata(0,'read_time',16);
state_on=1;

% set text: IND
set(handles.txt_err,'Visible','off');
set(handles.ind_sim,'String','OFF');
set(handles.ind_status,'String','IDLE');
set(handles.ind_status,'Foregroundcolor','black');

% load: SIMULINK
load_system('Autoalign_system.mdl');
set_param('Autoalign_system','SimulationMode','external');
% set_param('Autoalign_system','SimulationCommand','connect');
% set_param('Autoalign_system','SimulationMode','normal'); % TEMP settings

% plot: location
% yyaxis(handles.plt_pos,'left');
cla(handles.plt_pos);
title(handles.plt_pos,'Location matrix');
axis(handles.plt_pos,[-30 30 -30 30]);
grid(handles.plt_pos,'on');
grid(handles.plt_pos,'minor');
xlabel(handles.plt_pos,'X [um]');
ylabel(handles.plt_pos,'Y [um]');

% plot: data in t-domain
yyaxis(handles.plt_pow,'left');
cla(handles.plt_pow);
title(handles.plt_pow,'Data in time domain');
xlabel(handles.plt_pow,'time [seconds]');
grid(handles.plt_pow,'on');
axis(handles.plt_pow,[0 15 0 3]);
ylabel(handles.plt_pow,'Power [uW]');
yyaxis(handles.plt_pow,'right');
cla(handles.plt_pow);
axis(handles.plt_pow,[0 15 -30 30]);
ylabel(handles.plt_pow,'position [um]');


%% %% %% %% %% MAIN FUNCTION %% %% %% %% %%

% --- Outputs from this function are returned to the command line.
function varargout = UserInterface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% %% %% %% %% BUTTON CALLBACKS %% %% %% %% %% 

% --- Executes on button press in btn_on.
function btn_on_Callback(hObject, eventdata, handles)
% hObject    handle to btn_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% state=str2double(get(hObject,'Value'));
global state_on;
% disable: BTN'S
set(handles.btn_on,'Enable','off');
set(handles.btn_export,'Enable','off');
set(handles.val_centerx,'Enable','off');
set(handles.val_centery,'Enable','off');
set(handles.val_diameter,'Enable','off');
set(handles.val_loops,'Enable','off');
set(handles.val_delay,'Enable','off');
set(handles.val_tRead,'Enable','off');
set(handles.txt_err,'Visible','off');

set(handles.val_acc,'String','...');
set(handles.val_min,'String','...');
set(handles.val_max,'String','...');
set(handles.val_phigh,'String','...');
set(handles.val_xhigh,'String','...');
set(handles.val_yhigh,'String','...');
set(handles.val_thigh,'String','...');
switch state_on
    case 0 % do: STOP
        % show that stop is in progress
        set(handles.ind_status,'String','STOPPING');
        set(handles.ind_status,'foregroundColor',[0.5 0 0]);
        [result,changes]=main(0);
        state_on=1;
    case 1 % do: BUILD
        cla(handles.plt_pos);
%         yyaxis(handles.plt_pos,'left');
        cla(handles.plt_pow);
%         yyaxis(handles.plt_pos,'right');
%         cla(handles.plt_pow);
        set(handles.btn_on,'String','Wait...');
        set(handles.btn_on,'Enable','off');
        set(handles.ind_sim,'String','ON');
        set(handles.ind_status,'String','BUILD');
        set(handles.ind_status,'ForegroundColor',[0 0.33 0.67]);
        set_param('Autoalign_system','SimulationCommand','connect');
        state_on=2;
        [result,changes]=main(1);
    case 2 % do: RUN
        time=getappdata(0,'approx_time');
        set(handles.val_time,'String',num2str(ceil(time/60)));
        set(handles.btn_on,'String','Pause');
        set(handles.btn_on,'Enable','on');
        set(handles.ind_status,'String','RUN');
        set(handles.ind_status,'ForegroundColor',[0 0.67 0.33]);
        state_on=3;
        [result,changes]=main(2);
    case 3 % do: PAUSE
        set(handles.ind_status,'String','PAUSE');
        set(handles.ind_status,'ForegroundColor',[0.33 0.67 0]);
        [result,changes]=main(3);
        state_on=4;
    case 4 % do: UNPAUSE
        set(handles.btn_on,'String','Pause');
        set(handles.btn_on,'Enable','on');
        set(handles.ind_status,'String','RUN');
        set(handles.ind_status,'ForegroundColor',[0 0.67 0.33]);
        state_on=3;
        [result,changes]=main(4);
        if changes==1 % any input is changed, requires re-build
            state_on=1;
            [result,changes]=main(1);
        end
    otherwise % do: QUIT
        set(handles.val_centerx,'BackgroundColor','white');
        set(handles.val_centery,'BackgroundColor','white');
        set(handles.val_diameter,'BackgroundColor','white');
        set(handles.val_loops,'BackgroundColor','white');
        set(handles.val_delay,'BackgroundColor','white');
        set(handles.val_tRead,'BackgroundColor','white');
        [result,changes]=main(0);
        state_on=1;
end
switch result
    case 'build' % result: BUILD / RE-BUILD
        set(handles.btn_on,'String','Pause');
        set(handles.btn_on,'Enable','on');
        state_on=2;
        btn_on_Callback(hObject,eventdata,handles);
        return;
    case 'stopped' % result: STOPPED
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.btn_export,'Enable','off');
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_status,'String','IDLE');
        set(handles.ind_status,'Foregroundcolor',[0 0 0]);%black
        set(handles.txt_err,'String','Simulation succesfully stopped');
        set(handles.txt_err,'Visible','on');
        moveon=0;
    case 'paused' % result: PAUSED
        set(handles.btn_on,'Enable','on');
        set(handles.btn_on,'String','Unpause');
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.ind_sim,'String','ON');
        set(handles.ind_status,'String','PAUSED');
        set(handles.ind_status,'Foregroundcolor',[0.33 0.67 0]);
        moveon=1;
    case 'resumed' % result: RESUMED FROM PAUSE (NOTHING CHANGED)
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_status,'String','IDLE');
        set(handles.ind_status,'Foregroundcolor',[0 0 0]);%black
        moveon=1;
    case 'finished' % result: SIMULATION FINISHED SUCCESFULL
        state_on=1;
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_status,'String','IDLE');
        set(handles.ind_status,'Foregroundcolor',[0 0 0]);%black
        moveon=1;
    case 'time' % result: TIME OVERFLOW, SIMULATION RUNNING?
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.btn_export,'Enable','off');
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_status,'String','ERROR');
        set(handles.ind_status,'Foregroundcolor',[1 0 0]);%red
        set(handles.txt_err,'String','Time limit reached, possible that simulation is still running');
        set(handles.txt_err,'Visible','on');
        moveon=0;
    otherwise % result: UNKNOWN (STOPPED SIMULATION)
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.btn_export,'Enable','off');
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_status,'String','IDLE');
        set(handles.ind_status,'Foregroundcolor',[0 0 0]);%black
        set(handles.txt_err,'String','Unexpected result, risk of unreliable data');
        set(handles.txt_err,'Visible','on');
        moveon=0;
end

err_sizexy=0;
err_sizept=0;
if moveon==1 % if data acquisition succesfull
    % check output data
    if ~isappdata(0,'x_data')||~isappdata(0,'y_data')||~isappdata(0,'p_data')...
            ||~isappdata(0,'clk')||~isappdata(0,'centerx')||~isappdata(0,'centery')...
            ||~isappdata(0,'diameter')||~isappdata(0,'loops')
        set(handles.txt_err,'String','Unable to load output data');
        set(handles.txt_err,'Visible','on');
        return;
    end
    set(handles.ind_sim,'String','BUSY');
    set(handles.ind_sim,'ForegroundColor',[0.5 0 0]); % red
    set(handles.btn_export,'Enable','on');
    % extract data
    xdev=getappdata(0,'x_data');
    ydev=getappdata(0,'y_data');
    p=getappdata(0,'p_data');
    t=getappdata(0,'clk');
    centerx=getappdata(0,'centerx');
    centery=getappdata(0,'centery');
    diameter=getappdata(0,'diameter');
    loops=getappdata(0,'loops');
    acc=diameter/(2*loops-1);
    set(handles.val_acc,'String',acc);
    if ~isequal(size(xdev),size(ydev))
        err_sizexy=1;
    end
    if ~isequal(size(p),size(t)) % expand to add X & Y to time plot
        err_sizept=1;
    end
    skip=0;
    if err_sizexy==1 % size Y(X) mismatch
        set(handles.txt_err,'String','Unable to plot location, size mismatch [x/y]');
        set(handles.txt_err,'Visible','on');
        skip=1;
    else
        % transform steps to position
        factor=50/4096; % 50um/4096 steps, theoretical accuracy (excl. hysteresis)
        xpos=xdev.*factor;
        xnew(:,1)=xpos(:,1)+(centerx-diameter/(4*loops-2));
        ypos=ydev.*factor;
        ynew(:,1)=ypos(:,1)+(centery-diameter/(4*loops-2));
        % plot location
        set(handles.val_min,'String',num2str(min(xnew)));
        set(handles.val_max,'String',num2str(max(xnew)));
        setappdata(0,'x_pos',xnew);
        setappdata(0,'y_pos',ynew);
        xmin=centerx-diameter/2-(diameter/(4*loops-2));
        xmax=centerx+diameter/2+(diameter/(4*loops-2));
        ymin=centery-diameter/2-(diameter/(4*loops-2));
        ymax=centery+diameter/2+(diameter/(4*loops-2));
%         yyaxis(handles.plt_pos,'left');
        plot(handles.plt_pos,xnew,ynew);
        axis(handles.plt_pos,[xmin xmax ymin ymax]);
        grid(handles.plt_pos,'on');
        grid(handles.plt_pos,'minor');
    end
    if err_sizept==1 % size P(t) mismatch
        set(handles.txt_err,'String','Unable to plot power, size mismatch [p/t]');
        set(handles.txt_err,'Visible','on');
        skip=1;
    else
        x=getappdata(0,'x_pos');
        y=getappdata(0,'y_pos');
        xmin=centerx-diameter/2-(diameter/(4*loops-2));
        xmax=centerx+diameter/2+(diameter/(4*loops-2));
        ymin=centery-diameter/2-(diameter/(4*loops-2));
        ymax=centery+diameter/2+(diameter/(4*loops-2));
        secmin=min(xmin,ymin);
        secmax=max(xmax,ymax);
        tmin=0;
        tmax=max(t);
        pmin=0;
        pmax=max(p);
        xlim(handles.plt_pos,[0 tmax]);
        grid(handles.plt_pos,'on');
        grid(handles.plt_pos,'minor');
        legend(handles.plt_pos,'Power','X position','Y position')
        % plot P(t) (left)
        yyaxis(handles.plt_pow,'left');
        plot(handles.plt_pow,t,p);
        ylim(handles.plt_pow,[pmin pmax]);
%         axis(handles.plt_pos,[tmin tmax pmin pmax]);
        % plot X(t) & Y(t)
        yyaxis(handles.plt_pow,'right');
        plot(handles.plt_pow,t,x,t,y);
        ylim(handles.plt_pow,[secmin secmax]);
    end
    set(handles.ind_sim,'String','OFF');
    set(handles.ind_sim,'ForegroundColor',[0 0 0]); % black
    if skip==1 % proceed to determine highest power?
        return;
    end
    if max(p)>2
        max_p=0;
    else
        max_p=max(p);
    end
    highmin=max_p*0.9;
    highmax=max_p;
    row=find(p>highmin & p<highmax);
    for i=1:size(row)
       xi(i,1)=xnew(row(i,1),1);
       yi(i,1)=ynew(row(i,1),1);
       ti(i,1)=t(row(i,1),1);
%        plot(handles.plt_pos,xnew,ynew,xi(i,1),yi(i,1),'r');
    end
%     yyaxis(handles.plt_pos,'left');
    setappdata(0,'xnew',xi);
    setappdata(0,'ynew',yi);
    plot(handles.plt_pos,xnew,ynew,xi,yi,'r');
    phigh_txt=strcat(num2str(floor(highmin)),' |  ',num2str(floor(highmax)));
    xhigh_txt=strcat(num2str(floor(xi(1))),' |  ',num2str(floor(xi(numel(row)))));
    yhigh_txt=strcat(num2str(floor(yi(1))),' |  ',num2str(floor(yi(numel(row)))));
    thigh_txt=strcat(num2str(floor(ti(1))),' |  ',num2str(floor(ti(numel(row)))));
    set(handles.val_phigh,'String',phigh_txt);
    set(handles.val_xhigh,'String',xhigh_txt);
    set(handles.val_yhigh,'String',yhigh_txt);
    set(handles.val_thigh,'String',thigh_txt);
end

% --- Executes on button press in btn_export.
function btn_export_Callback(hObject, eventdata, handles)
% hObject    handle to btn_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check output data
if ~isappdata(0,'x_pos')||~isappdata(0,'y_pos')||~isappdata(0,'p_data')...
        ||~isappdata(0,'clk')||~isappdata(0,'centerx')||~isappdata(0,'centery')...
        ||~isappdata(0,'diameter')||~isappdata(0,'loops')
    set(handles.txt_err,'String','Unable to load output data');
    set(handles.txt_err,'Visible','on');
    return;
end
set(handles.ind_sim,'String','BUSY');
set(handles.ind_sim,'ForegroundColor',[0.5 0 0]); % red
Time=getappdata(0,'clk');
X_value=getappdata(0,'x_pos');
Y_value=getappdata(0,'y_pos');
Power=getappdata(0,'p_data');

[filename,pathname,filter]=uiputfile({'*.xlsx','Excel-Workbook';...
    '*.csv','CSV (Comma-Seperated Value)';...
    '*.txt','Text Document';'*.*','All Files'}...
    ,'Export data','Alignment Data.xlsx');
if isequal(filename,0)||isequal(pathname,0)
    % check for cancel
    set(handles.txt_err,'String','Export cancelled');
    set(handles.txt_err,'Visible','on');
    return;
end
[f,fname,fext]=fileparts(filename);
full=fullfile(pathname,[fname,fext]);
m=[Time,X_value,Y_value,Power];
header={'Time', 'X-value', 'Y-value', 'Power'};
% | Time | X-val | Y-val | Pow |
% |------+-------+-------+-----|
% |    0 |  400  |  400  |   0 |
% |    1 |  400  |  300  |  50 |
% |    2 |  ...  |  ...  | ... |
switch filter
    case 1 % *.xlsx
        xlswrite(full,header,'Sheet1','A1');
        xlswrite(full,m,'Sheet1','A2');
    case 2 % *.csv
        mtable=table(Time,X_value,Y_value,Power);
        writetable(mtable,full,'WriteVariableNames',1);
    case 3 %*.txt
        mtable=table(Time,X_value,Y_value,Power);
        writetable(mtable,full,'WriteVariableNames',1);
    otherwise % *.*
        if strcmp(fext,'.xlsx')
            % correct excel extensions
            xlswrite(full,header,'Sheet1','A1');
            xlswrite(full,m,'Sheet1','A2');
        elseif strcmp(fext,'.csv')||strcmp(fext,'.txt')
            % correct other extension
            mtable=table(Time,X_value,Y_value,Power);
            writetable(mtable,full,'WriteVariableNames',1);
        else
            % invalid extension
            fext='.txt';
            full=fullfile(pathname,[fname,fext]);
            mtable=table(Time,X_value,Y_value,Power);
            writetable(mtable,full,'WriteVariableNames',1);
            set(handles.txt_err,'String','unknown extension');
            set(handles.txt_err,'Visible','on');
        end
end
set(handles.ind_status,'String',strcat('To *',fext));
set(handles.ind_sim,'String','OFF');
set(handles.ind_sim,'ForegroundColor',[0 0 0]); % BLACK

% --- Executes on button press in btn_stop.
function btn_stop_Callback(hObject, eventdata, handles)
% hObject    handle to btn_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state_on;
set(handles.ind_status,'String','STOPPING');
set(handles.ind_status,'ForegroundColor',[0.5 0.5 0.5]);
if strcmp(get_param('Autoalign_system','SimulationStatus'),'building')
    set(handles.txt_err,'String','Simulation is in building mode, please wait until building is finished. The simulaton will stop when possible.');
end
state_on=0;
h=findobj('Tag','btn_on');
btn_on_Callback(h,eventdata,handles);

%%%%%%%%%%%%%%%%% SETTING VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function val_centerx_Callback(hObject, eventdata, handles)
% hObject    handle to val_centerx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_centerx as text
%        str2double(get(hObject,'String')) returns contents of val_centerx as a double
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'i')||contains(val,'j')...
        ||isempty(val)||isnan(check)||check>10000||check<-10000
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.txt_err,'String','Input for "Center X" is invalid! Make sure it is a real number between -10.000,0 and 10.000,0');
    set(handles.txt_err,'Visible','on');
else
    setappdata(0,'centerx',check); % Update value in appdata
    set(hObject,'backgroundColor',[0 .5 0]);% green
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end

function val_centery_Callback(hObject, eventdata, handles)
% hObject    handle to val_centery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_centery as text
%        str2double(get(hObject,'String')) returns contents of val_centery as a double
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'i')||contains(val,'j')...
        ||isempty(val)||isnan(check)||check>10000||check<-10000
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.txt_err,'String','Input for "Center Y" is invalid! Make sure it is a real number between -10.000,0 and 10.000,0');
    set(handles.txt_err,'Visible','on');
else
    setappdata(0,'centery',check); % Update value in appdata
    set(hObject,'backgroundColor',[0 .5 0]);% grey
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end

function val_diameter_Callback(hObject, eventdata, handles)
% hObject    handle to val_diameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_diameter as text
%        str2double(get(hObject,'String')) returns contents of val_diameter as a double
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'i')||contains(val,'j')...
        ||contains(val,'-')||isempty(val)||isnan(check)||check>10000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.txt_err,'String','Input for "Diameter" is invalid! Make sure it is a real number between 1,0 and 10.000,0');
    set(handles.txt_err,'Visible','on');
else
    setappdata(0,'diameter',check); % Update value in appdata
    set(hObject,'backgroundColor',[0 .5 0]);% green
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
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>50||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.txt_err,'String','Input for "Loops" is invalid! Make sure it is a real, natural number between 1 and 50');
    set(handles.txt_err,'Visible','on');
else
    setappdata(0,'loops',check); % Update value in appdata
    set(hObject,'backgroundColor',[0 .5 0]);% green
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
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>50||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.txt_err,'String','Input for "Delay" is invalid! Make sure it is a real, natural number between 1 and 50');
    set(handles.txt_err,'Visible','on');
else
    setappdata(0,'delay',check); % Update value in appdata
    set(hObject,'backgroundColor',[0 .5 0]);% green
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end

function val_tRead_Callback(hObject, eventdata, handles)
% hObject    handle to val_tRead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_tRead as text
%        str2double(get(hObject,'String')) returns contents of val_tRead as a double
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>50||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.txt_err,'String','Input for "Read time" is invalid! Make sure it is a real, natural number between 1 and 50');
    set(handles.txt_err,'Visible','on');
else
    setappdata(0,'read_time',check); % Update value in appdata
    set(hObject,'backgroundColor',[0 .5 0]);% green
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
% hObject    handle to val_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_time as text
%        str2double(get(hObject,'String')) returns contents of val_time as a double

function val_min_Callback(hObject, eventdata, handles)
% hObject    handle to val_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_min as text
%        str2double(get(hObject,'String')) returns contents of val_min as a double

function val_max_Callback(hObject, eventdata, handles)
% hObject    handle to val_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_max as text
%        str2double(get(hObject,'String')) returns contents of val_max as a double

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
function val_centerx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_centerx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_centery_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_centery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_diameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_diameter (see GCBO)
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
function val_tRead_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_tRead (see GCBO)
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
% hObject    handle to val_time (see GCBO)
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


% --- Executes during object creation, after setting all properties.
function val_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function val_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
