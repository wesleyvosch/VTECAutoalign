function time=calcTime()
if ~isappdata(0,'loops')||~isappdata(0,'centerx')||~isappdata(0,'centery')...
        ||~isappdata(0,'diameter')||~isappdata(0,'delay')
    time=0;
end
loops=getappdata(0,'loops');
centerx=getappdata(0,'centerx');
centery=getappdata(0,'centery');
diameter=getappdata(0,'diameter');
delay=getappdata(0,'delay');

ci=0;
for i=1:loops
   ci=ci+(2*i-1)*diameter*4096/((2*loops-1)*50);
end
ct=4*ci+diameter*4096/((2*loops-1)*50);
% start_diff=abs(centerx-centerx_sim)+abs(centery-centery_sim);
start_diff=0;
cto=ct+start_diff*4096/50;
time=cto*(1+16/delay)/800;
display(time);
setappdata(0,'approx_time',time);