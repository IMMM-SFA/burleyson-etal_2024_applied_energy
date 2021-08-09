% Process_Raw_EIA_930_BA_Hourly_Load_Data.m
% 20210806
% Casey D. Burleyson
% Pacific Northwest National Laboratory

% This script takes the raw EIA-930 hourly load data by balancing authority
% and convert it from .xlsx files into .mat and .csv files. The output
% file format is given below. All times are in UTC. Missing values are reported as -9999
% in the .csv output files and are reported as NaN in the .mat output files. 

%   .csv and .mat output file format: 
%   C1: Year
%   C2: Month
%   C3: Day
%   C4: Hour
%   C5: Forecast demand in MWh
%   C6: Adjusted demand in MWh
%   C7: Adjusted generation in MWh
%   C8: Adjusted net interchange with adjacent balancing authorities in MWh

warning off all; clear all; close all; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN USER INPUT SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the data input directory:
data_input_dir = '/Users/burl878/OneDrive - PNNL/Documents/Papers/2021_Burleyson_et_al_TELL/burleyson-etal_2021_tbd_data/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END USER INPUT SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PROCESSING SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a list of all of the files in the 'EIA_930_Balancing_Authority_Hourly_Load' directory:
input_files = dir([data_input_dir,'input_data/EIA_930_Balancing_Authority_Hourly_Load/Raw_Data/*.xlsx']);

% Loop over each of the files and extract the variables of interest:
for file = 1:size(input_files,1)
    % Read in the raw .xlsx file:
    filename = input_files(file,1).name;
    [~,~,Raw_Data] = xlsread([data_input_dir,'input_data/EIA_930_Balancing_Authority_Hourly_Load/Raw_Data/',filename],'Published Hourly Data');
    Raw_Data(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),Raw_Data)) = {''};
    
    % Extract the balancing authority code:
    BA_Code = char(Raw_Data{2,1});
    
    % Loop over the rows and extract the variables of interest:
    counter = 0;
    for row = 2:size(Raw_Data,1)
        counter = counter + 1;
        
        % Convert the UTC date from the Excel time format to the Matlab date number format:
        Data(counter,1:6) = datevec(Raw_Data{row,2} + 693960);
        
        % Extract the forecast demand:
        if isempty(Raw_Data{row,8}) == 0
           Data(counter,5) = Raw_Data{row,8};
        else
           Data(counter,5) = NaN.*0;
        end
        
        % Extract the adjusted demand:
        if isempty(Raw_Data{row,15}) == 0
           Data(counter,6) = Raw_Data{row,15};
        else
           Data(counter,6) = NaN.*0;
        end
        
        % Extract the adjusted generation:
        if isempty(Raw_Data{row,16}) == 0
           Data(counter,7) = Raw_Data{row,16};
        else
           Data(counter,7) = NaN.*0;
        end
        
        % Extract the adjusted interchange from adjacent balancing authorities:
        if isempty(Raw_Data{row,17}) == 0
           Data(counter,8) = Raw_Data{row,17};
        else
           Data(counter,8) = NaN.*0;
        end
    end
        
    % Save the data as a .mat file:
    save([data_input_dir,'input_data/EIA_930_Balancing_Authority_Hourly_Load/Matlab_Files/',BA_Code,'_Hourly_Load_Data.mat'],'Data');
    
    % Convert the NaN values to -9999 for the .csv file:
    Data(find(isnan(Data) == 1)) = -9999;
    
    % Convert the data into a table and save it as a .csv file:
    Output_Table = array2table(Data);
    Output_Table.Properties.VariableNames = {'Year','Month','Day','Hour','Forecast_Demand_MWh','Adjusted_Demand_MWh','Adjusted_Generation_MWh','Adjusted_Interchange_MWh'};
    writetable(Output_Table,strcat([data_input_dir,'input_data/EIA_930_Balancing_Authority_Hourly_Load/CSV_Files/',BA_Code,'_Hourly_Load_Data.csv']),'Delimiter',',','WriteVariableNames',1);
    clear Output_Table Data filename Raw_Data counter row BA_Code
end
clear input_files file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                BEGIN CLEANUP SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear data_input_dir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 END CLEANUP SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%