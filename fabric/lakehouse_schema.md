# Lakehouse Tables (Delta)

## 1) isolates
**Path:** /Tables/isolates  
**PK:** (province, organism, antibiotic, specimen, sector, year)

| column            | type   | notes                               |
|-------------------|--------|-------------------------------------|
| province          | string | SA province name                    |
| organism          | string | e.g., E. coli, Klebsiella pneumoniae|
| antibiotic        | string | e.g., Ciprofloxacin, Ceftriaxone    |
| specimen          | string | e.g., Blood                         |
| sector            | string | "Public" for sample data            |
| year              | int    | calendar year                       |
| n_tested          | int    | number of isolates tested           |
| percent_resistant | double | 0–100                               |

---

## 2) thresholds
**Path:** /Tables/thresholds  
**PK:** (organism, antibiotic, specimen, year_ref)

| column     | type   | notes                                 |
|------------|--------|---------------------------------------|
| organism   | string |                                       |
| antibiotic | string |                                       |
| specimen   | string | optional; null = pooled across specimen |
| year_ref   | int    | year used to pick τ                   |
| tau        | double | chosen threshold in [0.10, 0.40]      |
| method     | string | "grid_search_latest_year"             |
| meta_json  | string | JSON: grid, scores, tie-breaks (opt)  |

---

## 3) alerts
**Path:** /Tables/alerts  
**PK:** (province, organism, antibiotic, specimen, year)

| column          | type    | notes                                                         |
|-----------------|---------|---------------------------------------------------------------|
| province        | string  |                                                               |
| organism        | string  |                                                               |
| antibiotic      | string  |                                                               |
| specimen        | string  |                                                               |
| year            | int     |                                                               |
| theta_hat       | double  | EB posterior mean                                             |
| tau             | double  | from thresholds                                               |
| pr_exceed_tau   | double  | Pr(θ > τ)                                                     |
| is_stable_alert | boolean | gate AND (persistence K>=2 OR slope >= 0.05)                  |
| impact_score    | double  | 1000 * max(theta_hat - tau, 0)                                |
| reason          | string  | short text: which rule(s) triggered                           |
| n_tested        | int     | carried from isolates                                         |

---

## 4) alerts_ai_summaries
**Path:** /Tables/alerts_ai_summaries  
**PK:** (row_key)

| column     | type          | notes                                                       |
|------------|---------------|-------------------------------------------------------------|
| row_key    | string        | province\|organism\|antibiotic\|specimen\|year              |
| title      | string        | one-line headline                                           |
| bullets    | array<string> | 3 bullet points                                             |
| sms        | string        | ≤160 chars                                                  |
| created_at | timestamp     | default now()                                               |
