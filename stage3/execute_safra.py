from argparse import ArgumentParser
from pathlib import Path
from sqlalchemy import create_engine, text
from sqlalchemy.exc import OperationalError
from sys import exit

# Argumentos de linha de comando
parser = ArgumentParser(description="Insere safra na tabela tb_book_sellers.")
parser.add_argument("--date", "-d", help="Data de referência no formato YYYY-MM-DD", default="2017-04-01")
args = parser.parse_args()
date = args.date

# Caminhos
QUERY_FILE = Path(__file__).resolve().parents[1] / "stage3" / "book_sellers.sql"
DB_PATH = Path(__file__).resolve().parents[1] / "dados" / "olist.db"

# Funções auxiliares
def import_query(path: Path, **kwargs) -> str:
    with open(path, "r", **kwargs) as file:
        return file.read()

def connect_db():
    return create_engine(f"sqlite:///{DB_PATH}")

def table_exists(conn, table_name: str) -> bool:
    query = text(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=:table_name"
    )
    result = conn.execute(query, {"table_name": table_name})
    return result.scalar() is not None

# Leitura e formatação da query
query = import_query(QUERY_FILE).format(date=date)
engine = connect_db()

with engine.begin() as conn:  # usa transação automática
    if table_exists(conn, "tb_book_sellers"):
        try:
            conn.execute(text("DELETE FROM tb_book_sellers WHERE dt_ref = :date"), {"date": date})
            print(f"Registros antigos com dt_ref = {date} foram removidos.")
        except Exception as e:
            print(f"Erro ao tentar deletar registros antigos: {e}")
            exit(1)
        
        try:
            # Executa diretamente o SELECT completo carregado do arquivo
            sql_insert = f"INSERT INTO tb_book_sellers {query}"
            conn.execute(text(sql_insert))  # query já é um SELECT válido
            print("Novos dados inseridos com sucesso.")
        except Exception as e:
            print(f"Erro ao inserir novos dados: {e}")
            exit(1)
    else:
        try:
            conn.execute(text(f"CREATE TABLE tb_book_sellers AS {query}"))
            print("Tabela 'tb_book_sellers' criada e dados inseridos com sucesso.")
        except Exception as e:
            print(f"Erro ao criar tabela: {e}")
            exit(1)
