% Process_Raw_MLP_Model_Output_Data_into_Matlab_Files_WRF.m
% 20210707
% Casey D. Burleyson
% Pacific Northwest National Laboratory

% Take Aowabin's output from the MLP models and clean up the formatting.
% Add in the forecast demand from EIA as a means of benchmarking the models. Save the 
% output as both .csv and .mat files for easier use in downstream processing and analysis.
%
% .mat output file format:
% C1:  MATLAB date number
% C2:  Year
% C3:  Month
% C4:  Day
% C5:  Hour
% C6:  Actual demand in MWh
% C7:  MLP forecast demand in MWh
% C8:  MLP forecast error in MWh
% C9:  EIA forecast demand in MWh
% C10: EIA forecast error in MWh
% C11: WRF temperature in C
%
% .csv output file format:
% C1:  Year
% C2:  Month
% C3:  Day
% C4:  Hour
% C5:  Actual demand in MWh
% C6:  MLP forecast demand in MWh
% C7:  MLP forecast error in MWh
% C8:  EIA forecast demand in MWh
% C9:  EIA forecast error in MWh
% C10: WRF temperature in C

warning off all; clear all; close all; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN USER INPUT SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the data input and output directories:
mlp_model_data_input_dir = '/Users/burl878/OneDrive - PNNL/Documents/IMMM/Data/TELL_Input_Data/outputs/MLP_Model_Evaluation/Raw_Data_WRF/';
composite_data_input_dir = '/Users/burl878/OneDrive - PNNL/Documents/IMMM/Data/TELL_Input_Data/inputs/Composite_BA_Hourly_Data_WRF/Matlab_Files/';
mat_data_output_dir = '/Users/burl878/OneDrive - PNNL/Documents/IMMM/Data/TELL_Input_Data/outputs/MLP_Model_Evaluation/Matlab_Files_WRF/';
csv_data_output_dir = '/Users/burl878/OneDrive - PNNL/Documents/IMMM/Data/TELL_Input_Data/outputs/MLP_Model_Evaluation/CSV_Files_WRF/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              END USER INPUT SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              BEGIN PROCESSING SECTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a list of all of the files in the composite data input directory:
input_files = dir([composite_data_input_dir,'*.mat']);
for file = 1:size(input_files,1)
    % Find the filename and the code of the BA being processed:
    filename = input_files(file,1).name;
    BA_Short_Name = filename(1,1:(size(filename,2)-43));
    [EIA_BA_Number,BA_Long_Name] = EIA_930_BA_Information_From_BA_Short_Name(BA_Short_Name);
    Composite_File_Names(file,1).name = filename;
    Composite_File_Metadata(file,1) = EIA_BA_Number;
    clear BA_Short_Name EIA_BA_Number BA_Long_Name filename
end
clear input_files file

% Make a list of all of the files in the MLP model data input directory:
input_files = dir([mlp_model_data_input_dir,'*.csv']);

% Loop over each of the files and extract the variables of interest:
% for file = 1:size(input_files,1)
for file = 42
    % Find the filename and the code of the BA being processed:
    filename = input_files(file,1).name;
    BA_Short_Name = filename(1,1:(size(filename,2)-20));
    [EIA_BA_Number,BA_Long_Name] = EIA_930_BA_Information_From_BA_Short_Name(BA_Short_Name);
           
    fileID = fopen([mlp_model_data_input_dir,filename],'r');    
    Array = textscan(fileID,'%s%f%f%[^\n\r]','Delimiter',',','TextType','string','EmptyValue',NaN,'HeaderLines',1,'ReturnOnError',false,'EndOfLine','\r\n');
    fclose(fileID);
    Raw_Data = table;
    Raw_Data.Datetime = cellstr(Array{:, 1});
    Raw_Data.GroundTruth = Array{:, 2};
    Raw_Data.Predictions = Array{:, 3};
        
    % Convert the data from a table to a standard array structure:
    for row = 1:size(Raw_Data,1)
        MLP_Data(row,1) = datenum(table2array(Raw_Data(row,1)));
        MLP_Data(row,2:7) = datevec(MLP_Data(row,1));
        MLP_Data(row,6) = table2array(Raw_Data(row,2));
        MLP_Data(row,7) = table2array(Raw_Data(row,3));
        MLP_Data(row,8) = MLP_Data(row,7) - MLP_Data(row,6);
    end
    
    % Load in the composite data for the same BA and map it to a common axis:
    if isempty(find(Composite_File_Metadata(:,1) == EIA_BA_Number)) == 0
       load([composite_data_input_dir,Composite_File_Names(find(Composite_File_Metadata(:,1) == EIA_BA_Number)).name]);
       for row = 1:size(MLP_Data,1)
           if isempty(find(Data(:,1) == MLP_Data(row,1))) == 0 & Data(find(Data(:,1) == MLP_Data(row,1)),13) == MLP_Data(row,6)
              MLP_Data(row,9) = Data(find(Data(:,1) == MLP_Data(row,1)),12);
              MLP_Data(row,10) = MLP_Data(row,9) - MLP_Data(row,6);
              MLP_Data(row,11) = Data(find(Data(:,1) == MLP_Data(row,1)),7) - 273.15;
           else
              MLP_Data(row,9) = NaN.*0;
              MLP_Data(row,10) = NaN.*0;
              MLP_Data(row,11) = NaN.*0;
           end
       end
       clear row Data
    else
       MLP_Data(:,9:11) = NaN.*0;
    end
    
    % Round of the values to save space: 
    Data = MLP_Data;
    for row = 1:size(Data,1)
        Data(row,7) = roundn(Data(row,7),0);
        Data(row,8) = roundn(Data(row,8),0);
        Data(row,11) = roundn(Data(row,11),-1);
    end        
    
%     % Save the data as a .mat file:
%     save([mat_data_output_dir,BA_Short_Name,'_MLP_Model_Evaluation_Data_WRF.mat'],'Data');
%     
%     % Convert the NaN values to -9999 for the .csv file:
%     Data(find(isnan(Data) == 1)) = -9999;
%     
%     % Convert the data into a table and save it as a .csv file:
%     Output_Table = array2table(Data(:,2:11));
%     Output_Table.Properties.VariableNames = {'Year','Month','Day','Hour','Actual_Demand_MWh','MLP_Forecast_Demand_MWh','MLP_Error_MWh','EIA_Forecast_Demand_MWh','EIA_Forecast_Error_MWh','Temperature_C'};
%     writetable(Output_Table,strcat([csv_data_output_dir,BA_Short_Name,'_MLP_Model_Evaluation_Data_WRF.csv']),'Delimiter',',','WriteVariableNames',1);
%     clear Output_Table Data row Raw_Data BA_Short_Name filename fileID Array ans BA_Long_Name EIA_BA_Number MLP_Data
end
clear input_files file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               END PROCESSING SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                BEGIN CLEANUP SECTION                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear mlp_model_data_input_dir mat_data_output_dir csv_data_output_dir composite_data_input_dir Composite_File_Metadata Composite_File_Names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 END CLEANUP SECTION                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%