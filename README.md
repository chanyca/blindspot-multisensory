# blindspot-multisensory  

[![DOI](https://zenodo.org/badge/888130091.svg)](https://doi.org/10.5281/zenodo.14167119)  
Data and code accompaning the paper "Filling in of the Blindspot is Multisensory." by Ailene Chan, N. R. B. Stiles, C. A. Levitan, A. R. Tanguay, and S.
Shimojo.
---
### Getting Started
#### Prerequisites
- Psychtoolbox (Download [here](http://psychtoolbox.org/download))
- EyeLink Developers Kit (Download [here](https://www.sr-research.com/support/thread-13.html))
  - You will need to create an account to access SR Support Forum
 
#### Tested on:
- MATLAB R2023b
- Psychtoolbox-3.0.19
- EyeLink Developers Kit v2.1.1197

#### Hardware information
- Monitor: Dell UltraSharp U2720Q, 3840 x 2160, 60 Hz refresh rate
- Speaker: Bose Companion 2 Series III
- Eye-tracker: EyeLink 1000

#### Installation
1. Clone this repository:  
```
    git clone https://github.com/chanyca/blindspot-multisensory.git
```
2. Navigate to the project directory in terminal:
```
    cd('blindspot-multisensory')
```
3. Set up environment
```
    conda env create -f blindspot-multisensory.yml
    conda activate blindspot-multisensory
```
---
### Key functions
`BS_mapping`: Main script for blind spot mapping
`runExpt`: Main script to run AV Rabbit Illusion experiments. Note: It won't start if it fails to find the participant's blind spot data file.

### Data analysis + plotting

To reproduce each figure:  
  
**IMPORTANT: Run `helper/genAllData_rabbit` to generate compiled data files for plotting.**  
In MATLAB, run:
```
cd('helper')
allData = genAllData_rabbit;
```
- Figure 1:
  - `Data/figure_1.ipynb`
- Figure 2:
  - `Data/figure_2.ipynb`
- Figure 3:
  - `Data/figure_3.ipynb`
- Figure 4:
  - `Data/figure_4.ipynb`
- Figure 5:
  - `Data/figure_5.ipynb`
---
### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
