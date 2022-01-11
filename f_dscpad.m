function [dat,t]=f_dscpad(govee,Range,humidnorm,weight2,val)
delt=hours(abs(val));
padsize=size(govee.t(1:find(govee.t==govee.t(1)+delt)));
%weightmod=weight2(Range)+humidnorm(Range).*(max(weight2(Range))-min(weight2(Range)));
modhumid=abs(humidnorm(Range).*(max(weight2(Range))-min(weight2(Range))));
%deal with padding to allign values
weightmod=weight2(Range);
if val>0
    weightmod=weightmod(padsize:end);
    modhumid=modhumid(1:end-padsize+1);
else
    weightmod=weightmod(1:end-padsize+1);
    modhumid=modhumid(padsize:end);
end
dat=weightmod+modhumid;
t=govee.t(Range);
t=t(padsize:end);