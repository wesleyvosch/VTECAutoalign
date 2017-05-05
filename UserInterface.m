%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% This file is required for the GUI to be functional, it consists of
% callbacks for the buttons and inputs. after startup it need to connect to
% an Arduino board, when first connected it need to build the program onto
% the board. afterwards it is able to switch between move mode and search
% mode without re-building.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% Last Modified by GUIDE v2.5 05-May-2017 10:10:57

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
% uiwait(handles.fig_GUI);
global state_on;
global connected;
global check_sum;
load_system('Autoalign_system.mdl');
% set_param('Autoalign_system','SimulationMode','external');
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

% set values for elements in Settings panel
set(handles.val_centerx,'String','0');
set(handles.val_centery,'String','0');
set(handles.val_diameter,'String','50');
set(handles.val_loops,'String','3');
set(handles.val_delay,'String','16');
set(handles.val_tRead,'String','16');

% enable elements in Settings panel
set(handles.val_centerx,'enable','on');
set(handles.val_centery,'enable','on');
set(handles.val_diameter,'enable','on');
set(handles.val_loops,'enable','on');
set(handles.val_delay,'enable','on');
set(handles.val_tRead,'enable','on');

% set color for elements in Settings panel
set(handles.val_centerx,'backgroundcolor','white');
set(handles.val_centery,'backgroundcolor','white');
set(handles.val_diameter,'backgroundcolor','white');
set(handles.val_loops,'backgroundcolor','white');
set(handles.val_delay,'backgroundcolor','white');
set(handles.val_tRead,'backgroundcolor','white');

% set values for elements in Results panel
set(handles.val_sample,'String','800');
set(handles.val_time,'String','1m 16s');
set(handles.val_acc,'String','10');
set(handles.val_xmin,'String','-25');
set(handles.val_xmax,'String','25');
set(handles.val_ymin,'String','-25');
set(handles.val_ymax,'String','25');

% set values for elements in Power panel
set(handles.val_Pmin,'String','...');
set(handles.val_Pxmin,'String','...');
set(handles.val_Pymin,'String','...');
set(handles.val_Ptmin,'String','...');
set(handles.val_Pmax,'String','...');
set(handles.val_Pxmax,'String','...');
set(handles.val_Pymax,'String','...');
set(handles.val_Ptmax,'String','...');

% set values for elements in Status panel
set(handles.ind_sim,'String','OFF');
set(handles.ind_status,'String','IDLE');
set(handles.ind_error,'String','NONE');
set(handles.ind_time,'String','1 min, 15 sec');

% set color for elements in Status panel
set(handles.ind_sim,'Foregroundcolor',[0 0 0]);
set(handles.ind_status,'Foregroundcolor',[0 1 0]);
set(handles.ind_error,'Foregroundcolor',[.5 0 0]);


% enable elements in Controls panel
set(handles.btn_connect,'Enable','on');
set(handles.btn_on,'Enable','off');
set(handles.btn_export,'Enable','off');
set(handles.btn_reset,'Enable','on');

% set values for elements in Controls panel
set(handles.btn_connect,'string','Connect');
set(handles.btn_on,'string','Run');
state_on=0;
connected=0; % external setting-> 0, debug setting-> -1
check_sum=0;

% set color for elements in Controls panel
set(handles.btn_connect,'backgroundcolor',[0.94 0.94 0.94]);
set(handles.btn_on,'backgroundcolor',[0.94 0.94 0.94]);
set(handles.btn_connect,'foregroundcolor',[0 0 0]);
set(handles.btn_on,'foregroundcolor',[0 0 0]);

% set data values
setappdata(0,'centerx',0);
setappdata(0,'centery',0);
setappdata(0,'diameter',50);
setappdata(0,'loops',3);
setappdata(0,'delay',16);
setappdata(0,'read_time',16);

% Default location plot
cla(handles.plt_pos,'reset');
title(handles.plt_pos,'Location matrix');
axis(handles.plt_pos,[-30 30 -30 30]);
grid(handles.plt_pos,'on');
grid(handles.plt_pos,'minor');
xlabel(handles.plt_pos,'X position [um]');
ylabel(handles.plt_pos,'Y position [um]');

% Default time plot
cla(handles.plt_time,'reset'); % clear plot
title(handles.plt_time,'Data in time domain');
xlim(handles.plt_time,[0 90]);
xlabel(handles.plt_time,'time [seconds]');
% legend(handles.plt_time,'Power','X position','Y position');
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');
yyaxis(handles.plt_time,'left');
ylabel(handles.plt_time,'Position [um]');
ylim(handles.plt_time,[-30 30]);
yyaxis(handles.plt_time,'right');
ylabel(handles.plt_time,'Power [uW]');
ylim(handles.plt_time,[0 3]);

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
% --- Executes on button press in btn_connect.
function btn_connect_Callback(hObject, eventdata, handles)
% hObject    handle to btn_connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global connected;
global state_on;
global check_sum;
display('btn_C');
display(connected);

% disable inputs & buttons
set(handles.val_centerx,'Enable','off');
set(handles.val_centery,'Enable','off');
set(handles.val_diameter,'Enable','off');
set(handles.val_loops,'Enable','off');
set(handles.val_delay,'Enable','off');
set(handles.val_tRead,'Enable','off');
set(handles.btn_connect,'Enable','off');
set(handles.btn_on,'Enable','off');
set(handles.btn_export,'Enable','off');

switch connected
    case -1 % debug mode
        display('btn_C: debug mode');
        set(handles.btn_connect,'string','Debug');
        set(handles.ind_sim,'String','ON');
        set(handles.ind_status,'String','DEBUGGING');
        set(handles.ind_status,'ForegroundColor',[0 0 0]);
        set_param('Autoalign_system','SimulationMode','normal');
        connected=0;
        % enable inputs
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.btn_connect,'Enable','on');
        set(handles.btn_connect,'String','Connect');
        set(handles.btn_on,'Enable','on');
        set(handles.btn_on,'String','Run');
        state_on=1;
        
    case 0 % Connecting
        display('btn_C: connecting');
%         set_param('Autoalign_system','HardwareBoard','Arduino Mega 2560');
        set(handles.ind_status,'String','CONNECTING');
        set(handles.ind_status,'ForegroundColor',[0 0 .5]);
        % checksum 
        if check_sum==1
            % already build, only connecting required
            display('already build');
            [result,changes]=main(0);
            display('btn_C: simulink mode set to 0 (idle)');
            set_param('Autoalign_system','SimulationCommand','Connect');
            display('btn_C: connected');
            set(handles.ind_sim,'String','ON');
            set(handles.ind_status,'String','CONNECTED');
            set(handles.ind_status,'ForegroundColor',[0 0 0.75]);
            connected=1;
            state_on=1;
            % enable inputs
            set(handles.val_centerx,'Enable','on');
            set(handles.val_centery,'Enable','on');
            set(handles.val_diameter,'Enable','on');
            set(handles.val_loops,'Enable','on');
            set(handles.val_delay,'Enable','on');
            set(handles.val_tRead,'Enable','on');
            set(handles.btn_on,'Enable','on');
            set(handles.btn_on,'String','Run');
            set(handles.btn_connect,'Enable','on');
            set(handles.btn_connect,'String','Disconnect');
            return;
        else
            display('start build');
            check_sum=1;
            set(handles.ind_status,'String','BUILDING');
            set(handles.ind_status,'ForegroundColor',[0 0 1]);
            [result,changes]=main(1);
            % enable inputs
            set(handles.val_centerx,'Enable','on');
            set(handles.val_centery,'Enable','on');
            set(handles.val_diameter,'Enable','on');
            set(handles.val_loops,'Enable','on');
            set(handles.val_delay,'Enable','on');
            set(handles.val_tRead,'Enable','on');
            set(handles.btn_on,'Enable','on');
            set(handles.btn_on,'String','Run');
            set(handles.btn_connect,'Enable','on');
            set(handles.btn_connect,'String','Disconnect');
        end
    case 1 % Disconnecting
        display('btn_C: disconnecting');
        set(handles.ind_status,'String','STOPPING');
        set(handles.ind_status,'foregroundcolor',[1 0.75 0]);
        state_on=0;
        connected=0;
        [result,changes]=main(0); 
        % enable inputs
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.btn_on,'Enable','off');
        set(handles.btn_connect,'Enable','on');
        set(handles.btn_connect,'String','Connect');
    otherwise % do nothing
        return;
end
switch result
    case 'build'
        display('btn_C: result=build');
       % enable inputs
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.ind_status,'String','BUILD');
        set(handles.ind_status,'ForegroundColor',[.5 0 1]);
        set(handles.btn_on,'Enable','on');
        set(handles.btn_on,'String','Run');
        set(handles.btn_connect,'Enable','on');
        set(handles.btn_connect,'String','Disconnect');
        state_on=1;
    case 'stopped'
        display('btn_C: result=stopped');
        set(handles.ind_status,'String','DISCONNECTING');
        set(handles.ind_status,'foregroundcolor',[.75 0 0.5]);
        set_param('Autoalign_system','SimulationCommand','Disconnect');
        set(handles.ind_status,'String','DISCONNECTED');
        set(handles.ind_status,'foregroundcolor',[.75 0 0.25]);
        connected=0;
        % enable inputs
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.btn_on,'Enable','off');
        set(handles.btn_on,'String','Run');
        set(handles.btn_export,'Enable','off');
        set(handles.btn_connect,'Enable','on');
        set(handles.btn_connect,'String','Connect');
    otherwise
        display('btn_C: result=unknown');
        return;
end

% --- Executes on button press in btn_on.
function btn_on_Callback(hObject, eventdata, handles)
% hObject    handle to btn_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% state=str2double(get(hObject,'Value'));
global state_on;
global connected;
global cx;
global cy;
global diam;
display('btn_O');
display(state_on);
% disable inputs & buttons
set(handles.val_centerx,'Enable','off');
set(handles.val_centery,'Enable','off');
set(handles.val_diameter,'Enable','off');
set(handles.val_loops,'Enable','off');
set(handles.val_delay,'Enable','off');
set(handles.val_tRead,'Enable','off');
set(handles.btn_connect,'Enable','off');
set(handles.btn_on,'Enable','off');
set(handles.btn_export,'Enable','off');
set(handles.ind_error,'String','');

switch state_on
    case -1 % EXIT
        display('btn_O: EXIT');
        state_on=-1;
        [result,changes]=main(-1);
    case 0 % IDLE mode
        display('btn_O: IDLE');
        set(handles.ind_status,'String','STOPPING');
        set(handles.ind_status,'foregroundColor',[0.5 0 0]);
        state_on=0;
        [result,changes]=main(0);
    case 1 % MOVE mode
        display('btn_O: moving');
        time=getappdata(0,'approx_time');
        time_txt=strcat(num2str(floor(time/60)),' min, ',num2str(floor(time-floor(time/60)*60)),' sec');
        set(handles.ind_time,'String',time_txt);
        set(handles.btn_on,'String','Pause');
        set(handles.btn_on,'Enable','on');
        set(handles.ind_status,'String','Moving');
        set(handles.ind_status,'ForegroundColor',[0 0.75 0.5]);
        state_on=3;
        [result,changes]=main(2);
    case 2 % SEARCH mode
        display('btn_O: searching');
        time=getappdata(0,'approx_time');
        time_txt=strcat(num2str(floor(time/60)),'m ',num2str(floor(time-floor(time/60)*60)),'s');
        set(handles.val_time,'String',time_txt);
        set(handles.btn_on,'String','Pause');
        set(handles.btn_on,'Enable','on');
        set(handles.ind_status,'String','RUNNING');
        set(handles.ind_status,'ForegroundColor',[0 0.25 0]);
        state_on=3;
        [result,changes]=main(2);
    case 3 % PAUSE simulation
        display('btn_O: pausing');
        set(handles.ind_status,'String','PAUSING');
        set(handles.ind_status,'ForegroundColor',[0 0.25 0.5]);
        state_on=4;
        [result,changes]=main(3);
    case 4 % UNPAUSE simulation
        display('btn_O: unpausing');
        set(handles.btn_on,'String','Pause');
        set(handles.btn_on,'Enable','on');
        state_on=3;
        [result,changes]=main(4);
    otherwise
        display('btn_O: unknown state');
        return;
end
switch result
    case 'stopped'
        display('btn_O: result=stopped');
        state_on=1;
        connected=1;
        % enable inputs
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.btn_connect,'Enable','on');
        set(handles.btn_export,'Enable','on');
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_status,'String','STOPPED');
        set(handles.ind_status,'Foregroundcolor',[1 0 0]);
        return;
    case 'finished'
        display('btn_O: result=finished');
        state_on=1;
        connected=1;
        % enable inputs
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.btn_connect,'Enable','on');
        set(handles.btn_export,'Enable','on');
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_status,'String','FINISHED');
        set(handles.ind_status,'Foregroundcolor',[0 1 0]);
    case 'moved'
        display('btn_O: result=moved');
        set(handles.ind_status,'String','MOVED');
        set(handles.ind_status,'ForegroundColor',[0 0.75 0.75]);
        state_on=3;
        return;
    case 'paused'
        display('btn_O: result=paused');
        set(handles.ind_status,'String','PAUSED');
        set(handles.ind_status,'ForegroundColor',[0 0 0.5]);
        state_on=5;
    case 'unpaused'
        display('btn_O: result=unpaused');
        if changes==0 % resume
            display('btn_O: no changes, resuming');
            set(handles.ind_status,'String','RESUMING');
            set(handles.ind_status,'ForegroundColor',[0 0.25 0.5]);
            state_on=4;
        else % restart
            display('btn_O: changes, restarting');
            set(handles.ind_status,'String','RESTARTING');
            set(handles.ind_status,'ForegroundColor',[0 0.25 0.75]);
            state_on=2;
            btn_on_Callback(hObject, eventdata, handles);
        end
        return;
    case 'time'
        display('btn_O: result=time');
        state_on=1;
        % enable inputs
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','on');
        set(handles.btn_connect,'Enable','on');
        set(handles.btn_export,'Enable','on');
        set(handles.ind_error,'String','Simulation time limit reached!');
        return;
     case 'exit'
        display('btn_O: result=exit');
        state_on=0;
        connected=0;
        % enable inputs
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_tRead,'Enable','on');
        set(handles.btn_on,'String','Run');
        set(handles.btn_on,'Enable','off');
        set(handles.btn_connect,'String','Connect');
        set(handles.btn_connect,'Enable','on');
        set(handles.btn_export,'Enable','on');
        set(handles.ind_status,'String','IDLE');
        set(handles.ind_status,'ForegroundColor',[0 1 0]);
        set(handles.ind_sim,'String','OFF');
        set(handles.ind_sim,'ForegroundColor',[0 0 0]);
        return;
    otherwise
        display('btn_O: result=unknown');
        return;
end
display('btn_O: check data');
% check output data
if ~isappdata(0,'x_data')||~isappdata(0,'y_data')||~isappdata(0,'p_data')...
        ||~isappdata(0,'clk')||~isappdata(0,'centerx')||~isappdata(0,'centery')...
        ||~isappdata(0,'diameter')||~isappdata(0,'loops')
    set(handles.ind_error,'String','Unable to load output data');
    display('btn_O: data not good');
    return;
end
set(handles.ind_status,'String','PLOTTING');
set(handles.ind_status,'ForegroundColor',[0 0.5 0.5]);
set(handles.btn_export,'Enable','on');
% extract data
xdev=getappdata(0,'x_data');
ydev=getappdata(0,'y_data');
p=getappdata(0,'p_data');
t=getappdata(0,'clk');
part=getappdata(0,'finish');

centerx=getappdata(0,'centerx');
centery=getappdata(0,'centery');
diameter=getappdata(0,'diameter');
loops=getappdata(0,'loops');
acc=diameter/(2*loops-1);
set(handles.val_acc,'String',acc);
if length(xdev)<length(ydev)
    %add zero's to xdev
    xdev(numel(ydev))=0;
    display('btn_O: x < y');
elseif length(xdev)>length(ydev)
    %add zero's to ydev
    display('btn_O: x > y');
    ydev(numel(xdev))=0;
end

% transform steps to position
factor=50/4096; % 50um/4096 steps, theoretical accuracy (excl. hysteresis)
xpos=xdev.*factor;
ypos=ydev.*factor;
mode=1;
for item=1:length(part)
    if part(item,1)==1 || part(item,1)==2
        mode=part(item,1);
    end
    if mode==1 % start of search state
        cx=centerx;
        cy=centery;
        xnew(item,1)=xpos(item,1)+(centerx-diameter/(4*loops-2));
        ynew(item,1)=ypos(item,1)+(centery-diameter/(4*loops-2));
    elseif mode==2 % start of move state
        xnew(item,1)=cx-diam/2-centerx;
        ynew(item,1)=cy-diam/2-centery;
    end
end
% xnew(:,1)=xpos(:,1)+(centerx-diameter/(4*loops-2));
% ynew(:,1)=ypos(:,1)+(centery-diameter/(4*loops-2));
display(factor);

% plot location
display('btn_O: plot location...');
set(handles.val_xmin,'String',num2str(round(min(xnew))));
set(handles.val_xmax,'String',num2str(round(max(xnew))));
set(handles.val_ymin,'String',num2str(round(min(ynew))));
set(handles.val_ymax,'String',num2str(round(max(ynew))));
setappdata(0,'x_pos',xnew);
setappdata(0,'y_pos',ynew);

% calculate boundaries for plot
xminval=centerx-diameter/2-(diameter/(4*loops-2));
xmaxval=centerx+diameter/2+(diameter/(4*loops-2));
yminval=centery-diameter/2-(diameter/(4*loops-2));
ymaxval=centery+diameter/2+(diameter/(4*loops-2));
if sign(xminval)==-1
    display('xmin is negative');
    xmin=-ceil(-xminval/5)*5;
else
    display('xmin is positive');
    xmin=ceil(xminval/5)*5;
end
if sign(xmaxval)==-1
    display('xmax is negative');
    xmax=-ceil(-xmaxval/5)*5;
else
    display('xmax is positive');
    xmax=ceil(xmaxval/5)*5;
end
if sign(yminval)==-1
    display('ymin is negative');
    ymin=-ceil(-yminval/5)*5;
else
    display('ymin is positive');
    ymin=ceil(yminval/5)*5;
end
if sign(ymaxval)==-1
    display('ymax is negative');
    ymax=-ceil(-ymaxval/5)*5;
else
    display('ymax is positive');
    ymax=ceil(ymaxval/5)*5;
end
% xmin=ceil((centerx-diameter/2-(diameter/(4*loops-2)))/5)*5;
% xmax=ceil((centerx+diameter/2+(diameter/(4*loops-2)))/5)*5;
% ymin=ceil((centery-diameter/2-(diameter/(4*loops-2)))/5)*5;
% ymax=ceil((centery+diameter/2+(diameter/(4*loops-2)))/5)*5;


display(centerx);
display(centery);
display(diameter);
display(loops);
% display('xmin=centerx-diameter/2-(diameter/(4*loops-2))');
% display('xmax=centerx+diameter/2+(diameter/(4*loops-2))');

display(xmin);
display(xmax);
display(ymin);
display(ymax);

plot(handles.plt_pos,xnew,ynew);
axis(handles.plt_pos,[xmin xmax ymin ymax]);
% title(handles.plt_pos,'Location matrix');
% xlabel(handles.plt_pos,'X position');
% ylabel(handles.plt_pos,'Y position');
grid(handles.plt_pos,'on');
grid(handles.plt_pos,'minor');

minright=min(xmin,ymin);
maxright=max(xmax,ymax);
tmin=0;
tmax=max(t)*1.05;
display(minright);
display(maxright);
display(tmin);
display(tmax);
display(min(p));
display(max(p));

if min(p)==max(p)
    % no change in power
    pmin=0;
    pmax=0.5;
else
    pmin=min(p)*0.9;
    pmax=max(p)*1.1;
end
display(pmin);
display(pmax);
tmaxx=tmax*1.1;
% title(handles.plt_time,'Data in time domain');
% xlabel(handles.plt_time,'Time [seconds]');
xlim(handles.plt_time,[tmin tmaxx]);
% plot P(t) (left)
yyaxis(handles.plt_time,'left');
display('btn_O: plot time (L)');
plot(handles.plt_time,t,xnew,'b',t,ynew,'m');
ylim(handles.plt_time,[minright maxright]);
% plot X&Y(t) (right)
yyaxis(handles.plt_time,'right');
display('btn_O: plot time (R)');
plot(handles.plt_time,t,p,'r');
ylim(handles.plt_time,[pmin pmax]);
ylabel(handles.plt_time,'Power [uW]');
% ylabel(handles.plt_time,'Position [um]');
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');
legend(handles.plt_time,'X position','Y position','Power');

set(handles.ind_sim,'String','OFF');
set(handles.ind_sim,'ForegroundColor',[0 0 0]); % black

display('btn_O: find highest power');
% find highest power area
max_p=max(p);
trigminp=max_p*0.9;
trigmaxp=max_p;
row=find(p>trigminp & p<trigmaxp);
for i=1:size(row)
   xi(i,1)=xnew(row(i,1),1);
   yi(i,1)=ynew(row(i,1),1);
   ti(i,1)=t(row(i,1),1);
end

setappdata(0,'xnew',xi);
setappdata(0,'ynew',yi);
plot(handles.plt_pos,xnew,ynew,xi,yi,'r*','markersize',1);
% title(handles.plt_pos,'Location matrix');
% xlabel(handles.plt_pos,'X position');
% ylabel(handles.plt_pos,'Y position');
axis(handles.plt_pos,[xmin xmax ymin ymax]);
grid(handles.plt_pos,'on');
grid(handles.plt_pos,'minor');

set(handles.val_Pmin,'String',num2str(floor(trigminp)));
set(handles.val_Pmax,'String',num2str(floor(trigmaxp)));
set(handles.val_Pxmin,'String',num2str(floor(xi(numel(1)))));
set(handles.val_Pxmax,'String',num2str(floor(xi(numel(row)))));
set(handles.val_Pymin,'String',num2str(floor(yi(numel(1)))));
set(handles.val_Pymax,'String',num2str(floor(yi(numel(row)))));
set(handles.val_Ptmin,'String',num2str(floor(ti(numel(1)))));
set(handles.val_Ptmax,'String',num2str(floor(ti(numel(row)))));

set(handles.ind_status,'String','IDLE');
set(handles.ind_status,'ForegroundColor',[0 1 0]);
set(handles.ind_sim,'String','OFF');
set(handles.ind_sim,'ForegroundColor',[0 0 0]);

% --- Executes on button press in btn_export.
function btn_export_Callback(hObject, eventdata, handles)
% hObject    handle to btn_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check output data
if ~isappdata(0,'x_pos')||~isappdata(0,'y_pos')||~isappdata(0,'p_data')...
        ||~isappdata(0,'clk')||~isappdata(0,'centerx')||~isappdata(0,'centery')...
        ||~isappdata(0,'diameter')||~isappdata(0,'loops')
    set(handles.ind_error,'String','Unable to load output data');
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
    set(handles.ind_error,'String','Export cancelled');
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
            set(handles.ind_error,'String','unknown extension, exporting to *.txt file');
        end
end
set(handles.ind_status,'String',strcat('To *',fext));
set(handles.ind_sim,'String','OFF');
set(handles.ind_sim,'ForegroundColor',[0 0 0]); % BLACK

% --- Executes on button press in btn_reset.
function btn_reset_Callback(hObject, eventdata, handles)
% hObject    handle to btn_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state_on;
display('btn_RESET');
set(handles.ind_status,'String','RESETTING');
set(handles.ind_status,'ForegroundColor',[0.5 0.5 0.5]);
% UserInterface_OpeningFcn(hObject, eventdata, handles, varargin)
reset=questdlg('Do you really want to reset the interface?!','Reset','Cancel','Reset','Cancel');
if strcmp(reset,'Cancel')
    display('RESET cancelled');
    return
end
display('RESETTING');
UserInterface_OpeningFcn(findobj('Tag','fig_GUI'),eventdata,handles);

% --- Executes on button press in btn_exit.
function btn_exit_Callback(hObject, eventdata, handles)
% hObject    handle to btn_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state_on;
global check_sum;
set(handles.ind_status,'String','EXITING');
set(handles.ind_status,'ForegroundColor',[1 0.5 0.5]);
state_on=-1;
check_sum=0;
btn_on_Callback(findobj('Tag','btn_on'),eventdata,handles);

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
    set(handles.ind_error,'String','Invallid value, -10.000 < CenterX < 10.000');
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
    set(handles.ind_error,'String','Invallid value, -10.000 < CenterY < 10.000');
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
    set(handles.ind_error,'String','Invallid value, 1 < Diameter < 10.000');
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
    set(handles.ind_error,'String','Invallid value, 1 < Loops < 50');
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
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>1000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invallid value, 1 < Delay < 1000');
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
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>1000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invallid value, 1 < Read time < 1000');
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

function val_xmin_Callback(hObject, eventdata, handles)
% hObject    handle to val_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_xmin as text
%        str2double(get(hObject,'String')) returns contents of val_xmin as a double

function val_xmax_Callback(hObject, eventdata, handles)
% hObject    handle to val_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_xmax as text
%        str2double(get(hObject,'String')) returns contents of val_xmax as a double

function val_Pmin_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Pmin as text
%        str2double(get(hObject,'String')) returns contents of val_Pmin as a double

function val_Ptmin_Callback(hObject, eventdata, handles)
% hObject    handle to val_Ptmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Ptmin as text
%        str2double(get(hObject,'String')) returns contents of val_Ptmin as a double

function val_Pxmin_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pxmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Pxmin as text
%        str2double(get(hObject,'String')) returns contents of val_Pxmin as a double

function val_Pymin_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Pymin as text
%        str2double(get(hObject,'String')) returns contents of val_Pymin as a double

function val_ymin_Callback(hObject, eventdata, handles)
% hObject    handle to val_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_ymin as text
%        str2double(get(hObject,'String')) returns contents of val_ymin as a double

function val_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to val_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_ymax as text
%        str2double(get(hObject,'String')) returns contents of val_ymax as a double

function val_Pmax_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Pmax as text
%        str2double(get(hObject,'String')) returns contents of val_Pmax as a double

function val_Pxmax_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pxmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Pxmax as text
%        str2double(get(hObject,'String')) returns contents of val_Pxmax as a double

function val_Pymax_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Pymax as text
%        str2double(get(hObject,'String')) returns contents of val_Pymax as a double

function val_Ptmax_Callback(hObject, eventdata, handles)
% hObject    handle to val_Ptmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Ptmax as text
%        str2double(get(hObject,'String')) returns contents of val_Ptmax as a double

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
function val_Pmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_Pmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_Ptmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_Ptmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_Pxmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_Pxmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_Pymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_Pymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_Pmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_Pmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_Pxmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_Pxmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_Pymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_Pymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_Ptmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_Ptmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
