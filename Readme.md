_your zenodo badge here_

# burleyson-etal_2023_applied_energy

**When Do Different Scenarios of Projected Electricity Demand Start to Meaningfully Diverge?**

Casey D. Burleyson<sup>1\*</sup>, Misha Kulshresta<sup>1,2</sup>, Zarrar Khan<sup>1,3</sup>, Nathalie Voisin<sup>1</sup>
, and Jennie S. Rice<sup>1</sup>

<sup>1 </sup> Pacific Northwest National Laboratory, Richland, WA, USA  
<sup>2 </sup> University of California - Santa Barbara, Santa Barbara, CA, USA  
<sup>3 </sup> Joint Global Change Research Institute, College Park, MD, USA  

\* corresponding author: casey.burleyson@pnnl.gov

## Abstract
Climate and population change are known to influence electricity demand, but what is the impact of uncertainty in 
climate and population scenarios on electricity demand in the United States (U.S.) over the next 30 years? This question 
has implications for investment decisions in the energy sector, which are typically made using a 15- to 30-year time 
horizon. If future climate and population scenarios do not lead to electricity demands that are distinctly different 
within the first 30 years then, for the purposes of investment decisions, it may not matter which potential pathway we 
are most likely on. The Integrated, Multisector, Multiscale Modeling (IM3) project has generated a wide yet plausible 
range of 21st century climate and socioeconomic scenarios for the U.S. The IM3 projections span two population/economic 
scenarios (Shared Socioeconomic Pathways 3 and 5) and two climate scenarios (Representative Concentration Pathways 4.5 
and 8.5). For each of the climate scenarios, we reflect a range of climate model uncertainty by utilizing warming levels 
from groups of climate models that are hotter and colder than the multi-model mean. In total there are eight (2 x 2 x 2) 
scenarios. This work explores a basic but important question: When do projected electricity demands start to 
meaningfully diverge across the eight scenarios? We show that the choice of socioeconomic scenario matters almost 
immediately, climate scenario matters within 25-30 years, and whether to use hotter or cooler climate models matters 
only after 50+ years.

## Journal reference
Burleyson, C.D., M. Kulshresta, Z. Khan, N. Voisin, and J.S. Rice (2023). When do different scenarios of projected 
electricity demand start to meaningfully diverge? Submitted to *Applied Energy* - April 2023.

## Code reference
Burleyson, C.D., M. Kulshresta, Z. Khan, N. Voisin, and J.S. Rice (2023). Supporting code for Burleyson et al. 2023 - 
Applied Energy [Code]. Zenodo. TBD.

## Data references

### Input data
|       Dataset       |               Repository Link                |               DOI                |
|:-------------------:|:--------------------------------------------:|:--------------------------------:|
|   GCAM-USA Output   |                     TBD                      |               TBD                |
| TGW Weather Forcing | https://data.msdlive.org/records/cnsy6-0y610 | https://doi.org/10.57931/1960530 |

### Output data
|    Dataset    | Repository Link | DOI |
|:-------------:|:---------------:|:---:|
|  TELL Output  |       TBD       | TBD |
| Analysis Data |       TBD       | TBD |

## Contributing modeling software
|  Model   | Version |                                              Repository Link                                               | DOI |
|:--------:|:-------:|:----------------------------------------------------------------------------------------------------------:|:---:|
| GCAM-USA |  v5.3   |https://stash.pnnl.gov/projects/JGCRI/repos/gcam-core/browse?at=refs%2Fheads%2Fzk%2Ffeature%2Fgcam-usa-im3  | TBD |
|   TELL   |  v1.1   |                                      https://github.com/IMMM-SFA/tell                                      | TBD |

## Reproduce my experiment
Use the following notebooks to rerun the TELL model to produce the output data used in this analysis.

| Script Name | Description |
|-------------|-------------|

## Reproduce my figures
Use the following notebooks to reproduce the figures used in this publication.

|                Script Name                 |                                Description                                 | Figure Numbers |
|:------------------------------------------:|:--------------------------------------------------------------------------:|:--------------:|
|        difference_calculation.ipynb        |           Shows how the mean and peak differences are calculated           |      TBD       |
| interconnection_time_series_analysis.ipynb | Analyzes the time series of annual total and peak loads by interconnection |      TBD       |
|      state_time_series_analysis.ipynb      |      Analyzes the time series of annual total and peak loads by state      |      TBD       |
|      state_divergence_analysis.ipynb       |             Analyzes the evolution of load divergence by state             |      TBD       |

## Supplementary figures
These landing pages show the complete results for each state and BA.

[State-Level Analyses](States_Analysis.md)  
[BA-Level Analyses](Balancing_Authorities_Analysis.md)