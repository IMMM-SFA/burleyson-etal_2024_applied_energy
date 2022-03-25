% Load_Perturbation_Incorporation_Example.m
% 20220325
% Casey D. Burleyson
% Pacific Northwest National Laboratory

% This script is used to demonstrate the how you might go about incorporating
% detailed load perturbtions from an upstream sectoral model into the total
% load time series in TELL. This example, which is based on data from the 
% ComEd utility in Illinois, shows how a model of residential PV
% integration could be fed into the TELL time series of total loads.

warning off all; clear all; close all; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN USER INPUT SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set some processing flags:
save_images = 1; % (1 = Yes)

% Set the sample month and year of ComEd data to use:
sample_month = 4; 
sample_year = 2019;

% Set the data input directory and image output directory:
data_input_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2022_Burleyson_et_al_TELL/burleyson-etal_2022_tbd_data/input_data/Sample_ComEd_Data/';
image_output_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2022_Burleyson_et_al_TELL/burleyson-etal_2022_tbd/figures/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END USER INPUT SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PROCESSING SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([data_input_dir,'Monthly_Residential_Load_Profiles.mat']);
Res_Load(1,:) = [0.25:0.5:23.75];
Res_Load(2,:) = Mean_Weekday_Load(find(Mean_Load_Time(:,1) == sample_year & Mean_Load_Time(:,2) == sample_month),:);

max_res_perturbation = 0.35*nanmean(Res_Load(2,:));
Res_Load(3,13:25) = sin((Res_Load(1,13:25) - 6)./(1.3*pi));
Res_Load(3,26:37) = fliplr(Res_Load(3,13:24));
Res_Load(3,:) = max_res_perturbation .* (Res_Load(3,:)./max(Res_Load(3,:)));

Res_Load(4,:) = Res_Load(2,:) - Res_Load(3,:);
Res_Load(5,:) = Res_Load(1,:) - 0.25;

clear Mean_Load_Time Mean_Weekday_Load Mean_Weekend_Load


load([data_input_dir,'PJM_Hourly_Load.mat']);
PJM = PJM_Hourly_Load(find(PJM_Hourly_Load(:,1) == sample_year & PJM_Hourly_Load(:,2) == sample_month),[1,2,3,4,6]);
PJM(:,5) = PJM(:,5)./10;
for row = 1:size(PJM,1)
    PJM(row,6) = Res_Load(3,find(Res_Load(5,:) == PJM(row,4)));
end
PJM(:,7) = PJM(:,5) - PJM(:,6);
PJM(:,8) = datenum(PJM(:,1),PJM(:,2),PJM(:,3),PJM(:,4),0,0);
clear row PJM_Hourly_Load
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PLOTTING SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = figure('Color',[1 1 1]); set(a,'Position',get(0,'Screensize')); 

subplot(2,3,1); hold on;
line(Res_Load(1,:),Res_Load(2,:),'Color','b','LineWidth',3);
legend('Residential Demand','Location','North')
xlim([0 24]); set(gca,'xtick',[0:3:24],'xticklabel',{'00','03','06','09','12','15','18','21','24'});
ylim([1200 3000]);
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top');
xlabel('Local Time','FontSize',21);
ylabel('Mean Residential Demand [MWh]','FontSize',21);
title('Base Residential Demand','FontSize',24);
text(0.015,0.95,'(a)','FontSize',21,'Units','normalized');

subplot(2,3,2); hold on;
line(Res_Load(1,:),Res_Load(3,:),'Color','m','LineWidth',3);
legend('Solar Supply','Location','NorthEast')
xlim([0 24]); set(gca,'xtick',[0:3:24],'xticklabel',{'00','03','06','09','12','15','18','21','24'});
ylim([0 1.07*max_res_perturbation]);
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top');
xlabel('Local Time','FontSize',21);
ylabel('Mean Solar Energy Supply [MWh]','FontSize',21);
title('Potential Solar Energy','FontSize',24);
text(0.015,0.95,'(b)','FontSize',21,'Units','normalized');

subplot(2,3,3); hold on;
line(Res_Load(1,:),Res_Load(2,:),'Color','b','LineWidth',3);
line(Res_Load(1,:),Res_Load(4,:),'Color','m','LineWidth',3);
fill([Res_Load(1,:) fliplr(Res_Load(1,:))], [Res_Load(2,:) fliplr(Res_Load(4,:))],'r','FaceAlpha',0.35,'EdgeAlpha',0)
line(Res_Load(1,:),Res_Load(2,:),'Color','b','LineWidth',3);
legend('Residential Demand Without Solar','Residential Demand With Solar','Difference','Location','North')
xlim([0 24]); set(gca,'xtick',[0:3:24],'xticklabel',{'00','03','06','09','12','15','18','21','24'});
ylim([1200 3000]);
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top');
xlabel('Local Time','FontSize',21);
ylabel('Mean Residential Demand [MWh]','FontSize',21);
title('Modified Residential Demand','FontSize',24);
text(0.015,0.95,'(c)','FontSize',21,'Units','normalized');

subplot(2,3,[4:6]); hold on;
line(PJM(:,8),PJM(:,5),'Color','k','LineWidth',3);
line(PJM(:,8),PJM(:,7),'Color','r','LineWidth',3);
line(PJM(:,8),PJM(:,5),'Color','k','LineWidth',3);
legend('Total Demand','Total Demand + Difference','Location','NorthEast');
ylim([5500 10500]);
xlim([datenum(2019,4,1,0,0,0) datenum(2019,4,8,0,0,0)]);
set(gca,'xtick',[737516:1:737523],'xticklabel',{'1-Apr','2-Apr','3-Apr','4-Apr','5-Apr','6-Apr','7-Apr','8-Apr'});
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top');
ylabel('Total Demand [MWh]','FontSize',21); 
title('Total Demand Time-Series','FontSize',24);
text(0.005,0.95,'(d)','FontSize',21,'Units','normalized');

if save_images == 1
   set(gcf,'Renderer','zbuffer'); set(gcf,'PaperPositionMode','auto');
   print(a,'-dpng','-r300',[image_output_dir,'Load_Perturbation_Incorporation_Example.png']);
   close(a);
end
clear a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                BEGIN CLEANUP SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear data_input_dir image_output_dir save_images sample_month sample_year max_res_perturbation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 END CLEANUP SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%