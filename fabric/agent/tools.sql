-- Spark SQL helpers for the Agent (Lakehouse)

-- Latest alert per province x bug x drug x specimen
CREATE OR REPLACE VIEW alerts_latest AS
SELECT *
FROM (
  SELECT
    a.*,
    ROW_NUMBER() OVER (
      PARTITION BY province, organism, antibiotic, specimen
      ORDER BY year DESC
    ) AS rn
  FROM alerts a
)
WHERE rn = 1;

-- Latest threshold per bug x drug x specimen
CREATE OR REPLACE VIEW thresholds_latest AS
SELECT *
FROM (
  SELECT
    t.*,
    ROW_NUMBER() OVER (
      PARTITION BY organism, antibiotic, specimen
      ORDER BY year_ref DESC
    ) AS rn
  FROM thresholds t
)
WHERE rn = 1;

-- 3-year trend window per key (uses max-year within each key)
CREATE OR REPLACE VIEW alerts_trend_3yr AS
SELECT province, organism, antibiotic, specimen, year, pr_exceed_tau
FROM (
  SELECT
    a.*,
    MAX(year) OVER (PARTITION BY province, organism, antibiotic, specimen) AS y_max
  FROM alerts a
)
WHERE year >= y_max - 2;

-- Convenience passthroughs (so the Agent can SELECT with WHERE filters)
CREATE OR REPLACE VIEW v_alerts AS SELECT * FROM alerts;
CREATE OR REPLACE VIEW v_thresholds AS SELECT * FROM thresholds;
CREATE OR REPLACE VIEW v_isolates AS SELECT * FROM isolates;
