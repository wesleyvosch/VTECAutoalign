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

% Last Modified by GUIDE v2.5 14-Jun-2017 11:49:17

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
load_system('Autoalign_system.slx'); % load simulink model
set_param('Autoalign_system','SimulationMode','external'); % set model to external mode

%% STORAGE
% declare global variables
global doPause;
global inputerr;
global changes;

doPause=0;
inputerr=zeros(8,1);
changes=0;

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

% set appdata values
setappdata(0,'diameter',diameter);
setappdata(0,'centerx',centerx);
setappdata(0,'centery',centery);
setappdata(0,'loops',loops);
setappdata(0,'scale',scale);
setappdata(0,'tot_acc',tot_acc);
setappdata(0,'delay',delay);
setappdata(0,'read_time',read);

cycles=ceil(1+log(1000*diameter/((2*loops-1)*tot_acc))/log(scale));
acc=round(1000*diameter*scale^(1-cycles)/(2*loops-1));
setappdata(0,'cycles',cycles);
setappdata(0,'acc',acc);
[tm,ts]=calcTime();

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

% Default settings for simulation indicator
set(handles.ind_sim,'String','OFF');
set(handles.ind_sim,'Foregroundcolor','black');

% Default niput values
set(handles.ind_status,'String','EXTERNAL');
set(handles.ind_status,'Foregroundcolor','black');
set(handles.ind_sample,'String','800');
set(handles.int_cyclecnt,'String',num2str(cycles));
set(handles.ind_acc,'String',num2str(acc));

% Default output values
set(handles.ind_xmin,'String',num2str(centerx-diameter/2));
set(handles.ind_xmax,'String',num2str(centerx+diameter/2));
set(handles.ind_ymin,'String',num2str(centery-diameter/2));
set(handles.ind_ymax,'String',num2str(centery+diameter/2));
set(handles.ind_est_min,'String',num2str(tm));
set(handles.ind_est_sec,'String',num2str(ts));

set(handles.ind_Pmax,'String','x');
set(handles.ind_Pprec,'String','x');
set(handles.ind_Px,'String','x');
set(handles.ind_Pxprec,'String','x');
set(handles.ind_Py,'String','x');
set(handles.ind_Pyprec,'String','x');
set(handles.ind_exp_min,'String','x');
set(handles.ind_exp_sec,'String','x');

% Default settings for buttons
set(handles.btn_on,'string','Run');
set(handles.btn_on,'Enable','on');
set(handles.btn_pause,'string','Pause');
set(handles.btn_pause,'Enable','off');
set(handles.btn_save,'Enable','off');
set(handles.btn_reset,'Enable','on');
set(handles.btn_stop,'Enable','on');
set(handles.btn_debug,'value',0);
set(handles.btn_debug,'Enable','on');

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
ylabel(handles.plt_time,'Position [um]');
ylim(handles.plt_time,[-diameter/2 diameter/2]);
yyaxis(handles.plt_time,'right');
ylabel(handles.plt_time,'Power [uW]');
ylim(handles.plt_time,[0 3]);
%% END OF INITIALIZATION

% --- Outputs from this function are returned to the command line.
function varargout = UserInterface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% BUTTON CALLBACKS
% --- Executes on button press in btn_on.
function btn_on_Callback(hObject, eventdata, handles)
% hObject    handle to btn_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% state=str2double(get(hObject,'Value'));
global doPause;
global changes;
global inputerr;

if max(inputerr)>0
    % error in parameters
    err_msg=strcat('ERROR: Unable to start simulation, there are ',num2str(sum(inputerr)),...
        ' pending errors! Solve these errors before running the program.');
    set(handles.ind_error,'String',err_msg);
    return;
else
    % clear error message
    set(handles.ind_error,'String','');
end
% disable inputs
set(handles.val_centerx,'Enable','off');
set(handles.val_centery,'Enable','off');
set(handles.val_diameter,'Enable','off');
set(handles.val_loops,'Enable','off');
set(handles.val_delay,'Enable','off');
set(handles.val_read,'Enable','off');
set(handles.val_tot_acc,'Enable','off');
set(handles.val_scale,'Enable','off');
set(handles.btn_on,'Enable','off');
set(handles.btn_save,'Enable','off');
set(handles.btn_debug,'Enable','off');

% clear output values
set(handles.ind_Pmax,'String','x');
set(handles.ind_Px,'String','x');
set(handles.ind_Py,'String','x');
set(handles.ind_exp_min,'String','x');
set(handles.ind_exp_sec,'String','x');

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

if doPause==0
    % prepare for simulation
    set(handles.ind_status,'String','PREPARING');
    [time_min,time_sec]=calcTime();
    set(handles.ind_est_min,'String',num2str(time_min));
    set(handles.ind_est_sec,'String',num2str(time_sec));
    % run simulation
    set(handles.btn_stop,'Enable','off');
    set(handles.ind_sim,'String','ON');
    main(0); % build sim
end

switch doPause
    case 1 % paused mode, 
        set(handles.btn_on,'Enable','off');
        set(handles.btn_stop,'Enable','on');
        set(handles.btn_save,'Enable','on');
        set(handles.btn_pause,'Enable','on');
        set(handles.btn_pause,'string','Unpause');
        set(handles.ind_status,'String','PAUSED');
        set(handles.btn_on,'Enable','on');
        set(handles.btn_debug,'Enable','on');
        main(3); % Sim paused, waiting
    case 2 % unpaused mode
        if changes==1 % rerun sim
            set(handles.btn_on,'Enable','off');
            set(handles.btn_save,'Enable','off');
            set(handles.btn_pause,'Enable','off');
            set(handles.btn_pause,'string','Pause');
            set(handles.btn_debug,'Enable','off');
            set(handles.ind_status,'String','RE-BUILDING');
            doPause=0;
            changes=0;
            btn_on_Callback(hObject, eventdata, handles);
        else % continue sim
            set(handles.btn_on,'Enable','off');
            set(handles.btn_save,'Enable','off');
            set(handles.btn_pause,'Enable','on');
            set(handles.btn_pause,'string','Pause');
            set(handles.ind_sim,'String','ON');
            set(handles.btn_debug,'Enable','off');
            set(handles.ind_status,'String','RUNNING');
            set(handles.btn_on,'Enable','off');
            main(2); % continue sim
            btn_on_Callback(hObject, eventdata, handles);
        end
    otherwise % normal mode
        set(handles.btn_on,'Enable','off');
        set(handles.btn_stop,'Enable','on');
        set(handles.btn_save,'Enable','off');
        set(handles.btn_pause,'Enable','on');
        set(handles.ind_status,'String','RUNNING');
        main(1); % run sim
        set(handles.btn_on,'Enable','on');
        set(handles.btn_stop,'Enable','on');
        set(handles.btn_save,'Enable','on');
        set(handles.btn_pause,'Enable','off');
        set(handles.btn_debug,'Enable','on');
        set(handles.ind_status,'String','FINISHED');
end

% enable inputs
set(handles.val_centerx,'Enable','on');
set(handles.val_centery,'Enable','on');
set(handles.val_diameter,'Enable','on');
set(handles.val_loops,'Enable','on');
set(handles.val_delay,'Enable','on');
set(handles.val_read,'Enable','on');
set(handles.val_tot_acc,'Enable','on');
set(handles.val_scale,'Enable','on');
set(handles.btn_on,'Enable','on');

% receive stored data
if ~isappdata(0,'x_data')||~isappdata(0,'y_data')||...
        ~isappdata(0,'p_data')||~isappdata(0,'t_data')||...
        ~isappdata(0,'loopnr')||~isappdata(0,'cyclenr')||...
        ~isappdata(0,'xmax')||~isappdata(0,'ymax')||~isappdata(0,'pmax')
    % error loading data
    set(handles.ind_error,'string','ERROR: unable to receive stored data!');
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
set(handles.ind_Pmax,'string',num2str(round(max_p(end,1)*100)/100));
set(handles.ind_Px,'string',num2str(round(max_x(end,1)*100)/100));
set(handles.ind_Py,'string',num2str(round(max_y(end,1)*100)/100));

set(handles.ind_Pprec,'string',num2str(round((max(max_p)-min(max_p))*100)/100));
set(handles.ind_Pxprec,'string',num2str(round((max(max_x)-min(max_x))*100)/100));
set(handles.ind_Pyprec,'string',num2str(round((max(max_y)-min(max_y))*100)/100));

% show range
set(handles.ind_xmin,'string',num2str(round(min(xpos)*100)/100));
set(handles.ind_xmax,'string',num2str(round(max(xpos)*100)/100));
set(handles.ind_ymin,'string',num2str(round(min(ypos)*100)/100));
set(handles.ind_ymax,'string',num2str(round(max(ypos)*100)/100));

% show actual time
minutes=floor(max(time)/60);
seconds=ceil(max(time)-minutes*60);
set(handles.ind_exp_min,'string',num2str(minutes));
set(handles.ind_exp_sec,'string',num2str(seconds));

set(handles.btn_save,'Enable','on');
set(handles.ind_sim,'String','OFF');
set(handles.ind_status,'String','IDLE');

% --- Executes on button press in btn_stop.
function btn_stop_Callback(hObject, eventdata, handles)
% hObject    handle to btn_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ind_status,'string','STOPPING');
main(-1);
set(handles.ind_sim,'string','OFF');
set(handles.ind_status,'string','IDLE');
% enable inputs
set(handles.val_centerx,'Enable','on');
set(handles.val_centery,'Enable','on');
set(handles.val_diameter,'Enable','on');
set(handles.val_loops,'Enable','on');
set(handles.val_delay,'Enable','on');
set(handles.val_read,'Enable','on');
set(handles.val_tot_acc,'Enable','on');
set(handles.val_scale,'Enable','on');

set(handles.btn_on,'Enable','on');
set(handles.btn_pause,'Enable','off');
set(handles.btn_pause,'String','Pause');

% --- Executes on button press in btn_pause.
function btn_pause_Callback(hObject, eventdata, handles)
% hObject    handle to btn_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global doPause;

switch doPause
    case 0 % pause
        % enable inputs
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_read,'Enable','on');
        set(handles.val_tot_acc,'Enable','on');
        set(handles.val_scale,'Enable','on');
        set(handles.btn_on,'Enable','off');
        set(handles.btn_pause,'Enable','on');
        set(handles.btn_pause,'String','Unpause');
        doPause=1;
    case 1 % Unpause
        % disable inputs
        set(handles.val_centerx,'Enable','off');
        set(handles.val_centery,'Enable','off');
        set(handles.val_diameter,'Enable','off');
        set(handles.val_loops,'Enable','off');
        set(handles.val_delay,'Enable','off');
        set(handles.val_read,'Enable','off');
        set(handles.val_tot_acc,'Enable','off');
        set(handles.val_scale,'Enable','off');
        set(handles.btn_pause,'enable','on');
        set(handles.btn_pause,'String','Pause');
        set(handles.ind_status,'String','RUNNING');
        doPause=2;
    otherwise % unknown
        % enable inputs
        set(handles.val_centerx,'Enable','on');
        set(handles.val_centery,'Enable','on');
        set(handles.val_diameter,'Enable','on');
        set(handles.val_loops,'Enable','on');
        set(handles.val_delay,'Enable','on');
        set(handles.val_read,'Enable','on');
        set(handles.val_tot_acc,'Enable','on');
        set(handles.val_scale,'Enable','on');
        set(handles.btn_on,'Enable','off');
        set(handles.btn_pause,'Enable','on');
        set(handles.btn_pause,'String','Pause');
        doPause=0;
end

% --- Executes on button press in btn_save.
function btn_save_Callback(hObject, eventdata, handles)
% hObject    handle to btn_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ind_status,'String','SAVING...');
% get appdata
if ~isappdata(0,'acc')||~isappdata(0,'centerx')||~isappdata(0,'centery')||~isappdata(0,'cyclenr')||...
        ~isappdata(0,'delay')||~isappdata(0,'diameter')||~isappdata(0,'loopnr')||~isappdata(0,'p_data')||...
        ~isappdata(0,'pmax')||~isappdata(0,'read_time')||~isappdata(0,'scale')||~isappdata(0,'t_data')||...
        ~isappdata(0,'tot_acc')||~isappdata(0,'x_data')||~isappdata(0,'xmax')||~isappdata(0,'y_data')||~isappdata(0,'ymax')
    % error loading
    set(handles.ind_error,'String','ERROR: Some data is unavailable!');
    set(handles.ind_status,'String','IDLE');
    return;
end

power_temp=getappdata(0,'p_data');
% centerx_temp=getappdata(0,'centerx');
% centery_temp=getappdata(0,'centery');
% diameter_temp=getappdata(0,'diameter');
loop_nr_temp=getappdata(0,'loopnr');
cycle_nr_temp=getappdata(0,'cyclenr');
% scale_temp=getappdata(0,'scale');
% delay_temp=getappdata(0,'delay');
% tRead_temp=getappdata(0,'read_time');
% acc_temp=getappdata(0,'acc');
% tot_acc_temp=getappdata(0,'tot_acc');
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
    set(handles.ind_status,'String','IDLE');
    return;
end

% save location found
[f,fname,fext]=fileparts(filename);
save_loc=fullfile(pathname,[fname,fext]);
switch lower(fext) % make sure extension is all lower case
    case {'.xlsx','.xls'}
        % Create SUMMARY tab
        summary={...
            'PARAMETERS','', '','','';...
            'Center',num2str(centerx),'um',num2str(centery),'um';...
            'Diameter',num2str(diameter),'um','','';...
            'Loops',num2str(max(loop_nr)),'','Cycles',num2str(max(cycle_nr));...
            'Scale',num2str(scale),'X','','';...
            'Delay time',num2str(delay),'samples','','';...
            'Read time',num2str(tRead),'samples','','';...
            'Accuracy',num2str(acc),'nm /',num2str(tot_acc),'nm';...
            'RESULTS','','','','';...
            'Frequency','800','Hz','125','ms';...
            'Range X',num2str(round(min(xpos)*1000)/1000),'um',num2str(round(max(xpos)*1000)/1000),'um';...
            'Range Y',num2str(round(min(ypos)*1000)/1000),'um',num2str(round(max(ypos)*1000)/1000),'um';...
            'Time',num2str(floor(max(time)/60)),'min',num2str(ceil(max(time)-floor(max(time)/60)*60)),'sec';...
            'High power',num2str(round(max_p(end)*1000)/1000),'uW ±',num2str(round((max(max_p)-min(max_p))*1000000)/1000),'nW';...
            'Location X',num2str(round(max_x(end)*1000)/1000),'um ±',num2str(round((max(max_x)-min(max_x))*1000000)/1000),'nm';...
            'Location Y',num2str(round(max_y(end)*1000)/1000),'um ±',num2str(round((max(max_y)-min(max_y))*1000000)/1000),'nm'};
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
            strcat('Center',centerx,'um',centery,'um');...
            strcat('Diameter',diameter,'um');...
            strcat('Loops',num2str(max(loop_nr)));...
            strcat('Scale',scale,'X');...
            strcat('Delay time',delay,'samples');...
            strcat('Read time',tRead,'samples');...
            strcat('Accuracy',acc,'nm / ',tot_acc,'nm');...
            'RESULTS';...
            'Frequency: 800 Hz, 125 ms';...
            strcat('Range X',num2str(round(min(xpos)*1000)/1000),'um',num2str(round(max(xpos)*1000)/1000),'um');...
            strcat('Range Y',num2str(round(min(ypos)*1000)/1000),'um',num2str(round(max(ypos)*1000)/1000),'um');...
            strcat('Time',num2str(floor(max(time)/60)),'min',num2str(ceil(max(time)-floor(max(time)/60)*60)),'sec');...
            strcat('High power',num2str(round(mean(max_p)*1000)/1000),'uW ±',num2str(round((max(max_p)-min(max_p))*1000000)/1000),'nW');...
            strcat('Location X',num2str(round(mean(max_x)*1000)/1000),'um ±',num2str(round((max(max_x)-min(max_x))*1000000)/1000),'nm');...
            strcat('Location Y',num2str(round(mean(max_y)*1000)/1000),'um ±',num2str(round((max(max_y)-min(max_y))*1000000)/1000),'nm')};
        data_param=table(summary);
        data=[time,cycle_nr,loop_nr,xpos,ypos,power,xmax,ymax];
        param_loc=strcat(fname,'_param',fext);
        writetable(data_param,param_loc,'WriteVariableNames',1);
        % create DATA file
        data_table=table(data);
        writetable(data_table,save_loc,'WriteVariableNames',1);
    otherwise
        % cancel save
        set(handles.ind_error,'String','ERROR: Unable to save as specified format!');
end
set(handles.ind_status,'String','IDLE');
set(handles.ind_error,'String',strcat('Saved as: ',fname,fext));
beep;

% --- Executes on button press in btn_debug.
function btn_debug_Callback(hObject, eventdata, handles)
% hObject    handle to btn_debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btn_debug
if get(hObject,'Value')==1
    % run simulink in debug mode
    set_param('Autoalign_system','SimulationMode','normal');
    set(handles.ind_status,'String','DEBUG');
else
    % run simulink in external mode
    set_param('Autoalign_system','SimulationMode','external');
    set(handles.ind_status,'String','EXTERNAL');
end

% --- Executes on button press in btn_reset.
function btn_reset_Callback(hObject, eventdata, handles)
% hObject    handle to btn_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ind_status,'String','RESET?');
reset=questdlg('Do you really want to reset the interface?!','Reset','Cancel','Reset','Cancel');
if strcmp(reset,'Cancel')
    return
end
UserInterface_OpeningFcn(findobj('Tag','fig_GUI'),eventdata,handles);

%% SETTING VALUES
function val_centerx_Callback(hObject, eventdata, handles)
% hObject    handle to val_centerx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_centerx as text
%        str2double(get(hObject,'String')) returns contents of val_centerx as a double
global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'i')||contains(val,'j')...
        ||isempty(val)||isnan(check)||check>10000||check<-10000
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invalid value, -10.000 < CenterX < 10.000');
    inputerr(1,1)=1;
else
    inputerr(1,1)=0;
    setappdata(0,'centerx',check); % Update value in appdata
    % update time
    [time_min,time_sec]=calcTime();
    set(handles.ind_est_min,'String',num2str(time_min));
    set(handles.ind_est_sec,'String',num2str(time_sec));
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
global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'i')||contains(val,'j')...
        ||isempty(val)||isnan(check)||check>10000||check<-10000
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invalid value, -10.000 < CenterY < 10.000');
    inputerr(2,1)=1;
else
    inputerr(2,1)=0;
    setappdata(0,'centery',check); % Update value in appdata
    % update time
    [time_min,time_sec]=calcTime();
    set(handles.ind_est_min,'String',num2str(time_min));
    set(handles.ind_est_sec,'String',num2str(time_sec));
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
global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'i')||contains(val,'j')...
        ||contains(val,'-')||isempty(val)||isnan(check)||check>10000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invalid value, 1 < Diameter < 10.000');
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
    % show values
    set(handles.val_diameter,'String',num2str(check));
    set(handles.int_cyclecnt,'String',num2str(cycles));
    set(handles.ind_acc,'String',num2str(acc));
    set(handles.ind_est_min,'String',num2str(time_min));
    set(handles.ind_est_sec,'String',num2str(time_sec));
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
global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>50||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invalid value, 1 < Loops < 50');
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
    % show values
    set(handles.val_loops,'String',num2str(check));
    set(handles.int_cyclecnt,'String',num2str(cycles));
    set(handles.ind_acc,'String',num2str(acc));
    set(handles.ind_est_min,'String',num2str(time_min));
    set(handles.ind_est_sec,'String',num2str(time_sec));
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
global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>100000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invalid value, 1 < Total accuracy < 100000');
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
    % show values
    set(handles.val_tot_acc,'String',num2str(check));
    set(handles.int_cyclecnt,'String',num2str(cycles));
    set(handles.ind_acc,'String',num2str(acc));
    set(handles.ind_est_min,'String',num2str(time_min));
    set(handles.ind_est_sec,'String',num2str(time_sec));
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
global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>20||check<=1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invalid value, 1 <= Scale < 20');
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
    % show values
    set(handles.val_scale,'String',num2str(check));
    set(handles.int_cyclecnt,'String',num2str(cycles));
    set(handles.ind_acc,'String',num2str(acc));
    set(handles.ind_est_min,'String',num2str(time_min));
    set(handles.ind_est_sec,'String',num2str(time_sec));
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
global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>1000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invalid value, 1 < Delay < 1000');
    inputerr(7,1)=1;
else
    inputerr(7,1)=0;
    setappdata(0,'delay',check); % Update value in appdata
    % update time
    [time_min,time_sec]=calcTime();
    set(handles.ind_est_min,'String',num2str(time_min));
    set(handles.ind_est_sec,'String',num2str(time_sec));
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
global inputerr;
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>1000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invalid value, 1 < Read time < 1000');
    inputerr(8,1)=1;
else
    inputerr(8,1)=0;
    setappdata(0,'read_time',check); % Update value in appdata
    % update time
    [time_min,time_sec]=calcTime();
    set(handles.ind_est_min,'String',num2str(time_min));
    set(handles.ind_est_sec,'String',num2str(time_sec));
    % flash green
    set(hObject,'backgroundColor',[0 .5 0]);% green
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end

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
% hObject    handle to ind_est_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_est_min as text
%        str2double(get(hObject,'String')) returns contents of ind_est_min as a double
function val_T_est_s_Callback(hObject, eventdata, handles)
% hObject    handle to ind_est_sec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_est_sec as text
%        str2double(get(hObject,'String')) returns contents of ind_est_sec as a double
function val_time_m_Callback(hObject, eventdata, handles)
% hObject    handle to ind_exp_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ind_exp_min as text
%        str2double(get(hObject,'String')) returns contents of ind_exp_min as a double
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
function ind_est_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_est_min (see GCBO)
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
function ind_exp_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_exp_min (see GCBO)
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

%% END USERINTERFACE
