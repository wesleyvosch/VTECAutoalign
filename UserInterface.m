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

% Last Modified by GUIDE v2.5 11-May-2017 07:51:25

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
% set_param('Autoalign_system','SimulationMode','normal'); % debug mode
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
set(handles.val_scale,'String','2');
% set(handles.txt_tot_acc_unit,'String','nm');
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
set(handles.val_scale,'enable','on');

% reset background color
set(handles.val_centerx,'backgroundcolor','white');
set(handles.val_centery,'backgroundcolor','white');
set(handles.val_diameter,'backgroundcolor','white');
set(handles.val_loops,'backgroundcolor','white');
set(handles.val_delay,'backgroundcolor','white');
set(handles.val_tRead,'backgroundcolor','white');
set(handles.val_tot_acc,'backgroundcolor','white');
set(handles.val_scale,'backgroundcolor','white');

%% RESULTS PANEL
% set default values
set(handles.val_sample,'String','800');
set(handles.val_acc,'String','10');
% set(handles.txt_acc_unit,'String','um');
set(handles.val_xmin,'String','-25');
set(handles.val_xmax,'String','25');
set(handles.val_ymin,'String','-25');
set(handles.val_ymax,'String','25');
set(handles.val_curr_cycle,'String','1');
set(handles.val_tot_cycle,'String','4');
set(handles.val_Pmin,'String','...');
set(handles.val_Pmax,'String','...');
set(handles.val_Pxmin,'String','...');
set(handles.val_Pxmax,'String','...');
set(handles.val_Pymin,'String','...');
set(handles.val_Pymax,'String','...');
set(handles.val_Ptmin,'String','...');
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

%% STORAGE
% declare global variables
global mode;
global dosave;
global save_loc;

mode=0;
dosave=0;
save_loc='';

% clear appdata
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

if isappdata(0,'loopnr')
    rmappdata(0,'loopnr');
end
if isappdata(0,'cycles')
    rmappdata(0,'cycles');
end
if isappdata(0,'cyclenr')
    rmappdata(0,'cyclenr');
end
if isappdata(0,'delay')
    rmappdata(0,'delay');
end
if isappdata(0,'read_time')
    rmappdata(0,'read_time');
end
if isappdata(0,'tot_acc')
    rmappdata(0,'tot_acc');
end
if isappdata(0,'scale')
    rmappdata(0,'scale');
end
if isappdata(0,'x_data')
    rmappdata(0,'x_data');
end
if isappdata(0,'y_data')
    rmappdata(0,'y_data');
end
if isappdata(0,'p_data')
    rmappdata(0,'p_data');
end
if isappdata(0,'t_data')
    rmappdata(0,'t_data');
end

setappdata(0,'centerx',0);
setappdata(0,'centery',0);
setappdata(0,'diameter',50);
setappdata(0,'loops',3);
setappdata(0,'cycles',1);
setappdata(0,'delay',16);
setappdata(0,'read_time',16);
setappdata(0,'tot_acc',10);
setappdata(0,'scale',2);

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
xlabel(handles.plt_time,'Time [seconds]');
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');
yyaxis(handles.plt_time,'left');
ylabel(handles.plt_time,'Position [um]');
ylim(handles.plt_time,[-30 30]);
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
display('BTN_ON: is pressed');
global mode;
global dosave;
global save_loc;

if mode == 0 % now: idle | next: run
    display('BTN_ON: Mode = 0, start sim...');
    % disable inputs
    set(handles.val_centerx,'Enable','off');
    set(handles.val_centery,'Enable','off');
    set(handles.val_diameter,'Enable','off');
    set(handles.val_loops,'Enable','off');
    set(handles.val_delay,'Enable','off');
    set(handles.val_tRead,'Enable','off');
    set(handles.val_tot_acc,'Enable','off');
    set(handles.val_scale,'Enable','off');
    set(handles.btn_on,'Enable','off');

    % ask for save
    set(handles.ind_status,'String','WAITING');
    save_request=questdlg('Would you like to save the generated data?',...
        'Save data?','Yes','No','Yes');
    if strcmp(save_request,'Yes')
        display('BTN_ON: save request accepted');
        % show save menu
        dosave=1;
        [filename,pathname]=uiputfile({'*.xlsx','Excel-Workbook';...
            '*.csv','CSV (Comma-Seperated Value)';...
            '*.txt','Text Document';'*.*','All Files'}...
            ,'Save location','Alignment Data.xlsx');
        if isequal(filename,0)||isequal(pathname,0)
            display('BTN_ON: save menu canceled');
            % check for cancel
            return;
        end
        display('BTN_ON: save location found');
        [f,fname,fext]=fileparts(filename);
        save_loc=fullfile(pathname,[fname,fext]);
    else
        display('BTN_ON: save request denied');
        dosave=0;
    end
    
    set(handles.ind_status,'String','PREPARING');
    [time_min,time_sec]=calcTime();
    set(handles.ind_time_min,'String',num2str(time_min));
    set(handles.ind_time_sec,'String',num2str(time_sec));
    
    % run sim
    set(handles.ind_sim,'String','ON');
    display('BTN_ON: main(0)');
    main(0);
    % build finished
    set(handles.btn_pause,'Enable','on');
    set(handles.ind_status,'String','RUNNING');
    display('BTN_ON: main(1)');
    main(1);
    % run finished
    set(handles.btn_on,'Enable','on');
    set(handles.btn_pause,'Enable','off'); 
    set(handles.ind_sim,'String','OFF');
    set(handles.ind_status,'String','FINISHED');
end
display('BTN_ON: remaining steps');
% enable inputs
set(handles.val_centerx,'Enable','on');
set(handles.val_centery,'Enable','on');
set(handles.val_diameter,'Enable','on');
set(handles.val_loops,'Enable','on');
set(handles.val_delay,'Enable','on');
set(handles.val_tRead,'Enable','on');
set(handles.val_tot_acc,'Enable','on');
set(handles.val_scale,'Enable','on');

% receive generated data
if ~isappdata(0,'x_data')||~isappdata(0,'y_data')||...
        ~isappdata(0,'p_data')||~isappdata(0,'t_data')||...
        ~isappdata(0,'loopnr')||~isappdata(0,'cyclenr')
    % error while loading data
    display('BTN_ON: error while loading data');
    return;
end
display('BTN_ON: get appdata');
xpos=getappdata(0,'x_data');
ypos=getappdata(0,'y_data');
power=getappdata(0,'p_data');
time=getappdata(0,'t_data');
loop_nr=getappdata(0,'loopnr');
cycle_nr=getappdata(0,'cyclenr');

display('BTN_ON: plot position');
% position plot
plot(handles.plt_pos,xpos,ypos);
axis(handles.plt_pos,[min(xpos) max(xpos) min(ypos) max(ypos)]);
grid(handles.plt_pos,'on');
grid(handles.plt_pos,'minor');

display('BTN_ON: plot time');
% time plot
% calculate relative position
offsetx=min(xpos)+(max(xpos)-min(xpos))/2;
offsety=min(ypos)+(max(ypos)-min(ypos))/2;
xrel=xpos-offsetx;
yrel=ypos-offsety;

xlim(handles.plt_time,[0 max(time)]);
% primary side: positions
display('BTN_ON: plot time [x,y]');
yyaxis(handles.plt_time,'left');
plot(handles.plt_time,time,xrel,time,yrel);
ylim(handles.plt_time,[min(min(xrel),min(yrel)) max(max(xrel),max(yrel))]);
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');
% secondary side: power, loopnr, cyclenr
yyaxis(handles.plt_time,'right');
display('BTN_ON: plot time [p,loop,cycle]');
allvals=[power, loop_nr, cycle_nr];
plot(handles.plt_time,time,power,time,loop_nr,time,cycle_nr);
ylim(handles.plt_time,[min(allvals(:)) max(allvals(:))]);
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');

legend(handles.plt_time,'X position','Y position','Power','Loopnr.','Cyclenr.');

% display highest power


% save to file
display('BTN_ON: highest power not included');
if dosave==1
    [f,fname,fext]=fileparts(save_loc);
    ext=lower(fext); % make sure text is lower case
    header={'Timestamp','Loop','X position','Y position','Power'};
    data=[time,loop_nr,xpos,ypos,power];
    cnt_cycles=max(cycle_nr);
    for cnt=1:cnt_cycles
        elementnr=find(cycle_nr==cnt);
        display(cnt);
        switch ext
            case {'.xlsx','.xls'}
                display('BTN_ON: save as Excel');
                % save as Excel file
                sheet_name=strcat('Cycle',num2str(cnt));
                xlswrite(save_loc,header,sheet_name,'A1');
                xlswrite(save_loc,data(elementnr,:),sheet_name,'A2');
            case {'.csv','.txt'}
                display('BTN_ON: save as csv or txt');
                % save as CSV-file or TXT file
                data_table=table(data);
                writetable(data_table,save_loc,'WriteVariableNames',1);
            otherwise
                display('BTN_ON: unknown format, saving as Excel');
                % unknown extension, save as Excel file
                ext='.xlsx';
                sheet_name=strcat('Cycle',num2str(cnt));
                xlswrite(save_loc,header,sheet_name,'A1');
                xlswrite(save_loc,data(elementnr,:),sheet_name,'A2');
        end 
    end
end


set(handles.ind_status,'String','IDLE');
display('BTN_ON: END');

% --- Executes on button press in btn_pause.
function btn_pause_Callback(hObject, eventdata, handles)
% hObject    handle to btn_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check output data
display('BTN_PAUSE');
if mode == 1 % current: run, next: pause
    % enable inputs
    set(handles.val_centerx,'Enable','on');
    set(handles.val_centery,'Enable','on');
    set(handles.val_diameter,'Enable','on');
    set(handles.val_loops,'Enable','on');
    set(handles.val_delay,'Enable','on');
    set(handles.val_tRead,'Enable','on');
    set(handles.val_tot_acc,'Enable','on');
    set(handles.val_scale,'Enable','on');
    set(handles.btn_pause,'String','Unpause');
    main(2); % pause sim
elseif mode == 2 % current: pause, next: unpause
    % disable inputs
    set(handles.val_centerx,'Enable','off');
    set(handles.val_centery,'Enable','off');
    set(handles.val_diameter,'Enable','off');
    set(handles.val_loops,'Enable','off');
    set(handles.val_delay,'Enable','off');
    set(handles.val_tRead,'Enable','off');
    set(handles.val_tot_acc,'Enable','off');
    set(handles.val_scale,'Enable','off');
    set(handles.btn_pause,'String','Pause');
    main(3); % unpause sim
end

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
    % update time
    [time_min,time_sec]=calcTime();
    set(handles.ind_time_min,'String',num2str(time_min));
    set(handles.ind_time_sec,'String',num2str(time_sec));
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
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'i')||contains(val,'j')...
        ||isempty(val)||isnan(check)||check>10000||check<-10000
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invallid value, -10.000 < CenterY < 10.000');
else
    setappdata(0,'centery',check); % Update value in appdata
    % update time
    [time_min,time_sec]=calcTime();
    set(handles.ind_time_min,'String',num2str(time_min));
    set(handles.ind_time_sec,'String',num2str(time_sec));
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
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'i')||contains(val,'j')...
        ||contains(val,'-')||isempty(val)||isnan(check)||check>10000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invallid value, 1 < Diameter < 10.000');
else
    setappdata(0,'diameter',check); % Update value in appdata
    % update accuracy
    loops=getappdata(0,'loops');
    acc=check/(2*loops-1);
    setappdata(0,'acc',acc);
    set(handles.val_acc,'String',num2str(acc));
    % update cycles
    tot_acc=getappdata(0,'tot_acc')/1000;
    scale=getappdata(0,'scale');
    cycles=ceil(log(acc/tot_acc)/log(scale));
    setappdata(0,'cycles',cycles);
    set(handles.val_tot_cycle,'String',num2str(cycles));
    % update time
    [time_min,time_sec]=calcTime();
    set(handles.ind_time_min,'String',num2str(time_min));
    set(handles.ind_time_sec,'String',num2str(time_sec));
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
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>50||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invallid value, 1 < Loops < 50');
else
    setappdata(0,'loops',check); % Update value in appdata
    % update accuracy
    diameter=getappdata(0,'diameter');
    acc=diameter/(2*check-1);
    setappdata(0,'acc',acc);
    set(handles.val_acc,'String',num2str(acc));
    % update cycles
    tot_acc=getappdata(0,'tot_acc')/1000;
    scale=getappdata(0,'scale');
    cycles=ceil(log(acc/tot_acc)/log(scale));
    setappdata(0,'cycles',cycles);
    set(handles.val_tot_cycle,'String',num2str(cycles));
    % update time
    [time_min,time_sec]=calcTime();
    set(handles.ind_time_min,'String',num2str(time_min));
    set(handles.ind_time_sec,'String',num2str(time_sec));
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
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>100000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invallid value, 1 < Total accuracy < 100000');
else
    setappdata(0,'tot_acc',check); % Update value in appdata
    % update cycles
    acc=getappdata(0,'acc');
    scale=getappdata(0,'scale');
    cycles=ceil(log(1000*acc/check)/log(scale));
    setappdata(0,'cycles',cycles);
    set(handles.val_tot_cycle,'String',num2str(cycles));
    % update time
    [time_min,time_sec]=calcTime();
    set(handles.ind_time_min,'String',num2str(time_min));
    set(handles.ind_time_sec,'String',num2str(time_sec));
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
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>10||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invallid value, 1 < Scale < 10');
else
    setappdata(0,'loops',check); % Update value in appdata
    % update cycles
    tot_acc=getappdata(0,'tot_acc')/1000;
    acc=getappdata(0,'acc');
    cycles=ceil(log(acc/tot_acc)/log(check));
    setappdata(0,'cycles',cycles);
    set(handles.val_tot_cycle,'String',num2str(cycles));
    % update time
    [time_min,time_sec]=calcTime();
    set(handles.ind_time_min,'String',num2str(time_min));
    set(handles.ind_time_sec,'String',num2str(time_sec));
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
val=get(hObject,'String');
check=str2double(val);
if contains(val,' ')||contains(val,',')||contains(val,'.')||contains(val,'i')...
        ||contains(val,'j')||contains(val,'-')||isempty(val)||isnan(check)||check>1000||check<1
    set(hObject,'BackgroundColor',[1 0 0]);% red
    set(handles.ind_error,'String','Invallid value, 1 < Delay < 1000');
else
    setappdata(0,'delay',check); % Update value in appdata
    % update time
    [time_min,time_sec]=calcTime();
    set(handles.ind_time_min,'String',num2str(time_min));
    set(handles.ind_time_sec,'String',num2str(time_sec));
    % flash green
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
    % update time
    [time_min,time_sec]=calcTime();
    set(handles.ind_time_min,'String',num2str(time_min));
    set(handles.ind_time_sec,'String',num2str(time_sec));
    % flash green
    set(hObject,'backgroundColor',[0 .5 0]);% green
    pause(.05);
    set(hObject,'backgroundColor',[1 1 1]);% white
end

%%%%%%%%%%%%%%%%% SHOWING VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%

function val_sample_Callback(hObject, eventdata, handles)
% hObject    handle to val_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_time as text
%        str2double(get(hObject,'String')) returns contents of val_time as a double

function val_acc_Callback(hObject, eventdata, handles)
% hObject    handle to val_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_acc as text
%        str2double(get(hObject,'String')) returns contents of val_acc as a double

function val_xmin_Callback(hObject, eventdata, handles)
% hObject    handle to val_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_xmin as text
%        str2double(get(hObject,'String')) returns contents of val_xmin as a double

function val_ymin_Callback(hObject, eventdata, handles)
% hObject    handle to val_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_ymin as text
%        str2double(get(hObject,'String')) returns contents of val_ymin as a double

function val_xmax_Callback(hObject, eventdata, handles)
% hObject    handle to val_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_xmax as text
%        str2double(get(hObject,'String')) returns contents of val_xmax as a double

function val_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to val_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_ymax as text
%        str2double(get(hObject,'String')) returns contents of val_ymax as a double

function val_curr_cycle_Callback(hObject, eventdata, handles)
% hObject    handle to val_curr_cycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_curr_cycle as text
%        str2double(get(hObject,'String')) returns contents of val_curr_cycle as a double

function val_tot_cycle_Callback(hObject, eventdata, handles)
% hObject    handle to val_tot_cycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_tot_cycle as text
%        str2double(get(hObject,'String')) returns contents of val_tot_cycle as a double

function val_Pmin_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Pmin as text
%        str2double(get(hObject,'String')) returns contents of val_Pmin as a double

function val_Pmax_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Pmax as text
%        str2double(get(hObject,'String')) returns contents of val_Pmax as a double

function val_Pxmin_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pxmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Pxmin as text
%        str2double(get(hObject,'String')) returns contents of val_Pxmin as a double

function val_Pxmax_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pxmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Pxmax as text
%        str2double(get(hObject,'String')) returns contents of val_Pxmax as a double

function val_Pymin_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Pymin as text
%        str2double(get(hObject,'String')) returns contents of val_Pymin as a double

function val_Pymax_Callback(hObject, eventdata, handles)
% hObject    handle to val_Pymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_Pymax as text
%        str2double(get(hObject,'String')) returns contents of val_Pymax as a double

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

%%%%%%%%%%%%%%%%%% VAL_CREATE FCN'S %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
function val_curr_cycle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_curr_cycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
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