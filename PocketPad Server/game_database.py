import sqlite3

def get_connection():
    return sqlite3.connect('controller_database.db', check_same_thread=False)

def initialize_database():
    with get_connection() as db_connection:
        cursor = db_connection.cursor()
        cursor.execute("PRAGMA journal_mode=WAL;")
        cursor.execute(
            '''
            CREATE TABLE IF NOT EXISTS game_controllers (
                game_name TEXT PRIMARY KEY,
                controller_data TEXT
            )
            '''
        )
        db_connection.commit()

def add_to_database(game: str, controller_data: str):
    with get_connection() as db_connection:
        cursor = db_connection.cursor()
        cursor.execute(
            """
            INSERT OR REPLACE INTO game_controllers (game_name, controller_data)
            VALUES (?, ?)
            """,
            (game, controller_data)
        )
        db_connection.commit()

def get_controller_layout(game_name: str) -> str | None:
    with get_connection() as db_connection:
        cursor = db_connection.cursor()
        cursor.execute("SELECT controller_data FROM game_controllers WHERE game_name = ?", (game_name,))
        row = cursor.fetchone()
        if row:
            return row[0]
        else:
            return None
        
def get_games_in_database() -> list[str]:
    with get_connection() as db_connection:
        cursor = db_connection.cursor()
        cursor.execute("SELECT game_name FROM game_controllers")
        return [row[0] for row in cursor.fetchall()]

def remove_game_controller(game_name: str):
    conn = sqlite3.connect("controller_database.db")
    cursor = conn.cursor()
    cursor.execute("DELETE FROM game_controllers WHERE game_name = ?", (game_name,))
    conn.commit()
    conn.close()

def clear_database():
    conn = sqlite3.connect("controller_database.db")
    cursor = conn.cursor()
    cursor.execute("DELETE FROM game_controllers")
    conn.commit()
    conn.close()