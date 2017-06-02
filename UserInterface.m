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

% Last Modified by GUIDE v2.5 30-May-2017 12:32:46

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
% set_param('Autoalign_system','SimulationMode','external');
set_param('Autoalign_system','SimulationMode','normal'); % debug mode
%% START INITIALIZATION

%% PARAMETER PANEL
set(handles.val_centerx,'String','0');
set(handles.val_centerx,'enable','on');
set(handles.val_centerx,'backgroundcolor','white');

set(handles.val_centery,'String','0');
set(handles.val_centery,'enable','on');
set(handles.val_centery,'backgroundcolor','white');

set(handles.val_diameter,'String','20');
set(handles.val_diameter,'enable','on');
set(handles.val_diameter,'backgroundcolor','white');

set(handles.val_loops,'String','3');
set(handles.val_loops,'enable','on');
set(handles.val_loops,'backgroundcolor','white');

set(handles.val_tot_acc,'String','500');
set(handles.val_tot_acc,'enable','on');
set(handles.val_tot_acc,'backgroundcolor','white');

set(handles.val_scale,'String','2');
set(handles.val_scale,'enable','on');
set(handles.val_scale,'backgroundcolor','white');

set(handles.val_delay,'String','16');
set(handles.val_delay,'enable','on');
set(handles.val_delay,'backgroundcolor','white');

set(handles.val_tRead,'String','16');
set(handles.val_tRead,'enable','on');
set(handles.val_tRead,'backgroundcolor','white');

set(handles.ind_error,'String',' ');
set(handles.ind_error,'Foregroundcolor','red');

%% RESULTS PANEL
% set default values
set(handles.ind_sim,'String','OFF');
set(handles.ind_sim,'Foregroundcolor','black');

set(handles.ind_status,'String','IDLE');
set(handles.ind_status,'Foregroundcolor','black');

set(handles.val_sample,'String','800');
set(handles.val_cycles,'String','4');
set(handles.val_acc,'String','500');
set(handles.val_xmin,'String','-10');
set(handles.val_xmax,'String','10');
set(handles.val_ymin,'String','-10');
set(handles.val_ymax,'String','10');
set(handles.val_T_est_m,'String','0');
set(handles.val_T_est_s,'String','29');

set(handles.val_Pmax,'String','...');
set(handles.val_Pxmax,'String','...');
set(handles.val_Pymax,'String','...');
set(handles.val_time_m,'String','...');
set(handles.val_time_s,'String','...');

%% CONTROL PANEL
% set default values
set(handles.btn_on,'string','Run');
set(handles.btn_on,'Enable','on');

set(handles.btn_pause,'string','Pause');
set(handles.btn_pause,'Enable','off');

set(handles.btn_reset,'Enable','on');
set(handles.btn_stop,'Enable','on');

%% STORAGE
% declare global variables
global doPause;
global dosave;
global save_loc;
global inputerr;

doPause=0;
dosave=0;
save_loc='';
inputerr=zeros(8,1);

% clear appdata
if isappdata(0,'acc')
    rmappdata(0,'acc');
end
if isappdata(0,'centerx')
    rmappdata(0,'centerx');
end
if isappdata(0,'centery')
    rmappdata(0,'centery');
end
if isappdata(0,'cyclenr')
    rmappdata(0,'cyclenr');
end
if isappdata(0,'cycles')
    rmappdata(0,'cycles');
end
if isappdata(0,'delay')
    rmappdata(0,'delay');
end
if isappdata(0,'diameter')
    rmappdata(0,'diameter');
end
if isappdata(0,'loopnr')
    rmappdata(0,'loopnr');
end
if isappdata(0,'loops')
    rmappdata(0,'loops');
end
if isappdata(0,'p_data')
    rmappdata(0,'p_data');
end
if isappdata(0,'pmax')
    rmappdata(0,'pmax');
end
if isappdata(0,'read_time')
    rmappdata(0,'read_time');
end
if isappdata(0,'scale')
    rmappdata(0,'scale');
end
if isappdata(0,'t_data')
    rmappdata(0,'t_data');
end
if isappdata(0,'tot_acc')
    rmappdata(0,'tot_acc');
end
if isappdata(0,'x_data')
    rmappdata(0,'x_data');
end
if isappdata(0,'xmax')
    rmappdata(0,'xmax');
end
if isappdata(0,'y_data')
    rmappdata(0,'y_data');
end
if isappdata(0,'ymax')
    rmappdata(0,'ymax');
end

setappdata(0,'centerx',0);
setappdata(0,'centery',0);
setappdata(0,'diameter',20);
setappdata(0,'loops',3);
setappdata(0,'tot_acc',500);
setappdata(0,'scale',2);
setappdata(0,'delay',16);
setappdata(0,'read_time',16);
setappdata(0,'cycles',4);
setappdata(0,'acc',500);

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
global dosave;
global save_loc;
global doPause;
global changes;
global inputerr;

if max(inputerr)>0
    % error(s) occured
    
    err_msg=strcat('ERROR: Unable to start simulation, there are ',num2str(sum(inputerr)),...
        ' pending errors! Solve these errors before running the program.');
    set(handles.ind_error,'String',err_msg);
    display('RUN FAILED, error in inputs');
    return;
else
    set(handles.ind_error,'String','');
end
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

% clear outputs
set(handles.val_Pmax,'String','...');
set(handles.val_Pxmax,'String','...');
set(handles.val_Pymax,'String','...');
set(handles.val_time_m,'String','...');
set(handles.val_time_s,'String','...');

% clear/reset plots
cla(handles.plt_pos,'reset');
title(handles.plt_pos,'Location matrix');
axis(handles.plt_pos,[-30 30 -30 30]);
grid(handles.plt_pos,'on');
grid(handles.plt_pos,'minor');
xlabel(handles.plt_pos,'X position [um]');
ylabel(handles.plt_pos,'Y position [um]');

cla(handles.plt_time,'reset');
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

if doPause==0
    if isempty(save_loc)
        % save request
        set(handles.ind_status,'String','WAITING');
        save_request=questdlg('Would you like to save the generated data?',...
            'Save data?','Yes','No','Yes');
        if strcmp(save_request,'Yes')
            % handle save request
            [filename,pathname]=uiputfile({'*.xlsx','Excel-Workbook';...
                '*.csv','CSV (Comma-Seperated Value)';...
                '*.txt','Text Document';'*.*','All Files'}...
                ,'Save location','Alignment Data.xlsx');
            if isequal(filename,0)||isequal(pathname,0)
                % save canceled
                set(handles.ind_status,'String','IDLE');
                return;
            else
                [f,fname,fext]=fileparts(filename);
                ext=lower(fext); % make sure text is lower case
                switch ext
                    case {'.xlsx','.xls'}
                        % save as Excel file
                        dosave=1;
                    case {'.csv','.txt'}
                        % save as CSV-file or TXT file
                        dosave=2;
                    otherwise
                        % unknown extension, save as Excel file
                        fext='.xlsx';
                        dosave=1;
                end 
                save_loc=fullfile(pathname,[fname,fext]);
            end
        else
            % save request denied
            dosave=0;
        end
    end
    % prepare for simulation
    set(handles.ind_status,'String','PREPARING');
    [time_min,time_sec]=calcTime();
    set(handles.val_T_est_m,'String',num2str(time_min));
    set(handles.val_T_est_s,'String',num2str(time_sec));
    % run simulation
    set(handles.btn_stop,'Enable','off');
    set(handles.ind_sim,'String','ON');
    main(0); % build sim
end
switch doPause
    case 1 % paused mode, 
        set(handles.btn_on,'Enable','off');
        set(handles.btn_stop,'Enable','on');
        set(handles.btn_pause,'Enable','on');
        set(handles.btn_pause,'string','Unpause');
        set(handles.ind_status,'String','PAUSED');
        main(3); % Sim paused, waiting
    case 2 % unpaused mode
        if changes==1 % rerun sim
            set(handles.btn_on,'Enable','off');
            set(handles.btn_pause,'Enable','off');
            set(handles.btn_pause,'string','Pause');
            set(handles.ind_status,'String','RE-BUILDING');
            doPause=0;
            changes=0;
            btn_on_Callback(hObject, eventdata, handles);
        else % continue sim
            set(handles.btn_on,'Enable','off');
            set(handles.btn_pause,'Enable','on');
            set(handles.btn_pause,'string','Pause');
            set(handles.ind_sim,'String','ON');
            set(handles.ind_status,'String','RUNNING');
            main(2); % continue sim
            btn_on_Callback(hObject, eventdata, handles);
        end
    otherwise % normal mode/ unknown mode(run as normal)
        set(handles.btn_on,'Enable','off');
        set(handles.btn_stop,'Enable','on');
        set(handles.btn_pause,'Enable','on');
        set(handles.ind_status,'String','RUNNING');
        main(1); % run sim
        set(handles.btn_on,'Enable','on');
        set(handles.btn_stop,'Enable','on');
        set(handles.btn_pause,'Enable','off');
        set(handles.ind_status,'String','FINISHED');
end
% enable inputs
set(handles.val_centerx,'Enable','on');
set(handles.val_centery,'Enable','on');
set(handles.val_diameter,'Enable','on');
set(handles.val_loops,'Enable','on');
set(handles.val_delay,'Enable','on');
set(handles.val_tRead,'Enable','on');
set(handles.val_tot_acc,'Enable','on');
set(handles.val_scale,'Enable','on');

% receive data
if ~isappdata(0,'x_data')||~isappdata(0,'y_data')||...
        ~isappdata(0,'p_data')||~isappdata(0,'t_data')||...
        ~isappdata(0,'loopnr')||~isappdata(0,'cyclenr')||...
        ~isappdata(0,'xmax')||~isappdata(0,'ymax')||~isappdata(0,'pmax')
    % error loading data+
    set(handles.ind_error,'string','ERROR: unable to receive stored data!');
    return;
end
% get appdata
xpos_t=getappdata(0,'x_data');
xpos=xpos_t(2:end-2,1); % skip initial & last number
ypos_t=getappdata(0,'y_data');
ypos=ypos_t(2:end-2,1); % skip initial & last number
power_t=getappdata(0,'p_data');
power=power_t(2:end-2,1); % skip initial & last number
time_t=getappdata(0,'t_data');
time=time_t(2:end-2,1); % skip initial & last number
loop_nr_t=getappdata(0,'loopnr');
loop_nr=loop_nr_t(2:end-2,1); % skip initial & last number
cycle_nr_t=getappdata(0,'cyclenr');
cycle_nr=cycle_nr_t(2:end-2,1); % skip initial & last number
xmax_t=getappdata(0,'xmax')*50/4096; % convert to um
xmax=xmax_t(2:end-2,1); % skip initial & last number
ymax_t=getappdata(0,'ymax')*50/4096; % convert to um
ymax=ymax_t(2:end-2,1); % skip initial & last number
pmax_t=getappdata(0,'pmax');
pmax=pmax_t(2:end-2,1); % skip initial & last number
% get GUI data
centerx=get(handles.val_centerx,'string');
centery=get(handles.val_centery,'string');
diameter=get(handles.val_diameter,'string');
delay=get(handles.val_delay,'string');
tRead=get(handles.val_tRead,'string');
scale=get(handles.val_scale,'string');
acc=get(handles.val_acc,'string');
tot_acc=get(handles.val_tot_acc,'string');

% receive highest power per cycle
for cycle=1:max(cycle_nr)
    max_x(cycle,1)=xmax(find(cycle_nr==cycle,1,'last'));
    max_y(cycle,1)=ymax(find(cycle_nr==cycle,1,'last'));
    max_p(cycle,1)=pmax(find(cycle_nr==cycle,1,'last'));
end

% plot position [xy, max_xy]
plot(handles.plt_pos,xpos,ypos,max_x,max_y,'r*','markersize',3);
axis(handles.plt_pos,[min(xpos) max(xpos) min(ypos) max(ypos)]);
grid(handles.plt_pos,'on');
grid(handles.plt_pos,'minor');

% calculate relative position
offsetx=min(xpos)+(max(xpos)-min(xpos))/2;
offsety=min(ypos)+(max(ypos)-min(ypos))/2;
xrel=xpos-offsetx;
yrel=ypos-offsety;

% plot data(t) [x,y,P]
xlim(handles.plt_time,[0 max(time)]);
% primary side: positions
yyaxis(handles.plt_time,'left');
plot(handles.plt_time,time,xrel,time,yrel);
ylim(handles.plt_time,[min(min(xrel),min(yrel)) max(max(xrel),max(yrel))]);
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');

% secondary side: power, loopnr, cyclenr
yyaxis(handles.plt_time,'right');
plot(handles.plt_time,time,power);
ylim(handles.plt_time,[min(power(:,1)) max(power(:,1))]);
grid(handles.plt_time,'on');
grid(handles.plt_time,'minor');

legend(handles.plt_time,'X position','Y position','Power','location','northoutside','Orientation','Horizontal');

% show position of highest power
set(handles.val_Pmax,'string',num2str(round(max_p(end,1)*100)/100));
set(handles.val_Pxmax,'string',num2str(round(max_x(end,1)*100)/100));
set(handles.val_Pymax,'string',num2str(round(max_y(end,1)*100)/100));

% show range
set(handles.val_xmin,'string',num2str(round(min(xpos)*100)/100));
set(handles.val_xmax,'string',num2str(round(max(xpos)*100)/100));
set(handles.val_ymin,'string',num2str(round(min(ypos)*100)/100));
set(handles.val_ymax,'string',num2str(round(max(ypos)*100)/100));

% show actual time
minutes=floor(max(time)/60);
seconds=ceil(max(time)-minutes*60);
set(handles.val_time_m,'string',num2str(minutes));
set(handles.val_time_s,'string',num2str(seconds));

if doPause==0
    % save to file
    set(handles.ind_sim,'String','BUSY');
    set(handles.ind_status,'String','SAVING');
    if dosave>0
        % create parameter info
        summary={'PARAMETERS','','','','';...
            'Center',centerx,'um',centery,'um';...
            'Diameter',diameter,'um','','';...
            'Loops',num2str(max(loop_nr)),'','','';...
            'Scale',scale,'X','','';...
            'Delay time',delay,'samples','','';...
            'Read time',tRead,'samples','','';...
            'Accuracy',acc,'nm /',tot_acc,'nm';...
            'RESULTS','','','','';...
            'Sample frequency','800','Hz','125','ms';...
            'Range X',num2str(round(min(xpos)*1000)/1000),'um',num2str(round(max(xpos)*1000)/1000),'um';...
            'Range Y',num2str(round(min(ypos)*1000)/1000),'um',num2str(round(max(ypos)*1000)/1000),'um';...
            'Time',num2str(floor(max(time)/60)),'min',num2str(ceil(max(time)-floor(max(time)/60)*60)),'sec';...
            'High power',num2str(round(max_p(end,1)*1000)/1000),'uW','','';...
            'Location',num2str(round(xmax(end,1)*1000)/1000),'um',num2str(round(ymax(end,1)*1000)/1000),'um'};
        switch dosave
            case 1 % save as Excel file
                % Create SUMMARY tab
                xlswrite(save_loc,summary,'SUMMARY','A1');

                % Create ALL DATA tab
                all_header={'Time','Cycle','Loop','Xpos','Ypos','Power','Xmax','Ymax'};
                all_data=[time,cycle_nr,loop_nr,xpos,ypos,power,xmax,ymax];
                xlswrite(save_loc,all_header,'ALL','A1');
                xlswrite(save_loc,all_data,'ALL','A2');

                % Create MOVE tab
                move_header={'Time','Cycle','Xpos','Ypos','Power','Xmax','Ymax'};
                move_data=[time,cycle_nr,xpos,ypos,power,xmax,ymax];
                el=find(loop_nr==0);
                xlswrite(save_loc,move_header,'Move','A1');
                xlswrite(save_loc,move_data(find(loop_nr==0),:),'Move','A2');
                
                % Create CYCLE tabs
                cycle_header={'Time','Loop','Xpos','Ypos','Power','Xmax','Ymax'};
                cycle_data=[time,loop_nr,xpos,ypos,power,xmax,ymax];
                el=2;
                for cycle=1:max(cycle_nr)
                    el=find((cycle_nr==cycle)&(loop_nr>0));
                    name=strcat('Cycle',num2str(cycle));
                    xlswrite(save_loc,cycle_header,name,'A1');
                    xlswrite(save_loc,cycle_data(el,:),name,'A2');
                end
            case 2 % save as CSV file
                [f,fname,fext]=fileparts(save_loc);
                % generate parameter file
                param_loc=strcat(fname,'_param',fext);
                data_param=table(sum_txt);
                writetable(data_param,param_loc,'WriteVariableNames',1);
                % generate data file
                data_table=table(data);
                writetable(data_table,save_loc,'WriteVariableNames',1);
            otherwise
                % no save
        end
        save_loc='';
    end
    set(handles.ind_sim,'String','OFF');
    set(handles.ind_status,'String','IDLE');
end

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
        set(handles.val_tRead,'Enable','on');
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
        set(handles.val_tRead,'Enable','off');
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
        set(handles.val_tRead,'Enable','on');
        set(handles.val_tot_acc,'Enable','on');
        set(handles.val_scale,'Enable','on');
        set(handles.btn_on,'Enable','off');
        set(handles.btn_pause,'Enable','on');
        set(handles.btn_pause,'String','Pause');
        doPause=0;
end

% --- Executes on button press in btn_reset.
function btn_reset_Callback(hObject, eventdata, handles)
% hObject    handle to btn_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
reset=questdlg('Do you really want to reset the interface?!','Reset','Cancel','Reset','Cancel');
if strcmp(reset,'Cancel')
    return
end
UserInterface_OpeningFcn(findobj('Tag','fig_GUI'),eventdata,handles);

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
set(handles.val_tRead,'Enable','on');
set(handles.val_tot_acc,'Enable','on');
set(handles.val_scale,'Enable','on');
set(handles.btn_on,'Enable','on');
set(handles.btn_pause,'Enable','off');
set(handles.btn_pause,'String','Pause');

%%%%%%%%%%%%%%%%% SETTING VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    set(handles.val_T_est_m,'String',num2str(time_min));
    set(handles.val_T_est_s,'String',num2str(time_sec));
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
    set(handles.val_T_est_m,'String',num2str(time_min));
    set(handles.val_T_est_s,'String',num2str(time_sec));
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
    set(handles.val_cycles,'String',num2str(cycles));
    set(handles.val_acc,'String',num2str(acc));
    set(handles.val_T_est_m,'String',num2str(time_min));
    set(handles.val_T_est_s,'String',num2str(time_sec));
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
    set(handles.val_cycles,'String',num2str(cycles));
    set(handles.val_acc,'String',num2str(acc));
    set(handles.val_T_est_m,'String',num2str(time_min));
    set(handles.val_T_est_s,'String',num2str(time_sec));
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
    set(handles.val_cycles,'String',num2str(cycles));
    set(handles.val_acc,'String',num2str(acc));
    set(handles.val_T_est_m,'String',num2str(time_min));
    set(handles.val_T_est_s,'String',num2str(time_sec));
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
    set(handles.val_cycles,'String',num2str(cycles));
    set(handles.val_acc,'String',num2str(acc));
    set(handles.val_T_est_m,'String',num2str(time_min));
    set(handles.val_T_est_s,'String',num2str(time_sec));
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
    set(handles.val_T_est_m,'String',num2str(time_min));
    set(handles.val_T_est_s,'String',num2str(time_sec));
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
    set(handles.val_T_est_m,'String',num2str(time_min));
    set(handles.val_T_est_s,'String',num2str(time_sec));
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

function val_cycles_Callback(hObject, eventdata, handles)
% hObject    handle to val_cycles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_cycles as text
%        str2double(get(hObject,'String')) returns contents of val_cycles as a double

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

function val_T_est_m_Callback(hObject, eventdata, handles)
% hObject    handle to val_T_est_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_T_est_m as text
%        str2double(get(hObject,'String')) returns contents of val_T_est_m as a double

function val_T_est_s_Callback(hObject, eventdata, handles)
% hObject    handle to val_T_est_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_T_est_s as text
%        str2double(get(hObject,'String')) returns contents of val_T_est_s as a double

function val_time_m_Callback(hObject, eventdata, handles)
% hObject    handle to val_time_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_time_m as text
%        str2double(get(hObject,'String')) returns contents of val_time_m as a double

function val_time_s_Callback(hObject, eventdata, handles)
% hObject    handle to val_time_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of val_time_s as text
%        str2double(get(hObject,'String')) returns contents of val_time_s as a double

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
function val_cycles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_cycles (see GCBO)
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
% --- Executes during object creation, after setting all properties.
function val_T_est_m_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_T_est_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_T_est_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_T_est_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_time_m_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_time_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function val_time_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_time_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%% END USERINTERFACE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
