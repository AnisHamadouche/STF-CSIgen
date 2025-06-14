# CSI Dataset Directory

This directory is intended to hold the generated 3D Channel State Information (CSI) datasets for Seman3DCSI.

## Contents

- `D1_csi.mat`
- `D2_csi.mat`
- ...
- `D19_csi.mat`

Each file contains pre-divided training, validation, and test sets for one specific scenario (see the main repository README for details about each dataset configuration).

## File Format

Each `.mat` file includes the following variables:

- `train_csi` : [nAnt, K, T, N_train]  
- `val_csi`   : [nAnt, K, T, N_val]
- `test_csi`  : [nAnt, K, T, N_test]
- `data_mean` : mean over all samples (for de-standardization)
- `data_std`  : std over all samples (for de-standardization)

where:
- `nAnt` = number of transmit antennas (depends on dataset)
- `K`    = number of subcarriers
- `T`    = number of time steps
- `N_*`  = number of samples in the subset

All data are stored as single-precision (and complex) arrays.

## Download

Due to size constraints, datasets are **not stored in this repository**.

**Download all generated `.mat` CSI files from this link:**

[Download CSI Datasets (Google Drive)](https://drive.google.com/your-download-link-here)

> If you use these datasets, please cite the repository and provide a link to the generator.

---

**Contact**: If you need help or have trouble downloading the data, please open an issue or contact the maintainer.


