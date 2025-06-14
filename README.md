Here’s a comprehensive **README.md-style documentation** suitable for GitHub for your 3D CSI dataset generation code, **explaining every detail** for reproducibility, adaptation, and understanding. This assumes readers have a signal processing/wireless background and basic MATLAB knowledge.

---

# 3D Spatio-Temporal-Frequency CSI Dataset Generator (QuaDRiGa, MATLAB)

This repository contains MATLAB scripts to generate synthetic, physically accurate, **3D spatio-temporal-frequency channel state information (CSI) datasets** for MISO-OFDM systems, using the [QuaDRiGa](https://quadriga-channel-model.de/) channel simulator with standardized **3GPP channel models**. These datasets are ideal for training and benchmarking deep learning-based CSI prediction, beamforming, and wireless AI models in realistic 5G (and beyond) scenarios.

## Overview

* **Generates 19 diverse datasets (D1–D19)** spanning various frequencies (1.5–28 GHz), antenna arrays, channel scenarios, and user mobility conditions.
* **Each dataset** contains 12,000 CSI samples, each representing the time evolution of a moving user’s MISO-OFDM channel over several subcarriers and timesteps.
* **Samples are split** into training (9k), validation (1k), and test (2k) sets, standardized, and corrupted with 20dB SNR noise for realism.

---

## Features

* **Physically realistic channels:** Generated using QuaDRiGa with 3GPP standardized scenarios (UMi, UMa, RMa, Indoor).
* **User mobility:** Each CSI sample simulates a single-antenna user following a unique straight-line trajectory with random start position and speed.
* **Antenna arrays:** Various UPA (Uniform Planar Array) configurations at the BS, single omni antenna at the user.
* **OFDM structure:** Each CSI tensor is of shape `[nAnt, K, T]` = `[# Tx antennas, # subcarriers, # timesteps]`.
* **Noise & Standardization:** Datasets include realistic receiver noise and are pre-standardized (zero mean, unit variance).

---

## Dataset Configuration

Each dataset is defined in `dataset_info` as:

| D   | fC (GHz) | K   | df (kHz) | T   | dt (ms) | UPA    | Scenario | vmin (km/h) | vmax (km/h) |
| --- | -------- | --- | -------- | --- | ------- | ------ | -------- | ----------- | ----------- |
| 1   | 1.5      | 128 | 90       | 24  | 1       | \[1,4] | UMi+NLoS | 3           | 50          |
| ... | ...      | ... | ...      | ... | ...     | ...    | ...      | ...         | ...         |
| 19  | 28.0     | 32  | 360      | 16  | 0.25    | \[4,8] | UMa+LoS  | 30          | 100         |

Where:

* **fC:** Center frequency in GHz
* **K:** Number of OFDM subcarriers
* **df:** Subcarrier spacing (kHz)
* **T:** Number of time steps (snapshots)
* **dt:** Time step (ms)
* **UPA:** BS array size \[rows, columns]
* **Scenario:** 3GPP scenario (urban micro/macro, rural, indoor, LoS/NLoS)
* **vmin/vmax:** User speed range (km/h)

---

## CSI Generation Process

### 1. **Parameter Extraction**

For each dataset (D1–D19):

* System parameters are loaded (frequency, subcarriers, time steps, antenna array, scenario, user speed).

### 2. **Sample Generation**

For each CSI sample (`N_SAMPLES = 12,000`):

* **Random User Initialization:** Start position uniformly random within a 400m x 400m cell at 1.5m height.
* **Random Mobility:** Speed drawn uniformly from the allowed range, random direction.
* **Trajectory Construction:** The user follows a straight line; their position is updated at each time step.
* **Display:** For the first few samples and every 1000th sample, print dataset label, frequency, subcarriers, step size, trajectory info, and Rx positions for debug/transparency.

### 3. **QuaDRiGa Channel Modeling**

* **Scenario Setup:** Appropriate 3GPP channel scenario assigned (UMi/UMa/RMa/Indoor; LoS or NLoS).
* **Antenna Setup:**

  * BS: UPA of specified size, dual polarization (only the first pol is used in final data).
  * User: Omni-directional antenna.
* **Channel Generation:** For each sample, the function `.fr()` returns the frequency-domain channel matrix for all subcarriers/timesteps.
* **Polarization Handling:** Only one (vertical) polarization is kept, matching `nAnt = prod(UPA)`.

### 4. **Data Shaping & Consistency**

* Channel tensor is shaped to `[nAnt, K, T]`.
* Robust size checks ensure correct array dimensions.

### 5. **Standardization & Noise Injection**

* **Standardization:** Each dataset is standardized by subtracting the mean and dividing by std. deviation (per antenna/subcarrier/time) over all samples.
* **Additive Noise:** 20dB SNR complex Gaussian noise is added to every standardized sample, modeling practical CSI measurement imperfections.

### 6. **Splitting & Saving**

* Samples are split into training (`train_csi`), validation (`val_csi`), and test (`test_csi`) sets.
* All variables and statistics are saved as `.mat` files (`D1_csi.mat`, ..., `D19_csi.mat`) with `-v7.3` for large data.

---

## File Structure

* `CSI_Dataset_Generator.m`: Main code (see above)
* `/quadriga_src/`: QuaDRiGa source code (you must have a local installation, see [QuaDRiGa](https://quadriga-channel-model.de/))
* `D*_csi.mat`: Output files for each dataset.

---

## Running the Code

1. **Requirements:**

   * MATLAB (2019b or newer recommended)
   * QuaDRiGa v2.8+ (see [QuaDRiGa downloads](https://quadriga-channel-model.de/))
   * Sufficient RAM and disk space for large datasets

2. **Setup:**

   * Update the `addpath` in the script to point to your QuaDRiGa source directory.

3. **Run:**

   ```matlab
   CSI_Dataset_Generator
   ```

4. **Monitor:**

   * Script prints detailed information for first samples of each dataset and every 1000th sample (dataset number, Rx positions, frequency, etc.)

5. **Outputs:**

   * `.mat` files: Each contains training, validation, test CSI tensors and normalization statistics.

---

## Helper Functions

### `getScenarioName(scenestr)`

Maps readable scenario strings (e.g. `'UMi+NLoS'`) to QuaDRiGa scenario codes (e.g. `'3GPP_38.901_UMi_NLOS'`).

---

## Example Output

For a single sample (debug printout):

```
[Dataset D11] Sample 1/12000
  fC = 4.90 GHz, K = 64, df = 90 kHz, T = 16, dt = 0.500 ms
  Init Rx position: [-119.02, 113.24, 1.50] (m), speed = 10.42 m/s, angle = 83.6 deg
  Rx positions at first three timesteps:
      -119.0200  113.2400    1.5000
      -118.9952  118.4578    1.5000
      -118.9704  123.6755    1.5000
  ... (16 total steps)
```

---

## Citation

If you use these scripts or datasets in your research, please cite [QuaDRiGa](https://quadriga-channel-model.de/).

---

## Acknowledgments

Developed by Anis Hamadouche and contributors.
See [QuaDRiGa](https://quadriga-channel-model.de/) for full channel model details.

---

**Feel free to fork, adapt, or open issues for clarification or new feature requests.**

---

Let me know if you want additional sections such as "How to extend this dataset to MIMO/multicell", a **FAQ**, or a "How to load and use the datasets in PyTorch"!

