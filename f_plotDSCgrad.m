function fignum=f_plotDSCgrad(data,file,fignum)

if ~exist("fignum","var")
    fignum=1;
end
dydx = gradient(smoothdata(data{fignum}.HF(:))) ./ gradient(smoothdata(data{fignum}.Tr(:)));
plot(data{fignum}.Tr,dydx,'LineWidth',2)
title(file{fignum}(1:2))
xlabel('T_r')
ylabel('Gradient of Heat Flow')