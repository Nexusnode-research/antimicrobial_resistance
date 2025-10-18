# Antimicrobial Resistance (AMR) - Threshold-Aligned Policy Signals

[](https://www.google.com/url?sa=E&source=gmail&q=https://doi.org/10.5281/zenodo.17384867)

This repository contains the full, reproducible analytical pipeline that converts routine antimicrobial surveillance data into stable, threshold-aligned policy alerts per province. The methodology and results are detailed in the accompanying paper, "Stable, Threshold-Aligned AMR Policy Signals from Routine Surveillance."

-----

## 📂 Repository Structure

```
.
├── docker/
│   ├── Dockerfile             # Micromamba + JupyterLab Image
│   └── docker-compose.yml     # Service to run Jupyter & mount repo
├── notebooks/
│   └── AMR.ipynb              # Main analysis notebook
├── outputs/
│   ├── figures/               # Generated plots
│   └── tables/                # Generated CSVs and parameters
├── data/
│   ├── raw/                   # For raw NICD CSVs and geojson
│   └── ...
└── src/
    └── ...                    # Utility scripts (if any)
```

-----

## 🔬 Methodology Overview

[cite\_start]The pipeline transforms raw antibiogram data into actionable insights through a deterministic, closed-form process without MCMC[cite: 10, 28, 34, 111, 180, 159].

1.  [cite\_start]**Data Ingestion:** Reads and cleans raw provincial AMR CSVs from NICD for 2021-2024[cite: 39, 41, 46, 47].
2.  [cite\_start]**Empirical-Bayes (EB) Shrinkage:** Fits a Beta-Binomial model using a **Bayes-Laplace prior** (+1.0 pseudo-counts) to stabilize resistance estimates ($\hat{\theta}$), borrowing strength from national totals[cite: 6, 28, 54, 56, 150].
3.  **Adaptive Thresholds ($\tau$):** For each syndrome (e.g., UTI), it learns an optimal resistance threshold by performing a grid search over $\tau \in [0.10, 0.40]$ in the latest year. [cite\_start]The chosen $\tau$ is the one that minimizes the absolute difference between a clinical target and the mean resistance of all provinces exceeding that $\tau$[cite: 50].
4.  [cite\_start]**Stability & Impact:** A province is flagged with a **stable alert** if it meets a current-year gate ($Pr(\theta > \tau) \ge 0.80$) and either a **persistence rule** (K=2 consecutive years above the gate) or a **positive trend rule** (3-year slope of $Pr(\theta > \tau) \ge 0.05$)[cite: 8, 32, 66, 67, 68, 144]. [cite\_start]Alerts are then ranked by an **impact score**: $1000 \cdot \max(\hat{\theta} - \tau, 0)$[cite: 9, 33, 71, 146].

-----

## 🚀 Quick Start

This project is containerized using Docker for full reproducibility.

1.  **Prepare Data:**
    Follow the instructions in the **Data Access** section below to download and place the necessary NICD files in the `data/raw/nicd/` directory.

2.  **Build and Run the Container:**
    From the root directory of this repository, run:

    ```bash
    docker compose up --build
    ```

3.  **Execute the Analysis:**
    Open the URL provided in your terminal (usually `http://localhost:8888`) and run the `notebooks/AMR.ipynb` notebook from start to finish. All outputs will be generated in the `outputs/` directory.

-----

## 📊 Outputs

The primary outputs of the pipeline are generated in the `outputs/tables/` directory:

  * [cite\_start]`scores_eb.csv`: Contains the detailed Empirical-Bayes estimates ($\hat{\theta}$), credible intervals, and exceedance probabilities ($Pr(\theta > \tau)$) for each province-year[cite: 10, 75, 106].
  * [cite\_start]`stability_flags.csv`: Shows the results of the stability analysis, including the persistence and slope rule flags[cite: 10, 75, 107].
  * [cite\_start]`change_list_actionable.csv`: The final, ranked list of provinces with stable, high-impact resistance alerts, ready for stewardship review[cite: 10, 75, 108].
  * [cite\_start]`adaptive_thresholds.json`: The learned $\tau$ value for each clinical syndrome[cite: 75].

-----

## 📥 Data Access and Reproduction

The raw NICD/NHLS data is not redistributed in this repository. To reproduce the analysis, you must:

1.  [cite\_start]Obtain the public-sector antibiogram extracts for 2021-2024 under their terms[cite: 39, 40].
2.  Save the data as CSV files in the `data/raw/nicd/` directory (e.g., `amr_nicd_2021.csv`).
3.  [cite\_start]Ensure the files have columns for `province`, `organism`, `antibiotic`, `specimen`, `sector`, `year`, `percent_resistant`, and `n_tested`[cite: 41, 44].
4.  The `data/raw/provinces.geojson` file for mapping is optional and only used for visualization cells.

-----

## 🔧 Key Parameters

[cite\_start]These parameters are defined in the `AMR.ipynb` notebook and can be adjusted for sensitivity analysis[cite: 160]:

  * [cite\_start]**`P_STAR = 0.80`**: The exceedance probability cutoff for the stability rules[cite: 8].
  * [cite\_start]**`K_CONS = 2`**: The number of consecutive years required for the persistence rule[cite: 8, 32, 67].
  * [cite\_start]**`SLOPE_WINDOW = 3`**: The number of years for the rolling slope calculation[cite: 8, 32, 68, 144].
  * [cite\_start]**`SLOPE_MIN = 0.05`**: The minimum positive slope on $Pr(\theta > \tau)$ to trigger the trend rule[cite: 68].
  * **`N_MIN = 30`**: The minimum number of tests required for a province to be included in the final actionable list.

-----

## 📜 Citation

If you use this code or methodology in your research, please cite:

```bibtex
@software{nexusnode-research_amr_eb_pipeline_2025,
  author       = {NexusNode Research},
  title        = {{AMR EB pipeline (code only)}},
  month        = oct,
  year         = 2025,
  publisher    = {Zenodo},
  version      = {1.0.0},
  doi          = {10.5281/zenodo.17384867},
  url          = {https://doi.org/10.5281/zenodo.17384867}
}
```

-----

## ⚖️ License

  * **Code:** MIT License
  * **Data:** Data follows the terms of the original provider (NICD/NHLS).
