
# AMR – Fabric Narrative AI Layer

## ▶️ Demo video (5 min)
https://youtu.be/ygPV1n7le-Q


This package builds a small AMR policy-signals lakehouse (Delta) with:

* Model outputs (**alerts**) aligned to thresholds (τ),
* Stability logic (Gate + Persistence/Slope),
* Optional narrative snippets joined by a deterministic row key,
* A ready-made Power BI report.

---

## 0) Repo layout (this folder)

```
fabric/
  agent/
    prompt.md            # System prompt for Narrative agent
    tools.sql            # CREATE VIEW scripts (alerts_with_brief, thresholds_latest, alerts_trend_3yr)
  data/
    sample/
      sample_amr.csv     # Mock isolates
  notebooks/
    01_ingest.ipynb      # Ingest + thresholds + alerts + (optional) AI summaries
  powerbi/
    AMR_Policy_Alerts.pbix  # Report connected to the lakehouse
  lakehouse_schema.md    # Canonical table + view contract
  README_fabric.md       # This file
```

---

## 1) Run order (Fabric)

1. **Create/Select a Lakehouse** in Microsoft Fabric (this project).

2. **Upload** the sample CSV to the lakehouse Files area (or keep as-is if you synced the repo):

   * `/files/fabric/data/sample/sample_amr.csv`

3. **Import & run** the notebook:

   * Open **`/fabric/notebooks/01_ingest.ipynb`**
   * Update any paths if needed (cell near the top).
   * Run all cells. The notebook will:

     * Write **`/Tables/isolates`** (Delta) from the CSV.
     * Derive **`/Tables/thresholds`** (τ grid search) and **`/Tables/alerts`** (EB θ̂, Pr(θ>τ), stability flags).
     * (Optional) Materialize **`/Tables/alerts_ai_summaries`** if you keep the AI section enabled.

4. **Create convenience views** for BI & the agent:

   * In the Lakehouse SQL endpoint (or “SQL analytics endpoint”), run the contents of
     **`/fabric/agent/tools.sql`** to create:

     * `thresholds_latest`
     * `alerts_trend_3yr`
     * `alerts_with_brief`

> Table/column contract is documented in **`lakehouse_schema.md`**.

---

## 2) Lakehouse Tables (Delta)

* **isolates**
  `(province, organism, antibiotic, specimen, sector, year, n_tested, percent_resistant)`

* **thresholds**
  `(organism, antibiotic, specimen [nullable for pooled], year_ref, tau, method, meta_json)`

* **alerts**
  `(province, organism, antibiotic, specimen, year, theta_hat, tau, pr_exceed_tau, is_stable_alert, impact_score, reason, n_tested)`

* **alerts_ai_summaries** *(optional)*
  `(row_key, title, bullets, sms, created_at)` where
  `row_key = lower(trim(province)) | lower(trim(organism)) | lower(trim(antibiotic)) | lower(trim(specimen)) | year`

**Derived views created by `tools.sql`:**

* `thresholds_latest` – latest τ per (organism, antibiotic, specimen)
* `alerts_trend_3yr` – rolling 3-year series for PrAlert
* `alerts_with_brief` – `alerts` joined to `alerts_ai_summaries` via `row_key`

---

## 3) Stability & impact (business rules)

* **Gate:** `pr_exceed_tau ≥ 0.80`
* **Persistence (K=2):** alert in at least **2 of the last 3 years**
* **Slope (3-yr):** linear slope of PrAlert **≥ 0.05**
* **Stable alert:** `Gate AND (Persistence OR Slope)`
* **Impact score:** `1000 * max(theta_hat - tau, 0)`

---

## 4) Power BI report

* Open **`/fabric/powerbi/AMR_Policy_Alerts.pbix`** in Power BI Desktop.
* Connect to your Fabric Lakehouse (same workspace).
* Validate visuals:

  * KPI cards: **GatePass %**, **Persistence K2 %**, **Slope Pass %**
  * Trends: national and by province
  * Matrix: organism × antibiotic breakdown with `PrAlert`, `StableAlerts`, `ImpactScore`
* Publish to the same Fabric workspace.

> If you change field names, refresh your model or update visual mappings accordingly.

---

## 5) Narrative Agent (optional)

* The agent uses **`/fabric/agent/prompt.md`** and queries only lakehouse views/tables:

  * `alerts`, `thresholds`, `thresholds_latest`, `alerts_trend_3yr`, `alerts_with_brief`
* It must **not** fabricate numbers; it returns fields from `alerts` plus `title/bullets/sms` where available.

---

## 6) Paths & defaults

* Sample CSV: `/files/fabric/data/sample/sample_amr.csv`
* Tables written under: `/Tables/*` (Delta)
* Views created in Lakehouse SQL endpoint by `agent/tools.sql`

---

## 7) Troubleshooting

* **Nothing in visuals?** Ensure `01_ingest.ipynb` finished and tables exist; refresh the Power BI model.
* **Row-key joins missing narratives?** Check that `row_key` parts are lower-cased & trimmed in both `alerts_with_brief` and `alerts_ai_summaries`.
* **Measures off by a factor of 100?** Remember: `pr_exceed_tau` is **0–1**; `percent_resistant` is **0–100**.


