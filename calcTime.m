function [min,sec]=calcTime()
if ~isappdata(0,'centerx')||~isappdata(0,'centery')||...
        ~isappdata(0,'diameter')||~isappdata(0,'loops')||...
        ~isappdata(0,'cycles')||~isappdata(0,'scale')||...
        ~isappdata(0,'delay')||~isappdata(0,'read_time')
    min=0;
    sec=0;
else
    res=50/4096;
    centerx=getappdata(0,'centerx')/res;
    centery=getappdata(0,'centery')/res;
    diameter=getappdata(0,'diameter')/res;
    loops=getappdata(0,'loops');
    cycles=getappdata(0,'cycles');
    scale=getappdata(0,'scale');
    delay=getappdata(0,'delay');
    read_time=getappdata(0,'read_time');

    % add delay (&read_time) to equation
    loop_time=0;
    move_time=0;
    for cycleA=1:cycles
        for loopA=1:loops
            loop_time=loop_time+diameter*(8*loopA-3)/((2*loops-1)*scale^(cycleA-1));
            move_time=move_time+2*diameter/scale^(cycleA-1);
        end
    end
    samples=loop_time+move_time+abs(centerx)+abs(centery);
    time=samples*(1+delay)/(800*(delay+read_time));
    min=floor(time/60);
    sec=ceil(time-min*60);
end