function Enthalpy=f_heatflowcalib(data,file,numfiles,mass)

Enthalpy=NaN(1,numfiles);
for idx=1:numfiles
    figure(idx)
    f_plotDSCres(data,file,idx);
    ax=gca;
    roi=drawline(ax);
    input('Happy to procede? Type any key to continue:','s');
    %define the line you just drew
    pos1=roi.Position;
    %define the ROI line equation and sample 1000 points on it
    m1=(pos1(2,2)-pos1(1,2))./(pos1(2,1)-pos1(1,1));
    b1=pos1(2,2)-m1.*pos1(2,1);
    x=linspace(min([pos1(2,1),pos1(1,1)]),max([pos1(2,1),pos1(1,1)]),1000);
    y=m1.*x+b1;
    %find the index of the ends of the line you drew
    [~,p1idx]=min(abs(data{idx}.Tr-min([pos1(2,1),pos1(1,1)])));
    [~,p2idx]=min(abs(data{idx}.Tr-max([pos1(2,1),pos1(1,1)])));
    %int=trapz(x,y)-trapz(data{idx}.Tr(p1idx:p2idx),data{idx}.HF(p1idx:p2idx));
    %create an inclosed body
    hold off
    figure(idx)
    f_plotDSCt(data,file,idx);
    %convert the temperature values into time
    xprime=linspace(data{idx}.t(p1idx),data{idx}.t(p2idx),1000);
    x2 = [xprime, [flipud(data{idx}.t(p1idx:p2idx))]'];
    inBetween = [y, [flipud(data{idx}.HF(p1idx:p2idx))]'];
    hold on
    
    fill(x2, inBetween, 'g');
    a=polyarea(x2,inBetween); %find the area of the shaded region using polyarea
    figure(idx)
    Enthalpy(idx)=(a.*1e-3)/(mass(idx).*1e-3);
end


