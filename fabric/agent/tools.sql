-- GET_ALERTS_WITH_BRIEF
CREATE OR REPLACE VIEW alerts_with_brief AS
WITH base AS (
  SELECT
      a.*,
      -- portable null-safe row_key
      CONCAT(
        COALESCE(a.province, ''), '|',
        COALESCE(a.organism, ''), '|',
        COALESCE(a.antibiotic, ''), '|',
        COALESCE(a.specimen, ''), '|',
        CAST(a.year AS STRING)
      ) AS row_key
  FROM alerts a
)
SELECT b.*, s.title, s.bullets, s.sms
FROM base b
LEFT JOIN alerts_ai_summaries s USING (row_key);

-- Latest thresholds (per organism, antibiotic, specimen)
CREATE OR REPLACE VIEW thresholds_latest AS
SELECT *
FROM (
  SELECT
    t.*,
    ROW_NUMBER() OVER (
      PARTITION BY organism, antibiotic, specimen
      ORDER BY tau_year DESC
    ) AS rn
  FROM thresholds t
) AS ranked
WHERE rn = 1;

-- Last 3 years trend per province/organism/antibiotic/specimen
CREATE OR REPLACE VIEW alerts_trend_3yr AS
SELECT province, organism, antibiotic, specimen, year, pr_exceed_tau
FROM (
  SELECT
    a.*,
    MAX(year) OVER (
      PARTITION BY province, organism, antibiotic, specimen
    ) AS y_max
  FROM alerts a
) AS w
WHERE year >= y_max - 2;
