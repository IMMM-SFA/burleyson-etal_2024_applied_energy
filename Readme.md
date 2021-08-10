_your zenodo badge here_

# burleyson-etal_2021_tbd

**Formulation and Calibration of a Model for Predicting the Short- and Long-Term Evolution of Total Electricity Loads in the United States**

Casey D. Burleyson<sup>1\*</sup>, Casey McGrath<sup>1</sup>, Zarrar Khan<sup>1</sup>, Aowabin Rahman<sup>1</sup>, Chris Vernon<sup>1</sup>, Nathalie Voisin<sup>1</sup>, and Jennie S. Rice<sup>1</sup>

<sup>1 </sup> Pacific Northwest National Laboratory, Richland, WA, USA

\* corresponding author: casey.burleyson@pnnl.gov

## Abstract
TBD

## Journal reference
TBD

## Code reference
TBD

## Data reference

### Input data
TBD

### Output data
TBD

## Contributing modeling software
| Model | Version | Repository Link | DOI |
|-------|---------|-----------------|-----|
| TELL | v1.0 | https://github.com/IMMM-SFA/tell | TBD |

## Reproduce my experiment
1. Download and unzip the input data required to conduct the experiment using the DOI link above.
2. Run the following Matlab scripts in the `workflow` directory to process the raw data used in this experiment:

| Script Name | Description |
| --- | --- |
| `Process_Raw_EIA_930_BA_Hourly_Load_Data.m` | This script takes the raw EIA-930 hourly load data by balancing authority and converts it from .xlsx files into .mat and .csv files. |
| `Process_BA_Service_Territory_CSV_Files_into_Matlab_Files.m` | This script takes as input .csv files containing the county mapping of utilities and balancing authorities and processes the data into .mat files for easier use in subsequent scripts. |

## Reproduce my figures
1. Use the scripts found in the `figures` directory to reproduce the figures used in this publication.

| Script Name | Description |
| --- | --- |
| `Balancing_Authority_Service_Territory_Maps.m`| This script takes .mat files containing the county mapping of utilities and balancing authorities generates maps showing the spatial coverage of each balancing authority. |
| `Load_Projection_Dissagregation_Example.m`| This script is used to demonstrate the forward prediction and spatial dissaggregation capability of TELL for a sample balancing authority. |