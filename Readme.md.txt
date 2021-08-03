_your zenodo badge here_

# burleyson-etal_2021_tbdd

**TBD**

Jae Edmonds<sup>1\*</sup> and John Reilly<sup>1</sup>

<sup>1 </sup> Institute for Energy Analysis, Oak Ridge Associated Universities, 1346 Connecticut Avenue, NW, Washington, DC 20036, USA

\* corresponding author:  email@myorg.gov

## Abstract
TBD

## Journal reference
TBD

## Code reference
TBD

## Data reference

### Input data
Reference for each minted data source for your input data.  For example:

Human, I.M. (2021). My input dataset name [Data set]. DataHub. https://doi.org/some-doi-number

### Output data
Reference for each minted data source for your output data.  For example:

Human, I.M. (2021). My output dataset name [Data set]. DataHub. https://doi.org/some-doi-number

## Contributing modeling software
| Model | Version | Repository Link | DOI |
|-------|---------|-----------------|-----|
| model 1 | version | link to code repository | link to DOI dataset |
| model 2 | version | link to code repository | link to DOI dataset |
| component 1 | version | link to code repository | link to DOI dataset |

## Reproduce my experiment
Fill in detailed info here or link to other documentation that is a thorough walkthrough of how to use what is in this repository to reproduce your experiment.


1. Install the software components required to conduct the experiement from [Contributing modeling software](#contributing-modeling-software)
2. Download and install the supporting input data required to conduct the experiement from [Input data](#input-data)
3. Run the following scripts in the `workflow` directory to re-create this experiment:

| Script Name | Description | How to Run |
| --- | --- | --- |
| `step_one.py` | Script to run the first part of my experiment | `python3 step_one.py -f /path/to/inputdata/file_one.csv` |
| `step_two.py` | Script to run the last part of my experiment | `python3 step_two.py -o /path/to/my/outputdir` |

4. Download and unzip the output data from my experiment [Output data](#output-data)
5. Run the following scripts in the `workflow` directory to compare my outputs to those from the publication

| Script Name | Description | How to Run |
| --- | --- | --- |
| `compare.py` | Script to compare my outputs to the original | `python3 compare.py --orig /path/to/original/data.csv --new /path/to/new/data.csv` |

## Reproduce my figures
Use the scripts found in the `figures` directory to reproduce the figures used in this publication.

| Script Name | Description | How to Run |
| --- | --- | --- |
| `generate_figures.py` | Script to generate my figures | `python3 generate_figures.py -i /path/to/inputs -o /path/to/outuptdir` |
