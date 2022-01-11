set(groot, 'DefaultLineLineWidth', 2);
set(groot,'defaultAxesFontSize',15);
set(groot,'defaultMarkerSize',4);
[file, path] = uigetfile('.fig','MultiSelect','on');

if size(file,2)>1
    fnum=length(file);
    for i=1:fnum
        h=open([path,file{i}])
        Lines = findobj(h, 'Type', 'line');
        Line(1).Color='r';
        saveas(gcf,'file.png'))
    end
else
    h=open([path,file])
    Lines = findobj(h, 'Type', 'line');
    Line(1).Color='r'
    
end
