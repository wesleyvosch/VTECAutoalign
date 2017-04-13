% this is the main entry point
function plotall() % plot data
    % gather data
    x=getappdata(0,'x_data');
    y=getappdata(0,'y_data');
    p=getappdata(0,'p_data');
    t=getappdata(0,'clk');
    startx=getappdata(0,'startx');
    starty=getappdata(0,'starty');
    lengthx=getappdata(0,'lengthx');
    lengthy=getappdata(0,'lengthy');
    loops=getappdata(0,'loops');
    
    % calculate boundaries
    % plot1 (x over y)
	xmin=startx-lengthx/2;
    xmax=startx+lengthx/2+lengthx/loops;
    ymin=starty-lengthy/2;
    ymax=starty+lengthy/2+lengthy/loops;
    
    % plot2 (p,x,y over t)
    xymin=min(xmin,ymin);
    xymax=max(xmax,ymax);
    tmin=0;
    tmax=max(t)+10;
    pmin=0;
    pmax=3.5;
    
    % prepare plot1
    handles=guihandles('UserInterface');
    plot(handles.plt_xypos,x,y);
end