# %%
from pathlib import Path
from sqlalchemy import create_engine
import pandas as pd
from sklearn import model_selection
from sklearn import tree
from sklearn import metrics


# %%
DATA_PATH = Path(__file__).resolve().parents[1]/'dados'/'olist.db'
engine = create_engine(f'sqlite:///{DATA_PATH}')
abt = pd.read_sql('tb_abt_churn', engine)

# Filtrando base Out Of Time
oot_filter = abt['dt_ref'] == abt['dt_ref'].max()
df_oot = abt[oot_filter].copy()

# Filtrando base Analytical Base Table
abt_filter = abt['dt_ref'] < abt['dt_ref'].max()
df_abt = abt[abt_filter].copy()

# %%
features = list(df_abt.columns[4:-1])
target = [df_abt.columns[-1]]
X = df_abt[features]
y = df_abt[target]

# %%
X_train, X_test, y_train, y_test = model_selection.train_test_split(
   X, 
   y,
   test_size=0.2,
   random_state=42)

classifier = tree.DecisionTreeClassifier(min_samples_leaf=50)
classifier.fit(X_train, y_train)

y_train_predict = classifier.predict(X_train)
y_train_proba = classifier.predict_proba(X_train)[:, 1]

print(f'ACC (train): {metrics.accuracy_score(y_train, y_train_predict)}')
print(f'AUC (train): {metrics.roc_auc_score(y_train, y_train_proba)}')

y_test_predict = classifier.predict(X_test)
y_test_proba = classifier.predict_proba(X_test)[:, 1]

print(f'ACC (test): {metrics.accuracy_score(y_test, y_test_predict)}')
print(f'AUC (test): {metrics.roc_auc_score(y_test, y_test_proba)}')

y_oot_predict = classifier.predict(df_oot[features])
y_oot_proba = classifier.predict_proba(df_oot[features])[:, 1]

print(f'ACC (oot): {metrics.accuracy_score(df_oot[target], y_oot_predict)}')
print(f'AUC (oot): {metrics.roc_auc_score(df_oot[target], y_oot_proba)}')

