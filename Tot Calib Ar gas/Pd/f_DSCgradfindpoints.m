function fignum=f_DSCgradfindpoints(data,file,fignum)
fignum=f_plotDSCgrad(data,file,fignum);
dydx = smoothdata(gradient(smoothdata(data{fignum}.HF(:)))...
    ./ gradient(data{fignum}.Tr(:)));
dsqydxsq = gradient(smoothdata(gradient(smoothdata(data{fignum}.HF(:))) ...
    ./ gradient(smoothdata(data{fignum}.Tr(:)))));
[mmin,idmin]=min(dydx);
[mmax,idmax]=max(dydx);

[idzer]=find(dydx(idmin:idmax)<1 & dydx(idmin:idmax)>-1);
idcross=round(mean(idzer))+idmin;
idx=idcross;
dydx=smoothdata(dydx)
m1=dydx(idx);

%c=y-mx
c1=data{fignum}.HF(idx)-data{fignum}.Tr(idx).*m1;
T=linspace(min(data{fignum}.Tr(1:end)),max(data{fignum}.Tr(1:end-1)),1000);
tang=m1.*T+c1;
figure()
fignum=f_plotDSCres(data,file,fignum);
hold on
plot(T,tang,'LineWidth',3)
