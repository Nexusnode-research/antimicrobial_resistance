# Lakehouse Tables (Delta) — AMR Policy Alerts

> **Conventions**
>
> * Timestamps in UTC.
> * Strings are trimmed + stored in lowercase where noted.
> * Probabilities in **[0–1]**, percentages in **[0–100]** (explicit below).
> * Partitioning chosen for common time/province filters.

---

## 1) `isolates`

**Path:** `/Tables/isolates`
**Primary Key:** `(province, organism, antibiotic, specimen, sector, year)`
**Partitioned by:** `(year)`

| column            | type      | null | notes                                    |
| ----------------- | --------- | ---- | ---------------------------------------- |
| province          | string    | no   | SA province name                         |
| organism          | string    | no   | e.g., *E. coli*, *Klebsiella pneumoniae* |
| antibiotic        | string    | no   | e.g., Ciprofloxacin, Ceftriaxone         |
| specimen          | string    | no   | e.g., Blood                              |
| sector            | string    | no   | “Public” in sample set                   |
| year              | int       | no   | calendar year                            |
| n_tested          | int       | no   | number of isolates tested                |
| percent_resistant | double    | no   | **0–100** (%)                            |
| loaded_at         | timestamp | yes  | ingestion timestamp                      |

---

## 2) `thresholds`

**Path:** `/Tables/thresholds`
**Primary Key:** `(organism, antibiotic, specimen, year_ref)`
**Partitioned by:** `(year_ref)`
**Notes:** `specimen` may be **NULL** to indicate pooled thresholds.

| column     | type      | null | notes                                   |
| ---------- | --------- | ---- | --------------------------------------- |
| organism   | string    | no   |                                         |
| antibiotic | string    | no   |                                         |
| specimen   | string    | yes  | **NULL => pooled across specimen**      |
| year_ref   | int       | no   | year used to pick τ                     |
| tau        | double    | no   | threshold τ in **[0.10, 0.40]**         |
| method     | string    | no   | e.g., `"grid_search_latest_year"`       |
| meta_json  | string    | yes  | optional JSON: grid, scores, tie-breaks |
| loaded_at  | timestamp | yes  | ingestion timestamp                     |

---

## 3) `alerts` (model output)

**Path:** `/Tables/alerts`
**Primary Key:** `(province, organism, antibiotic, specimen, year)`
**Partitioned by:** `(year, province)`

| column          | type      | null | notes                                      |
| --------------- | --------- | ---- | ------------------------------------------ |
| province        | string    | no   |                                            |
| organism        | string    | no   |                                            |
| antibiotic      | string    | no   |                                            |
| specimen        | string    | no   |                                            |
| year            | int       | no   |                                            |
| theta_hat       | double    | no   | EB posterior mean                          |
| tau             | double    | no   | copied from thresholds                     |
| pr_exceed_tau   | double    | no   | **0–1** probability Pr(θ > τ)              |
| is_stable_alert | boolean   | no   | gate AND (persistence K≥2 OR slope ≥ 0.05) |
| impact_score    | double    | no   | `1000 * max(theta_hat - tau, 0)`           |
| reason          | string    | yes  | short text: which rule(s) triggered        |
| n_tested        | int       | no   | carried from isolates                      |
| loaded_at       | timestamp | yes  | ingestion timestamp                        |

---

## 4) `alerts_ai_summaries`

**Path:** `/Tables/alerts_ai_summaries`
**Primary Key:** `(row_key)`

> **row_key format (lowercase & trimmed parts):**
> `province|organism|antibiotic|specimen|year`

| column     | type          | null | notes                           |
| ---------- | ------------- | ---- | ------------------------------- |
| row_key    | string        | no   | join key to `alerts_with_brief` |
| title      | string        | yes  | one-line headline               |
| bullets    | array<string> | yes  | up to 3 bullet points           |
| sms        | string        | yes  | ≤160 chars                      |
| created_at | timestamp     | yes  | default now()                   |

> If some consumers can’t handle arrays, store an additional `bullets_json STRING`.

---

## Derived Views (for BI & agents)

### `thresholds_latest`

> Latest τ per (organism, antibiotic, specimen). Handles pooled (`specimen IS NULL`) upstream.

```sql
CREATE OR REPLACE VIEW thresholds_latest AS
SELECT *
FROM (
  SELECT t.*,
         ROW_NUMBER() OVER (
           PARTITION BY organism, antibiotic, specimen
           ORDER BY year_ref DESC
         ) rn
  FROM thresholds t
) s
WHERE rn = 1;
```

### `alerts_trend_3yr`

> Last 3 calendar years per (province, organism, antibiotic, specimen).

```sql
CREATE OR REPLACE VIEW alerts_trend_3yr AS
SELECT province, organism, antibiotic, specimen, year, pr_exceed_tau
FROM (
  SELECT a.*,
         MAX(year) OVER (PARTITION BY province, organism, antibiotic, specimen) AS y_max
  FROM alerts a
)
WHERE year >= y_max - 2;
```

### `alerts_with_brief`

> Join `alerts` to narrative summaries by normalized key.

```sql
CREATE OR REPLACE VIEW alerts_with_brief AS
WITH base AS (
  SELECT
    a.*,
    LOWER(CONCAT_WS('|',
      TRIM(province), TRIM(organism), TRIM(antibiotic), TRIM(specimen), CAST(year AS STRING)
    )) AS row_key
  FROM alerts a
)
SELECT b.*, s.title, s.bullets, s.sms
FROM base b
LEFT JOIN alerts_ai_summaries s
  USING (row_key);
```

---

## Notes & Guidance

* **Value ranges:**
  `pr_exceed_tau` in **[0–1]**; `percent_resistant` in **[0–100]**. Measures should convert explicitly if needed.
* **Nullability:**
  `thresholds.specimen` may be **NULL** for pooled rules; match logic in your pipelines accordingly.
* **Lineage fields:**
  `loaded_at`/`created_at` help audits & reprocessing.
* **Row-key hygiene:**
  Always generate with `LOWER(TRIM())` on each component to avoid join misses.
* **Performance:**
  The chosen partitioning supports your most common filters (time & province). Adjust if data grows substantially.

