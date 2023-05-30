-- Return the python path your postgres used in this computer
CREATE OR REPLACE FUNCTION return_py_path()
  RETURNS VARCHAR
AS $$
  import sys
  return sys.path
$$ LANGUAGE plpython3u;

SELECT return_py_path();

-- Return the python version
CREATE OR REPLACE FUNCTION get_py()
  RETURNS VARCHAR
AS $$
  import os
  return os.popen('which python3').read()
$$ LANGUAGE plpython3u;

SELECT get_py();

-- Return the path in which the package installed (modify the module want to import and inspect in this script)
CREATE OR REPLACE FUNCTION pkg_path()
  RETURNS VARCHAR
AS $$
  from urllib.parse import quote
  import inspect
  path = inspect.getfile(pkg)
  return path
$$ LANGUAGE plpython3u;

SELECT pkg_path();
