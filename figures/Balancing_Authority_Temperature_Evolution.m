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
ba_code = 'CISO'; % Code of the balancing authority to process and plot
scenario_string = 'SSP 5, RCP 8.5, Hot';
ef_bins = [0.90,0.95,0.98,0.99,0.999]';

% Set the data input and image output directories:
data_input_dir = '/Users/burl878/OneDrive - PNNL/Documents/IMMM/Data/TELL_Input_Data/forward_execution/Climate_Forcing/wrf_tell_bas_output/';
image_output_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2022_Burleyson_et_al_TELL/burleyson-etal_2021_tbd/figures/Balancing_Authority_Temperature_Evolution/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END USER INPUT SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             BEGIN PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_files = dir([data_input_dir,'CONUS_TGW_WRF_Historical/',ba_code,'*.csv']);
T2_K_A = NaN.*ones(8784,size(input_files,1));
for file = 1:size(input_files,1)
    filename = [data_input_dir,'CONUS_TGW_WRF_Historical/',input_files(file,1).name];
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, '%s%f%f%f%f%f%[^\n\r]', 'Delimiter', ',', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    
    Time_A(1,file) = str2num(filename(1,(size(filename,2)-7):(size(filename,2)-4)));
    T2_K_A(1:size(dataArray{:,2},1),file) = dataArray{:,2};
      
    clear filename fileID dataArray ans
end
clear input_files file

input_files = dir([data_input_dir,'CONUS_TGW_WRF_SSP585_HOT/',ba_code,'*.csv']);
T2_K_B = NaN.*ones(8784,size(input_files,1));
for file = 1:size(input_files,1)
    filename = [data_input_dir,'CONUS_TGW_WRF_SSP585_HOT/',input_files(file,1).name];
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, '%s%f%f%f%f%f%[^\n\r]', 'Delimiter', ',', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    
    Time_B(1,file) = str2num(filename(1,(size(filename,2)-7):(size(filename,2)-4)));
    T2_K_B(1:size(dataArray{:,2},1),file) = dataArray{:,2};
      
    clear filename fileID dataArray ans
end
clear input_files file

T2_K = cat(2,T2_K_A,T2_K_B); clear T2_K_A T2_K_B
Time = cat(2,Time_A,Time_B); clear Time_A Time_B

T2_F = ((T2_K - 273.15) .* (9/5)) + 32;

t_bins = [min(T2_F(:)):((max(T2_F(:)) - min(T2_F(:)))/40):max(T2_F(:))];

counter = 0;
for year = 1980:10:2090
    counter = counter + 1;
    T_Hist_Time(1,counter) = year;
    Subset = T2_F(:,find(Time(1,:) >= year & Time(1,:) < (year+10)));
    T_Hist(:,counter) = histc(Subset(:),t_bins)';
    T_Hist(:,counter) = T_Hist(:,counter)./sum(T_Hist(:,counter));
    clear Subset
end
clear counter year

T_Hist_Norm = (T_Hist./max(T_Hist(:)))*9;

Subset = T2_F(:,find(Time(1,:) >= 1980 & Time(1,:) < 2020));
for row = 1:size(ef_bins,1)
    ef_bins(row,2) = prctile(Subset(:),100*ef_bins(row,1));
end
clear row Subset

EF_Time(1,1) = 2010;
EF(:,1) = ef_bins(:,1);
counter = 1;
for year = 2020:10:2090
    counter = counter + 1;
    EF_Time(1,counter) = year;
    Subset = T2_F(:,find(Time(1,:) >= year & Time(1,:) < (year+10)));
    for row = 1:size(ef_bins,1)
        EF(row,counter) = 1 - (size(find(Subset(:) >= ef_bins(row,2)),1)./size(Subset(:),1));
    end
end
clear counter row
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END PROCESSING SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PLOTTING SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = figure('Color',[1 1 1]); set(a,'Position',get(0,'Screensize'));
subplot(2,1,1); hold on; colormap(jet(60))
pcolor(Time(1,:),[0:1:8783],T2_F); shading flat;
line([1980 1980],[0 8760],'Color','k','LineWidth',4);
line([2020 2020],[0 8760],'Color','k','LineWidth',4);
line([2060 2060],[0 8760],'Color','k','LineWidth',4);
line([1990 1990],[0 8760],'Color','r','LineWidth',4);
line([2030 2030],[0 8760],'Color','r','LineWidth',4);
line([2070 2070],[0 8760],'Color','r','LineWidth',4);
line([2000 2000],[0 8760],'Color','b','LineWidth',4);
line([2040 2040],[0 8760],'Color','b','LineWidth',4);
line([2080 2080],[0 8760],'Color','b','LineWidth',4);
line([2010 2010],[0 8760],'Color','m','LineWidth',4);
line([2050 2050],[0 8760],'Color','m','LineWidth',4);
line([2090 2090],[0 8760],'Color','m','LineWidth',4);
xlim([1980 2099]); set(gca,'xtick',[1980:10:2100],'xticklabel',{'1980','1990','2000','2010','2020','2030','2040','2050','2060','2070','2080','2090','2100'});
ylim([0 8760]); set(gca,'ytick',([0,32,60,91,121,152,182,213,244,274,305,335].*24),'yticklabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'});
set(gca,'clim',[min(T2_F(:)) max(T2_F(:))]); 
colo = colorbar('Location','EastOutside','ytickmode','manual'); 
set(colo,'FontSize',18,'ytick',[-20:10:120],'yticklabel',{'-20','-10','0','10','20','30','40','50','60','70','80','90','100','110','120'});
set(get(colo,'yLabel'),'String',['Mean 2-m Air Temperature [',setstr(176),'F]'],'FontSize',21); 
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top')
title([ba_code,' Temperature Evolution: ',scenario_string],'FontSize',27)
text(0.00,1.10,'(a)','FontSize',24,'Units','normalized');
clear colo

subplot(2,2,3); hold on;
for year = 1980:10:2090
    line([year year],[min(T2_F(:)) max(T2_F(:))],'Color',[0.8 0.8 0.8],'LineWidth',1);
end
for column = 1:size(T_Hist_Time,2)
    line((T_Hist_Time(:,column) + T_Hist_Norm(:,column)),t_bins(1,:),'Color','r','LineWidth',3);
end
xlim([1980 2100]); set(gca,'xtick',[1980:10:2100],'xticklabel',{'1980','','2000','','2020','','2040','','2060','','2080','','2100'});
ylim([min(T2_F(:)) max(T2_F(:))]); set(gca,'ytick',[-20:10:120],'yticklabel',{'-20','-10','0','10','20','30','40','50','60','70','80','90','100','110','120'});
ylabel(['Mean 2-m Air Temperature [',setstr(176),'F]'],'FontSize',24);
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top')
title(['Decadal Temperature Distributions'],'FontSize',27)
text(0.00,1.10,'(b)','FontSize',24,'Units','normalized');
clear year column

subplot(2,2,4); hold on; cmap = jet(size(EF,1));
for row = 1:size(EF,1)
    line(EF_Time(1,:)+5,EF(row,:),'Color',cmap(row,:),'LineWidth',4);
end
legend(['Historically 1 in 10 (',num2str(roundn(ef_bins(1,2),-1)),setstr(176),'F)'],...
       ['Historically 1 in 20 (',num2str(roundn(ef_bins(2,2),-1)),setstr(176),'F)'],...
       ['Historically 1 in 50 (',num2str(roundn(ef_bins(3,2),-1)),setstr(176),'F)'],...
       ['Historically 1 in 100 (',num2str(roundn(ef_bins(4,2),-1)),setstr(176),'F)'],...
       ['Historically 1 in 1000 (',num2str(roundn(ef_bins(5,2),-1)),setstr(176),'F)'],'Location','SouthWest');
xlim([2015 2095]); set(gca,'xtick',[2015:10:2095],'xticklabel',{'1980-2020','','2030-2040','','2050-2060','','2070-2080','','2090-2100'});
set(gca,'ytick',[0:0.05:1],'yticklabel',{'100','95','90','85','80','75','70','65','60','55','50','45','40','35','30','25','20','15','10','5','0'});
ylabel(['Exceedance Frequency [%]'],'FontSize',24);
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top')
title(['Extreme Temperature Trends'],'FontSize',27)
text(0.00,1.10,'(c)','FontSize',24,'Units','normalized');
grid on
clear row

if save_images == 1
   set(gcf,'Renderer','zbuffer'); set(gcf,'PaperPositionMode','auto');
   print(a,'-dpng','-r200',[image_output_dir,ba_code,'_Temperature_Evolution.png']);
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