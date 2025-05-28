# %%
from pathlib import Path
from sqlalchemy import create_engine
import pandas as pd
from sklearn import model_selection, tree, metrics, preprocessing
import numpy as np

# %%
DATA_PATH = Path(__file__).resolve().parents[1] / 'dados' / 'olist.db'
engine = create_engine(f'sqlite:///{DATA_PATH}') 
abt = pd.read_sql('tb_abt_churn', engine)

# Garante que todos os nomes de colunas sejam strings
abt.columns = abt.columns.astype(str)

# Filtrando base Out Of Time
oot_filter = abt['dt_ref'] == abt['dt_ref'].max()
df_oot = abt[oot_filter].copy()

# Filtrando base ABT
abt_filter = abt['dt_ref'] < abt['dt_ref'].max()
df_abt = abt[abt_filter].copy()

# %%
# Definição dos features e target removendo colunas irrelevantes
features = df_abt.columns.tolist()
target = ['flag_churn']
to_remove = ['dt_ref', 'seller_city', 'seller_id'] + target

features = [f for f in features if f not in to_remove]

# Separando variáveis categóricas e numéricas
category_features = df_abt[features].select_dtypes(include='object').columns.tolist()
numerical_features = df_abt[features].select_dtypes(exclude='object').columns.tolist()

# %%
# Separação X e y
X = df_abt[features].copy()
y = df_abt[target].copy()

# Separação treino e teste
X_train, X_test, y_train, y_test = model_selection.train_test_split(
    X, y, test_size=0.2, random_state=42
)

X_train.reset_index(drop=True, inplace=True)
X_test.reset_index(drop=True, inplace=True)
y_train.reset_index(drop=True, inplace=True)
y_test.reset_index(drop=True, inplace=True)

# %%
# Codificação one-hot
onehot = preprocessing.OneHotEncoder(
    sparse_output=False,
    handle_unknown='ignore'
)
onehot.fit(X_train[category_features])

# Transforma treino
df_onehot_train = pd.DataFrame(
    onehot.transform(X_train[category_features]),
    columns=onehot.get_feature_names_out(category_features)
)

df_numeric_train = X_train[numerical_features].copy()
df_numeric_train.columns = df_numeric_train.columns.astype(str)

df_train = pd.concat([df_onehot_train, df_numeric_train], axis=1)
df_train.columns = df_train.columns.astype(str)

# %%
# Treina modelo
classifier = tree.DecisionTreeClassifier(min_samples_leaf=50)
classifier.fit(df_train, y_train)

# Avaliação treino
y_train_pred = classifier.predict(df_train)
y_train_proba = classifier.predict_proba(df_train)[:, 1]

print(f'ACC (train): {metrics.accuracy_score(y_train, y_train_pred)}')
print(f'AUC (train): {metrics.roc_auc_score(y_train, y_train_proba)}')

# %%
# Transforma teste
df_onehot_test = pd.DataFrame(
    onehot.transform(X_test[category_features]),
    columns=onehot.get_feature_names_out(category_features)
)

df_numeric_test = X_test[numerical_features].copy()
df_numeric_test.columns = df_numeric_test.columns.astype(str)

df_test = pd.concat([df_onehot_test, df_numeric_test], axis=1)
df_test.columns = df_test.columns.astype(str)

# Avaliação teste
y_test_pred = classifier.predict(df_test)
y_test_proba = classifier.predict_proba(df_test)[:, 1]

print(f'ACC (test): {metrics.accuracy_score(y_test, y_test_pred)}')
print(f'AUC (test): {metrics.roc_auc_score(y_test, y_test_proba)}')

# %%
# Aplicando no OOT
X_oot = df_oot[features].copy()
y_oot = df_oot[target].copy()

df_onehot_oot = pd.DataFrame(
    onehot.transform(X_oot[category_features]),
    columns=onehot.get_feature_names_out(category_features)
)

df_numeric_oot = X_oot[numerical_features].copy()
df_numeric_oot.columns = df_numeric_oot.columns.astype(str)

df_oot_final = pd.concat([df_onehot_oot, df_numeric_oot], axis=1)
df_oot_final.columns = df_oot_final.columns.astype(str)

y_oot_pred = classifier.predict(df_oot_final)
y_oot_proba = classifier.predict_proba(df_oot_final)[:, 1]

print(f'ACC (oot): {metrics.accuracy_score(y_oot, y_oot_pred)}')
print(f'AUC (oot): {metrics.roc_auc_score(y_oot, y_oot_proba)}')
