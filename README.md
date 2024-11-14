# blindspot-multisensory  

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
2. Navigate to the project directory in MATLAB:
```
    cd('blindspot-multisensory')
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
  - `Data/plot.ipynb`
- Figure 2:
  - in MATLAB, run:
  ```
  cd('helper')
  plt = plotGenerator_rabbit;
  plt.grpAvg_combined
  ```
- Figure 3:
  - in MATLAB, run:
  ```
  cd('helper')
  plt = plotGenerator_rabbit;
  plt.heatmap_but_image
  ```
- Figure 4:
  - `Data/figures.ipynb` (run the cell under section 'Figure 4')
- Figure 5:
  - **A**:  
    in MATLAB, run
  ```
  cd('helper')
  plt = plotGenerator_rabbit;
  plt.schematics_rabbit
  ```
  - **B, C**:  
    in MATLAB, run  
  ```
  cd('helper')
  draw_bs_flash;
  ```
  (Note: Psychtoolbox required, resulting image may look different depending on your display's resolution)
  - **D**:  
    in MATLAB, navigate to `'blindspot-multisensory/helper/get_flash_loc_num_key`. Uncomment lines 67-68. Code snippet here:  

  ```
  imgArray = Screen('GetImage', window);
  imwrite(imgArray, 'flashResp.png','png');
  ```
  (Note: Psychtoolbox required, resulting image may look different depending on your display's resolution)  


After running the above commands, `Run All` in `Data/figures.ipynb` to reproduce all 5 main figures.  

---
### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
