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
abt.columns = abt.columns.astype(str)

# Filtrando base Out Of Time
oot_filter = abt['dt_ref'] == abt['dt_ref'].max()
df_oot = abt[oot_filter].copy()

# Filtrando base Analytical Base Table
abt_filter = abt['dt_ref'] < abt['dt_ref'].max()
df_abt = abt[abt_filter].copy()

# %%
# Definindo features e target
features = list(df_abt.columns)
target = ['flag_churn']
to_remove = ['dt_ref', 'seller_city', 'seller_id'] + target

for f in to_remove:
    features.remove(f)

# Separando features categóricas e numéricas
category_filter = df_abt[features].dtypes == 'object'
category_features = df_abt[features].dtypes[category_filter].index.tolist()

numerical_filter = df_abt[features].dtypes != 'object'
numerical_features = df_abt[features].dtypes[numerical_filter].index.tolist()

# %%
X = df_abt[features].copy()
X.columns = X.columns.astype(str)
y = df_abt[target].copy()

X_train, X_test, y_train, y_test = model_selection.train_test_split(
    X, y, test_size=0.2, random_state=42
)

X_train.reset_index(drop=True, inplace=True)
X_test.reset_index(drop=True, inplace=True)
y_train.reset_index(drop=True, inplace=True)
y_test.reset_index(drop=True, inplace=True)

# %%
# Codificação One-Hot
onehot = preprocessing.OneHotEncoder(
    sparse_output=False,
    handle_unknown='ignore'
)
onehot.fit(X_train[category_features])

# Transforma treino
df_onehot_train = pd.DataFrame(
    onehot.transform(X_train[category_features]),
    columns=[str(col) for col in onehot.get_feature_names_out(category_features)]
)

X_train_numeric = X_train[numerical_features].copy()
X_train_numeric.columns = X_train_numeric.columns.astype(str)

df_train = pd.concat([df_onehot_train, X_train_numeric], axis=1)
df_train.columns = df_train.columns.astype(str)

# %%
# Treinamento do modelo
classifier = tree.DecisionTreeClassifier(min_samples_leaf=50)
classifier.fit(df_train, y_train)

# %%
# Avaliação em treino
# y_train_pred = classifier.predict(df_train)
# y_train_proba = classifier.predict_proba(df_train)[:, 1]

# print(f'ACC (train): {metrics.accuracy_score(y_train, y_train_pred):.4f}')
# print(f'AUC (train): {metrics.roc_auc_score(y_train, y_train_proba):.4f}')

# # %%
# # Transformação e avaliação em teste
# df_onehot_test = pd.DataFrame(
#     onehot.transform(X_test[category_features]),
#     columns=[str(col) for col in onehot.get_feature_names_out(category_features)]
# )

# X_test_numeric = X_test[numerical_features].copy()
# X_test_numeric.columns = X_test_numeric.columns.astype(str)

# df_test = pd.concat([df_onehot_test, X_test_numeric], axis=1)
# df_test.columns = df_test.columns.astype(str)

# y_test_pred = classifier.predict(df_test)
# y_test_proba = classifier.predict_proba(df_test)[:, 1]

# print(f'ACC (test): {metrics.accuracy_score(y_test, y_test_pred):.4f}')
# print(f'AUC (test): {metrics.roc_auc_score(y_test, y_test_proba):.4f}')

# # %%
# # Transformação e avaliação em OOT
# X_oot = df_oot[features].copy()
# y_oot = df_oot[target].copy()

# df_onehot_oot = pd.DataFrame(
#     onehot.transform(X_oot[category_features]),
#     columns=[str(col) for col in onehot.get_feature_names_out(category_features)]
# )

# X_oot_numeric = X_oot[numerical_features].copy()
# X_oot_numeric.columns = X_oot_numeric.columns.astype(str)

# df_oot_final = pd.concat([df_onehot_oot, X_oot_numeric], axis=1)
# df_oot_final.columns = df_oot_final.columns.astype(str)

# y_oot_pred = classifier.predict(df_oot_final)
# y_oot_proba = classifier.predict_proba(df_oot_final)[:, 1]

# print(f'ACC (oot): {metrics.accuracy_score(y_oot, y_oot_pred):.4f}')
# print(f'AUC (oot): {metrics.roc_auc_score(y_oot, y_oot_proba):.4f}')
