% Balancing_Authority_Service_Territory_Maps.m
% 20210808
% Casey D. Burleyson
% Pacific Northwest National Laboratory

% This script takes as .csv files containing the county mapping of
% utilities and balancing authorities (BAs) generates figures showing
% the spatial coverage of each BA.

warning off all; clear all; close all; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN USER INPUT SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set some processing flags:
year_to_plot = 2015; % Year of data to plot
save_images = 0; % (1 = Yes)

% Set the data input and image output directories:
population_data_input_dir = '/Users/burl878/OneDrive - PNNL/Documents/IMMM/Data/TELL_Input_Data/inputs/';
service_territory_data_input_dir = '/Users/burl878/OneDrive - PNNL/Documents/IMMM/Data/TELL_Input_Data/inputs/Utility_Mapping/Matlab_Files/';
image_output_dir = '/Users/burl878/OneDrive - PNNL/Documents/IMMM/Images/TELL/Analysis/BA_Service_Territory_Quick_Look_Plots/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END USER INPUT SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PROCESSING SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([population_data_input_dir,'county_populations_2000_to_2019.mat']);
Pop(:,1) = FIPS_Code;
Pop(:,2) = Population(:,find(Year(1,:) == year_to_plot));
clear FIPS_Code Population Year

load([service_territory_data_input_dir,'BA_Service_Territory_',num2str(year_to_plot),'.mat']);

load([population_data_input_dir,'/shapefile_counties.mat'],'shapefile_counties');
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
% for i = 1:size(BA_Metadata,1)
for i = 1
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
        Territory(row,3) = Pop(find(Pop(:,1) == Territory(row,1)),2)./10000;
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
    set(gca,'clim',[0,max(Territory(:,3))]); colo = colorbar; set(get(colo,'ylabel'),'String',{[num2str(year_to_process),' Population [*10^4 People]']},'FontSize',21);
    tightmap; framem on; gridm off; mlabel off; plabel off;
    set(gca,'LineWidth',3,'FontSize',21,'Box','on','Layer','top');
    title([BA_String,' Service Territory ',num2str(year_to_plot)],'FontSize',24);
    if save_images == 1
       set(gcf,'Renderer','zbuffer'); set(gcf,'PaperPositionMode','auto');
       print(a,'-dpng','-r150',[image_output_dir,BA_Code,'_Service_Territory_',num2str(year_to_plot),'.png']);
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
clear image_output_dir population_data_input_dir save_images service_territory_data_input_dir shapefile_counties year_to_plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 END CLEANUP SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%