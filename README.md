# Genetic matching workshop

**Project Status: Completed**

## About this project
Code from workshop delivered in Cardiff and Leeds as part of NHS R community training programme. This workshop aims to teach the basic principles of how to run genetic matching for a matched cohort study, where we would like to examine the change made by an intervention to a healthcare outcome. In this workshop we also run some introductory data checks and produce descriptive statistics to understand the structure of a fake healthcare dataset provided.

## How does it work?

### Requirements
These scripts were written in R version (to be added) and RStudio Version 1.1.383. The following R packages (available on CRAN) are needed:

* [**tidyverse**](https://www.tidyverse.org/)
* [**tidylog**](https://cran.r-project.org/web/packages/tidylog/index.html)
* [**tableone**](https://cran.r-project.org/web/packages/tableone/vignettes/introduction.html)
* [**skimr**](https://cran.r-project.org/web/packages/skimr/index.html) 
* [**broom**](https://cran.r-project.org/web/packages/broom/index.html)
* [**Matching**](https://cran.r-project.org/web/packages/Matching/index.html)
* [**rgenoud**](https://cran.r-project.org/web/packages/rgenoud/index.html)
* [**here**](https://cran.r-project.org/web/packages/here/index.html)

### Getting started

The 'R' folder contains:

1. 1_Create fake data for workshop.R
* generates and saves the fake data as well as runs the matching and saves the output. You can run this script but all the outputs are already available in the data folder. Please note that running this script is likely to be very CPU intensive.

2. workshop_for_participants.Rmd
* Instructions and exercises for participants.
3. workshop_with_answers.Rmd
* Same as 2 but with possible solutions to the exercises. 


## Data source

This project does not use any real data. We built a small fake dataset intended to replicate a patient level data where some patients received an intervention aimed at reducing a negative outcome

## Authors

This workshop was created and delivered by 

* Emma Vestesson  [Github](www.github.com/emma) / [Twitter](www.twitter.com/gummifot)
* Geraldine Clarke [Twitter](https://twitter.com/GeraldineCTHF)
* Paris Pariza  [GitHub](https://github.com/Ppariz) / [Twitter](https://twitter.com/ParizaParis)
* Richard Brine 
