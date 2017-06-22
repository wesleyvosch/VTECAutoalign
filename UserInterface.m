%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% This file is used for the functions within the GUI, the callbacks are
% generated automatically and are used to operate the buttons and change
% the parameters. 
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

% Last Modified by GUIDE v2.5 19-Jun-2017 14:57:10

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

%% START INITIALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% After the GUI is created is this function called. 
% It will remove all previously saved appdata, clear the plots and reset
% the parameters to their default values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load_system('Autoalign_system.slx'); % load simulink model
set_param('Autoalign_system','SimulationMode','external'); % set model to external mode

% declare global variables
global doPause;
global wasPaused;
global inputerr;
global doStop;

doStop=0;
doPause=0;
wasPaused=0;
inputerr=zeros(8,1);

% clear appdata
appdata={'cyclenr';'loopnr';'t_data';...    %from callbacks in Simulink
        'x_data';'y_data';'p_data';...      %from callbacks in Simulink
        'xmax';'ymax';'pmax';...            %from callbacks in Simulink
        'diameter';'centerx';'centery';...  %from function in GUI
        'cycles';'loops';'scale';...        %from function in GUI
        'acc';'tot_acc';'delay';'read_time'};%from function in GUI
for a=1:length(appdata)
    if isappdata(0,appdata{a})
        rmappdata(0,appdata{a});
    end
end
% values
diameter=20;
centerx=0;
centery=0;
loops=3;
scale=2;
tot_acc=500;
delay=16;
read=1;
pset=3;
pxset=-8;
pyset=4;
pfactor=5;

% set appdata values
setappdata(0,'diameter',diameter);
setappdata(0,'centerx',centerx);
setappdata(0,'centery',centery);
setappdata(0,'loops',loops);
setappdata(0,'scale',scale);
setappdata(0,'tot_acc',tot_acc);
setappdata(0,'delay',delay);
setappdata(0,'read_time',read);
%temp
setappdata(0,'p_set',pset);
setappdata(0,'px_set',pxset);
setappdata(0,'py_set',pyset);
setappdata(0,'pfactor',pfactor);

cycles=ceil(1+log(1000*diameter/((2*loops-1)*tot_acc))/log(scale));
acc=round(1000*diameter*scale^(1-cycles)/(2*loops-1));
setappdata(0,'cycles',cycles);
setappdata(0,'acc',acc);
[tm,ts]=calcTime();
t=strcat(num2str(tm,'%02i'),':',num2str(ts,'%02i'));

% Default settings for centerx
set(handles.val_centerx,'String',num2str(centerx));
set(handles.val_centerx,'enable','on');
set(handles.val_centerx,'backgroundcolor','white');

% Default settings for centery
set(handles.val_centery,'String',num2str(centery));
set(handles.val_centery,'enable','on');
set(handles.val_centery,'backgroundcolor','white');

% Default settings for diameter
set(handles.val_diameter,'String',num2str(diameter));
set(handles.val_diameter,'enable','on');
set(handles.val_diameter,'backgroundcolor','white');

% Default settings for loops
set(handles.val_loops,'String',num2str(loops));
set(handles.val_loops,'enable','on');
set(handles.val_loops,'backgroundcolor','white');

% Default settings for accuracy
set(handles.val_tot_acc,'String',num2str(tot_acc));
set(handles.val_tot_acc,'enable','on');
set(handles.val_tot_acc,'backgroundcolor','white');

% Default settings for scale
set(handles.val_scale,'String',num2str(scale));
set(handles.val_scale,'enable','on');
set(handles.val_scale,'backgroundcolor','white');

% Default settings for delay
set(handles.val_delay,'String',num2str(delay));
set(handles.val_delay,'enable','on');
set(handles.val_delay,'backgroundcolor','white');

% Default settings for read_time
set(handles.val_read,'String',num2str(read));
set(handles.val_read,'enable','on');
set(handles.val_read,'backgroundcolor','white');

% Default settings for error message
set(handles.ind_error,'String',' ');
set(handles.ind_error,'Foregroundcolor','red');

% Default values
% set(handles.val_sim,'String','OFF');
% set(handles.val_status,'String','ARDUINO');
set(handles.val_safreq,'String','800 Hz');
set(handles.text140,'String','');
set(handles.text168,'String','');
set(handles.val_time_est,'String',t);
set(handles.val_time_exp,'String','00:00');
set(handles.val_rangex_min,'String',strcat(num2str(centerx-diameter/2),' um'));
set(handles.val_rangex_max,'String',strcat(num2str(centerx+diameter/2),' um'));
set(handles.val_rangey_min,'String',strcat(num2str(centery-diameter/2),' um'));
set(handles.val_rangey_max,'String',strcat(num2str(centery+diameter/2),' um'));
set(handles.val_pmax,'String','____ uW');
set(handles.val_p_prec,'String','____ nW');
set(handles.val_sweetx,'String','____ um');
set(handles.val_sweetx_prec,'String','____ nm');
set(handles.val_sweety,'String','____ um');
set(handles.val_sweety_prec,'String','____ nm');
set(handles.val_acc,'String',strcat(num2str(acc),' nm'));
set(handles.val_cycle,'String',num2str(cycles));
set(handles.ind_error,'String','');

%temp
set(handles.val_pSet,'String',num2str(pset));
set(handles.val_pxSet,'String',num2str(pxset));
set(handles.val_pySet,'String',num2str(pyset));
set(handles.val_pfactor,'String',num2str(pfactor));

% Default settings for buttons
set_values('IDLE',handles);
set(handles.btn_pause,'string','Pause');
set(handles.btn_debug,'value',0);
set(handles.btn_ack,'Visible','off');

%% PLOT
% Default location plot
cla(handles.plt_pos,'reset');
scatter(handles.plt_pos,[0;0],[0;0],1,[0,3]);
colormap(handles.plt_pos,'jet');
c=colorbar(handles.plt_pos);
c.Label.String = 'Power [uW]';
title(handles.plt_pos,'Location matrix');
axis(handles.plt_pos,[centerx-diameter/2 centerx+diameter/2 centery-diameter/2 centery+diameter/2]);
grid(handles.plt_pos,'on');
grid(handles.plt_pos,'minor');
xlabel(handles.plt_pos,'X position [um]');
ylabel(handles.plt_pos,'Y position [um]');

% Default time plot
cla(handles.plt_time,'reset'); % clear plot
title(handles.plt_time,'Data in time domain');
time=tm*60+ts;
xlim(handles.plt_time,[0 time]);
xlabel(handles.plt_time,'Time [seconds]');
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');
yyaxis(handles.plt_time,'left');
plot(handles.plt_time,0,0,0,0);
ylabel(handles.plt_time,'Position [um]');
ylim(handles.plt_time,[-diameter/2 diameter/2]);
yyaxis(handles.plt_time,'right');
ylabel(handles.plt_time,'Power [uW]');
plot(handles.plt_time,0,0);
ylim(handles.plt_time,[0 3]);
legend(handles.plt_time,'X position','Y position','Power','location','northoutside','Orientation','Horizontal');
%% END OF INITIALIZATION

% --- Outputs from this function are returned to the command line.
function varargout = UserInterface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% set enable/disable items
function set_values(status, handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% This function is controls which buttons and parameters are enabled.
% And depends on the status of the simulation. It uses the handles from the
% callback to write to the correct items.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch status
    case 'BUILDING'
        % enable/disable buttons
        set(handles.btn_on,'enable','off');
        set(handles.btn_stop,'enable','off');
        set(handles.btn_pause,'enable','off');
        set(handles.btn_save,'enable','off');
        set(handles.btn_debug,'enable','off');
        set(handles.btn_reset,'enable','on');
        
        % enable/disable parameters
        set(handles.val_centerx,'enable','off');
        set(handles.val_centery,'enable','off');
        set(handles.val_diameter,'enable','off');
        set(handles.val_loops,'enable','off');
        set(handles.val_tot_acc,'enable','off');
        set(handles.val_scale,'enable','off');
        set(handles.val_delay,'enable','off');
        set(handles.val_read,'enable','off');
        
        set(handles.val_sim,'String','ON');
    case {'IDLE','FINISHED','DEBUG','EXTERNAL'}
        % enable/disable buttons
        set(handles.btn_on,'enable','on');
        set(handles.btn_stop,'enable','off');
        set(handles.btn_pause,'enable','off');
        set(handles.btn_save,'enable','on');
        set(handles.btn_debug,'enable','on');
        set(handles.btn_reset,'enable','on');
        
        % enable/disable parameters
        set(handles.val_centerx,'enable','on');
        set(handles.val_centery,'enable','on');
        set(handles.val_diameter,'enable','on');
        set(handles.val_loops,'enable','on');
        set(handles.val_tot_acc,'enable','on');
        set(handles.val_scale,'enable','on');
        set(handles.val_delay,'enable','on');
        set(handles.val_read,'enable','on');
        
        set(handles.val_sim,'String','OFF');
    case 'RUNNING'
        % enable/disable buttons
        set(handles.btn_on,'enable','off');
        set(handles.btn_stop,'enable','on');
        set(handles.btn_pause,'enable','on');
        set(handles.btn_save,'enable','off');
        set(handles.btn_debug,'enable','off');
        set(handles.btn_reset,'enable','on');
        
        % enable/disable parameters
        set(handles.val_centerx,'enable','off');
        set(handles.val_centery,'enable','off');
        set(handles.val_diameter,'enable','off');
        set(handles.val_loops,'enable','off');
        set(handles.val_tot_acc,'enable','off');
        set(handles.val_scale,'enable','off');
        set(handles.val_delay,'enable','off');
        set(handles.val_read,'enable','off');
        
        set(handles.val_sim,'String','ON');
    case 'PAUSED'
        % enable/disable buttons
        set(handles.btn_on,'enable','off');
        set(handles.btn_stop,'enable','on');
        set(handles.btn_pause,'enable','on');
        set(handles.btn_save,'enable','on');
        set(handles.btn_debug,'enable','on');
        set(handles.btn_reset,'enable','on');
        
        % enable/disable parameters
        set(handles.val_centerx,'enable','on');
        set(handles.val_centery,'enable','on');
        set(handles.val_diameter,'enable','on');
        set(handles.val_loops,'enable','on');
        set(handles.val_tot_acc,'enable','on');
        set(handles.val_scale,'enable','on');
        set(handles.val_delay,'enable','on');
        set(handles.val_read,'enable','on');
        
        set(handles.val_sim,'String','ON');
    case 'SAVING'
        % enable/disable buttons
        set(handles.btn_on,'enable','on');
        set(handles.btn_stop,'enable','on');
        set(handles.btn_pause,'enable','off');
        set(handles.btn_save,'enable','off');
        set(handles.btn_debug,'enable','on');
        set(handles.btn_reset,'enable','on');
        
        % enable/disable parameters
        set(handles.val_centerx,'enable','on');
        set(handles.val_centery,'enable','on');
        set(handles.val_diameter,'enable','on');
        set(handles.val_loops,'enable','on');
        set(handles.val_tot_acc,'enable','on');
        set(handles.val_scale,'enable','on');
        set(handles.val_delay,'enable','on');
        set(handles.val_read,'enable','on');
        
        set(handles.val_sim,'String','OFF');
    otherwise % set as idle
        % enable/disable buttons
        set(handles.btn_on,'enable','on');
        set(handles.btn_stop,'enable','off');
        set(handles.btn_pause,'enable','off');
        set(handles.btn_save,'enable','on');
        set(handles.btn_debug,'enable','on');
        set(handles.btn_reset,'enable','on');
        
        % enable/disable parameters
        set(handles.val_centerx,'enable','on');
        set(handles.val_centery,'enable','on');
        set(handles.val_diameter,'enable','on');
        set(handles.val_loops,'enable','on');
        set(handles.val_tot_acc,'enable','on');
        set(handles.val_scale,'enable','on');
        set(handles.val_delay,'enable','on');
        set(handles.val_read,'enable','on');
        
        set(handles.val_sim,'String','OFF');
        status='IDLE';
end
set(handles.val_status,'string',status);

%% pressed btn_on
function btn_on_Callback(hObject, eventdata, handles)
% hObject    handle to btn_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the button 'run' is pressed. This function is
% active when no errors are present. The results and plots are cleared and
% the parameters are disabled. Then is the system build and running, after
% the system is finished, are the results displayed and the plots made.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global doStop;
global doPause;
global wasPaused;
global inputerr;
global counter;

if max(inputerr)>0
    % error in parameters
    err_msg=strcat('Error: Unable to start simulation, there are ',num2str(sum(inputerr)),' errors!');
    set(handles.ind_error,'String',err_msg);
    return;
end
% clear error message
set(handles.ind_error,'String','');
% clear output values
set(handles.val_time_exp,'String','00:00');
set(handles.val_pmax,'String','____ uW');
set(handles.val_p_prec,'String','____ nW');
set(handles.val_sweetx,'String','____ um');
set(handles.val_sweetx_prec,'String','____ nm');
set(handles.val_sweety,'String','____ um');
set(handles.val_sweety_prec,'String','____ nm');

% clear/reset plots
cla(handles.plt_pos,'reset');
scatter(handles.plt_pos,[0;0],[0;0],1,[0,3]);
colormap(handles.plt_pos,'jet');
c=colorbar(handles.plt_pos);
c.Label.String = 'Power [uW]';
title(handles.plt_pos,'Location matrix');
if isappdata(0,'diameter')&&isappdata(0,'centerx')&&isappdata(0,'centery')
    d=getappdata(0,'diameter');
    cx=getappdata(0,'centerx');
    cy=getappdata(0,'centery');
    axis(handles.plt_pos,[cx-d/2 cx+d/2 cy-d/2 cy+d/2]);
else
    axis(handles.plt_pos,[-10 10 -10 10]);
end
grid(handles.plt_pos,'on');
grid(handles.plt_pos,'minor');
xlabel(handles.plt_pos,'X position [um]');
ylabel(handles.plt_pos,'Y position [um]');

cla(handles.plt_time,'reset');
title(handles.plt_time,'Data in time domain');
[tm,ts]=calcTime();
time=tm*60+ts;
xlim(handles.plt_time,[0 time]);
xlabel(handles.plt_time,'Time [seconds]');
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');
yyaxis(handles.plt_time,'left');
ylabel(handles.plt_time,'Position [um]');
if isappdata(0,'diameter')
    d=getappdata(0,'diameter');
    ylim(handles.plt_time,[-d/2 d/2]);
else
    ylim(handles.plt_time,[-30 30]);
end
yyaxis(handles.plt_time,'right');
ylabel(handles.plt_time,'Power [uW]');
ylim(handles.plt_time,[0 3]);

if doPause==0 && wasPaused==0 && doStop==0
    set(handles.btn_ack,'visible','off');
    % prepare for simulation
    set_values('BUILDING',handles);
    [time_min,time_sec]=calcTime();
    time=strcat(num2str(time_min,'%02i'),':',num2str(time_sec,'%02i'));
    set(handles.val_time_est,'String',time);
    
    % run simulation
%     set(handles.val_sim,'String','ON');
%     set_values('RUNNING',handles);
    set(handles.val_time_exp,'String','00:00');
    main(0); % build sim
    beep;
end

switch doPause
    case 1 % paused mode, 
        set_values('PAUSED',handles);
        main(3); % Sim paused, waiting
    case 2 % unpaused mode
        set_values('RUNNING',handles);
        main(2); % continue sim
        btn_on_Callback(hObject, eventdata, handles);
    otherwise % normal mode
        if wasPaused==0
            set_values('RUNNING',handles);
            main(1); % run sim
            if doPause>0
                set_values('PAUSED',handles);
                btn_on_Callback(hObject, eventdata, handles);
            else
                set_values('FINISHED',handles);
            end
        else
           set_values('FINISHED',handles);
           wasPaused=0;
        end
end
% receive stored data
if ~isappdata(0,'x_data')||~isappdata(0,'y_data')||...
        ~isappdata(0,'p_data')||~isappdata(0,'t_data')||...
        ~isappdata(0,'loopnr')||~isappdata(0,'cyclenr')||...
        ~isappdata(0,'xmax')||~isappdata(0,'ymax')||~isappdata(0,'pmax')
    % error loading data
    set(handles.ind_error,'string','Error: Unable to receive stored data!');
    return;
end
% get appdata
time_t=getappdata(0,'t_data');
power_t=getappdata(0,'p_data');
xpos_t=getappdata(0,'x_data');
ypos_t=getappdata(0,'y_data');
cycle_nr_t=getappdata(0,'cyclenr');
pmax_t=getappdata(0,'pmax');
xmax_t=getappdata(0,'xmax')*50/4096; % convert to um
ymax_t=getappdata(0,'ymax')*50/4096; % convert to um

% skip initial & last number
time=time_t(2:end-2,1);
power=power_t(2:end-2,1);
xpos=xpos_t(2:end-2,1);
ypos=ypos_t(2:end-2,1);
cycle_nr=cycle_nr_t(2:end-2,1);
pmax=pmax_t(2:end-2,1);
xmax=xmax_t(2:end-2,1);
ymax=ymax_t(2:end-2,1);

% receive highest power per cycle
for cycle=1:max(cycle_nr)
    max_x(cycle,1)=xmax(find(cycle_nr==cycle,1,'last'));
    max_y(cycle,1)=ymax(find(cycle_nr==cycle,1,'last'));
    max_p(cycle,1)=pmax(find(cycle_nr==cycle,1,'last'));
end

% plot position [y(x), max_y(max_x)]
scatter(handles.plt_pos,xpos,ypos,1,power);
title(handles.plt_pos,'Location matrix');
colormap(handles.plt_pos,'jet');
c=colorbar(handles.plt_pos);
c.Label.String='Power [uW]';
axis(handles.plt_pos,[min(xpos) max(xpos) min(ypos) max(ypos)]);
grid(handles.plt_pos,'on');
grid(handles.plt_pos,'minor');
xlabel(handles.plt_pos,'X position [um]');
ylabel(handles.plt_pos,'Y position [um]');

% calculate relative position
offsetx=min(xpos)+(max(xpos)-min(xpos))/2;
offsety=min(ypos)+(max(ypos)-min(ypos))/2;
xrel=xpos-offsetx;
yrel=ypos-offsety;

% plot data [x(t),y(t),P(t)]
xlim(handles.plt_time,[0 max(time)]);
% primary side: positions [x & y]
yyaxis(handles.plt_time,'left');
plot(handles.plt_time,time,xrel,time,yrel);
ylim(handles.plt_time,[min(min(xrel),min(yrel)) max(max(xrel),max(yrel))]);
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');
ylabel(handles.plt_time,'Position [um]');

% secondary side: extra data [P, loop, cycle]
yyaxis(handles.plt_time,'right');
plot(handles.plt_time,time,power);
ylim(handles.plt_time,[min(power(:,1)) max(power(:,1))]);
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');
ylabel(handles.plt_time,'Power [uW]');
legend(handles.plt_time,'X position','Y position','Power','location','northoutside','Orientation','Horizontal');

% show position of highest power
set(handles.val_pmax,'String',strcat(num2str(round(max_p(end,1)*100)/100),' uW'));
set(handles.val_sweetx,'String',strcat(num2str(round(max_x(end,1)*100)/100),' um'));
set(handles.val_sweety,'String',strcat(num2str(round(max_y(end,1)*100)/100),' um'));

set(handles.val_p_prec,'String',strcat(num2str(round((max(max_p)-min(max_p))*100)/100),' nW'));
set(handles.val_sweetx_prec,'String',strcat(num2str(round((max(max_x)-min(max_x))*100)/100),' nm'));
set(handles.val_sweety_prec,'String',strcat(num2str(round((max(max_y)-min(max_y))*100)/100),' nm'));

if wasPaused==0
    set_values('IDLE',handles);
else
    m=floor(counter/600);
    s=floor(counter/10-m*60);
    t=strcat(num2str(m,'%02i'),':',num2str(s,'%02i'));
    set(findobj('tag','val_time_exp'),'String',t);
end

%% pressed btn_stop.
function btn_stop_Callback(hObject, eventdata, handles)
% hObject    handle to btn_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the button 'stop' is pressed. This function
% will stop the simulation safely. (meaning that the motors are turned off
% first and the read function is completed. Afterwards are the parameters
% and buttons enabled.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global wasPaused;
global doPause;
global doStop;
doStop=1;
set_values('STOPPED',handles);
main(-1);
set_values('IDLE',handles);
wasPaused=0;
doPause=0;
set(handles.ind_error,'string','System is stopped, check the Acknowledge box before running again');
set(handles.btn_ack,'value',0);
set(handles.btn_ack,'visible','on');

%% pressed btn_pause.
function btn_pause_Callback(hObject, eventdata, handles)
% hObject    handle to btn_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the button 'pause' is pressed. This function
% is enabled when the system is running and will allow the user to pause
% the system, change the parameters and re-run the system. Or only pause
% and later continue the system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global doPause;
global wasPaused;
switch doPause
    case 0 % pause
        % enable inputs
        wasPaused=wasPaused+1;
        set_values('PAUSED',handles);
        set(handles.btn_pause,'String','Unpause');
        doPause=1;
    case 1 % Unpause
        % disable inputs
        set_values('RUNNING',handles);
        set(handles.btn_pause,'String','Pause');
        doPause=2;
        btn_on_Callback(findobj('tag','btn_on'),eventdata,handles);
%         main(2);
    otherwise % unknown
        set_values('RUNNING',handles);
        doPause=0;
end

%% pressed btn_save
function btn_save_Callback(hObject, eventdata, handles)
% hObject    handle to btn_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the button 'save' is pressed. This will pop-up
% a save menu to select where to save it to and in which format. It is
% possible to save as an Excel file or as text file (CSV-format). When
% other formats are used is this function aborted, this also happens when
% the save menu is cancelled. In both cases is an error message displayed.
% The Excel file consist of a summary tab, tab with the all data, tab with
% all move parts and tabs for all the cycles. 
% The summary tab consisit of the parameters and the results as shown in
% the GUI itself. The 'ALL' tab consisit of data for the cycle and loop
% number, the x/y coordinates and the max power with coordinates.
% The move tab is similar to the ALL tab, but is the loop number skipped.
% The cycle tabs are also similar to the ALL tab, but is the cycle number
% skipped.
% For the CSV files is a new file with '_param' at the end created which
% contains the parameters and results (same as the summary tab in Excel)
% the normal csv-file is similar to the all tab in Excel.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set(handles.val_status,'String','SAVE');
set_values('SAVING',handles);
% get appdata
if ~isappdata(0,'acc')||~isappdata(0,'centerx')||~isappdata(0,'centery')||~isappdata(0,'cyclenr')||...
        ~isappdata(0,'delay')||~isappdata(0,'diameter')||~isappdata(0,'loopnr')||~isappdata(0,'p_data')||...
        ~isappdata(0,'pmax')||~isappdata(0,'read_time')||~isappdata(0,'scale')||~isappdata(0,'t_data')||...
        ~isappdata(0,'tot_acc')||~isappdata(0,'x_data')||~isappdata(0,'xmax')||~isappdata(0,'y_data')||~isappdata(0,'ymax')
    % error loading
    set(handles.ind_error,'String','Error: Some data is unavailable!');
    set_values('IDLE',handles);
    return;
end

power_temp=getappdata(0,'p_data');
loop_nr_temp=getappdata(0,'loopnr');
cycle_nr_temp=getappdata(0,'cyclenr');
xpos_temp=getappdata(0,'x_data');
ypos_temp=getappdata(0,'y_data');
time_temp=getappdata(0,'t_data');
pmax_temp=getappdata(0,'pmax');
xmax_temp=getappdata(0,'xmax')*50/4096;
ymax_temp=getappdata(0,'ymax')*50/4096;

% skip initial & last number
power=power_temp(2:end-2,1);
centerx=getappdata(0,'centerx');
centery=getappdata(0,'centery');
diameter=getappdata(0,'diameter');
loop_nr=loop_nr_temp(2:end-2,1);
cycle_nr=cycle_nr_temp(2:end-2,1);
scale=getappdata(0,'scale');
delay=getappdata(0,'delay');
tRead=getappdata(0,'read_time');
acc=getappdata(0,'acc');
tot_acc=getappdata(0,'tot_acc');
xpos=xpos_temp(2:end-2,1);
ypos=ypos_temp(2:end-2,1);
time=time_temp(2:end-2,1);
pmax=pmax_temp(2:end-2,1);
xmax=xmax_temp(2:end-2,1);
ymax=ymax_temp(2:end-2,1);

% get best position per cycle
for cycle=1:max(cycle_nr)
    max_x(cycle,1)=xmax(find(cycle_nr==cycle,1,'last'));
    max_y(cycle,1)=ymax(find(cycle_nr==cycle,1,'last'));
    max_p(cycle,1)=pmax(find(cycle_nr==cycle,1,'last'));
end

% show save menu
[filename,pathname]=uiputfile({'*.xlsx','Excel-Workbook';...
    '*.csv','CSV (Comma-Seperated Value)';...
    '*.txt','Text Document';'*.*','All Files'}...
    ,'Save location','Alignment_Data.xlsx');
if isequal(filename,0)||isequal(pathname,0)
    % save canceled
    set_values('IDLE',handles);
    return;
end

% save location found
[f,fname,fext]=fileparts(filename);
save_loc=fullfile(pathname,[fname,fext]);
switch lower(fext) % make sure extension is all lower case
    case {'.xlsx','.xls'}
        centerx_str=strcat(num2str(floor(centerx)),',',num2str(floor((centerx-floor(centerx))*1000)));
        centery_str=strcat(num2str(floor(centery)),',',num2str(floor((centery-floor(centery))*1000)));
        diameter_str=strcat(num2str(floor(diameter)),',',num2str(floor((diameter-floor(diameter))*1000)));
        loops_str=strcat(num2str(floor(max(loop_nr))),',',num2str(floor((max(loop_nr)-floor(max(loop_nr)))*1000)));
        cycles_str=strcat(num2str(floor(max(cycle_nr))),',',num2str(floor((max(cycle_nr)-floor(max(cycle_nr)))*1000)));
        scale_str=strcat(num2str(floor(scale)),',',num2str(floor((scale-floor(scale))*1000)));
        delay_str=strcat(num2str(floor(delay)),',',num2str(floor((delay-floor(delay))*1000)));
        read_str=strcat(num2str(floor(tRead)),',',num2str(floor((tRead-floor(tRead))*1000)));
        acc_str=strcat(num2str(floor(acc)),',',num2str(floor((acc-floor(acc))*1000)));
        totacc_str=strcat(num2str(floor(tot_acc)),',',num2str(floor((tot_acc-floor(tot_acc))*1000)));
        posxmin=round(min(xpos)*1000)/1000;
        posxmax=round(max(xpos)*1000)/1000;
        posymin=round(min(ypos)*1000)/1000;
        posymax=round(max(ypos)*1000)/1000;
        if posxmin<0
            xmin_str=strcat(num2str(ceil(posxmin)),',',num2str(ceil((abs(posxmin-ceil(posxmin))*1000))));
        else
            xmin_str=strcat(num2str(floor(posxmin)),',',num2str(floor((posxmin-floor(posxmin))*1000)));
        end
        if posxmax<0
            xmax_str=strcat(num2str(ceil(posxmax)),',',num2str(ceil((abs(posxmax-ceil(posxmax))*1000))));
        else
            xmax_str=strcat(num2str(floor(posxmax)),',',num2str(floor((posxmax-floor(posxmax))*1000)));
        end
        if posymin<0
            ymin_str=strcat(num2str(ceil(posymin)),',',num2str(ceil((abs(posymin-ceil(posymin))*1000))));
        else
            ymin_str=strcat(num2str(floor(posymin)),',',num2str(floor((posymin-floor(posymin))*1000)));
        end
        if posymax<0
            ymax_str=strcat(num2str(ceil(posymax)),',',num2str(ceil((abs(posymax-ceil(posymax))*1000))));
        else
            ymax_str=strcat(num2str(floor(posymax)),',',num2str(floor((posymax-floor(posymax))*1000)));
        end
        tmin=floor(max(time)/60);
        tsec=ceil(max(time)-tmin*60);
        min_str=strcat(num2str(floor(tmin)),',',num2str(floor((tmin-floor(tmin))*1000)));
        sec_str=strcat(num2str(floor(tsec)),',',num2str(floor((tsec-floor(tsec))*1000)));
        pmax=round(max_p(end)*1000/1000);
        pmax_p=round((max(max_p)-min(max_p))*1000000)/1000;
        pmax_str=strcat(num2str(floor(pmax)),',',num2str(floor((pmax-floor(pmax))*1000)));
        pmax_p_str=strcat(num2str(floor(pmax_p)),',',num2str(floor((pmax_p-floor(pmax_p))*1000)));
        pxmax=round(max_x(end)*1000/1000);
        pxmax_p=round((max(max_x)-min(max_x))*1000000)/1000;
        pxmax_str=strcat(num2str(floor(pxmax)),',',num2str(floor((pxmax-floor(pxmax))*1000)));
        pxmax_p_str=strcat(num2str(floor(pxmax_p)),',',num2str(floor((pxmax_p-floor(pxmax_p))*1000)));
        pymax=round(max_y(end)*1000/1000);
        pymax_p=round((max(max_y)-min(max_y))*1000000)/1000;
        pymax_str=strcat(num2str(floor(pymax)),',',num2str(floor((pymax-floor(pymax))*1000)));
        pymax_p_str=strcat(num2str(floor(pymax_p)),',',num2str(floor((pymax_p-floor(pymax_p))*1000)));
        
        
        % Create SUMMARY tab
        summary={...
            'PARAMETERS','', '','','';...
            'Center',centerx_str,'um',centery_str,'um';...
            'Diameter',diameter_str,'um','','';...
            'Loops',loops_str,'','Cycles',cycles_str;...
            'Scale',scale_str,'X','','';...
            'Delay time',delay_str,'samples','','';...
            'Read time',read_str,'samples','','';...
            'Accuracy',acc_str,'nm /',totacc_str,'nm';...
            'RESULTS','','','','';...
            'Frequency','800','Hz','125','ms';...
            'Range X',xmin_str,'um',xmax_str,'um';...
            'Range Y',ymin_str,'um',ymax_str,'um';...
            'Time',min_str,'min',sec_str,'sec';...
            'High power',pmax_str,'uW ±',pmax_p_str,'nW';...
            'Location X',pxmax_str,'um ±',pxmax_p_str,'nm';...
            'Location Y',pymax_str,'um ±',pymax_p_str,'nm'};
        
%         summary={...
%             'PARAMETERS','', '','','';...
%             'Center',num2str(centerx),'um',num2str(centery),'um';...
%             'Diameter',num2str(diameter),'um','','';...
%             'Loops',num2str(max(loop_nr)),'','Cycles',num2str(max(cycle_nr));...
%             'Scale',num2str(scale),'X','','';...
%             'Delay time',num2str(delay),'samples','','';...
%             'Read time',num2str(tRead),'samples','','';...
%             'Accuracy',num2str(acc),'nm /',num2str(tot_acc),'nm';...
%             'RESULTS','','','','';...
%             'Frequency','800','Hz','125','ms';...
%             'Range X',num2str(round(min(xpos)*1000)/1000),'um',num2str(round(max(xpos)*1000)/1000),'um';...
%             'Range Y',num2str(round(min(ypos)*1000)/1000),'um',num2str(round(max(ypos)*1000)/1000),'um';...
%             'Time',num2str(floor(max(time)/60)),'min',num2str(ceil(max(time)-floor(max(time)/60)*60)),'sec';...
%             'High power',num2str(round(max_p(end)*1000)/1000),'uW ?',num2str(round((max(max_p)-min(max_p))*1000000)/1000),'nW';...
%             'Location X',num2str(round(max_x(end)*1000)/1000),'um ?',num2str(round((max(max_x)-min(max_x))*1000000)/1000),'nm';...
%             'Location Y',num2str(round(max_y(end)*1000)/1000),'um ?',num2str(round((max(max_y)-min(max_y))*1000000)/1000),'nm'};
        xlswrite(save_loc,summary,'SUMMARY','A1');

        % Create ALL DATA tab
        all_header={'Time','Cycle','Loop','Xpos','Ypos','Power','Xmax','Ymax'};
        all_data=[time,cycle_nr,loop_nr,xpos,ypos,power,xmax,ymax];
        xlswrite(save_loc,all_header,'ALL','A1');
        xlswrite(save_loc,all_data,'ALL','A2');

        % Create MOVE tab
        move_header={'Time','Cycle','Xpos','Ypos','Power','Xmax','Ymax'};
        move_data=[time,cycle_nr,xpos,ypos,power,xmax,ymax];
        xlswrite(save_loc,move_header,'Move','A1');
        xlswrite(save_loc,move_data(find(loop_nr==0),:),'Move','A2');

        % Create CYCLE tabs
        cycle_header={'Time','Loop','Xpos','Ypos','Power','Xmax','Ymax'};
        cycle_data=[time,loop_nr,xpos,ypos,power,xmax,ymax];
        for cycle=1:max(cycle_nr)
            name=strcat('Cycle',num2str(cycle));
            xlswrite(save_loc,cycle_header,name,'A1');
            xlswrite(save_loc,cycle_data(find((cycle_nr==cycle)&(loop_nr>0)),:),name,'A2');
        end
    case {'.csv','.txt'}
        % Create PARAMETER file
        summary={...
            'PARAMETERS';...
            strcat('Center',num2str(centerx),'um',num2str(centery),'um');...
            strcat('Diameter',num2str(diameter),'um');...
            strcat('Loops',num2str(max(loop_nr)));...
            strcat('Scale',num2str(scale),'X');...
            strcat('Delay time',num2str(delay),'samples');...
            strcat('Read time',num2str(tRead),'samples');...
            strcat('Accuracy',num2str(acc),'nm / ',num2str(tot_acc),'nm');...
            'RESULTS';...
            'Frequency: 800 Hz, 125 ms';...
            strcat('Range X',num2str(round(min(xpos)*1000)/1000),'um',num2str(round(max(xpos)*1000)/1000),'um');...
            strcat('Range Y',num2str(round(min(ypos)*1000)/1000),'um',num2str(round(max(ypos)*1000)/1000),'um');...
            strcat('Time',num2str(floor(max(time)/60)),'min',num2str(ceil(max(time)-floor(max(time)/60)*60)),'sec');...
            strcat('High power',num2str(round(mean(max_p)*1000)/1000),'uW ?',num2str(round((max(max_p)-min(max_p))*1000000)/1000),'nW');...
            strcat('Location X',num2str(round(mean(max_x)*1000)/1000),'um ?',num2str(round((max(max_x)-min(max_x))*1000000)/1000),'nm');...
            strcat('Location Y',num2str(round(mean(max_y)*1000)/1000),'um ?',num2str(round((max(max_y)-min(max_y))*1000000)/1000),'nm')};
        data_param=table(summary);
        data=[time,cycle_nr,loop_nr,xpos,ypos,power,xmax,ymax];
        param_loc=strcat(fname,'_param',fext);
        writetable(data_param,param_loc,'WriteVariableNames',1);
        % create DATA file
        data_table=table(data);
        writetable(data_table,save_loc,'WriteVariableNames',1);
    otherwise
        % cancel save
        set(handles.ind_error,'String','Error: Unable to save as specified format!');
end
set_values('IDLE',handles);
set(handles.ind_error,'String',strcat('Saved as: ',fname,fext));
beep;

%% pressed btn_debug.
function btn_debug_Callback(hObject, eventdata, handles)
% hObject    handle to btn_debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of btn_debug

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the button 'debug' is checked or unchecked. By
% default is the system set to the external mode, the user can choose to
% set it to debug mode. This way is the Arduino disconnected from the
% system and is the runtime a lot quicker, ideal for testing.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if get(hObject,'Value')==1
    % run simulink in debug mode
    set_param('Autoalign_system','SimulationMode','normal');
    set_values('DEBUG',handles);
else
    % run simulink in external mode
    set_param('Autoalign_system','SimulationMode','external');
    set_values('EXTERNAL',handles);
end

%% Pressed btn_reset
function btn_reset_Callback(hObject, eventdata, handles)
% hObject    handle to btn_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the button 'reset' is pressed. This will
% pop-up a window which asks for confirmation of resetting the system. The
% reset will only re-initialize the GUI, not the simulation!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(handles.val_status,'String','RESET?');
reset=questdlg('Do you really want to reset the interface?!','Reset','Cancel','Reset','Cancel');
if strcmp(reset,'Cancel')
    return
end
beep;
UserInterface_OpeningFcn(findobj('Tag','fig_GUI'),eventdata,handles);
% --- Executes on button press in btn_ack.
function btn_ack_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btn_ack
global doStop;
ack=get(hObject,'Value');
if ack==1
    % cleared stop --> continue
    doStop=0;
end
%% SETTING VALUES
function val_centerx_Callback(hObject, eventdata, handles)
% hObject    handle to val_centerx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_centerx as text
%        str2double(get(hObject,'String')) returns contents of val_centerx as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the value for 'center X' is changed. First is
% checked whether the value is valid, then is the time re-calculated. The
% center value is used to define the offset at which the system need to
% start. [default value is 0um]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'i')||contains(val,'j')...
        ||isempty(val)||isnan(check)||check>10000||check<-10000
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Error: Invalid value, -10.000 < CenterX < 10.000');
    inputerr(1,1)=1;
else
    inputerr(1,1)=0;
    setappdata(0,'centerx',check); % Update value in appdata
    % update time
    [time_min,time_sec]=calcTime();
    time=strcat(num2str(time_min,'%02i'),':',num2str(time_sec,'%02i'));
    set(handles.val_time_est,'String',time);
    % flash green
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the value for 'center Y' is changed. First is
% checked whether the value is valid, then is the time re-calculated. The
% center value is used to define the offset at which the system need to
% start. [default value is 0um]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'i')||contains(val,'j')...
        ||isempty(val)||isnan(check)||check>10000||check<-10000
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Error: Invalid value, -10.000 < CenterY < 10.000');
    inputerr(2,1)=1;
else
    inputerr(2,1)=0;
    setappdata(0,'centery',check); % Update value in appdata
    % update time
    [time_min,time_sec]=calcTime();
    time=strcat(num2str(time_min,'%02i'),':',num2str(time_sec,'%02i'));
    set(handles.val_time_est,'String',time);
    % flash green
    set(hObject,'backgroundColor',[0 .5 0]);% green
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end
function val_diameter_Callback(hObject, eventdata, handles)
% hObject    handle to val_diameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_diameter as text
%        str2double(get(hObject,'String')) returns contents of val_diameter as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the value for 'Diameter' is changed. First is
% checked whether the value is valid, then are the time, cycles and accuracy
% re-calculated. The Diameter is used to define the total area in which the
% search will take place. [default value is 20um]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'i')||contains(val,'j')...
        ||contains(val,'-')||isempty(val)||isnan(check)||check>10000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Error: Invalid value, 1 < Diameter < 10.000');
    inputerr(3,1)=1;
else
    inputerr(3,1)=0;
    tot_acc=getappdata(0,'tot_acc');
    loops=getappdata(0,'loops');
    scale=getappdata(0,'scale');
    % update diameter
    setappdata(0,'diameter',check);
    % update cycles + acc
    cycles=ceil(1+log(1000*check/((2*loops-1)*tot_acc))/log(scale));
    acc=round(1000*check*scale^(1-cycles)/(2*loops-1));
    setappdata(0,'cycles',cycles);
    setappdata(0,'acc',acc);
    % update time
    [time_min,time_sec]=calcTime();
    time=strcat(num2str(time_min,'%02i'),':',num2str(time_sec,'%02i'));
    % show values
    set(handles.val_diameter,'String',num2str(check));
    set(handles.val_acc,'String',strcat(num2str(acc),' nm'));
    set(handles.val_cycle,'String',num2str(cycles));
    set(handles.val_time_est,'String',time);
    % flash green
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the value for 'Loops' is changed. First is
% checked whether the value is valid, then are the time, cycles and accuracy
% re-calculated. The number of loops is used to minimize the number of
% cycles and to increase the overall accuracy. [default value is 3 loops]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>50||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Error: Invalid value, 1 < Loops < 50');
    inputerr(4,1)=1;
else
    inputerr(4,1)=0;
    tot_acc=getappdata(0,'tot_acc');
    diameter=getappdata(0,'diameter');
    scale=getappdata(0,'scale');
    % update loops
    setappdata(0,'loops',check);
    % update cycles + acc
    cycles=ceil(1+log(1000*diameter/((2*check-1)*tot_acc))/log(scale));
    acc=round(1000*diameter*scale^(1-cycles)/(2*check-1));
    setappdata(0,'cycles',cycles);
    setappdata(0,'acc',acc);
    % update time
    [time_min,time_sec]=calcTime();
    time=strcat(num2str(time_min,'%02i'),':',num2str(time_sec,'%02i'));
    % show values
    set(handles.val_loops,'String',num2str(check));
    set(handles.val_acc,'String',strcat(num2str(acc),' nm'));
    set(handles.val_cycle,'String',num2str(cycles));
    set(handles.val_time_est,'String',time);
    % flash green
    set(hObject,'backgroundColor',[0 .5 0]);% green
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end
function val_tot_acc_Callback(hObject, eventdata, handles)
% hObject    handle to val_tot_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_tot_acc as text
%        str2double(get(hObject,'String')) returns contents of val_tot_acc as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the value for 'Total Accuracy' is changed. First is
% checked whether the value is valid, then are the time, cycles and accuracy
% re-calculated. The total accuracy is used to determine what the maximum
% allowed deviation between loops is. [default value is 500nm]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>100000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Error: Invalid value, 1 < Total accuracy < 100000');
    inputerr(5,1)=1;
else
    inputerr(5,1)=0;
    diameter=getappdata(0,'diameter');
    loops=getappdata(0,'loops');
    scale=getappdata(0,'scale');
    % update tot_acc
    setappdata(0,'tot_acc',check);
    % update cycles + acc
    cycles=ceil(1+log(1000*diameter/((2*loops-1)*check))/log(scale));
    acc=round(1000*diameter*scale^(1-cycles)/(2*loops-1));
    setappdata(0,'cycles',cycles);
    setappdata(0,'acc',acc);
    % update time
    [time_min,time_sec]=calcTime();
    time=strcat(num2str(time_min,'%02i'),':',num2str(time_sec,'%02i'));
    % show values
    set(handles.val_tot_acc,'String',num2str(check));
    set(handles.val_acc,'String',strcat(num2str(acc),' nm'));
    set(handles.val_cycle,'String',num2str(cycles));
    set(handles.val_time_est,'String',time);
    % flash green
    set(hObject,'backgroundColor',[0 .5 0]);% green
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end
function val_scale_Callback(hObject, eventdata, handles)
% hObject    handle to val_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_scale as text
%        str2double(get(hObject,'String')) returns contents of val_scale as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the value for 'Scale' is changed. First is
% checked whether the value is valid, then are the time, cycles and accuracy
% re-calculated. The scale factor is used to define how much smaller the
% diameter decreased per cycle. [default value is 2x]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>20||check<=1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Error: Invalid value, 1 <= Scale < 20');
    inputerr(6,1)=1;
else
    inputerr(6,1)=0;
    tot_acc=getappdata(0,'tot_acc');
    diameter=getappdata(0,'diameter');
    loops=getappdata(0,'loops');
    % update loops
    setappdata(0,'scale',check);
    % update cycles + acc
    cycles=ceil(1+log(1000*diameter/((2*loops-1)*tot_acc))/log(check));
    acc=round(1000*diameter*check^(1-cycles)/(2*loops-1));
    setappdata(0,'cycles',cycles);
    setappdata(0,'acc',acc);
    % update time
    [time_min,time_sec]=calcTime();
    time=strcat(num2str(time_min,'%02i'),':',num2str(time_sec,'%02i'));
    % show values
    set(handles.val_scale,'String',num2str(check));
    set(handles.val_acc,'String',strcat(num2str(acc),' nm'));
    set(handles.val_cycle,'String',num2str(cycles));
    set(handles.val_time_est,'String',time);
    % flash green
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the value for 'Delay' is changed. First is
% checked whether the value is valid, then is the time re-calculated. The
% delay value is used to determine the interval between two readings
% [default value is 16 samples]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>1000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Error: Invalid value, 1 < Delay < 1000');
    inputerr(7,1)=1;
else
    inputerr(7,1)=0;
    setappdata(0,'delay',check); % Update value in appdata
    % update time
    [time_min,time_sec]=calcTime();
    time=strcat(num2str(time_min,'%02i'),':',num2str(time_sec,'%02i'));
    set(handles.val_time_est,'String',time);
    % flash green
    set(hObject,'backgroundColor',[0 .5 0]);% green
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end
function val_read_Callback(hObject, eventdata, handles)
% hObject    handle to val_read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_read as text
%        str2double(get(hObject,'String')) returns contents of val_read as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the value for 'Read' is changed. First is
% checked whether the value is valid, then is the time re-calculated. The
% read value is used to set the number of samples required to read the
% power. [default value is 1 sample]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>1000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Error: Invalid value, 1 < Read time < 1000');
    inputerr(8,1)=1;
else
    inputerr(8,1)=0;
    setappdata(0,'read_time',check); % Update value in appdata
    % update time
    [time_min,time_sec]=calcTime();
    time=strcat(num2str(time_min,'%02i'),':',num2str(time_sec,'%02i'));
    set(handles.val_time_est,'String',time);
    % flash green
    set(hObject,'backgroundColor',[0 .5 0]);% green
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end
function val_pSet_Callback(hObject, eventdata, handles)
% hObject    handle to val_pSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_pSet as text
%        str2double(get(hObject,'String')) returns contents of val_pSet as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the value for 'Max power' is changed. This
% function is used to test the accuracy of the system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

val=get(hObject,'String');
check=str2double(val);
setappdata(0,'p_set',check); % Update value in appdata
% flash green
set(hObject,'backgroundColor',[0 .5 0]);% green
pause(.05);
set(hObject,'backgroundColor',[1 1 1]);% white
function val_pxSet_Callback(hObject, eventdata, handles)
% hObject    handle to val_pxSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_pxSet as text
%        str2double(get(hObject,'String')) returns contents of val_pxSet as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the value for 'Location X' is changed. This
% function is used to test the accuracy of the system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

val=get(hObject,'String');
check=str2double(val);
setappdata(0,'px_set',check); % Update value in appdata
% flash green
set(hObject,'backgroundColor',[0 .5 0]);% green
pause(.05);
set(hObject,'backgroundColor',[1 1 1]);% white
function val_pySet_Callback(hObject, eventdata, handles)
% hObject    handle to val_pySet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_pySet as text
%        str2double(get(hObject,'String')) returns contents of val_pySet as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This callback is used when the value for 'Location Y' is changed. This
% function is used to test the accuracy of the system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

val=get(hObject,'String');
check=str2double(val);
setappdata(0,'py_set',check); % Update value in appdata
% flash green
set(hObject,'backgroundColor',[0 .5 0]);% green
pause(.05);
set(hObject,'backgroundColor',[1 1 1]);% white
function val_pfactor_Callback(hObject, eventdata, handles)
% hObject    handle to val_pfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_pfactor as text
%        str2double(get(hObject,'String')) returns contents of val_pfactor as a double
val=get(hObject,'String');
check=str2double(val);
setappdata(0,'pfactor_set',check); % Update value in appdata
% flash green
set(hObject,'backgroundColor',[0 .5 0]);% green
pause(.05);
set(hObject,'backgroundColor',[1 1 1]);% white

%% SHOWING VALUES
function val_sample_Callback(hObject, eventdata, handles)
% hObject    handle to val_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of val_time as text
%        str2double(get(hObject,'String')) returns contents of val_time as a double
function val_acc_Callback(hObject, eventdata, handles)
% hObject    handle to ind_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_acc as text
%        str2double(get(hObject,'String')) returns contents of ind_acc as a double
function val_xmin_Callback(hObject, eventdata, handles)
% hObject    handle to ind_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_xmin as text
%        str2double(get(hObject,'String')) returns contents of ind_xmin as a double
function val_ymin_Callback(hObject, eventdata, handles)
% hObject    handle to ind_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_ymin as text
%        str2double(get(hObject,'String')) returns contents of ind_ymin as a double
function val_xmax_Callback(hObject, eventdata, handles)
% hObject    handle to ind_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_xmax as text
%        str2double(get(hObject,'String')) returns contents of ind_xmax as a double
function val_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to ind_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_ymax as text
%        str2double(get(hObject,'String')) returns contents of ind_ymax as a double
function val_cycles_Callback(hObject, eventdata, handles)
% hObject    handle to int_cyclecnt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of int_cyclecnt as text
%        str2double(get(hObject,'String')) returns contents of int_cyclecnt as a double
function val_Pmin_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of val_Pmin as text
%        str2double(get(hObject,'String')) returns contents of val_Pmin as a double
function val_Pmax_Callback(hObject, eventdata, handles)
% hObject    handle to ind_Pmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_Pmax as text
%        str2double(get(hObject,'String')) returns contents of ind_Pmax as a double
function val_Pxmin_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pxmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of val_Pxmin as text
%        str2double(get(hObject,'String')) returns contents of val_Pxmin as a double
function val_Pxmax_Callback(hObject, eventdata, handles)
% hObject    handle to ind_Px (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_Px as text
%        str2double(get(hObject,'String')) returns contents of ind_Px as a double
function val_Pymin_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of val_Pymin as text
%        str2double(get(hObject,'String')) returns contents of val_Pymin as a double
function val_Pymax_Callback(hObject, eventdata, handles)
% hObject    handle to ind_Py (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_Py as text
%        str2double(get(hObject,'String')) returns contents of ind_Py as a double
function val_Ptmin_Callback(hObject, eventdata, handles)
% hObject    handle to val_Ptmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of val_Ptmin as text
%        str2double(get(hObject,'String')) returns contents of val_Ptmin as a double
function val_Ptmax_Callback(hObject, eventdata, handles)
% hObject    handle to val_Ptmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of val_Ptmax as text
%        str2double(get(hObject,'String')) returns contents of val_Ptmax as a double
function val_T_est_m_Callback(hObject, eventdata, handles)
% hObject    handle to ind_est_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_est_time as text
%        str2double(get(hObject,'String')) returns contents of ind_est_time as a double
function val_T_est_s_Callback(hObject, eventdata, handles)
% hObject    handle to ind_est_sec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_est_sec as text
%        str2double(get(hObject,'String')) returns contents of ind_est_sec as a double
function val_time_m_Callback(hObject, eventdata, handles)
% hObject    handle to ind_exp_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_exp_time as text
%        str2double(get(hObject,'String')) returns contents of ind_exp_time as a double
function val_time_s_Callback(hObject, eventdata, handles)
% hObject    handle to ind_exp_sec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_exp_sec as text
%        str2double(get(hObject,'String')) returns contents of ind_exp_sec as a double
function val_x_prec_Callback(hObject, eventdata, handles)
% hObject    handle to ind_Pxprec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_Pxprec as text
%        str2double(get(hObject,'String')) returns contents of ind_Pxprec as a double
function val_y_prec_Callback(hObject, eventdata, handles)
% hObject    handle to ind_Pyprec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_Pyprec as text
%        str2double(get(hObject,'String')) returns contents of ind_Pyprec as a double
function val_P_prec_Callback(hObject, eventdata, handles)
% hObject    handle to ind_Pprec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_Pprec as text
%        str2double(get(hObject,'String')) returns contents of ind_Pprec as a double

%% VAL_CREATE FCN'S
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
function val_read_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_tot_acc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_tot_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_scale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_sample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_acc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function int_cyclecnt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int_cyclecnt (see GCBO)
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
function ind_Pmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_Pmax (see GCBO)
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
function ind_Px_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_Px (see GCBO)
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
function ind_Py_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_Py (see GCBO)
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
function val_Ptmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_Ptmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_est_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_est_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_est_sec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_est_sec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_exp_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_exp_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_exp_sec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_exp_sec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_Pxprec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_Pxprec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_Pyprec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_Pyprec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ind_Pprec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_Pprec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_pSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_pSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_pxSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_pxSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_pySet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_pySet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_pfactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_pfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%% END USERINTERFACE
