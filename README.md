# Antimicrobial Resistance (AMR) - Threshold-Aligned Policy Signals

[](https://www.google.com/url?sa=E&source=gmail&q=https://doi.org/10.5281/zenodo.17384867)

This repository contains the full, reproducible analytical pipeline that converts routine antimicrobial surveillance data into stable, threshold-aligned policy alerts per province. The methodology and results are detailed in the accompanying paper, "Stable, Threshold-Aligned AMR Policy Signals from Routine Surveillance."

-----

## 📂 Repository Structure

```
.
├── docker/
│   └── Dockerfile             # Micromamba + JupyterLab Image
├── notebooks/
│   └── AMR.ipynb              # Main analysis notebook
├── Paper/
│   └── AMR.pdf                # Research paper PDF
├── outputs/                   # Generated artifacts (not committed)
│   ├── figures/
│   └── tables/
├── data/                      # Raw input data (not committed)
│   └── raw/
└── src/
    └── ...                    # Utility scripts (if any)
.gitignore
README.md
docker-compose.yml             # Docker service definition
```

-----

## 🔬 Methodology Overview

The pipeline transforms raw antibiogram data into actionable insights through a deterministic, closed-form process without MCMC.

1.  **Data Ingestion:** Reads and cleans raw provincial AMR CSVs from NICD for 2021-2024.
2.  **Empirical-Bayes (EB) Shrinkage:** Fits a Beta-Binomial model using a **Bayes-Laplace prior** (+1.0 pseudo-counts) to stabilize resistance estimates ($\hat{\theta}$), borrowing strength from national totals.
3.  **Adaptive Thresholds ($\tau$):** For each syndrome (e.g., UTI), it learns an optimal resistance threshold by performing a grid search over $\tau \in [0.10, 0.40]$ in the latest year. The chosen $\tau$ is the one that minimizes the absolute difference between a clinical target and the mean resistance of all provinces exceeding that $\tau$.
4.  **Stability & Impact:** A province is flagged with a **stable alert** if it meets a current-year gate ($Pr(\theta > \tau) \ge 0.80$) and either a **persistence rule** (K=2 consecutive years above the gate) or a **positive trend rule** (3-year slope of $Pr(\theta > \tau) \ge 0.05$). Alerts are then ranked by an **impact score**: $1000 \cdot \max(\hat{\theta} - \tau, 0)$.

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

  * `scores_eb.csv`: Contains the detailed Empirical-Bayes estimates ($\hat{\theta}$), credible intervals, and exceedance probabilities ($Pr(\theta > \tau)$) for each province-year.
  * `stability_flags.csv`: Shows the results of the stability analysis, including the persistence and slope rule flags.
  * `change_list_actionable.csv`: The final, ranked list of provinces with stable, high-impact resistance alerts, ready for stewardship review.
  * `adaptive_thresholds.json`: The learned $\tau$ value for each clinical syndrome.

-----

## 📥 Data Access and Reproduction

The raw NICD/NHLS data is not redistributed in this repository. To reproduce the analysis, you must:

1.  Obtain the public-sector antibiogram extracts for 2021-2024 under their terms.
2.  Save the data as CSV files in the `data/raw/nicd/` directory (e.g., `amr_nicd_2021.csv`).
3.  Ensure the files have columns for `province`, `organism`, `antibiotic`, `specimen`, `sector`, `year`, `percent_resistant`, and `n_tested`.
4.  The `data/raw/provinces.geojson` file for mapping is optional and only used for visualization cells.

-----

## 🔧 Key Parameters

These parameters are defined in the `AMR.ipynb` notebook and can be adjusted for sensitivity analysis:

  * **`P_STAR = 0.80`**: The exceedance probability cutoff for the stability rules.
  * **`K_CONS = 2`**: The number of consecutive years required for the persistence rule.
  * **`SLOPE_WINDOW = 3`**: The number of years for the rolling slope calculation.
  * **`SLOPE_MIN = 0.05`**: The minimum positive slope on $Pr(\theta > \tau)$ to trigger the trend rule.
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
