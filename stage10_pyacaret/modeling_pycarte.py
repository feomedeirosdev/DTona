# %% Importando bibliotecas
from pathlib import Path
from sqlalchemy import create_engine
import pandas as pd
import numpy as np

# %%
from pycaret.classification import *  

# %% Carregamento de dados
database_path = Path(__file__).resolve().parents[1]/'dados'/'olist.db'
work_dir_path = Path(__file__).resolve().parents[1]
engine = create_engine(f'sqlite:///{database_path}')

pd.set_option('display.max_columns', 100)
df = pd.read_sql_table('tb_abt_churn', engine)

# %% Determinação das bases
dt_max = df['dt_ref'].max()
df_oot = df[df['dt_ref'] == dt_max].copy() # Base Out Of Time
df_abt = df[df['dt_ref'] < dt_max].copy() # Base Analytical Base Table

# %% Determinação das variáveis
target = 'flag_churn'
to_remove = ['dt_ref', 'seller_state', 'seller_city', 'seller_id','flag_churn']
num_features = list(df.columns.difference(to_remove))

# %% Configurando o PyCaret
ml_setup = setup(
   data = df_abt,
   target = target,
   train_size = 0.8,
   session_id = 1234,
   ignore_features = ['dt_ref', 'seller_state', 'seller_city', 'seller_id'],
   numeric_features = num_features
)

# %% 
compared_models = compare_models(fold=5) # Rank dos modelos, organizados pela Accuracy
rf_model = create_model(estimator = 'rf', fold = 5) # Base de treino
predict_modeld = predict_model(rf_model) # Base de teste
tuned_rf = tune_model(rf_model, fold=5) # Modelo tunado

# %%
evaluate_model(tuned_rf)

# %%
final_rf_tuned = finalize_model(tuned_rf)
save_model(final_rf_tuned, 'random_forest_model')

# %%
loaded_rf_model = load_model('random_forest_model')
predictions = predict_model(
   loaded_rf_model,
   data = df_oot)

predictions.head()

# %%
from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import roc_auc_score
from sklearn.metrics import f1_score

# %%
acc = accuracy_score(predictions[target], predictions['prediction_label'])
auc = roc_auc_score(predictions[target], predictions['prediction_score'])
recall = recall_score(predictions[target], predictions['prediction_label'])
precision = precision_score(predictions[target], predictions['prediction_label'])
f1 = f1_score(predictions[target], predictions['prediction_label'])

df_metrics_oot = pd.DataFrame({
   'Model': ['Decision Tree Classifier'],
   'Accuracy': [f'{acc*100:.2f}%'],
   'AUC': [f'{auc*100:.2f}%'],
   'Recall': [f'{recall*100:.2f}%'],
   'Precision': [f'{precision*100:.2f}%'],
   'F1': [f'{f1*100:.2f}%'],})

df_metrics_oot

# %%
xgboost_model = create_model(estimator = 'xgboost', fold = 5)
tuned_xgboost = tune_model(xgboost_model, fold=5)

# %%
df_pred_tuned_xgboost = predict_model(tuned_xgboost)

# %%
evaluate_model(tuned_xgboost)

# %%
interpret_model(tuned_xgboost)
