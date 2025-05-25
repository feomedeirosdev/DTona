import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy import text
from pathlib import Path

# Caminhos
db_path = Path(__file__).resolve().parent.parent / 'dados' / 'olist.db'
query_path = Path(__file__).resolve().parent.parent / 'stage2' / 'consulta_book_sellers.sql'

# Função para importar a consulta SQL
def import_query(path, **kwargs):
    with open(path, 'r', **kwargs) as file_open:
        return file_open.read()

# Função para conectar ao banco
def connect_db():
    return create_engine(f'sqlite:///{db_path}')

# Lê a query e formata com a data desejada
query = import_query(query_path)
query = query.format(date='2017-07-01')
engine = connect_db()

# Executa INSERT se a tabela já existir, senão cria a tabela
with engine.connect() as conn:
    try:
        conn.execute(text('INSERT INTO tb_book_sellers\n' + query))
    except Exception as e:
        print(f'INSERT falhou (possivelmente a tabela não existe). Criando a tabela...')
        try:
            conn.execute(text('CREATE TABLE tb_book_sellers AS\n' + query))
            print('Tabela criada com sucesso.')
        except Exception as e2:
            print(f'Erro ao criar a tabela: {e2}')
