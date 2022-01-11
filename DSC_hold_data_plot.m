govee=readtable("/Users/roryrose/OneDrive - Imperial College London/Year 1/DSC/1 week hold/DSC 1 week  hold - 2 room T ")
govee.t=datetime(govee.Timestamp_for_sample_frequency_every_1Min_min);
if ~exist("fignum","var")
    fignum=1;
end
time=datetime(2021,12,09,19,14,45)-seconds(data{fignum}.t(end-1))+seconds(data{fignum}.t);
%% figure 1
t=figure(fignum);
subplot(2,2,1)
plot(time,data{fignum}.HF,'LineWidth',2)
title('Heat Flow')
ylabel('Heat Flow (mW)')

subplot(2,2,2)
plot(time,data{fignum}.Ts,'LineWidth',2)
title('Sample Temperature')
ylabel('Temperature ^oC')

subplot(2,2,3)

plot(time,data{fignum}.Weight,'LineWidth',2)
title('Weight')
ylabel('Mass (mg)')
subplot(2,2,4)

plot(time,data{fignum}.Tr,'LineWidth',2)
title('Reference Temperature')
ylabel('Temperature ^oC')


%% second plot comparing to room data
figure(2)
subplot(1,2,1)
yyaxis left
plot(time,data{fignum}.Weight,'LineWidth',2)
title('Weight')
ylabel('Mass (mg)')

yyaxis right
%histT=datetime(2021,11,22)+days(DSC_temp_data(:,1)-22);
%plot(histT,DSC_temp_data(:,2))

plot(govee.t,govee.Temperature_Celsius)
ylabel('Room Temperature (^oC)')
%ylim([-3,11])
%xlim([datetime(2021,11,22,17,40,42),datetime(2021,11,29,17,40,42)])
subplot(1,2,2)
yyaxis left
plot(time,data{fignum}.Weight,'LineWidth',2)
title('Weight')
ylabel('Mass (mg)')
yyaxis right
%histT=datetime(2021,11,22)+days(DSC_temp_data(:,1)-22);
%plot(histT,DSC_temp_data(:,2))
plot(govee.t,govee.Relative_Humidity)
ylabel('Room Humidity (%)')
%
% ylim([-3,11])
%xlim([datetime(2021,11,22,17,40,42),datetime(2021,11,29,17,40,42)])



%% corrplot
weight2=NaN(length(govee.t),1);
for i=1:length(govee.t)
    [~,idx]=min(abs(time-govee.t(i)));
    weight2(i)=data{fignum}.Weight(idx);
end
Range=govee.t<max(time) & govee.t>min(time)+hours(1);
mat=table(weight2(Range),govee.Relative_Humidity(Range),govee.Temperature_Celsius(Range));
mat.Properties.VariableNames={'Mass','RHumidity','RTemperature'};
corrplot(mat)
figure()
plot(govee.t(Rrange),weight2)

%% allogn start and re-scale
%weightmod=weight2(Range)+humidnorm(Range).*(max(weight2(Range))-min(weight2(Range)));
modhumid=abs(humidnorm(Range).*(max(weight2(Range))-min(weight2(Range))));

%%
valstotry=-10:0.5:10;
range=NaN(length(valstotry),1);
for i=1:length(valstotry)
    
    
    dat=f_dscpad(govee,Range,humidnorm,weight2,valstotry(i));
    range(i)=std(dat);
end
[~,idx]=min(range);
[dat,datt]=f_dscpad(govee,Range,humidnorm,weight2,valstotry(idx));

%% 
figure(1)
plot(govee.t(Range),modhumid)
hold on
plot(govee.t(Range),weight2(Range))
plot(datt,dat)
legend({strcat('humidity norm + disp = ',num2str(valstotry(idx)),'hours'),'Sample weight','Sample Weight + humidity'})