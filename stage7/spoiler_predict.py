# %% Imports
from pathlib import Path
from sqlalchemy import create_engine
import pandas as pd
from sklearn import model_selection
from sklearn import preprocessing
from sklearn import tree
from sklearn import metrics 

# Definindo caminho e abrindo conexão com o banco de dados SQLite
database_path = Path(__file__).resolve().parents[1] / 'dados' / 'olist.db'
models_path = Path(__file__).resolve().parent/'models'

engine = create_engine(f'sqlite:///{database_path}')

# %%
query = '''
SELECT * FROM tb_book_sellers WHERE dt_ref = '2018-06-01'
'''

data = pd.read_sql_query(query, engine)
model = pd.read_pickle(models_path/'arvore_de_decisao.pkl')
print(model)

# %%
# model['encoder']
df_encoder = pd.DataFrame(
   model['encoder'].transform(data[model['cat_features']]),
   columns=model['encoder'].get_feature_names_out(model['cat_features'])
)

# %%
