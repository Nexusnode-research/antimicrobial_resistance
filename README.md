
# Antimicrobial Resistance (AMR) – Threshold-Aligned Policy Signals

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17384867.svg)](https://doi.org/10.5281/zenodo.17384867)

This repository contains the full, reproducible analytical pipeline that converts routine antimicrobial surveillance data into stable, threshold-aligned policy alerts per province. The methodology and results are detailed in the accompanying paper: [`Paper/AMR.pdf`](Paper/AMR.pdf).

## ▶️ Demo Video (5 min)
[![Watch the demo](https://img.youtube.com/vi/ygPV1n7le-Q/hqdefault.jpg)](https://youtu.be/ygPV1n7le-Q)

> **Note:** This `main` branch is the local Docker implementation. A Microsoft Fabric (Lakehouse + Power BI) implementation lives on the `fabric-narrative-ai` branch (`fabric/README_fabric.md`).

---

## 📂 Repository Structure

```

.
├── Paper/
│   └── AMR.pdf                 # Research paper PDF
├── docker/
│   └── Dockerfile              # Micromamba + JupyterLab image
├── notebooks/
│   └── AMR.ipynb               # Main analysis notebook
├── src/                        # Utility scripts
├── outputs/                    # Generated artifacts (not committed)
│   ├── figures/
│   └── tables/
├── data/                       # Raw inputs (not committed)
│   └── raw/
│       └── nicd/
│           └── _incoming/      # Drop per-file CSVs here
├── .gitignore
├── README.md
└── docker-compose.yml          # Docker service definition

````

---

## 🔬 Methodology Overview

Deterministic, closed-form workflow (no MCMC):

1. **Data ingestion** — Reads individual NICD public-sector antibiogram CSVs (2021–2024) from `data/raw/nicd/_incoming/` and builds a single master table for analysis.
2. **Empirical-Bayes (EB) shrinkage** — Beta–Binomial with **Bayes–Laplace prior** (+1.0 pseudo-counts) to stabilize provincial estimates, borrowing strength from national totals.
3. **Adaptive thresholds (τ)** — Per-syndrome grid search over τ ∈ [0.10, 0.40] using the latest year to align with a clinical failure tolerance.
4. **Stability & impact** — **Gate AND (Persistence OR Slope)**: Gate is Pr(θ>τ) ≥ 0.80 in the current year; Persistence is K=2 (this year **and** last year); Slope is a positive 3-year trend of Pr(θ>τ) ≥ 0.05. Rank by **impact**: 1000·max(θ̂ − τ, 0).

---

## ⚙️ Implementations (by Branch)
This pipeline has two fully functional implementations with identical logic, separated by branch.

### 🚀 Quick Start (Local Docker — `main` branch)
You are currently on the `main` branch, which runs the analysis locally using Docker.

1. **Prepare data** — see the section below.  
2. **Build & run**
   ```bash
   docker compose up --build
   ```
3. **Execute** — open the URL printed in the terminal (usually `http://localhost:8888`) and run the notebook: `notebooks/AMR.ipynb`. Outputs will appear under `outputs/`.

### ☁️ Microsoft Fabric (Lakehouse — `fabric-narrative-ai` branch)
A separate, enterprise-scale implementation of this pipeline is available on the `fabric-narrative-ai` branch. It mirrors the exact same logic using a modern Lakehouse, SQL Views, and Power BI.

**To view the Fabric implementation, switch to that branch:**
```bash
git checkout fabric-narrative-ai
```

The `fabric/` directory on that branch contains the dedicated assets:

- `fabric/README_fabric.md` — Setup guide  
- `fabric/notebooks/01_ingest.ipynb` — Data ingest  
- `fabric/agent/tools.sql` — SQL analytic views  
- `fabric/powerbi/AMR Policy Alerts.pbix` — BI report

---

## 🚀 Quick Start

1) **Prepare data** — see the Data Access section below.  
2) **Build & run**
```bash
docker compose up --build
````

3. **Execute** — open the URL printed in the terminal (usually [http://localhost:8888](http://localhost:8888)) and run the notebook: [`notebooks/AMR.ipynb`](notebooks/AMR.ipynb). Outputs will appear under `outputs/`.

---

## 📊 Outputs

Written to `outputs/tables/`:

* `scores_eb.csv` — EB estimates (θ̂), credible intervals, exceedance probabilities Pr(θ>τ)
* `stability_flags.csv` — results of persistence + slope checks
* `change_list.csv` — all candidate changes
* `change_list_clean.csv` — deduplicated/clean list
* `change_list_actionable.csv` — final ranked list for stewardship
* `adaptive_thresholds.json` — learned τ per clinical syndrome

---

## 📥 Data Access & Reproduction

We **do not** redistribute NICD/NHLS raw data.

1. Obtain the NICD/NHLS public-sector antibiogram extracts for **2021–2024** under their terms.
2. Place the CSV files in `data/raw/nicd/_incoming/` (e.g., `nicd_ecoli_ciprofloxacin_2021.csv`, …).
3. Required columns (long format): `province, organism, antibiotic, specimen, sector, year, percent_resistant, n_tested`.
4. Optional for maps: `data/raw/provinces.geojson`.

---

## 🔧 Key Parameters

* `P_STAR = 0.80` — exceedance cutoff for the current-year gate
* `K_CONS = 2` — years required for persistence
* `SLOPE_WINDOW = 3` — window for the probability slope check
* `SLOPE_MIN = 0.05` — minimum positive slope of Pr(θ>τ)
* `N_MIN = 30` — minimum isolates for inclusion in visuals and the actionable list

---

## 📜 Citation

If you use this code or methodology, please cite:

```bibtex
@software{nexusnode-research_amr_eb_pipeline_2025,
  author    = {Nexusnode Research},
  title     = {AMR EB pipeline (code only)},
  year      = {2025},
  publisher = {Zenodo},
  version   = {1.0.0},
  doi       = {10.5281/zenodo.17384867},
  url       = {https://doi.org/10.5281/zenodo.17384867}
}
```

---

## ⚖️ License

* **Code:** MIT
* **Data:** Subject to NICD/NHLS terms (no redistribution here).


