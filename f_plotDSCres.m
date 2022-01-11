function fignum=f_plotDSCres(data,file,fignum)

if ~exist("fignum","var")
    fignum=1;
end
plot(data{fignum}.Tr,data{fignum}.HF,'LineWidth',2)
title(file{fignum}(1:2))
xlabel('T_r')
ylabel('Heat Flow')