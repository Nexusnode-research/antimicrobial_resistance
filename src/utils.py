from dataclasses import dataclass
import pandas as pd

@dataclass
class MismatchParams:
    threshold_pct: float = 20.0

def compute_mismatch(df: pd.DataFrame, params: MismatchParams = MismatchParams()) -> pd.DataFrame:
    out = df.copy()
    out["resistance_pct"] = pd.to_numeric(out["resistance_pct"], errors="coerce")
    out["mismatch_index"] = (out["resistance_pct"] - float(params.threshold_pct)).clip(lower=0)
    out["flag"] = (out["mismatch_index"] > 0).map({True: "review", False: "ok"})
    return out

def top_n_mismatches(df: pd.DataFrame, n: int = 10) -> pd.DataFrame:
    return df.sort_values("mismatch_index", ascending=False).head(n).reset_index(drop=True)
