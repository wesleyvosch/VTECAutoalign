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

% Last Modified by GUIDE v2.5 09-May-2017 14:07:29

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

load_system('Autoalign_system.slx');
set_param('Autoalign_system','SimulationMode','external');
%% START INITIALIZATION

%% PARAMETER PANEL
% set default values
set(handles.val_centerx,'String','0');
set(handles.val_centery,'String','0');
set(handles.val_diameter,'String','50');
set(handles.val_loops,'String','3');
set(handles.val_delay,'String','16');
set(handles.val_tRead,'String','16');
set(handles.val_tot_acc,'String','100');
set(handles.txt_tot_acc_unit,'String','nm');
set(handles.ind_time_min,'String','1');
set(handles.ind_time_sec,'String','15');

% enable
set(handles.val_centerx,'enable','on');
set(handles.val_centery,'enable','on');
set(handles.val_diameter,'enable','on');
set(handles.val_loops,'enable','on');
set(handles.val_delay,'enable','on');
set(handles.val_tRead,'enable','on');
set(handles.val_tot_acc,'enable','on');

% reset background color
set(handles.val_centerx,'backgroundcolor','white');
set(handles.val_centery,'backgroundcolor','white');
set(handles.val_diameter,'backgroundcolor','white');
set(handles.val_loops,'backgroundcolor','white');
set(handles.val_delay,'backgroundcolor','white');
set(handles.val_tRead,'backgroundcolor','white');
set(handles.val_tot_acc,'backgroundcolor','white');

%% RESULTS PANEL
% set default values
set(handles.val_sample,'String','800');
set(handles.val_acc,'String','10');
set(handles.txt_acc_unit,'String','um');
set(handles.val_xmin,'String','-25');
set(handles.val_xmax,'String','25');
set(handles.val_ymin,'String','-25');
set(handles.val_ymax,'String','25');
set(handles.val_curr_cycle,'String','...');
set(handles.val_tot_cycle,'String','4');
set(handles.val_Pmin,'String','...');
set(handles.val_Pxmin,'String','...');
set(handles.val_Pymin,'String','...');
set(handles.val_Ptmin,'String','...');
set(handles.val_Pmax,'String','...');
set(handles.val_Pxmax,'String','...');
set(handles.val_Pymax,'String','...');
set(handles.val_Ptmax,'String','...');

%% CONTROL PANEL
% set default values
set(handles.ind_sim,'String','OFF');
set(handles.ind_status,'String','IDLE');
set(handles.ind_error,'String','');
set(handles.btn_on,'string','Run');
set(handles.btn_pause,'string','Pause');

% enable
set(handles.btn_on,'Enable','on');
set(handles.btn_pause,'Enable','off');
set(handles.btn_reset,'Enable','on');
set(handles.btn_exit,'Enable','on');

% set foreground color
set(handles.ind_sim,'Foregroundcolor','black');
set(handles.ind_status,'Foregroundcolor','black');
set(handles.ind_error,'Foregroundcolor','red');

%% VARIABLES
% declare globals
global fcn_mode;
global centerx_old;
global centery_old;

% clear values
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
if isappdata(0,'tot_acc')
    rmappdata(0,'tot_acc');
end
if isappdata(0,'cycles')
    rmappdata(0,'cycles');
end

% Set default values
fcn_mode=0;
centerx_old=0;
centery_old=0;

setappdata(0,'centerx',0);
setappdata(0,'centery',0);
setappdata(0,'diameter',50);
setappdata(0,'loops',3);
setappdata(0,'delay',16);
setappdata(0,'read_time',16);
setappdata(0,'tot_acc',10);

%% PLOTS
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
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');
yyaxis(handles.plt_time,'left');
ylabel(handles.plt_time,'Position [um]');
ylim(handles.plt_time,[-30 30]);
yyaxis(handles.plt_time,'right');
ylabel(handles.plt_time,'Power [uW]');
ylim(handles.plt_time,[0 3]);

%% END OF INITIALIZATION

%% START MAIN CODE

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
%% DECLARE GLOBALS
global centerx_old;
global centery_old;


%% MAIN CODE
display('BTN_ON: is pressed');

% DISABLE inputs
% set(handles.val_centerx,'Enable','off');
% set(handles.val_centery,'Enable','off');
% set(handles.val_diameter,'Enable','off');
% set(handles.val_loops,'Enable','off');
% set(handles.val_delay,'Enable','off');
% set(handles.val_tRead,'Enable','off');
% set(handles.val_tot_acc,'Enable','off');
% set(handles.btn_exit,'Enable','off');
% set(handles.btn_on,'Enable','off');
% set(handles.btn_pause,'Enable','off');
% set(handles.ind_error,'String','');

% get parameters
if ~isappdata(0,'centerx')||~isappdata(0,'centery')||...
        ~isappdata(0,'diameter')||~isappdata(0,'loops')||...
        ~isappdata(0,'delay')||~isappdata(0,'read_time')||~isappdata(0,'tot_acc')
    display('BTN_ON: appdata incorrect');
    set(handles.ind_err,'String','ERROR: appdata is corrupted, unable to continue!');
    return;
end
centerx=getappdata(0,'centerx');
centery=getappdata(0,'centery');
diameter=getappdata(0,'diameter');
loops=getappdata(0,'loops');
delay=getappdata(0,'delay');
read_time=getappdata(0,'read_time');
tot_acc=getappdata(0,'tot_acc');

% calculations
xmin=centerx-diameter/2;
ymin=centery-diameter/2;
xmax=centerx+diameter/2;
ymax=centery+diameter/2;

acc=diameter/(2*loops-1);
cycles=ceil(log(acc/tot_acc))+2;
set(handles.val_acc,'String',num2str(acc));
set(handles.val_tot_cycle,'String',num2str(cycles));

main(0); % update simulation

for cycle=1:cycles
    display(cycle);
    % clear appdata
    if isappdata(0,'x_data')
        rmappdata(0,'x_data');
    end
    if isappdata(0,'x_pos')
        rmappdata(0,'x_pos');
    end
    if isappdata(0,'y_data')
        rmappdata(0,'y_data');
    end
    if isappdata(0,'y_pos')
        rmappdata(0,'y_pos');
    end
    if isappdata(0,'p_data')
        rmappdata(0,'p_data');
    end
    if isappdata(0,'clk')
        rmappdata(0,'clk');
    end
    if isappdata(0,'xpow')
        rmappdata(0,'xpow');
    end
    if isappdata(0,'ypow')
        rmappdata(0,'ypow');
    end
    
    if centerx~=centerx_old || centery~=centery_old
        % move first
        main(1); % move mode
        % reset appdata
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
    end
    main(2); % search mode
    % transform steps to position
    if ~isappdata(0,'x_data')||~isappdata(0,'y_data')||...
            ~isappdata(0,'p_data')||~isappdata(0,'clk')
        set(handles.ind_error,'String','ERROR: outputed data is corrupted, terminate simulation?');
        break;
    end
    xstep=getappdata(0,'x_data');
    ystep=getappdata(0,'y_data');
    power=getappdata(0,'p_data');
    clock=getappdata(0,'clk');
    % check for same length
    if length(xstep)<length(ystep)
        % add zeros to xstep
        xstep(numel(ystep))=0;
    elseif length(xstep)>length(ystep)
        % add zeros to ystep
        ystep(numel(xstep))=0;
    end
    xtemp=xstep*4096/50;
    ytemp=ystep*4096/50;
    for item=1:length(clock)
        xpos(item,1)=xtemp(item,1)+(centerx-diameter/(4*loops-2));
        ypos(item,1)=ytemp(item,1)+(centery-diameter/(4*loops-2));
    end
    setappdata(0,'x_pos',xpos);
    setappdata(0,'y_pos',ypos);

    set(handles.val_xmin,'String',num2str(round(min(xpos))));
    set(handles.val_xmax,'String',num2str(round(max(xpos))));
    set(handles.val_ymin,'String',num2str(round(min(ypos))));
    set(handles.val_ymax,'String',num2str(round(max(ypos))));

    % calculate boundaries for plot
    xminval=centerx-diameter/2-(diameter/(4*loops-2));
    xmaxval=centerx+diameter/2+(diameter/(4*loops-2));
    yminval=centery-diameter/2-(diameter/(4*loops-2));
    ymaxval=centery+diameter/2+(diameter/(4*loops-2));

    xmin=sign(xminval)*ceil(sign(xminval)*xminval/5)*5;
    ymin=sign(yminval)*ceil(sign(yminval)*yminval/5)*5;
    xmax=sign(xmaxval)*ceil(sign(xmaxval)*xmaxval/5)*5;
    ymax=sign(ymaxval)*ceil(sign(ymaxval)*ymaxval/5)*5;

    plot(handles.plt_pos,xpos,ypos);
    axis(handles.plt_pos,[xmin xmax ymin ymax]);
    grid(handles.plt_pos,'on');
    grid(handles.plt_pos,'minor');

    minright=min(xmin,ymin);
    maxright=max(xmax,ymax);
    tmin=0;
    tmax=max(clock)*1.05;
    if min(power)==max(power)
        % no change in power
        pmin=0;
        pmax=0.5;
    else
        pmin=min(p)*0.9;
        pmax=max(p)*1.1;
    end
    tmaxx=tmax*1.1;
    xlim(handles.plt_time,[tmin tmaxx]);
    % plot P(t) (left)
    yyaxis(handles.plt_time,'left');
    display('btn_ON: plot time (L)');
    plot(handles.plt_time,t,xnew,'b',t,ynew,'m');
    ylim(handles.plt_time,[minright maxright]);
    % plot X&Y(t) (right)
    yyaxis(handles.plt_time,'right');
    display('btn_ON: plot time (R)');
    plot(handles.plt_time,t,p,'r');
    ylim(handles.plt_time,[pmin pmax]);
    ylabel(handles.plt_time,'Power [uW]');
    % ylabel(handles.plt_time,'Position [um]');
    grid(handles.plt_time,'on');
    grid(handles.plt_time,'minor');
    legend(handles.plt_time,'X position','Y position','Power');
    % find highest power area
    max_pow=max(power);
    trig_minpow=max_pow*0.9;
    trig_maxpow=max_pow;
    row=find(power>trig_minpow & power<trig_maxpow);
    for i=1:size(row)
       xi(i,1)=xnew(row(i,1),1);
       yi(i,1)=ynew(row(i,1),1);
       ti(i,1)=t(row(i,1),1);
    end
    setappdata(0,'xpow',xi);
    setappdata(0,'ypow',yi);
    plot(handles.plt_pos,xpos,ypos,xi,yi,'r*','markersize',1);
    axis(handles.plt_pos,[xmin xmax ymin ymax]);
    grid(handles.plt_pos,'on');
    grid(handles.plt_pos,'minor');
    
    % calculate new values
    centerx_new=(min(xi)+max(xi))/2;
    centery_new=(min(yi)+max(yi))/2;
    diameter_new=diamter/5;
    
    
    % update values
    set(handles.val_Pmin,'String',num2str(floor(trig_minpow)));
    set(handles.val_Pmax,'String',num2str(floor(trig_maxpow)));
    set(handles.val_Pxmin,'String',num2str(floor(xi(numel(1)))));
    set(handles.val_Pxmax,'String',num2str(floor(xi(numel(row)))));
    set(handles.val_Pymin,'String',num2str(floor(yi(numel(1)))));
    set(handles.val_Pymax,'String',num2str(floor(yi(numel(row)))));
    set(handles.val_Ptmin,'String',num2str(floor(ti(numel(1)))));
    set(handles.val_Ptmax,'String',num2str(floor(ti(numel(row)))));
    
    set(handles.val_centerx,'String',num2str(centerx_new));
    set(handles.val_centery,'String',num2str(centery_new));
    set(handles.val_diameter,'String',num2str(diameter_new));
    
end

display('btn_ON: END');

% --- Executes on button press in btn_pause.
function btn_pause_Callback(hObject, eventdata, handles)
% hObject    handle to btn_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check output data
set(handles.ind_error,'string','Warning: pause button not implemented');
display('pause button not implemented yet');

% --- Executes on button press in btn_reset.
function btn_reset_Callback(hObject, eventdata, handles)
% hObject    handle to btn_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display('btn_RESET');
reset=questdlg('Do you really want to reset the interface?!','Reset','Cancel','Reset','Cancel');
if strcmp(reset,'Cancel')
    display('RESET cancelled');
    return
end
display('RESET!');
UserInterface_OpeningFcn(findobj('Tag','fig_GUI'),eventdata,handles);

% --- Executes on button press in btn_exit.
function btn_exit_Callback(hObject, eventdata, handles)
% hObject    handle to btn_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ind_error,'string','Warning: exit button not implemented');
display('exit button not implemented yet');


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
    time=calcTime();
    time_txt=strcat(num2str(floor(time/60)),' min, ',num2str(round(time-floor(time/60)*60)),' sec');
    set(handles.ind_time_min,'String',num2str(time_txt));
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
    time=calcTime();
    time_txt=strcat(num2str(floor(time/60)),' min, ',num2str(round(time-floor(time/60)*60)),' sec');
    set(handles.ind_time_min,'String',num2str(time_txt));
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
    time=calcTime();
    time_txt=strcat(num2str(floor(time/60)),' min, ',num2str(round(time-floor(time/60)*60)),' sec');
    set(handles.ind_time_min,'String',num2str(time_txt));
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
    time=calcTime();
    time_txt=strcat(num2str(floor(time/60)),' min, ',num2str(round(time-floor(time/60)*60)),' sec');
    set(handles.ind_time_min,'String',num2str(time_txt));
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
    time=calcTime();
    time_txt=strcat(num2str(floor(time/60)),' min, ',num2str(round(time-floor(time/60)*60)),' sec');
    set(handles.ind_time_min,'String',num2str(time_txt));
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



function val_curr_cycle_Callback(hObject, eventdata, handles)
% hObject    handle to val_curr_cycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_curr_cycle as text
%        str2double(get(hObject,'String')) returns contents of val_curr_cycle as a double


% --- Executes during object creation, after setting all properties.
function val_curr_cycle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_curr_cycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function val_tot_cycle_Callback(hObject, eventdata, handles)
% hObject    handle to val_tot_cycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_tot_cycle as text
%        str2double(get(hObject,'String')) returns contents of val_tot_cycle as a double


% --- Executes during object creation, after setting all properties.
function val_tot_cycle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_tot_cycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function val_tot_acc_Callback(hObject, eventdata, handles)
% hObject    handle to val_tot_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_tot_acc as text
%        str2double(get(hObject,'String')) returns contents of val_tot_acc as a double


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
