# %%
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy import text
from pathlib import Path
from sklearn import tree
from sklearn import metrics

# %%
db_path = Path(__file__).resolve().parent.parent / 'dados' / 'olist.db'
query_path = Path(__file__).resolve().parent.parent / 'stage2' / 'consulta_book_sellers.sql'

# %%
def import_query(path, **kwargs):
    with open(path, 'r', **kwargs) as file_open:
        return file_open.read()

def connect_db():
    return create_engine(f'sqlite:///{db_path}')

# %%
query = import_query(query_path)
query = query.format(date='2017-04-01')
engine = connect_db()

# %%
print(query)
# %%
