function [min,sec]=calcTime()
display('CALCTIME');
if ~isappdata(0,'centerx')||~isappdata(0,'centery')||...
        ~isappdata(0,'diameter')||~isappdata(0,'loops')||...
        ~isappdata(0,'cycles')||~isappdata(0,'scale')||...
        ~isappdata(0,'delay')||~isappdata(0,'read_time')
    min=0;
    sec=0;
    display('CALCTIME: error loading data');
    return;
end
centerx=getappdata(0,'centerx');
centery=getappdata(0,'centery');
diameter=getappdata(0,'diameter');
loops=getappdata(0,'loops');
cycles=getappdata(0,'cycles');
scale=getappdata(0,'scale');
delay=getappdata(0,'delay');
read_time=getappdata(0,'read_time');

% add delay (&read_time) to equation
time_loops=0;
for i=1:loops
    time_loops=time_loops+(2*i-1)*diameter/((2*loops-1));
end
time_cycles=0;
time_move=0;
for j=1:cycles
    time_cycles=time_loops*scale^(1-j);
    time_movex=centerx+0.5*diameter/scale^(j-1);
    time_movey=centery+0.5*diameter/scale^(j-1);
    time_move=time_move+abs(time_movex)+abs(time_movey);
end

time_move_init=(abs(centerx)+abs(centery));
time=time_loops+time_cycles+time_move+time_move_init;

min=floor(time/60);
sec=ceil(time-min*60);