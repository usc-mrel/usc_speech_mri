# Speech MRI Open Dataset
<p align="center"> 
<img src="https://raw.githubusercontent.com/yongwanlim/yongwanlim.github.io/master/assets/img/75subj.png" />
</p>

This package contains code samples to load, reconstruct, and use the open raw MRI data set for the following paper:\
Y Lim, A Toutios, et al. A multispeaker dataset of raw and reconstructed speech production real-time MRI video and 3D volumetric images, *Nature Scientific Data*, In press. 

The submitted version of the paper is available in *arXiv*: [Link](https://arxiv.org/abs/2102.07896)

The dataset is publicly available in *figshare*: [Link](https://doi.org/10.6084/m9.figshare.13725546.v1)
 
Code is provided in Python and Maltab programming languages.

Please also find useful links for papers and tools relevant to the dataset: [Link](https://github.com/yongwanlim/links_speech_rtmri_tools)

## Example Usage

### Matlab
```matlab
addpath /path/to/ismrmrd/matlab/
run demo_recon_matlab.m
```
### Python
```bash
pip install -r requirements.txt
python demo_recon_python.py
```

## Citing
```
@misc{lim2021multispeaker,
      title={A multispeaker dataset of raw and reconstructed speech production real-time MRI video and 3D volumetric images}, 
      author={Yongwan Lim and Asterios Toutios and Yannick Bliesener and Ye Tian and Sajan Goud Lingala and Colin Vaz and Tanner Sorensen and Miran Oh and Sarah Harper and Weiyi Chen and Yoonjeong Lee and Johannes Töger and Mairym Lloréns Montesserin and Caitlin Smith and Bianca Godinez and Louis Goldstein and Dani Byrd and Krishna S. Nayak and Shrikanth S. Narayanan},
      year={2021},
      eprint={2102.07896},
      archivePrefix={arXiv},
      primaryClass={eess.SP}
}
```

## Data
https://doi.org/10.6084/m9.figshare.13725546.v1

## Structure
* **matlab** contains MATLAB reconstruction files
* **python** contains Python reconstruction files
* **figures** contains MATLAB files to re-create Figures 2-6 in reference paper [to be updated]
