
%% select data files

[file, path] = uigetfile('.txt','MultiSelect','on');
exportq=0;%do you want to export the data?
outputfilename = strcat('DSCpost1callibdata',date,'.xlsx');
%find the literature data (put your location in here)
litpath='/Users/roryrose/OneDrive - Imperial College London/Year 1/DSC/Analysis Code/litdata.csv';
litdata=readtable(litpath);
% OR do this:
%{
[litfile, litpath] = uigetfile('.csv','MultiSelect','off');
%}

% change WD
cd(path);
% find file names
for i=1:size(file,2)
    splitname=strsplit(file{i},'.');
    splitname=splitname{1};
    names{i}=splitname(1:2);
end
% extract data

if size(file,2)>1
    numfiles=length(file);
    data=cell(length(file),1);
    for i=1:numfiles

        data{i}=readtable([path,file{i}]);
    end
else
    data{1}=readtable([path,file]);
    numfiles=1;
end
% plot data
close all
h=figure(1);
for i=1:numfiles
    subplot(2,3,i)
    fignum=f_plotDSCres(data,file,i);
    hold on
end
hold off
figname='raw_data';
saveas(h,figname,'tiffn')
saveas(h,figname,'fig')
%% User inputs lines which are tangent to the transformation 
% curve to define the extrapolated initiation temperature
DB=table();
DB.Element=names';
Te=f_createlineDSC(data,file,numfiles);
DB.Te=Te';
disp('All samples Calculated')
% Input the masses of the samples
mass=NaN(1,numfiles);
for i=1:numfiles
    mass(i) = input(strcat("what was the sample mass of ",names{i},'(mg):'));
end
DB.mass=mass';
% Calculate Enthalpy of transofrmation per gram
Enthalpy=f_heatflowcalib(data,file,numfiles,mass);
DB.Enthalpy=Enthalpy';
close all
% plot diferences between samples
%{
figure()
Te2=Te([4,2,3,5,6,1])
plot(1:6,Te2,'-o','markerSize',10)
xlabel('Heating Number')
ylabel('Extrapolated Onset Temperature')
title('Al cycling')
%}
%% import the literature data from a csv file and plot 
% the difference to the observed data as a function of Temperatre
exportq=1;
delT=NaN(numfiles,1);
delH=delT;
for i=1:numfiles
    litidx=find(strcmp(litdata.Standard,DB.Element(i)));%find the index in the literature data for this element
    delT(i)=DB.Te(i)-litdata.Te(litidx);
    delH(i)=(-DB.Enthalpy(i)-litdata.H(litidx))./litdata.H(litidx).*100;
end
DB.delT=delT;
DB.delH=delH;

if exportq==1
    outdata=DB;
    outdata.Properties.VariableNames={'Element','Measured_Te_deg','mass_g','enthalpy_J/g','measuredT_e-litT_e','measuredH-LitH'};
    writetable(outdata,[path,outputfilename],'Sheet',1)
end
%% DEBUG - take total calib data and ut it into this structure type
elems={'In','Zn','Al','Au','Pd'};
Temp=table();
for i=1:5
    Temp.Te(i)=DB.(elems{i}).Te.Te(2);
    Temp.Element{i}=elems{i};
    Temp.Enthalpy(i)=DB.(elems{i}).H.("Enthalpy (J/g)")(2);
end
numfiles=5;
DB=Temp;
%% plot and save figures
figure(5)
scatter(DB.Te,DB.delT)
xlabel('T_e (^oC)')
ylabel('\Delta T_e (^oC) [real-measured]')
ylim([-20,25])
figure(6)
scatter(DB.Te,DB.delH)
xlabel('T_e (^oC)')
ylabel('\Delta H (J/g) [real-measured]')
% fit using b-splines (using SLM engine - must be on the path! [https://uk.mathworks.com/matlabcentral/fileexchange/24443-slm-shape-language-modeling]) 
[calibfit,TrueTfit,delTfit] = slmengine(DB.Te,DB.delT,'plot','off');
h=figure(5);
hold on
plot(TrueTfit,delTfit)
hold off
legend('Standard Samples','Cubic Spline Fit')
figname='T_fit';
saveas(h,figname,'tiffn')
saveas(h,figname,'fig')
[calibHfit,TrueHfit,delHfit] = slmengine(DB.Te,DB.delH,'plot','off');
h=figure(6);
hold on
plot(TrueHfit,delHfit)
hold off
legend('Standard Samples','Cubic Spline Fit')
figname='H_fit';
saveas(h,figname,'tiffn')
saveas(h,figname,'fig')