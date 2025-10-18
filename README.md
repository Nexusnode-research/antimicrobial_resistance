```markdown
# Antimicrobial Resistance (AMR) — Threshold-Aligned Policy Signals

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17384867.svg)](https://doi.org/10.5281/zenodo.17384867)

Empirical-Bayes (EB) pipeline that converts routine antibiograms into stable, threshold-aligned policy alerts per province, organism, drug, and year.

---

## Repository

```

docker/              # Micromamba + JupyterLab image
docker-compose.yml   # runs Jupyter, mounts repo at /workspace
notebooks/AMR.ipynb  # main analysis
src/                 # helpers
outputs/             # generated at runtime

````

---

## Quickstart

```bash
docker compose up --build
# open http://localhost:8888 and run notebooks/AMR.ipynb
````

Outputs are written to:

```
outputs/tables/
  scores_eb.csv
  stability_flags.csv
  change_list.csv
  change_list_clean.csv
  change_list_actionable.csv
outputs/figures/
```

---

## Data access

Raw NICD/NHLS data are not redistributed in this repository.

To reproduce:

1. Obtain NICD/NHLS public-sector antibiogram extracts for 2021–2024 under their terms.
2. Save as `data/raw/amr_nicd_2021_2024.csv`.
3. Required columns (long format):

```
province, organism, antibiotic, specimen, sector, year, percent_resistant, n_tested
```

4. Optional for maps: `data/raw/provinces.geojson`.

---

## Method

* EB Beta–Binomial pooling with Bayes–Laplace pseudo-counts (+1.0).
* Decision quantity: exceedance probability (P(\theta>\tau)).
* Thresholds ( \tau ): per-syndrome grid search over [0.10, 0.40] against target tolerance in the latest year.
* Stability rule: current-year gate (P(\theta>\tau)\ge 0.80) and (K=2 persistence or 3-year positive slope of (P(\theta>\tau))).
* Impact: excess failures per 1,000 tests (= 1000 \times \max(\hat{\theta}-\tau, 0)).

**Key parameters**

```
P_STAR = 0.80
K_CONS = 2
SLOPE_WINDOW = 3
SLOPE_MIN = 0.05
```

---

## Citation

**Code:** Nexusnode-research (2025). AMR EB pipeline (code only). Zenodo. [https://doi.org/10.5281/zenodo.17384867](https://doi.org/10.5281/zenodo.17384867)

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

---

## License

Code: MIT.
Data: follow NICD/NHLS terms.

```
::contentReference[oaicite:0]{index=0}
```
