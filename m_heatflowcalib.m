%% select data files
[path] = uigetdir();
exportq=1;%do you want to export the data?
outputfilename = strcat('DSCtotcalibdata',date,'.mat');
[litfile, litpath] = uigetfile('.csv','MultiSelect','off');
%load("/Users/roryrose/OneDrive - Imperial College London/Year 1/DSC/Analysis Code/DSC_tot_calib_data.mat");
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

%% find the 10k/min line
close all
degpermin=round(Hrate);
idx=find(degpermin==10);
mass = input(strcat("what was the sample mass of ",names{idx}(1:2),'(mg):'));
for idx=1:numfiles
    figure(idx)
    fignum=f_plotDSCres(data,file,idx);
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
    [p1,p1idx]=min(abs(data{idx}.Tr-min([pos1(2,1),pos1(1,1)])));
    [p2,p2idx]=min(abs(data{idx}.Tr-max([pos1(2,1),pos1(1,1)])));
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
    a=polyarea(x2,inBetween); %find the area of the shaded region suing polyarea
    figure(idx)
    Enthalpy(idx)=(a.*1e-3)/(mass.*1e-3);
end
element=names{idx}(1:2);
enths=table(Hrate',Enthalpy');
enths.Properties.VariableNames={'Heating Rate (Deg/min)','Enthalpy (J/g)'};
DB.(element).H=enths;
save('FINAL_DSC_tot_calib_data.mat',"DB")
