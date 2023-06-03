-- This would run very long time
CREATE OR REPLACE FUNCTION autofj()
RETURNS TEXT
AS $$
  from autofj.datasets import load_data
  from autofj import AutoFJ
  left_table, right_table, gt_table = load_data("TennisTournament")
  fj = AutoFJ(precision_target=0.9)
  result = fj.join(left_table, right_table, "id")
  return result
$$ LANGUAGE plpython3u;

SELECT autofj();
