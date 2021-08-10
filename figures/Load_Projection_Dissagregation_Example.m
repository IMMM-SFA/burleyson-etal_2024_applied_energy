% Load_Projection_Dissagregation_Example.m
% 20210808
% Casey D. Burleyson
% Pacific Northwest National Laboratory

% This script is used to demonstrate the forward prediction and spatial
% dissagregation capability of TELL for a sample balancing authority.

warning off all; clear all; close all; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN USER INPUT SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set some processing flags:
save_images = 1; % (1 = Yes)

ba_to_plot = 'ISNE'; % Code of the representative balancing authority to plot
counties{1,1} = 9003;  counties{1,2} = 'Hartford County, CT';     counties{1,3} = 41.76; counties{1,4} = -72.72;
counties{2,1} = 25017; counties{2,2} = 'Middlesex County, MA';    counties{2,3} = 42.45; counties{2,4} = -71.26;
counties{3,1} = 33011; counties{3,2} = 'Hillsborough County, NH'; counties{3,3} = 42.88; counties{3,4} = -71.53;
counties{4,1} = 23017; counties{4,2} = 'Oxford County, ME';       counties{4,3} = 44.28; counties{4,4} = -70.61;

% Set the data input directory and image output directory:
data_input_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2021_Burleyson_et_al_TELL/burleyson-etal_2021_tbd_data/';
image_output_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2021_Burleyson_et_al_TELL/burleyson-etal_2021_tbd/figures/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END USER INPUT SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PROCESSING SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([data_input_dir,'input_data/EIA_930_Balancing_Authority_Hourly_Load/Matlab_Files/',ba_to_plot,'_Hourly_Load_Data.mat']);
BA_Historical_Load(:,1) = datenum(Data(:,1),Data(:,2),Data(:,3),Data(:,4),0,0);
BA_Historical_Load(:,2:5) = Data(:,1:4);
BA_Historical_Load(:,6) = Data(:,6);
clear Data

load([data_input_dir,'input_data/Census_Observed_Population/county_populations_2000_to_2019.mat']);
Population(:,1) = County_FIPS_Code;
Population(:,2) = County_Populations(:,find(Years(1,:) == 2019));
clear County_FIPS_Code County_Populations Years

load([data_input_dir,'output_data/BA_Service_Territory_Data/Matlab_Files/BA_Service_Territory_2019.mat']);
for i = 1:size(BA_Metadata,1)
    if strcmp(BA_Metadata(i,2),ba_to_plot) == 1
       EIA_BA_Number = BA_Metadata{i,1};
       BA_Long_Name = BA_Metadata{i,3};
       break
    end
end
BA_Service_Territory = BA_Service_Territory(find(BA_Service_Territory(:,2) == EIA_BA_Number),:);
clear i BA_Metadata EIA_BA_Number

for row = 1:size(BA_Service_Territory,1)
    BA_Service_Territory(row,3) = Population(find(Population(:,1) == BA_Service_Territory(row,1)),2);
end
BA_Service_Territory(:,4) = BA_Service_Territory(:,3)./sum(BA_Service_Territory(:,3),1);
clear row Population

load([data_input_dir,'input_data/shapefile_counties.mat'],'shapefile_counties');
for i = 1:size(shapefile_counties,1)
    shapefile_counties_fips(i,1) = shapefile_counties(i,1).county_FIPS;
end
clear i

load([data_input_dir,'output_data/BA_MLP_Model_Output_Data/Matlab_Files/',ba_to_plot,'_MLP_Model_Evaluation_Data_WRF.mat']);
BA_Future_Load = Data(:,1:7);
clear Data

for row = 1:size(BA_Service_Territory,1)
     if row == 1
        all_lat_vector = shapefile_counties(find(shapefile_counties_fips(:,1) == BA_Service_Territory(row,1)),1).lat_vector;
        all_lon_vector = shapefile_counties(find(shapefile_counties_fips(:,1) == BA_Service_Territory(row,1)),1).lon_vector;
     else
        all_lat_vector = cat(2,all_lat_vector,shapefile_counties(find(shapefile_counties_fips(:,1) == BA_Service_Territory(row,1)),1).lat_vector);
        all_lon_vector = cat(2,all_lon_vector,shapefile_counties(find(shapefile_counties_fips(:,1) == BA_Service_Territory(row,1)),1).lon_vector);
     end
end
lat_min = min(all_lat_vector) - 0.25; lat_max = max(all_lat_vector) + 0.25; lon_min = min(all_lon_vector) - 0.25; lon_max = max(all_lon_vector) + 0.25;
clear row all_lat_vector all_lon_vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PLOTTING SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = figure('Color',[1 1 1]); set(a,'Position',get(0,'Screensize')); 

subplot(2,1,1); hold on;
y_min = 0.95.*min(min(BA_Historical_Load(:,6)),min(BA_Future_Load(:,7))); y_max = 1.05.*max(max(BA_Historical_Load(:,6)),max(BA_Future_Load(:,7)));
line(0,0,'Color','k','LineWidth',5);
line(0,0,'Color','r','LineWidth',5);
patch([datenum(2016,1,1,0,0,0) datenum(2016,1,1,0,0,0) datenum(2019,1,1,0,0,0) datenum(2019,1,1,0,0,0)],[y_min y_max y_max y_min],'k','FaceAlpha',0.1);
patch([datenum(2019,1,1,0,0,0) datenum(2019,1,1,0,0,0) datenum(2020,1,1,0,0,0) datenum(2020,1,1,0,0,0)],[y_min y_max y_max y_min],'r','FaceAlpha',0.1);
line(BA_Historical_Load(:,1),BA_Historical_Load(:,6),'Color','k','LineWidth',1);
line(BA_Future_Load(:,1),BA_Future_Load(:,7),'Color','r','LineWidth',1);
legend('Observed Hourly Demand','MLP Model Prediction','MLP Model Training Period','MLP Model Evaluation Period','Location','North','Orientation','Horizontal');
ylim([y_min y_max]);
xlim([datenum(2016,1,1,0,0,0) datenum(2020,1,1,0,0,0)]);
set(gca,'xtick',[736330,736696,737061,737426,737791],'xticklabel',{'2016','2017','2018','2019','2020'});
ylabel('Demand [MWh]','FontSize',21); 
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top');
text(0.015,0.95,'(a)','FontSize',21,'Units','normalized');
title([BA_Long_Name,' (',ba_to_plot,') Hourly Electricity Demand'],'FontSize',24)

subplot(2,4,5); hold on;
ax1 = usamap([lat_min lat_max],[lon_min lon_max]); colormap(ax1,LCH_Spiral(64,1,180,1,[90 25]));
states = shaperead('usastatelo','UseGeoCoords',true,'Selector',{@(name)~any(strcmp(name,{'Alaska','Hawaii'})),'Name'});
faceColors = makesymbolspec('Polygon',{'INDEX',[1 numel(states)],'FaceColor',polcmap(numel(states))});
faceColors.FaceColor{1,3} = faceColors.FaceColor{1,3}./faceColors.FaceColor{1,3};
geoshow(ax1,states,'DisplayType','polygon','SymbolSpec',faceColors,'LineWidth',2,'LineStyle','-');
for row = 1:size(BA_Service_Territory,1)
    if BA_Service_Territory(row,1) ~= 11000
       patchm(shapefile_counties(find(shapefile_counties_fips(:,1) == BA_Service_Territory(row,1)),1).lat_vector,shapefile_counties(find(shapefile_counties_fips(:,1) == BA_Service_Territory(row,1)),1).lon_vector,0,'FaceVertexCData',(BA_Service_Territory(row,3)./10000),'FaceColor','flat');
    end
end
set(gca,'clim',[0,max(BA_Service_Territory(:,3)./10000)]); colo = colorbar; set(get(colo,'ylabel'),'String',{['2019 Population [10^4 People]']},'FontSize',21);
tightmap; framem on; gridm off; mlabel off; plabel off;
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top');
text(0.1,0.95,'(b)','FontSize',21,'Units','normalized');
title(['Service Territory'],'FontSize',24);

subplot(2,4,6); hold on;
ax1 = usamap([lat_min lat_max],[lon_min lon_max]); colormap(ax1,jet(25));
states = shaperead('usastatelo','UseGeoCoords',true,'Selector',{@(name)~any(strcmp(name,{'Alaska','Hawaii'})),'Name'});
faceColors = makesymbolspec('Polygon',{'INDEX',[1 numel(states)],'FaceColor',polcmap(numel(states))});
faceColors.FaceColor{1,3} = faceColors.FaceColor{1,3}./faceColors.FaceColor{1,3};
geoshow(ax1,states,'DisplayType','polygon','SymbolSpec',faceColors,'LineWidth',2,'LineStyle','-');
for row = 1:size(BA_Service_Territory,1)
    if BA_Service_Territory(row,1) ~= 11000
       patchm(shapefile_counties(find(shapefile_counties_fips(:,1) == BA_Service_Territory(row,1)),1).lat_vector,shapefile_counties(find(shapefile_counties_fips(:,1) == BA_Service_Territory(row,1)),1).lon_vector,0,'FaceVertexCData',BA_Service_Territory(row,4),'FaceColor','flat');
    end
end
scatterm(counties{1,3},counties{1,4},120,'d','filled','MarkerFaceColor','w','MarkerEdgeColor','k','LineWidth',2);
scatterm(counties{2,3},counties{2,4},120,'d','filled','MarkerFaceColor','w','MarkerEdgeColor','k','LineWidth',2);
scatterm(counties{3,3},counties{3,4},120,'d','filled','MarkerFaceColor','w','MarkerEdgeColor','k','LineWidth',2);
scatterm(counties{4,3},counties{4,4},120,'d','filled','MarkerFaceColor','w','MarkerEdgeColor','k','LineWidth',2);
set(gca,'clim',[0,0.1]); colo = colorbar;
tightmap; framem on; gridm off; mlabel off; plabel off;
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top');
text(0.1,0.95,'(c)','FontSize',21,'Units','normalized');
title(['Fraction of ',ba_to_plot,' Load'],'FontSize',24);

subplot(4,4,11); hold on;
line(BA_Future_Load(:,1),BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{1,1}),4).*BA_Future_Load(:,7),'Color','r','LineWidth',1);
ylim([min(BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{1,1}),4).*BA_Future_Load(:,7)) max(BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{1,1}),4).*BA_Future_Load(:,7))]);
xlim([datenum(2019,1,1,0,0,0) datenum(2020,1,1,0,0,0)]);
set(gca,'xtick',[737426,737791],'xticklabel',{'2019','2020'});
ylabel('Demand [MWh]','FontSize',15); 
set(gca,'LineWidth',1,'FontSize',15,'Box','on','Layer','top');
text(0.015,0.92,'(d)','FontSize',15,'Units','normalized');
title([counties{1,2}],'FontSize',18);

subplot(4,4,12); hold on;
line(BA_Future_Load(:,1),BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{2,1}),4).*BA_Future_Load(:,7),'Color','r','LineWidth',1);
ylim([min(BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{2,1}),4).*BA_Future_Load(:,7)) max(BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{2,1}),4).*BA_Future_Load(:,7))]);
xlim([datenum(2019,1,1,0,0,0) datenum(2020,1,1,0,0,0)]);
set(gca,'xtick',[737426,737791],'xticklabel',{'2019','2020'});
ylabel('Demand [MWh]','FontSize',15); 
set(gca,'LineWidth',1,'FontSize',15,'Box','on','Layer','top');
text(0.015,0.92,'(e)','FontSize',15,'Units','normalized');
title([counties{2,2}],'FontSize',18);

subplot(4,4,15); hold on;
line(BA_Future_Load(:,1),BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{3,1}),4).*BA_Future_Load(:,7),'Color','r','LineWidth',1);
ylim([min(BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{3,1}),4).*BA_Future_Load(:,7)) max(BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{3,1}),4).*BA_Future_Load(:,7))]);
xlim([datenum(2019,1,1,0,0,0) datenum(2020,1,1,0,0,0)]);
set(gca,'xtick',[737426,737791],'xticklabel',{'2019','2020'});
ylabel('Demand [MWh]','FontSize',15); 
set(gca,'LineWidth',1,'FontSize',15,'Box','on','Layer','top');
text(0.015,0.92,'(f)','FontSize',15,'Units','normalized');
title([counties{3,2}],'FontSize',18);

subplot(4,4,16); hold on;
line(BA_Future_Load(:,1),BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{4,1}),4).*BA_Future_Load(:,7),'Color','r','LineWidth',1);
ylim([min(BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{4,1}),4).*BA_Future_Load(:,7)) max(BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{4,1}),4).*BA_Future_Load(:,7))]);
xlim([datenum(2019,1,1,0,0,0) datenum(2020,1,1,0,0,0)]);
set(gca,'xtick',[737426,737791],'xticklabel',{'2019','2020'});
ylabel('Demand [MWh]','FontSize',15); 
set(gca,'LineWidth',1,'FontSize',15,'Box','on','Layer','top');
text(0.015,0.92,'(g)','FontSize',15,'Units','normalized');
title([counties{4,2}],'FontSize',18);

if save_images == 1
   set(gcf,'Renderer','zbuffer'); set(gcf,'PaperPositionMode','auto');
   print(a,'-dpng','-r150',[image_output_dir,'Load_Projection_Dissagregation_Example_',ba_to_plot,'.png']);
   close(a);
end
clear a ax1 colo counties faceColors lat_max lat_min lon_max lon_min row states y_max y_min
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                BEGIN CLEANUP SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear data_input_dir image_output_dir save_images shapefile_counties shapefile_counties_fips
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 END CLEANUP SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%