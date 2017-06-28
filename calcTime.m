function [min,sec]=calcTime()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% The calcTime function is often required to recalculate the estimated
% time. The time depends on the number of loops, cycles, range and offset.
% The first for-loop is used to get the total amount of samples for 1
% cycle (tL). Next is the initial time to move the offset (tM) determined
% and is the total time for all cycles calculated (tC) and is the move time
% increased with worst case movement (1/2 diameter with respect of the
% scale). The delay & read time increases the total time by a factor, the
% total time is then divided in minutes and seconds for easy use in later
% code.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

for L=1:loops-1
    % circumference of loop (incl. piece to new loop)
    tL=tL+5*((2*L-1)*diameter/(2*loops-1));
end
% circumference of loop 
L=L+1;
tL=tL+4*((2*L-1)*diameter/(2*loops-1));
% offset
tM=abs(centerx)+abs(centery);
for C=1:cycles
    tC=tC+tL*scale^(1-C);
    tM=tM+abs(centerx+0.5*diameter*scale^(1-C))+abs(centery+0.5*diameter*scale^(1-C));
end

tTot=(tC+tM)/800;
time=tTot*(1+read/delay);
min=floor(time/60);
sec=floor(time-min*60);
