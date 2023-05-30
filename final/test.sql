-- Define the return format of table
CREATE TABLE public.test (
  id serial NOT NULL,
  name   varchar(200) NOT NULL CHECK (name <> ''),
  salary int,
  created  date,
  CONSTRAINT id PRIMARY KEY (id)
) WITH (
  OIDS = FALSE,
  autovacuum_enabled = true
);

-- Use self-defined format to display response content
CREATE OR REPLACE FUNCTION demo_report()
  RETURNS SETOF test
AS $$
  resp = []
  rv = plpy.execute("SELECT * FROM test")
  for i in rv:
    resp.append(i)
  return resp

$$ LANGUAGE 'plpython3u' VOLATILE;

SELECT * FROM demo_report();

-- Test of passing parameter in the python script
CREATE OR REPLACE FUNCTION url_quote (url text)
RETURNS TEXT
AS $$
  from urllib.parse import quote
  return quote(url)
$$
LANGUAGE 'plpython3u';

SELECT url_quote('https://www.postgresql.org/docs/12/plpython-data.html#id-1.8.11.11.3');

-- Test of numpy module
CREATE OR REPLACE FUNCTION np_test ()
RETURNS SETOF TEXT
AS $$
  import numpy as np
  x = np.array([[1, 2, 3], [4, 5, 6]], np.int32)
  return x
$$ LANGUAGE 'plpython3u';

SELECT np_test();

-- Test of pandas module
CREATE OR REPLACE FUNCTION pd_test()
  RETURNS TEXT
AS $$
  import pandas as pd
  a = 1
  return a
$$ LANGUAGE 'plpython3u';

SELECT pd_test();

-- Display plot using matplotlib (test)
CREATE OR REPLACE FUNCTION show()
RETURNS TEXT
AS $$
  import matplotlib.pyplot as plt
  import numpy as np

  # Fixing random state for reproducibility
  np.random.seed(19680801)

  plt.rcdefaults()
  fig, ax = plt.subplots()

  # Example data
  people = ('Tom', 'Dick', 'Harry', 'Slim', 'Jim')
  y_pos = np.arange(len(people))
  performance = 3 + 10 * np.random.rand(len(people))
  error = np.random.rand(len(people))

  ax.barh(y_pos, performance, xerr=error, align='center')
  ax.set_yticks(y_pos, labels=people)
  ax.invert_yaxis()  # labels read top-to-bottom
  ax.set_xlabel('Performance')
  ax.set_title('How fast do you want to go today?')

  plt.show()
$$ LANGUAGE 'plpython3u' VOLATILE;
