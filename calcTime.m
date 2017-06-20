function [min,sec]=calcTime()
if ~isappdata(0,'centerx')||~isappdata(0,'centery')||~isappdata(0,'diameter')...
        ||~isappdata(0,'scale')||~isappdata(0,'loops')||~isappdata(0,'cycles')...
        ||~isappdata(0,'delay')||~isappdata(0,'read_time')
    min=0;
    sec=0;
    return;
end

resolution=50/4096;
tL=0;
tC=0;

centerx=getappdata(0,'centerx')/resolution;
centery=getappdata(0,'centery')/resolution;
diameter=getappdata(0,'diameter')/resolution;
scale=getappdata(0,'scale');
loops=getappdata(0,'loops');
cycles=getappdata(0,'cycles');
delay=getappdata(0,'delay');
read=getappdata(0,'read_time');

for L=1:loops
    tL=tL+(2*L-1)*diameter/(2*loops-1);
end
tM=abs(centerx)+abs(centery);
for C=1:cycles
    tC=tL*scale^(C-1);
    tM=tM+abs(centerx+0.5*diameter/scale^(C-1))+abs(centery+0.5*diameter/scale^(C-1));
end

tTot=(tC+tM)/800;
time=tTot+tTot/delay*read;
min=floor(time/60);
sec=floor(time-min*60);
display(strcat('time:',num2str(min,'%02i'),':',num2str(sec,'%02i')))
