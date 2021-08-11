% Overlapping_Balancing_Authorities_Map.m
% 20210810
% Casey D. Burleyson
% Pacific Northwest National Laboratory

% This script is used to plot the number of balancing authorities
% operating in each county and to show one example county that
% contains multiple overlapping balancing authorities.

warning off all; clear all; close all; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN USER INPUT SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set some processing flags:
save_images = 1; % (1 = Yes)

counties{1,1} = 12009; counties{1,2} = 'Brevard County, FL';  counties{1,3} = 28.23; counties{1,4} = -80.69;
ba_names{1,1} = 'Florida Power and Light'; ba_names{1,2} = 'Duke Energy Florida'; ba_names{1,3} = 'Florida Municipal Power Pool'; ba_names{1,4} = 'Seminole Electric Cooperative';

% Set the data input directory and image output directory:
data_input_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2021_Burleyson_et_al_TELL/burleyson-etal_2021_tbd_data/';
image_output_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2021_Burleyson_et_al_TELL/burleyson-etal_2021_tbd/figures/';

lat_min = 24.5;
lat_max = 49.5;
lon_min = -125.3;
lon_max = -66.2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END USER INPUT SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PROCESSING SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([data_input_dir,'input_data/Census_Observed_Population/county_populations_2000_to_2019.mat']);
Population(:,1) = County_FIPS_Code;
Population(:,2) = County_Populations(:,find(Years(1,:) == 2019));
clear County_FIPS_Code County_Populations Years

load([data_input_dir,'output_data/BA_Service_Territory_Data/Matlab_Files/BA_Service_Territory_2019.mat']);
for row = 1:size(Population,1)
    Population(row,3) = size(find(BA_Service_Territory(:,1) == Population(row,1)),1);
end
clear row

load([data_input_dir,'input_data/shapefile_counties.mat'],'shapefile_counties');
for i = 1:size(shapefile_counties,1)
    shapefile_counties_fips(i,1) = shapefile_counties(i,1).county_FIPS;
end
clear i

BA_Subset = BA_Service_Territory(find(BA_Service_Territory(:,1) == counties{1,1}),:);
unique_bas = unique(BA_Subset(:,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PLOTTING SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = figure('Color',[1 1 1]); set(a,'Position',get(0,'Screensize')); 

subplot(3,1,[1 2]); hold on;
ax1 = usamap([lat_min lat_max],[lon_min lon_max]); colormap(ax1,jet(6));
states = shaperead('usastatelo','UseGeoCoords',true,'Selector',{@(name)~any(strcmp(name,{'Alaska','Hawaii'})),'Name'});
faceColors = makesymbolspec('Polygon',{'INDEX',[1 numel(states)],'FaceColor',polcmap(numel(states))});
faceColors.FaceColor{1,3} = faceColors.FaceColor{1,3}./faceColors.FaceColor{1,3};
geoshow(ax1,states,'DisplayType','polygon','SymbolSpec',faceColors,'LineWidth',2,'LineStyle','-');
for row = 1:size(Population,1)
% for row = 300:500
    if Population(row,1) ~= 11000
       patchm(shapefile_counties(find(shapefile_counties_fips(:,1) == Population(row,1)),1).lat_vector,shapefile_counties(find(shapefile_counties_fips(:,1) == Population(row,1)),1).lon_vector,0,'FaceVertexCData',Population(row,3),'FaceColor','flat');
    end
end
scatterm(counties{1,3},counties{1,4},100,'filled','MarkerFaceColor','r','MarkerEdgeColor','k','LineWidth',2);
set(gca,'clim',[-0.5,5.5]); 
colo = colorbar; set(get(colo,'ylabel'),'String',{['Number of Balancing Authorities Reported Operating']},'FontSize',21);
tightmap; framem on; gridm off; mlabel off; plabel off;
set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top');
text(0.015,0.185,'(a)','FontSize',21,'Units','normalized');
title(['Number of Balancing Authorities by County'],'FontSize',27);

for i = 1:4
    if i == 1; label = '(b)'; end
    if i == 2; label = '(c)'; end
    if i == 3; label = '(d)'; end
    if i == 4; label = '(e)'; end
    County_Subset = BA_Service_Territory(find(BA_Service_Territory(:,2) == unique_bas(i,1)),:);
    
    subplot(3,4,[8+i]); hold on; colormap(gca,LCH_Spiral(64,1,180,1,[90 25]));
    ax1 = usamap([24 31.5],[-88 -79.5]);
    states = shaperead('usastatelo','UseGeoCoords',true,'Selector',{@(name)~any(strcmp(name,{'Alaska','Hawaii'})),'Name'});
    faceColors = makesymbolspec('Polygon',{'INDEX',[1 numel(states)],'FaceColor',polcmap(numel(states))});
    faceColors.FaceColor{1,3} = faceColors.FaceColor{1,3}./faceColors.FaceColor{1,3};
    geoshow(ax1,states,'DisplayType','polygon','SymbolSpec',faceColors,'LineWidth',2,'LineStyle','-');
    for row = 1:size(County_Subset,1)
        if County_Subset(row,1) ~= 11000
           patchm(shapefile_counties(find(shapefile_counties_fips(:,1) == County_Subset(row,1)),1).lat_vector,shapefile_counties(find(shapefile_counties_fips(:,1) == County_Subset(row,1)),1).lon_vector,[0.8 0.8 0.8]);
        end
    end
    scatterm(counties{1,3},counties{1,4},100,'filled','MarkerFaceColor','r','MarkerEdgeColor','k','LineWidth',2);
    tightmap; framem on; gridm off; mlabel off; plabel off;
    set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top');
    title([ba_names{1,i}],'FontSize',24);
    text(0.04,0.1,label,'FontSize',21,'Units','normalized');
    clear County_Subset row ax1 colo faceColors row states label
end
clear i unique_bas

if save_images == 1
   set(gcf,'Renderer','zbuffer'); set(gcf,'PaperPositionMode','auto');
   print(a,'-dpng','-r300',[image_output_dir,'Overlapping_Balancing_Authorities_Map.png']);
   close(a);
end
clear a ax1 counties lat_max lat_min lon_max lon_min
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                BEGIN CLEANUP SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear data_input_dir image_output_dir save_images shapefile_counties shapefile_counties_fips ba_names BA_Subset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 END CLEANUP SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%