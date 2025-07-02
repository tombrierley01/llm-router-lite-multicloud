import asyncpg
import os

DB_POOL = None

async def get_db_pool():
    global DB_POOL
    if DB_POOL is None:
        DB_POOL = await asyncpg.create_pool(dsn=os.getenv("DATABASE_URL"))
    return DB_POOL

