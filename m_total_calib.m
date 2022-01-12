%% select data file directory
[path] = uigetdir();
exportq=1;%do you want to export the data?
outputfilename = strcat('DSCtotcalibdata',date,'.mat');
%[litfile, litpath] = uigetfile('.csv','MultiSelect','off');
litdata=readtable('litdata.csv');
%% change WD
cd(path);
txtfiles=dir('*.txt')
numfiles=length(txtfiles);
file=cell(1,numfiles);
for i=1:numfiles
    file{i}=txtfiles(i).name

end
%% find file names
names=cell(1,numfiles);
Hrate=names;
for i=1:numfiles
    splitname=strsplit(file{i},'.txt');
    names{i}=splitname{1};
    rateT=strsplit(names{i},' ');
    Hrate{i}=str2double(rateT{2});
end
Hrate=cell2mat(Hrate).*60;
%% extract data
data=cell(numfiles,1);
if numfiles>1
    fnum=length(file);
    for i=1:fnum

        data{i}=readtable([path,strcat('/',file{i})]);
    end
else
    temp=cell(1,2);
    data=temp;
    temp{1,1}=file;
    file=temp;
    data{1}=readtable([path,file{1}]);
    fnum=1;
end
%% plot data
close all
figure(1)
for i=1:fnum
    %subplot(2,2,i)
    fignum=f_plotDSCres(data,file,i);
    hold on
end
hold off
legend(names)
%% User inputs lines which are tangent to the transformation 
% curve to define the extrapolated initiation temperature

numlines=2;

intersect=cell(fnum,1);
Te=NaN(fnum,1);
roi=cell(fnum,numlines);
for fignum=1:fnum%length(file)
    [roi,intersect{fignum}]=f_createlineDSC(data,file,fignum,roi);
    Te(fignum)=intersect{fignum}(1,1);
end
disp('All samples Calculated')
%% plot diferences between samples
%{%
figure()
plot(Hrate,Te,'o','markerSize',10)
% Get coefficients of a line fit through the data.
coefficients = polyfit(Hrate, Te, 1);
% Create a new x axis with exactly 1000 points (or whatever you want).
xFit = linspace(min(Hrate), max(Hrate), 1000);
% Get the estimated yFit value for each of those 1000 new x locations.
yFit = polyval(coefficients , xFit);
hold on
plot(xFit,yFit)
if ~exist("litdata","var")
    litdata=readtable([litpath,litfile]);
end
yline(litdata.Te(strcmp(litdata.Standard,path(end-1:end))))
xlabel('Heating Rate (degrees per second)')
ylabel('Extrapolated Onset Temperature (^o C)')
title(strcat(path(end-1:end),{' '},'tau-lag'))
legend('Data','Fit','Standard Value')

save(outputfilename)
