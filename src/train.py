# %%
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy import text
from pathlib import Path
from sklearn import tree
from sklearn import metrics

# %%
db_path = Path(__file__).resolve().parent.parent / 'dados' / 'olist.db'
query_path = Path(__file__).resolve().parent.parent / 'stage2' / 'create_safra.sql'

# %%
def import_query(path, **kwargs):
    with open(path, 'r', **kwargs) as file_open:
        return file_open.read()

def connect_db():
    return create_engine(f'sqlite:///{db_path}')

# %%
query = import_query(query_path)
engine = connect_db()
 
# %%
df = pd.read_sql(text(query), engine)
df.head(5)

# %%
columns = list(df.columns)
to_remove = ['seller_id', 'seller_city']
target = 'flag_model'

# %%
for i in to_remove + [target]:
    columns.remove(i)

# %%
str_type_filter = df[columns].dtypes == 'object'
category_features = df[columns].dtypes[str_type_filter].index.tolist()
numerical_features = list(set(columns) - set(category_features))

# %%
category_features

# %%
len(numerical_features)

# %%
clf = tree.DecisionTreeClassifier(max_depth=10)
clf.fit(df[numerical_features], df[target])

# %%
y_pred = clf.predict(df[numerical_features])
y_proba = clf.predict_proba(df[numerical_features])

# %%
mconf = metrics.confusion_matrix(df[target], y_pred)
df_mconf = pd.DataFrame(
    mconf,
    index=['false', 'true'],
    columns=['false', 'true'],
)
df_mconf

# %%
features_importance = pd.Series(clf.feature_importances_, index=numerical_features).sort_values(ascending=False)
features_importance

# %%
