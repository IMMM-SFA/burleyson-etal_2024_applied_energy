% Balancing_Authority_Temperature_Evolution.m
% 20211221
% Casey D. Burleyson
% Pacific Northwest National Laboratory

% TBD.

clear all; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN USER INPUT SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set some processing flags:
save_images = 0; % (1 = Yes)
ba_code = 'CISO'; % Code of the balancing authority to process and plot
scenario = 'SSP585_HOT'; % Name of the IM3 scenario to process and plot
scenario_string = 'SSP 5, RCP 8.5, Hot';

% Set the data input and image output directories:
data_input_dir = ['/Users/burl878/OneDrive - PNNL/Documents/IMMM/Data/TELL_Input_Data/forward_execution/Climate_Forcing/wrf_tell_bas_output/CONUS_TGW_WRF_',scenario,'/'];
image_output_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2022_Burleyson_et_al_TELL/burleyson-etal_2021_tbd/figures/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END USER INPUT SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             BEGIN PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_files = dir([data_input_dir,ba_code,'*.csv']);
T2_K = NaN.*ones(8784,size(input_files,1));
for file = 1:size(input_files,1)
    filename = [data_input_dir,input_files(file,1).name];
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, '%s%f%f%f%f%f%[^\n\r]', 'Delimiter', ',', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    
    Time(1,file) = str2num(filename(1,(size(filename,2)-7):(size(filename,2)-4)));
    T2_K(1:size(dataArray{:,2},1),file) = dataArray{:,2};
      
    clear filename fileID dataArray ans
end
clear input_files file

T2_F = ((T2_K - 273.15) .* (9/5)) + 32;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END PROCESSING SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PLOTTING SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = figure('Color',[1 1 1]); set(a,'Position',get(0,'Screensize'));
subplot(2,1,1); hold on; colormap(jet(60))
pcolor(Time(1,:),[0:1:8783],T2_F); shading flat;
xlim([2020 2099]);
ylim([0 8760]);
line([2020 2020],[0 8760],'Color','k','LineWidth',4);
line([2060 2060],[0 8760],'Color','k','LineWidth',4);
line([2030 2030],[0 8760],'Color','r','LineWidth',4);
line([2070 2070],[0 8760],'Color','r','LineWidth',4);
line([2040 2040],[0 8760],'Color','b','LineWidth',4);
line([2080 2080],[0 8760],'Color','b','LineWidth',4);
line([2050 2050],[0 8760],'Color','g','LineWidth',4);
line([2090 2090],[0 8760],'Color','g','LineWidth',4);
set(gca,'ytick',([0,32,60,91,121,152,182,213,244,274,305,335].*24),'yticklabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'});
set(gca,'clim',[min(T2_F(:)) max(T2_F(:))]); 
colo = colorbar('Location','EastOutside','ytickmode','manual'); 
set(colo,'FontSize',18,'ytick',[-20:10:120],'yticklabel',{'-20','-10','0','10','20','30','40','50','60','70','80','90','100','110','120'});
set(get(colo,'yLabel'),'String',['Mean 2-m Air Temperature [',setstr(176),'F]'],'FontSize',21); 
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top')
title([ba_code,' Temperature Evolution: ',scenario_string],'FontSize',24)
text(0.00,1.10,'(a)','FontSize',24,'Units','normalized');



% if save_images == 1
%    set(gcf,'Renderer','zbuffer'); set(gcf,'PaperPositionMode','auto');
%    print(a,'-dpng','-r200',[image_output_dir,BA_Short_Name,'_Quick_Look_Plots.png']);
%    close(a);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PLOTTING SECTION                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                BEGIN CLEANUP SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear data_input_dir image_output_dir save_images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 END CLEANUP SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%