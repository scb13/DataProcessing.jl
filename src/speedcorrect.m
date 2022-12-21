function tspeed = speedcorrect(tarSp, frameinterval, startTime)
%
tspeed = tarSp;
ndx = find(diff(tarSp))+1;
if isempty(ndx) %as in no target speed
    return
end
if ndx(1) < startTime < ndx(2)
    tspeed(ndx(1):ndx(2)-1) = 0;%tarSp(ndx(1)) / ((ndx(2)-1-startTime) / frameinterval);
else
    tspeed(ndx(1):ndx(2)-1) = round(tarSp(ndx(1)) / ((ndx(2)-ndx(1)) / frameinterval));
end
for ii = 2:length(ndx)-1
    tspeed(ndx(ii):ndx(ii+1)-1) = round(tarSp(ndx(ii)) / ((ndx(ii+1)-ndx(ii)) / frameinterval));
end
end
