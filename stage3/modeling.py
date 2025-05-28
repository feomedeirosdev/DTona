
import pandas as pd
from sqlalchemy import create_engine
from pathlib import Path

DATA_PATH = Path(__file__).resolve().parents[1]/'dados'/'olist.db'
DATA_PATH

engine = create_engine(f'sqlite:///{DATA_PATH}')

abt = pd.read_sql('tb_abt_churn', engine)
