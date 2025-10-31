# AMR – Fabric Narrative AI Layer

## Run order (Fabric)
1) Import **/fabric/notebooks/01_ingest.ipynb** and run → writes Delta table **isolates** from `/files/fabric/data/sample/sample_amr.csv`.
2) Run **02_eb_thresholds.ipynb** → writes **thresholds** and **alerts** (EB shrinkage, τ grid search, stability flags).
3) Run **03_narrative_ai_demo.ipynb** → writes **alerts_ai_summaries** (AI Function).

## Lakehouse tables
- `isolates(province, organism, antibiotic, specimen, sector, year, n_tested, percent_resistant)`
- `thresholds(key_cols…, tau, method, year_ref)`
- `alerts(key_cols…, theta_hat, pr_exceed_tau, is_stable_alert, impact_score, reason, year)`
- `alerts_ai_summaries(row_key, title, bullets, sms)`

## Notes
- Sample CSV lives here: `/files/fabric/data/sample/sample_amr.csv`
- Stability rule: gate `pr_exceed_tau ≥ 0.80` **AND** (persistence K=2 **OR** 3-yr slope ≥ 0.05).
- Impact: `1000 * max(theta_hat - tau, 0)`.
