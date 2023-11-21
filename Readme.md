_your zenodo badge here_

# burleyson-etal_2023_applied_energy

**When Do Different Scenarios of Projected Electricity Demand Start to Meaningfully Diverge?**

Casey D. Burleyson<sup>1\*</sup>, Zarrar Khan<sup>1,2</sup>, Misha Kulshresta<sup>1,3</sup>, 
Nathalie Voisin<sup>1,4</sup>, and Jennie S. Rice<sup>1</sup>

<sup>1 </sup> Pacific Northwest National Laboratory, Richland, WA, USA  
<sup>2 </sup> Joint Global Change Research Institute, College Park, MD, USA  
<sup>3 </sup> University of California - Santa Barbara, Santa Barbara, CA, USA  
<sup>4 </sup> University of  Washington, Seattle, WA, USA  

\* corresponding author: casey.burleyson@pnnl.gov

## Abstract
Resources adequacy studies look at balancing electricity supply and demand on 10- to 15-year time horizons while asset 
investments typically look at returns on investment on 20- to 40-year time horizons. Projections of electricity demand 
are factored into the decision-making in both cases. Climate, policy, and socioeconomic changes are known to influence 
electricity demand projections. If different climate and socioeconomic scenarios do not lead to electricity demands 
that are distinctly different within the first 10-40 years then, for the purposes of investment and reliability 
decisions, it may not matter which potential climate or socioeconomic pathway we are most likely on. In this study, we 
evaluate the impact of uncertainty in climate and socioeconomic scenarios on electricity demand in the United States 
(U.S.). Specifically, we quantify when projected electricity demands start to meaningfully diverge in response to a 
range of climate and socioeconomic drivers. The Integrated Multisector Multiscale Modeling project has generated a wide 
yet plausible range of 21st century climate and socioeconomic scenarios for the U.S. The projections span two 
population/economic scenarios (Shared Socioeconomic Pathways 3 and 5) and two emissions scenarios (Representative 
Concentration Pathways 4.5 and 8.5). Each emissions scenario has two warming levels to reflect a range of climate model 
uncertainty. We show that the socioeconomic scenario matters almost immediately, emissions scenario matters within 
25-30 years, and climate model uncertainty matters only after 50+ years. This work can inform the power sector in 
integrating climate change uncertainties in their decision-making studies.

## Journal reference
Burleyson, C.D., Z. Khan, M. Kulshresta, N. Voisin, and J.S. Rice (2023). When do different scenarios of projected 
electricity demand start to meaningfully diverge? Submitted to *Applied Energy* - December 2023.

## Code reference
Burleyson, C.D., M. Kulshresta, Z. Khan, N. Voisin, and J.S. Rice (2023). Supporting code for Burleyson et al. 2023 - 
Applied Energy [Code]. Zenodo. TBD.

## Data references

### Input data
|       Dataset       |               Repository Link                |               DOI                |
|:-------------------:|:--------------------------------------------:|:--------------------------------:|
|   GCAM-USA Output   | https://data.msdlive.org/records/43sy2-n8y47 | https://doi.org/10.57931/1989373 |
| TGW Weather Forcing | https://data.msdlive.org/records/cnsy6-0y610 | https://doi.org/10.57931/1960530 |

### Output data
|    Dataset    | Repository Link | DOI |
|:-------------:|:---------------:|:---:|
|  TELL Output  |       TBD       | TBD |

## Contributing modeling software
|  Model   | Version |         Repository Link          | DOI |
|:--------:|:-------:|:--------------------------------:|:---:|
| GCAM-USA |  v5.3   | https://data.msdlive.org/records/r52tb-hez28 | https://doi.org/10.57931/1960381 |
|   TELL   |  v1.1   | https://github.com/IMMM-SFA/tell | https://doi.org/10.5281/zenodo.8264217 |

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
These landing pages show the complete results for each state and Balancing Authority (BA).

[State-Level Analyses](States_Analysis.md)  
[BA-Level Analyses](Balancing_Authorities_Analysis.md)