%select parent folder
[path] = uigetdir();
%% change WD
cd(path);
files=dir();
files(ismember( {files.name}, {'.', '..'})) = [];  %remove . and ..
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags);
files=subFolders;
numfiles=length(subFolders);
file=cell(1,numfiles);
matname=file;
data=file;
for i=1:numfiles
    file{i}=files(i).name;
    cd(strcat(path,'/',file{i}))
    matdir=dir('*.mat');
    matname{i}=matdir.name;
    load(strcat(path,'/',file{i},'/',matname{i}),'Te','Hrate','coefficients','litdata')
    data{i}=[Hrate',Te];
    grad(i)=coefficients(1);% get out the gradient
    yinter(i)=coefficients(2);% get out the y-intercept
end
%% import the literature data from a csv file and plot 
% the difference to the observed data as a function of Temperatre
litdata=readtable('litdata.csv');
delT=NaN(length(litdata.Standard),4);
figure(1);
elementnames=[];
delTcell=[];
names={subFolders.name};
for i=1:numfiles
    litidx=find(strcmp(litdata.Standard,names{i}));
    delT(litidx,:)=[litdata.Te(litidx)-data{i}(:,2)]';
    delTcell{i}=delT(litidx,:);
    gradlit(litidx)=grad(i);
end
scatter(litdata.Te,delT,'HandleVisibility','off')
% fit using b-splines (using SLM engine - must be on the path! [https://uk.mathworks.com/matlabcentral/fileexchange/24443-slm-shape-language-modeling]) 
for i=1:4
    [calibfit{i},TrueTfit{i},delTfit{i}] = slmengine(litdata.Te,delT(:,i),'plot','off');
    figure(1)
    hold on
    plot(TrueTfit{i},delTfit{i})
end
hold off
legend(strsplit(num2str(round(Hrate))))
xlabel('T_e (^oC)')
ylabel('\Delta T_e (^oC) [real-measured]')
ylim([-20,20])
%%
figure()
scatter(litdata.Te,gradlit)
% Get coefficients of a line fit through the data.
coefficients2 = polyfit(litdata.Te, gradlit, 2);
% Create a new x axis with exactly 1000 points (or whatever you want).
xFit = linspace(min(litdata.Te), max(litdata.Te), 1000);
% Get the estimated yFit value for each of those 1000 new x locations.
yFit = polyval(coefficients2 , xFit);
hold on
plot(xFit,yFit)
xlabel('T_e (^oC)')
ylabel('Gradient of Tau-Lag fit')
%% create struct for database
DB=struct();
for i=1:numfiles
    temps=table(data{i}(:,1),data{i}(:,2));
    temps.Properties.VariableNames={'Heating Rate (Deg/min)','Te'};
    DB.(names{i}).Te=temps;
    DB.(names{i}).taulag=grad(i);
    DB.(names{i}).zeroHrate_Te=yinter(i);
end
save(strcat[path,'DSC_tot_calib_data.mat'],'DB')
