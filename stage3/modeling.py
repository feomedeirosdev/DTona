import pandas as pd
from sqlalchemy import text
from sqlalchemy import create_engine
from pathlib import Path

DATA_PATH = Path(__file__).resolve().parents[1]/'dados'/'olist.db'

engine = create_engine(f'sqlite:///{DATA_PATH}')

df_abt = pd.read_sql('tb_abt_churn', engine)

print(df_abt.groupby(['seller_state'])['flag_churn'].mean())