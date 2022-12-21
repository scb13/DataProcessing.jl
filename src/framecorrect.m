function t = framecorrect(time, frameinterval)
%
t = time + frameinterval - mod(time,frameinterval);
t = round(t);
end
