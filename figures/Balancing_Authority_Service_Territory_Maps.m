% Balancing_Authority_Service_Territory_Maps.m
% 20210808
% Casey D. Burleyson
% Pacific Northwest National Laboratory

% This script takes as .mat files containing the county mapping of
% utilities and balancing authorities (BAs) generates maps showing
% the spatial coverage of each BA.

warning off all; clear all; close all; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN USER INPUT SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set some processing flags:
year_to_plot = 2019; % Year of data to plot
save_images = 1; % (1 = Yes)

% Set the data input directory and image output directory:
data_input_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2021_Burleyson_et_al_TELL/burleyson-etal_2021_tbd_data/';
image_output_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2021_Burleyson_et_al_TELL/burleyson-etal_2021_tbd/figures/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END USER INPUT SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PROCESSING SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([data_input_dir,'input_data/Census_Observed_Population/county_populations_2000_to_2019.mat']);
Population(:,1) = County_FIPS_Code;
Population(:,2) = County_Populations(:,find(Years(1,:) == year_to_plot));
clear County_FIPS_Code County_Populations Years

load([data_input_dir,'output_data/BA_Service_Territory_Data/Matlab_Files/BA_Service_Territory_',num2str(year_to_plot),'.mat']);

load([data_input_dir,'input_data/shapefile_counties.mat'],'shapefile_counties');
for i = 1:size(shapefile_counties,1)
    County_FIPS(i,1) = shapefile_counties(i,1).county_FIPS;
end
clear i
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PLOTTING SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:size(BA_Metadata,1)
    Progress = 100.*(i/size(BA_Metadata,1))
    BA_Code = char(BA_Metadata{i,2});
    BA_String = char(BA_Metadata{i,3});
    Territory = BA_Service_Territory(find(BA_Service_Territory(:,2) == BA_Metadata{i,1}),:);
       
    for row = 1:size(Territory,1)
        if row == 1
           all_lat_vector = shapefile_counties(find(County_FIPS(:,1) == Territory(row,1)),1).lat_vector;
           all_lon_vector = shapefile_counties(find(County_FIPS(:,1) == Territory(row,1)),1).lon_vector;
        else
           all_lat_vector = cat(2,all_lat_vector,shapefile_counties(find(County_FIPS(:,1) == Territory(row,1)),1).lat_vector);
           all_lon_vector = cat(2,all_lon_vector,shapefile_counties(find(County_FIPS(:,1) == Territory(row,1)),1).lon_vector);
        end
        Territory(row,3) = Population(find(Population(:,1) == Territory(row,1)),2)./10000;
    end
    lat_min = min(all_lat_vector) - 2; lat_max = max(all_lat_vector) + 2; lon_min = min(all_lon_vector) - 2; lon_max = max(all_lon_vector) + 2;
           
    a = figure('Color',[1 1 1]); set(a,'Position',get(0,'Screensize')); colormap(gca,LCH_Spiral(64,1,180,1,[90 25]));
    ax1 = usamap([lat_min lat_max],[lon_min lon_max]); hold on;
    states = shaperead('usastatelo','UseGeoCoords',true,'Selector',{@(name)~any(strcmp(name,{'Alaska','Hawaii'})),'Name'});
    faceColors = makesymbolspec('Polygon',{'INDEX',[1 numel(states)],'FaceColor',polcmap(numel(states))});
    faceColors.FaceColor{1,3} = faceColors.FaceColor{1,3}./faceColors.FaceColor{1,3};
    geoshow(ax1,states,'DisplayType','polygon','SymbolSpec',faceColors,'LineWidth',2,'LineStyle','-');
    for row = 1:size(Territory,1)
        if Territory(row,1) ~= 11000
           patchm(shapefile_counties(find(County_FIPS(:,1) == Territory(row,1)),1).lat_vector,shapefile_counties(find(County_FIPS(:,1) == Territory(row,1)),1).lon_vector,0,'FaceVertexCData',Territory(row,3),'FaceColor','flat');
        end
    end
    set(gca,'clim',[0,max(Territory(:,3))]); colo = colorbar; set(get(colo,'ylabel'),'String',{[num2str(year_to_plot),' Population [*10^4 People]']},'FontSize',21);
    tightmap; framem on; gridm off; mlabel off; plabel off;
    set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top');
    title([BA_String,' Service Territory ',num2str(year_to_plot)],'FontSize',24);
    if save_images == 1
       set(gcf,'Renderer','zbuffer'); set(gcf,'PaperPositionMode','auto');
       print(a,'-dpng','-r150',[image_output_dir,'Balancing_Authority_Service_Territory_Maps/',BA_Code,'_Service_Territory_',num2str(year_to_plot),'.png']);
       close(a);
    end
    clear Progress BA_Code BA_String Territory lat_min lat_max lon_min lon_max a ax1 colo row faceColors states all_lat_vector all_lon_vector
end
clear i
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                BEGIN CLEANUP SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear County_FIPS data_input_dir image_output_dir save_images shapefile_counties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 END CLEANUP SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%