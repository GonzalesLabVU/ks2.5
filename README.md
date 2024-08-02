# KS2.5

Custom KS2.5 for within-lab use.

## Getting started

This repository cloned [Kilosort-2.5](https://github.com/MouseLand/Kilosort/tree/v2.5) under [KS2.5/External/Kilosort-2.5](https://github.com/zhengyangwang/KS2.5/tree/main/External/Kilosort-2.5). 
Check [here](https://github.com/zhengyangwang/KS2.5/tree/main/External/Kilosort-2.5) for required MATLAB Toolboxes.

Install [Anaconda/Miniconda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html).

Install the python package [phy2](https://github.com/cortex-lab/phy#installation-instructions) inside a [conda environment](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#) following the instructions.

Edit the following line in [start_phy.bat](https://github.com/zhengyangwang/KS2.5/blob/main/start_phy.bat) to the correct `conda.bat` folder and environment name.
https://github.com/zhengyangwang/KS2.5/blob/c8ea5062da5fe8ec0d47556f97f1ec6d8511410d/start_phy.bat#L2

There are precompiled CUDA files under [KS2.5/External/Kilosort-2.5/CUDA](https://github.com/zhengyangwang/KS2.5/tree/main/External/Kilosort-2.5/CUDA). 
In case of CUDA error, re-compile for your platform:
When in root directory,
```
cd External/Kilosort-2.5/CUDA
mexGPUall.m
```

## Running the pipeline

1. Create the following folders on a local SSD:`Open Ephys`, `beh`, `KS_out` and `raw_LFP`.
2. Copy Open Ephys recording sessions (e.g. `PIC100`) into `Open Ephys`, and behavior MATLAB files (e.g. `PIC100_1.mat`) in to `beh`.
3. In `start_ks_pipeline.m`: point `daq_dir` to the `Open Ephys` folder, `beh_dir` to the `beh` folder, `ks_dir` to the `KS_out` folder and `raw_lfp_dir` to the `raw_LFP` folder; specify `subject_identifier` as e.g., `{'OLI', 'ROS'}` and `session_range` as e.g., `{90:100, 41:50}`.
4. Run `start_ks_pipeline.m`.
5. Run the following in command line on each kilosort output folder to start a phy2 sessions:
   ```
   start_phy F:\Database\VanderbiltDAQ\KS_out\OLI\OLI136_2024-08-01_13-08-45\1\kilosort3
   ```
   For each sessions, [Label](https://phy.readthedocs.io/en/latest/shortcuts/) any clusters that have unlikely waveforms as [`noise`](https://phy.readthedocs.io/en/latest/sorting_user_guide/#glossary), and the rest as `good`. Save and exit the phy interface after all clusters are labeled.
6. Edit `gen_all_template.m` to generate sparse and single unit files for ranges of subject and sessions intended.
