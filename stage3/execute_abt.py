from sqlalchemy import create_engine
from sqlalchemy import text
from pathlib import Path

DATA_PATH = Path(__file__).resolve().parents[1]/'dados'/'olist.db'
QUERY_FILE = Path(__file__).resolve().parents[1]/'stage3'/'criacao_abt.sql'
# print(QUERY_FILE)

engine = create_engine(f'sqlite:///{DATA_PATH}')

with open(QUERY_FILE, 'r') as file:
   query = file.read()

with engine.connect() as conn:
    for i in query.split(';')[:-1]:
        conn.execute(text(i))
    conn.commit()