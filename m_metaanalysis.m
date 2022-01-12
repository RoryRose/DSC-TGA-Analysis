%load("/Users/roryrose/OneDrive - Imperial College London/Year 1/DSC/Analysis Code/DSC_tot_calib_data.mat");
litdata=readtable('litdata.csv');
%select parent folder
[path] = uigetdir();
% change WD
cd(path);
files=dir();
files(ismember( {files.name}, {'.', '..'})) = [];  %remove . and ..subfolders=files(folderid);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags);

numfiles=length(subFolders);
names={subFolders.name};
%% plot HFR
outdata=table();

for i=1:numfiles
    litidx=strcmp(litdata.Standard,names{i});
    HFR=(DB.(names{i}).H);
    HFR.T=ones(length(HFR.("Enthalpy (J/g)")),1).*litdata.Te(litidx);
    HFR.deltaH=-HFR.("Enthalpy (J/g)")-litdata.H(litidx);
    HFR.Te=DB.(names{i}).Te;
    HFR.delT=DB.(names{i}).Te.Te-litdata.Te(litidx);
    outdata=[outdata;HFR];
    taulag(i)=DB.(names{i}).taulag;
end
figure()

scatter(outdata.T,(outdata.deltaH./outdata.("Enthalpy (J/g)")).*100)
ylabel("\Delta H [meas-lit] (%)")
xlabel("Temperature (^o C)")

figure()
tendata=outdata(round(outdata.("Heating Rate (Deg/min)"))==10,:)
tendata.element=names';
tendata.taulag_s=[taulag.*60]';
scatter(tendata.T,(tendata.deltaH./tendata.("Enthalpy (J/g)")).*100)
ylabel("\Delta H [meas-lit] (%)")
xlabel("Temperature (^o C)")
title('10 Deg/min Heating Rate')
%% save the data in a excel sheet
filename='Summary Data from DSC Total calibration.xlsx';
writetable(splitvars(tendata),filename,'Sheet',1,'Range','A1')
writetable(splitvars(outdata),filename,'Sheet',2,'Range','A1')