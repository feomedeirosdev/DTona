# %% Imports
from pathlib import Path
from sqlalchemy import create_engine
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score, confusion_matrix, classification_report

# %% Conexão com o banco de dados SQLite
database_path = Path(__file__).resolve().parents[1] / 'dados' / 'olist.db'
models_path = Path(__file__).resolve().parent/'models'
engine = create_engine(f'sqlite:///{database_path}')

# %% Leitura da tabela ABT
abt = pd.read_sql_table('tb_abt_churn', engine)

# %% Separação entre OOT (out-of-time) e dados para treino/teste
dt_max = abt['dt_ref'].max()

df_oot = abt[abt['dt_ref'] == dt_max].copy()
df_abt = abt[abt['dt_ref'] < dt_max].copy()

df_oot.reset_index(drop=True, inplace=True)

# %% Definição de features e target
target = 'flag_churn'
features = abt.columns.difference(['dt_ref', 'seller_id', 'seller_city', target]).tolist()

X = df_abt[features].copy()
X.columns = X.columns.astype(str)  # Garante que todas as colunas sejam strings
y = df_abt[target].copy()

# %% Separação treino/teste
X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

# Reset de índices (boas práticas para garantir alinhamento)
for df in [X_train, X_test, y_train, y_test]:
    df.reset_index(drop=True, inplace=True)

# %% Identificação de variáveis categóricas e numéricas
cat_features = X.select_dtypes(include='object').columns.tolist()
num_features = X.select_dtypes(exclude='object').columns.tolist()

# %% OneHot Encoding para variáveis categóricas
encoder = OneHotEncoder(sparse_output=False, handle_unknown='ignore')
encoder.fit(X_train[cat_features])

df_onehot_train = pd.DataFrame(
    encoder.transform(X_train[cat_features]),
    columns=encoder.get_feature_names_out(cat_features)
)

# Reconstrução do DataFrame de treino com variáveis numéricas
df_train = pd.concat([X_train[num_features], df_onehot_train], axis=1)
df_train.columns = [str(col) for col in df_train.columns]
features_fit = df_train.columns.tolist()

# %% Treinamento do modelo
model = DecisionTreeClassifier(min_samples_leaf=100, random_state=42)
model.fit(df_train, y_train)

# %% Avaliação no treino
y_train_pred = model.predict(df_train)
acc_train = accuracy_score(y_train, y_train_pred)

# %% Feature importances
feature_importances = (
    pd.Series(model.feature_importances_, index=df_train.columns)
    .sort_values(ascending=False)
    .head(10)
)

# %% Preparação do conjunto de teste
df_onehot_test = pd.DataFrame(
    encoder.transform(X_test[cat_features]),
    columns=encoder.get_feature_names_out(cat_features)
)

df_test = pd.concat([X_test[num_features], df_onehot_test], axis=1)
df_test.columns = [str(col) for col in df_test.columns]

# %% Avaliação no teste
y_test_pred = model.predict(df_test)
acc_test = accuracy_score(y_test, y_test_pred)
cm_test = confusion_matrix(y_test, y_test_pred)
report_test = classification_report(y_test, y_test_pred)

# %% Impressão de métricas
feature_importances

# %%
print(f"Acurácia - Teste : {acc_test:.4f}")

# %%
df_onehot_oot = pd.DataFrame(
    encoder.transform(df_oot[cat_features]),
    columns=encoder.get_feature_names_out(cat_features)
)
# %%
df_oot_predict = pd.concat([df_oot[num_features], df_onehot_oot], axis=1)
df_oot_predict.columns = [str(col) for col in df_oot_predict.columns]

# %%
oot_pred = model.predict(df_oot_predict)

# %%
acc_oot = accuracy_score(df_oot[target], oot_pred)


# %%
print(f"Acurácia (Treino): {acc_train:.4f}")
print(f"Acurácia (Teste): {acc_test:.4f}")
print(f"Acurácia (Out Of Time): {acc_oot:.4f}")

# %%
df_abt_enconder = pd.DataFrame(
    encoder.transform(abt[cat_features]),
    columns=encoder.get_feature_names_out(cat_features))

# %%
df_abt_predict = pd.concat([abt[num_features], df_abt_enconder], axis=1)
df_abt_predict.columns = [str(col) for col in df_abt_predict.columns]

# %%
probs = model.predict_proba(df_abt_predict)
abt['score_churn'] = probs[:,1]

# %%
df_abt_score = abt[['seller_id', 'score_churn']]

# %%
# df_abt_score.to_sql('tb_churn_score', engine, index=False, if_exists='replace')

# %% Salvando o modelo

model_data = pd.Series({
    'num_features': num_features,
    'cat_features': cat_features,
    'encoder': encoder,
    'features_fit': features_fit,
    'model': model,
    'acc_train': acc_train,
    'acc_test': acc_test,
    'acc_oot': acc_oot,
})

model_data.to_pickle(models_path/'arvore_de_decisao.pkl')