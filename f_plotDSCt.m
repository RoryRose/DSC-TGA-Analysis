function fignum=f_plotDSCt(data,file,fignum)

if ~exist("fignum","var")
    fignum=1;
end
plot(data{fignum}.t,data{fignum}.HF,'LineWidth',2)
title(file{fignum}(1:2))
xlabel('time (s)')
ylabel('Heat Flow')