# %%
from pathlib import Path
from sqlalchemy import create_engine
import pandas as pd
from sklearn import model_selection
from sklearn import preprocessing
from sklearn import tree
from sklearn import metrics

database_path = Path(__file__).resolve().parents[1]/'dados'/'olist.db'
engine = create_engine(f'sqlite:///{database_path}')

abt = pd.read_sql_table('tb_abt_churn', engine)

oot_filter = abt['dt_ref'] == abt['dt_ref'].max()
df_oot = abt[oot_filter].copy()

abt_filter = abt['dt_ref'] < abt['dt_ref'].max()
df_abt = abt[abt_filter].copy()

features = list(abt.columns)
to_remove = ['dt_ref', 'seller_id', 'seller_city', 'flag_churn']
for f in to_remove:
   features.remove(f)

target = 'flag_churn'

X = df_abt[features]
X.columns = X.columns.astype(str)

y = df_abt[target]

X_train, X_test, y_train, y_test = (
   model_selection.train_test_split(
      X, 
      y,
      test_size=0.2,
      random_state=42))

X_train.reset_index(drop=True, inplace=True)
X_test.reset_index(drop=True, inplace=True)
y_train.reset_index(drop=True, inplace=True)
y_test.reset_index(drop=True, inplace=True)

cat_filter = df_abt[features].dtypes == 'object'
cat_features = df_abt[features].dtypes[cat_filter].index.tolist()

num_filter = df_abt[features].dtypes != 'object'
num_features = df_abt[features].dtypes[num_filter].index.tolist()

onehot = preprocessing.OneHotEncoder(
   sparse_output=False,
   handle_unknown='ignore'
)

onehot.fit(X_train[cat_features])

onehot.transform(X_train[cat_features])
df_onehot_train = pd.DataFrame(
   onehot.transform(X_train[cat_features]),
   columns=onehot.get_feature_names_out(cat_features))

df_train = pd.concat([df_onehot_train, X_train[num_features]], axis=1)
df_train.columns = [str(col) for col in df_train.columns]

model = tree.DecisionTreeClassifier()
model.fit(df_train, y_train)

S_features_importances = (
   pd.Series(
      model.feature_importances_, 
      index=df_train.columns)
   .sort_values(ascending=False)[:10])

y_train_pred = model.predict(df_train)
acc = metrics.accuracy_score(y_train, y_train_pred)

df_onehot_test = pd.DataFrame(
   onehot.transform(X_test[cat_features]),
   columns=onehot.get_feature_names_out(cat_features)
)

df_predict = pd.concat([df_onehot_test, X_test[num_features]], axis=1)
df_predict.columns = [str(col) for col in df_predict.columns]

y_test_pred = model.predict(df_predict)
acc_predict = metrics.accuracy_score(y_test, y_test_pred) 

print(S_features_importances)
