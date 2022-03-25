% Balancing_Authority_Temperature_Evolution.m
% 20211221
% Casey D. Burleyson
% Pacific Northwest National Laboratory

clear all; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN USER INPUT SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set some processing flags:
save_images = 1; % (1 = Yes)
ba_code = 'PJM'; % Code of the balancing authority to process and plot
ef_bins = [0.90,0.95,0.98,0.99,0.999]';

% Set the data input and image output directories:
data_input_dir = '/Users/burl878/OneDrive - PNNL/Documents/IMMM/Data/TELL_Input_Data/forward_execution/Climate_Forcing/wrf_tell_bas_output/';
image_output_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2022_Burleyson_et_al_TELL/burleyson-etal_2022_tbd/figures/Balancing_Authority_Temperature_Evolution/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END USER INPUT SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             BEGIN PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_files = dir([data_input_dir,'CONUS_TGW_WRF_Historical/',ba_code,'*.csv']);
T2_K_Historical = NaN.*ones(8784,size(input_files,1));
for file = 1:size(input_files,1)
    filename = [data_input_dir,'CONUS_TGW_WRF_Historical/',input_files(file,1).name];
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, '%s%f%f%f%f%f%[^\n\r]', 'Delimiter', ',', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    
    Time_Historical(1,file) = str2num(filename(1,(size(filename,2)-7):(size(filename,2)-4)));
    T2_K_Historical(1:size(dataArray{:,2},1),file) = dataArray{:,2};
      
    clear filename fileID dataArray ans
end
clear input_files file

input_files = dir([data_input_dir,'CONUS_TGW_WRF_SSP585_COLD/',ba_code,'*.csv']);
T2_K_SSP585_Cold = NaN.*ones(8784,size(input_files,1));
for file = 1:size(input_files,1)
    filename = [data_input_dir,'CONUS_TGW_WRF_SSP585_COLD/',input_files(file,1).name];
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, '%s%f%f%f%f%f%[^\n\r]', 'Delimiter', ',', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    
    Time_SSP585_Cold(1,file) = str2num(filename(1,(size(filename,2)-7):(size(filename,2)-4)));
    T2_K_SSP585_Cold(1:size(dataArray{:,2},1),file) = dataArray{:,2};
      
    clear filename fileID dataArray ans
end
clear input_files file

input_files = dir([data_input_dir,'CONUS_TGW_WRF_SSP585_HOT/',ba_code,'*.csv']);
T2_K_SSP585_Hot = NaN.*ones(8784,size(input_files,1));
for file = 1:size(input_files,1)
    filename = [data_input_dir,'CONUS_TGW_WRF_SSP585_HOT/',input_files(file,1).name];
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, '%s%f%f%f%f%f%[^\n\r]', 'Delimiter', ',', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    
    Time_SSP585_Hot(1,file) = str2num(filename(1,(size(filename,2)-7):(size(filename,2)-4)));
    T2_K_SSP585_Hot(1:size(dataArray{:,2},1),file) = dataArray{:,2};
      
    clear filename fileID dataArray ans
end
clear input_files file

T2_K_Cold = cat(2,T2_K_Historical,T2_K_SSP585_Cold); 
T2_K_Hot = cat(2,T2_K_Historical,T2_K_SSP585_Hot); 
Time = cat(2,Time_Historical,Time_SSP585_Cold);
clear T2_K_SSP585_Cold T2_K_SSP585_Hot T2_K_Historical Time_Historical Time_SSP585_Cold Time_SSP585_Hot

T2_F_Cold = ((T2_K_Cold - 273.15) .* (9/5)) + 32; clear T2_K_Cold
T2_F_Hot = ((T2_K_Hot - 273.15) .* (9/5)) + 32; clear T2_K_Hot

Delta_T2_F_Cold(:,1:40) = T2_F_Cold(:,1:40) - T2_F_Cold(:,1:40);
Delta_T2_F_Cold(:,41:80) = T2_F_Cold(:,41:80) - T2_F_Cold(:,1:40);
Delta_T2_F_Cold(:,81:120) = T2_F_Cold(:,81:120) - T2_F_Cold(:,1:40);

Delta_T2_F_Hot(:,1:40) = T2_F_Hot(:,1:40) - T2_F_Hot(:,1:40);
Delta_T2_F_Hot(:,41:80) = T2_F_Hot(:,41:80) - T2_F_Hot(:,1:40);
Delta_T2_F_Hot(:,81:120) = T2_F_Hot(:,81:120) - T2_F_Hot(:,1:40);

% Establish the min and max temperatures to be used to define temperature bins:
t_min = min([min(T2_F_Cold(:)),min(T2_F_Hot(:))]);
t_max = max([max(T2_F_Cold(:)),max(T2_F_Hot(:))]);
t_bins = [t_min:((t_max - t_min)/40):t_max];
t_bins = [-20:((140)/40):120];
clear t_min t_max

counter = 0;
for year = 1980:10:2090
    counter = counter + 1;
    T_Hist_Time(1,counter) = year;
    
    Subset = T2_F_Cold(:,find(Time(1,:) >= year & Time(1,:) < (year+10)));
    T_Max_Cold(1,counter) = nanmax(Subset(:));
    T_Min_Cold(1,counter) = nanmin(Subset(:));
    T_Hist_Cold(:,counter) = histc(Subset(:),t_bins)';
    T_Hist_Cold(:,counter) = T_Hist_Cold(:,counter)./sum(T_Hist_Cold(:,counter));
    clear Subset
    
    Subset = T2_F_Hot(:,find(Time(1,:) >= year & Time(1,:) < (year+10)));
    T_Max_Hot(1,counter) = nanmax(Subset(:));
    T_Min_Hot(1,counter) = nanmin(Subset(:));
    T_Hist_Hot(:,counter) = histc(Subset(:),t_bins)';
    T_Hist_Hot(:,counter) = T_Hist_Hot(:,counter)./sum(T_Hist_Hot(:,counter));
    clear Subset
end
clear counter year

T_Hist_Cold_Norm = (T_Hist_Cold./max(T_Hist_Cold(:)))*9;
T_Hist_Hot_Norm = (T_Hist_Hot./max(T_Hist_Hot(:)))*9;

Subset = T2_F_Cold(:,find(Time(1,:) >= 1980 & Time(1,:) < 2020));
t_min = min(Subset(:));
t_max = max(Subset(:));
for row = 1:size(ef_bins,1)
    ef_bins(row,2) = prctile(Subset(:),100*ef_bins(row,1));
end
clear row Subset

EF_Time(1,1) = 2010;
EF_Cold(:,1) = ef_bins(:,1);
EF_Hot(:,1) = ef_bins(:,1);
counter = 1;
for year = 2020:10:2090
    counter = counter + 1;
    EF_Time(1,counter) = year;
    Subset = T2_F_Cold(:,find(Time(1,:) >= year & Time(1,:) < (year+10)));
    for row = 1:size(ef_bins,1)
        EF_Cold(row,counter) = 1 - (size(find(Subset(:) >= ef_bins(row,2)),1)./size(Subset(:),1));
    end
    clear Subset
    
    Subset = T2_F_Hot(:,find(Time(1,:) >= year & Time(1,:) < (year+10)));
    for row = 1:size(ef_bins,1)
        EF_Hot(row,counter) = 1 - (size(find(Subset(:) >= ef_bins(row,2)),1)./size(Subset(:),1));
    end
    clear Subset
end
clear counter row
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END PROCESSING SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PLOTTING SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = figure('Color',[1 1 1]); set(a,'Position',get(0,'Screensize'));
ax1 = subplot(2,2,1); hold on; colormap(ax1,jet(60))
pcolor(Time(1,:),[0:1:8783],T2_F_Hot); shading flat;
line([1980 1980],[0 8760],'Color','k','LineWidth',3);
line([2020 2020],[0 8760],'Color','k','LineWidth',3);
line([2060 2060],[0 8760],'Color','k','LineWidth',3);
line([1990 1990],[0 8760],'Color','r','LineWidth',3);
line([2030 2030],[0 8760],'Color','r','LineWidth',3);
line([2070 2070],[0 8760],'Color','r','LineWidth',3);
line([2000 2000],[0 8760],'Color','b','LineWidth',3);
line([2040 2040],[0 8760],'Color','b','LineWidth',3);
line([2080 2080],[0 8760],'Color','b','LineWidth',3);
line([2010 2010],[0 8760],'Color','m','LineWidth',3);
line([2050 2050],[0 8760],'Color','m','LineWidth',3);
line([2090 2090],[0 8760],'Color','m','LineWidth',3);
xlim([1980 2099]); set(gca,'xtick',[1980:10:2100],'xticklabel',{'1980','','2000','','2020','','2040','','2060','','2080','','2100'});
ylim([0 8760]); set(gca,'ytick',([0,32,60,91,121,152,182,213,244,274,305,335].*24),'yticklabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'});
set(gca,'clim',[-10 120]); 
colo = colorbar('Location','EastOutside','ytickmode','manual'); 
set(colo,'FontSize',18,'ytick',[-20:10:120],'yticklabel',{'-20','-10','0','10','20','30','40','50','60','70','80','90','100','110','120'});
set(get(colo,'yLabel'),'String',['2-m Air Temperature [',setstr(176),'F]'],'FontSize',21); 
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top')
title([ba_code,' Temperature Evolution: SSP5, RCP 8.5, Hot'],'FontSize',27)
text(-0.10,1.15,'(a)','FontSize',24,'Units','normalized');
clear colo

cmap = redblue(60);
cmap2 = cmap(31:60,:);

ax2 = subplot(2,2,2); hold on; colormap(ax2,redblue(60));
pcolor(Time(1,:),[0:1:8783],Delta_T2_F_Hot); shading flat;
line([1980 1980],[0 8760],'Color','k','LineWidth',3);
line([2020 2020],[0 8760],'Color','k','LineWidth',3);
line([2060 2060],[0 8760],'Color','k','LineWidth',3);
line([1990 1990],[0 8760],'Color','r','LineWidth',3);
line([2030 2030],[0 8760],'Color','r','LineWidth',3);
line([2070 2070],[0 8760],'Color','r','LineWidth',3);
line([2000 2000],[0 8760],'Color','b','LineWidth',3);
line([2040 2040],[0 8760],'Color','b','LineWidth',3);
line([2080 2080],[0 8760],'Color','b','LineWidth',3);
line([2010 2010],[0 8760],'Color','m','LineWidth',3);
line([2050 2050],[0 8760],'Color','m','LineWidth',3);
line([2090 2090],[0 8760],'Color','m','LineWidth',3);
xlim([1980 2099]); set(gca,'xtick',[1980:10:2100],'xticklabel',{'1980','','2000','','2020','','2040','','2060','','2080','','2100'});
ylim([0 8760]); set(gca,'ytick',([0,32,60,91,121,152,182,213,244,274,305,335].*24),'yticklabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'});
% set(gca,'clim',[-1*max(abs(Delta_T2_F_Hot(:))) max(abs(Delta_T2_F_Hot(:)))]); 
set(gca,'clim',[-30 30]); 
colo = colorbar('Location','EastOutside','ytickmode','manual'); 
set(colo,'FontSize',18,'ytick',[-30:5:30],'yticklabel',{'-30','-25','-20','-15','-10','-5','0','+5','+10','+15','+20','+25','+30'});
set(get(colo,'yLabel'),'String',['Temperature Perturbation [',setstr(176),'F]'],'FontSize',21); 
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top')
title([ba_code,' Temperature Perturbation: SSP5, RCP 8.5, Hot'],'FontSize',27)
text(-0.10,1.15,'(b)','FontSize',24,'Units','normalized');
clear colo

subplot(2,2,3); hold on;
line([1980 2100],[t_min t_min],'Color','b','LineWidth',3);
line([1980 2100],[t_max t_max],'Color','r','LineWidth',3);
scatter(T_Hist_Time,T_Min_Hot,150,'b','filled');
scatter(T_Hist_Time,T_Max_Hot,150,'r','filled');
for year = 1980:10:2090
    line([year year],[-20 120],'Color',[0.8 0.8 0.8],'LineWidth',1);
end
for column = 1:size(T_Hist_Time,2)
    line((T_Hist_Time(:,column) + T_Hist_Hot_Norm(:,column)),t_bins(1,:),'Color','k','LineWidth',3);
end
scatter(T_Hist_Time,T_Min_Hot,150,'b','filled');
scatter(T_Hist_Time,T_Max_Hot,150,'r','filled');
line([1980 2100],[t_min t_min],'Color','b','LineWidth',3);
line([1980 2100],[t_max t_max],'Color','r','LineWidth',3);
legend('Hist. Min.','Hist. Max.','Decadal Min.','Decadal Max.','Location','SouthWest')
xlim([1980 2100]); set(gca,'xtick',[1980:10:2100],'xticklabel',{'1980','','2000','','2020','','2040','','2060','','2080','','2100'});
ylim([-20 120]); set(gca,'ytick',[-20:10:120],'yticklabel',{'-20','','0','','20','','40','','60','','80','','100','','120'});
ylabel(['2-m Air Temperature [',setstr(176),'F]'],'FontSize',24);
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top')
title([ba_code,' Decadal Temperature Distributions'],'FontSize',27)
text(-0.10,1.15,'(c)','FontSize',24,'Units','normalized');
clear year column

subplot(2,2,4); hold on; cmap = jet(size(EF_Hot,1));
for row = 1:size(EF_Hot,1)
    line(EF_Time(1,:)+5,EF_Hot(row,:),'Color',cmap(row,:),'LineWidth',4);
end
legend(['Historically 1 in 10 Hours (',num2str(roundn(ef_bins(1,2),-1)),setstr(176),'F)'],...
       ['Historically 1 in 20 Hours (',num2str(roundn(ef_bins(2,2),-1)),setstr(176),'F)'],...
       ['Historically 1 in 50 Hours (',num2str(roundn(ef_bins(3,2),-1)),setstr(176),'F)'],...
       ['Historically 1 in 100 Hours (',num2str(roundn(ef_bins(4,2),-1)),setstr(176),'F)'],...
       ['Historically 1 in 1000 Hours (',num2str(roundn(ef_bins(5,2),-1)),setstr(176),'F)'],'Location','SouthWest');
xlim([2015 2095]); set(gca,'xtick',[2015:10:2095],'xticklabel',{'Historical','','2030-2040','','2050-2060','','2070-2080','','2090-2100'});
set(gca,'ytick',[0:0.05:1],'yticklabel',{'100','95','90','85','80','75','70','65','60','55','50','45','40','35','30','25','20','15','10','5','0'});
ylabel(['Exceedance Frequency [%]'],'FontSize',24);
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top')
title([ba_code,' Hourly Extreme Temperature Trends'],'FontSize',27)
text(-0.10,1.15,'(d)','FontSize',24,'Units','normalized');
grid on
clear row

if save_images == 1
   set(gcf,'Renderer','zbuffer'); set(gcf,'PaperPositionMode','auto');
   print(a,'-dpng','-r300',[image_output_dir,ba_code,'_Temperature_Evolution.png']);
   close(a);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PLOTTING SECTION                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                BEGIN CLEANUP SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear a data_input_dir image_output_dir save_images T2_K t_bins T_Hist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 END CLEANUP SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%