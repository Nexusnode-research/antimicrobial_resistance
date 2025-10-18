````markdown
# Antimicrobial Resistance (AMR) — Threshold-Aligned Policy Signals

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17384867.svg)](https://doi.org/10.5281/zenodo.17384867)

Empirical-Bayes pipeline that turns routine antibiograms into stable, threshold-aligned policy alerts per province, organism, drug, and year.

## Repository

- `docker/` — Micromamba + JupyterLab image  
- `docker-compose.yml` — runs Jupyter, mounts repo at `/workspace`  
- `notebooks/AMR.ipynb` — main analysis notebook  
- `src/` — helpers  
- `outputs/` — generated at runtime (not committed)

## Quickstart

```bash
docker compose up --build
````

Open [http://localhost:8888](http://localhost:8888) and run **notebooks/AMR.ipynb**.

## Outputs

* `outputs/tables/scores_eb.csv`
* `outputs/tables/stability_flags.csv`
* `outputs/tables/change_list.csv`
* `outputs/tables/change_list_clean.csv`
* `outputs/tables/change_list_actionable.csv`
* `outputs/figures/` (plots, maps)

## Data access

Raw NICD/NHLS data are not redistributed in this repository.

To reproduce:

1. Obtain NICD/NHLS public-sector antibiogram extracts for 2021–2024 under their terms.
2. Save as `data/raw/amr_nicd_2021_2024.csv`.
3. Required columns (long format): `province, organism, antibiotic, specimen, sector, year, percent_resistant, n_tested`
4. Optional for maps: `data/raw/provinces.geojson`.

## Method

* EB Beta–Binomial pooling with Bayes–Laplace pseudo-counts (+1.0).
* Decision quantity: `P(theta > tau)` (exceedance probability).
* Thresholds (`tau`): per-syndrome grid search over `[0.10, 0.40]` against target tolerance in the latest year.
* Stability: current-year gate `P(theta > tau) >= 0.80` and (`K=2` persistence or 3-year positive slope of `P(theta > tau)`).
* Impact: excess failures per 1,000 tests `= 1000 * max(theta_hat - tau, 0)`.

**Key parameters**

```
P_STAR = 0.80
K_CONS = 2
SLOPE_WINDOW = 3
SLOPE_MIN = 0.05
```

## Citation

Code: Nexusnode-research (2025). AMR EB pipeline (code only). Zenodo. [https://doi.org/10.5281/zenodo.17384867](https://doi.org/10.5281/zenodo.17384867)

**BibTeX**

```bibtex
@software{amr_code_2025,
  title   = {AMR EB pipeline (code only)},
  author  = {Nexusnode-research},
  year    = {2025},
  doi     = {10.5281/zenodo.17384867},
  url     = {https://doi.org/10.5281/zenodo.17384867}
}
```

## License

Code: MIT
Data: follow NICD/NHLS terms.

```
::contentReference[oaicite:0]{index=0}
```
