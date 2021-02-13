# Speech MRI Open Dataset

This package contains code samples to load, reconstruct, and use the open raw MRI data set for the following paper:\
Y Lim, A Toutios, et al. A multispeaker dataset of raw and reconstructedspeech production real-time MRI video and 3D volumetric images, *submitted to Nature Scientific Data* 

The dataset is publicly available in *figshare*: [Link](https://doi.org/10.6084/m9.figshare.13725546.v1)
 
Code is provided in Python and Maltab programming languages.

Please also find useful links for papers and tools relevant to the dataset: [Link](https://github.com/yongwanlim/links_rtmri_tools)

## Example Usage

### Matlab
```matlab
addpath /path/to/ismrmrd/matlab/
run demo_recon_matlab.m
```
### Python
```bash
pip install -r requirements.txt
python3 demo_recon_python.py
```

## Citing
To be updated

## Data
https://doi.org/10.6084/m9.figshare.13725546.v1

## Structure
* **matlab** contains MATLAB reconstruction files
* **python** contains Python reconstruction files
* **figures** contains MATLAB files to re-create Figures 2-6 in reference paper [to be updated]
