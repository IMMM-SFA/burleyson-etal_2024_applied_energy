% Process_BA_Service_Territory_CSV_Files_into_Matlab_Files.m
% 20210808
% Casey D. Burleyson
% Pacific Northwest National Laboratory

% This script takes as input .csv files containing the county mapping of
% utilities and balancing authorities (BAs) and processes the data
% into .mat files for easier use in subsequent scripts.

warning off all; clear all; close all; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN USER INPUT SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set some processing flags:
year_to_process = 2019; % Year of data to process

% Set the data input directory:
data_input_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2021_Burleyson_et_al_TELL/burleyson-etal_2021_tbd_data/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END USER INPUT SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PROCESSING SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the filename based on the 'year_to_process' variable assigned above:
filename = [data_input_dir,'output_data/BA_Service_Territory_Data/CSV_Files/BA_Service_Territory_',num2str(year_to_process),'.csv'];

% Read in the raw .csv file:
delimiter = ',';
start_row = 2;
end_row = inf;
formatSpec = '%f%f%C%C%C%f%C%f%f%C%C%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID,formatSpec,end_row(1)-start_row(1)+1,'Delimiter',delimiter,'TextType','string','EmptyValue',NaN,'HeaderLines',start_row(1)-1,'ReturnOnError',false,'EndOfLine','\r\n');
for block = 2:length(start_row)
    frewind(fileID);
    dataArrayBlock = textscan(fileID,formatSpec,end_row(block)-start_row(block)+1,'Delimiter',delimiter,'TextType','string','EmptyValue',NaN,'HeaderLines',start_row(block)-1,'ReturnOnError',false,'EndOfLine','\r\n');
    for col = 1:length(dataArray)
        dataArray{col} = [dataArray{col};
        dataArrayBlock{col}];
    end
end
fclose(fileID);
clear delimiter filename start_row end_row formatSpec fileID block col

% Convert the raw data into a table:
Service_Territory_Table = table;
Service_Territory_Table.year = dataArray{:,1};
Service_Territory_Table.utility_number = dataArray{:,2};
Service_Territory_Table.utility_name = dataArray{:,3};
Service_Territory_Table.state_abbreviation = dataArray{:,4};
Service_Territory_Table.state_name = dataArray{:,5};
Service_Territory_Table.state_fips = dataArray{:,6};
Service_Territory_Table.county_name = dataArray{:,7};
Service_Territory_Table.county_fips = dataArray{:,8};
Service_Territory_Table.ba_number = dataArray{:,9};
Service_Territory_Table.ba_abbreviation = dataArray{:,10};
Service_Territory_Table.ba_name = dataArray{:,11};
clear dataArray

% Loop over the table and extract relevant information from rows with no missing values:
counter = 0;
for row = 1:size(Service_Territory_Table,1)
    % Fix a typo for the Nevada Power balancing authority:
    if table2array(Service_Territory_Table(row,9)) == 13047;
       Service_Territory_Table{row,9} = 13407;
    end
    % If there is a valid BA # then extract the information:
    if isnan(table2array(Service_Territory_Table(row,9))) == 0
       counter = counter + 1;
       Service_Territory_Index(counter,[1:2]) = table2array(Service_Territory_Table(row,[8,9]));
       Service_Territory(counter,1).ba_abbreviation = char(table2array(Service_Territory_Table(row,10)));
       Service_Territory(counter,1).ba_name = char(table2array(Service_Territory_Table(row,11)));
    end
end
clear row counter Service_Territory_Table

% Get rid of the duplicate rows:
[dummy,unique_rows] = unique(Service_Territory_Index,'rows');
Service_Territory = Service_Territory(unique_rows,:);
Service_Territory_Index = Service_Territory_Index(unique_rows,:);
clear dummy unique_rows
   
% Extract the names and abbreviations of the unique balancing authorities:
unique_bas = unique(Service_Territory_Index(:,2));
for row = 1:size(unique_bas)
    BA_Metadata{row,1} = unique_bas(row,1);
    BA_Metadata{row,2} = Service_Territory(min(find(Service_Territory_Index(:,2) == unique_bas(row,1))),1).ba_abbreviation;
    BA_Metadata{row,3} = Service_Territory(min(find(Service_Territory_Index(:,2) == unique_bas(row,1))),1).ba_name;
end
clear row unique_bas

% Change the key variable name and save the output:
BA_Service_Territory(:,1) = Service_Territory_Index(:,1); % County FIPS Code
BA_Service_Territory(:,2) = Service_Territory_Index(:,2); % Balancing Authority Number
save([data_input_dir,'output_data/BA_Service_Territory_Data/Matlab_Files/BA_Service_Territory_',num2str(year_to_process),'.mat'],'BA_Service_Territory','BA_Metadata');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                BEGIN CLEANUP SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear ans data_input_dir Service_Territory Service_Territory_Index
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 END CLEANUP SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%