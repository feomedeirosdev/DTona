# %%
# Importando pacotes
from pathlib import Path
from sqlalchemy import create_engine
import pandas as pd
from sklearn.cluster import AgglomerativeClustering
import matplotlib.pyplot as plt
import seaborn
from sklearn import tree

# %%
# Criando conexão e importando dados
olist_db_path = Path(__file__).resolve().parents[1]/'dados'/'olist.db'
get_abt_file = Path(__file__).resolve().parents[1]/'stage11_clusters'/'get_abt.sql'
engine = create_engine(f'sqlite:///{olist_db_path}')

with open(get_abt_file, 'r') as file:
   query = file.read()

df = pd.read_sql(query, engine)
pd.set_option('display.max_columns', 100)

# %% Criando variáveis
categories = [
   'cat_cama_mesa_banho_qt',
   'cat_beleza_saude_qt',
   'cat_esporte_lazer_qt',
   'cat_moveis_decoracao_qt',
   'cat_informatica_acessorios_qt',
   'cat_utilidades_domesticas_qt',
   'cat_relogios_presentes_qt',
   'cat_telefonia_qt',
   'cat_ferramentas_jardim_qt',
   'cat_automotivo_qt',
   'cat_brinquedos_qt',
   'cat_cool_stuff_qt',
   'cat_perfumaria_qt',
   'cat_bebes_qt',
   'cat_eletronicos_qt',
   'cat_papelaria_qt',
   'cat_fashion_bolsas_e_acessorios_qt',
   'cat_pet_shop_qt',
   'cat_moveis_escritorio_qt',
   'cat_consoles_games_qt',
   'cat_malas_acessorios_qt',
   'cat_construcao_ferramentas_construcao_qt',
   'cat_eletrodomesticos_qt',
   'cat_instrumentos_musicais_qt',
   'cat_eletroportateis_qt',
   'cat_casa_construcao_qt',
   'cat_livros_interesse_geral_qt',
   'cat_alimentos_qt',
   'cat_moveis_sala_qt',
   'cat_casa_conforto_qt',
   'cat_bebidas_qt',
   'cat_audio_qt',
   'cat_market_place_qt',
   'cat_construcao_ferramentas_iluminacao_qt',
   'cat_climatizacao_qt',
   'cat_moveis_cozinha_area_de_servico_jantar_e_jardim_qt',
   'cat_alimentos_bebidas_qt',
   'cat_industria_comercio_e_negocios_qt',
   'cat_livros_tecnicos_qt',
   'cat_telefonia_fixa_qt',
   'cat_fashion_calcados_qt',
   'cat_eletrodomesticos_2_qt',
   'cat_construcao_ferramentas_jardim_qt',
   'cat_agro_industria_e_comercio_qt',
   'cat_artes_qt',
   'cat_pcs_qt',
   'cat_sinalizacao_e_seguranca_qt',
   'cat_construcao_ferramentas_seguranca_qt',
   'cat_artigos_de_natal_qt',
   'cat_fashion_roupa_masculina_qt',
]

df_prop = pd.DataFrame()
for c in categories:
   df_prop[f'{c}_pct'] = df[c] / df['products_qt']
   

# %% 
model = AgglomerativeClustering(
   n_clusters=10 # define a configuração do algorítimo
   )
model.fit(df_prop)

# %%
# Adicionando coluna nova de etiqueta
df_prop['cluster_id'] = model.labels_ 
df_prop['cluster_id'].value_counts(ascending=True)

# %%
features = list(df_prop.columns)[:-1]
target = df_prop.columns[-1]

X = df_prop[features]
y = df_prop[target]

# %%
clf = tree.DecisionTreeClassifier(random_state=42)
clf.fit(X, y)

# %%
features_importance = pd.Series(
   clf.feature_importances_,
   index=features
).sort_values(ascending=False)

features_importance

# %%
df_grouped = df_prop.groupby('cluster_id', as_index=True)[features_importance.index[:10]].mean()
seaborn.heatmap(df_grouped)
plt.show()

# %%
from sklearn.cluster import KMeans
from sklearn.datasets import make_blobs
from yellowbrick.cluster import KElbowVisualizer

# Instantiate the clustering model and visualizer
visualizer = KElbowVisualizer(model, k=(5,20))

visualizer.fit(X)        # Fit the data to the visualizer
visualizer.show()        # Finalize and render the figure

# %%
df['cluster_id'] = model.labels_
df[['seller_id', 'cluster_id']]
