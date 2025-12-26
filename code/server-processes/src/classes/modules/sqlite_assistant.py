import sqlite3
from threading import local
from typing import Optional


from supabase import Client

from classes.classes.local_share import LocalShare
from rich.progress import Progress

FIRST = 0

class SqliteAssistant:
    
    
    def __init__(self, supabase: Client) -> None:
        
        self.supabase = supabase
        
        self.conn = sqlite3.connect("local.db", timeout=10)
        self.conn.row_factory = sqlite3.Row
        self.conn.execute("PRAGMA journal_mode=WAL;")
        self.conn.execute("PRAGMA busy_timeout = 10000;")
        
        
        self.__init_tables__()
    
    
    def __init_tables__(self):
        
        with self.conn:
            
            cursor = self.conn.cursor()
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS shares (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                company_id INTEGER,
                stake REAL NOT NULL DEFAULT 0,
                purchased_price REAL NOT NULL DEFAULT 1,
                purchasable INTEGER NOT NULL DEFAULT 0,
                user_id INTEGER,
                sale_price REAL DEFAULT 0,
                share_id INTEGER
            ) STRICT;
            """)
            
            cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_shares_share_id
            ON shares(share_id);
            """)

            cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_shares_user_id
            ON shares(user_id);
            """)
            cursor.close()
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc, traceback):
        self.conn.close()
        
    def get_local_share_by_local_share_id(self, share_id: int) -> LocalShare:
        
        cursor = self.conn.cursor()
        
        cursor.execute("SELECT * FROM shares WHERE id = ?", (share_id,))
        
        local_share_results = cursor.fetchmany()
        
        cursor.close()
        
        assert len(local_share_results) >= 1, f"No share by share id {share_id}"
        
        local_share_raw = local_share_results[FIRST]
        
        local_share = LocalShare(
            id = local_share_raw ["id"],
            company_id = local_share_raw ["company_id"],
            stake = local_share_raw ["stake"],
            purchased_price = local_share_raw ["purchased_price"],
            purchasable = local_share_raw ["purchasable"],
            user_id = local_share_raw ["user_id"],
            sale_price = local_share_raw ["sale_price"],
            company_share_id = local_share_raw ["share_id"]
        )
        
        return local_share
    
    def try_get_local_share_by_local_share_id(self, share_id: int) -> Optional[LocalShare]:
        
        cursor = self.conn.cursor()
        
        cursor.execute("SELECT * FROM shares WHERE id = ?", (share_id,))
        
        local_share_results = cursor.fetchone()
        
        cursor.close()
        
        if local_share_results is None:
            return None
        
        local_share_raw = local_share_results
        
        local_share = LocalShare(
            id = local_share_raw ["id"],
            company_id = local_share_raw ["company_id"],
            stake = local_share_raw ["stake"],
            purchased_price = local_share_raw ["purchased_price"],
            purchasable = local_share_raw ["purchasable"],
            user_id = local_share_raw ["user_id"],
            sale_price = local_share_raw ["sale_price"],
            company_share_id = local_share_raw ["share_id"]
        )
        
        
        return local_share
    
    def get_local_shares_by_company_share_id(self, company_share_id: int) -> list[LocalShare]:
        
        cursor = self.conn.cursor()
        
        cursor.execute("SELECT * FROM shares WHERE share_id = ?", (company_share_id,))
        
        local_share_results = cursor.fetchall()
        
        cursor.close()
        
        assert len(local_share_results) >= 1, f"No share by company share id {company_share_id}"
        
        local_share_list = []
        
        for local_share_raw in local_share_results:
        
            local_share = LocalShare(
                id = local_share_raw ["id"],
                company_id = local_share_raw ["company_id"],
                stake = local_share_raw ["stake"],
                purchased_price = local_share_raw ["purchased_price"],
                purchasable = local_share_raw ["purchasable"],
                user_id = local_share_raw ["user_id"],
                sale_price = local_share_raw ["sale_price"],
                company_share_id = local_share_raw ["share_id"]
            )
            
            local_share_list.append(local_share)
        
        return local_share_list
    
    def get_local_shares_by_user_id(self, user_id: int) -> list[LocalShare]:
        
        cursor = self.conn.cursor()
        
        cursor.execute("SELECT * FROM shares WHERE user_id = ?", (user_id,))
        
        local_share_results = cursor.fetchall()
        
        cursor.close()
        
        local_share_list = []
        
        for local_share_raw in local_share_results:
        
            local_share = LocalShare(
                id = local_share_raw ["id"],
                company_id = local_share_raw ["company_id"],
                stake = local_share_raw ["stake"],
                purchased_price = local_share_raw ["purchased_price"],
                purchasable = local_share_raw ["purchasable"],
                user_id = local_share_raw ["user_id"],
                sale_price = local_share_raw ["sale_price"],
                company_share_id = local_share_raw ["share_id"]
            )
            
            local_share_list.append(local_share)
        
        return local_share_list
 
    def get_all_local_shares(self) -> list[LocalShare]:
        
        cursor = self.conn.cursor()
        
        cursor.execute("SELECT * FROM shares")
        
        local_share_results = cursor.fetchall()
        
        cursor.close()
        
        assert len(local_share_results) >= 1, f"No shares found"
        
        local_share_list = []
        
        for local_share_raw in local_share_results:
        
            local_share = LocalShare(
                id = local_share_raw ["id"],
                company_id = local_share_raw ["company_id"],
                stake = local_share_raw ["stake"],
                purchased_price = local_share_raw ["purchased_price"],
                purchasable = local_share_raw ["purchasable"],
                user_id = local_share_raw ["user_id"],
                sale_price = local_share_raw ["sale_price"],
                company_share_id = local_share_raw ["share_id"]
            )
            
            local_share_list.append(local_share)
        
        return local_share_list
    
    def update_local_share_purchasable_status(self, share_id : int, purchasable : bool) -> bool:
        
        with self.conn:
            
            cursor = self.conn.cursor()
            
            cur = cursor.execute(
                """
                UPDATE shares
                SET purchasable = ?
                WHERE id = ?
                """,
                (purchasable, share_id)
            )
            
            cursor.close()
            
        return cur.rowcount > 0
            
            

    
    def update_local_share_sale_price(self, share_id : int, new_sale_price : float) -> bool:
            
        with self.conn:
            
            cursor = self.conn.cursor()
            
            cur = cursor.execute(
                """
                UPDATE shares
                SET sale_price = ?
                WHERE id = ?
                """,
                (new_sale_price, share_id)
            )
            
            cursor.close()
            
        return cur.rowcount > 0
            

    
    def update_local_shares_owner(self, share_ids : list[int], new_owner_id : int) -> bool:
        
        try: 
            with self.conn:
            
                cursor = self.conn.cursor()
                
                for share_id in share_ids:
                
                    cur = cursor.execute(
                        """
                        UPDATE shares
                        SET user_id = ?, purchasable = ?
                        WHERE id = ?
                        """,
                        (new_owner_id, False, share_id)
                    )
                
                cursor.close()
            return True

        except sqlite3.Error as e:
            print("Transaction Failed for updating local shares owners --> Rolling back")
            return False
   
            
        
                

    
    def update_local_shares_purchased_price_post_transaction(self, share_ids: list[int],) -> bool:
        
        try:
            with self.conn:
                cursor = self.conn.cursor()
                
                for share_id in share_ids:
                
                    cur = cursor.execute(
                        """
                        UPDATE shares
                        SET purchased_price = sale_price
                        WHERE id = ?
                        """,
                        (share_id,)
                    )
                
                cursor.close()
                return True
            
        except sqlite3.Error as e:
            print("Transaction Failed for updating purchased price post transaction --> Rolling back")
            return False


        
        
        


    
    def insert_local_share(self, id: int, created_at: str, company_id : int, stake: float, purchased_price: float, purchasable: bool, user_id: int, sale_price: float, share_id: int):
        
        # assert type(id) is int
        # assert type(created_at) is str
        # assert type(company_id) is int
        # assert type(stake) is float
        # assert type(purchased_price) is float
        # assert type(user_id) is int
        # assert type(sale_price) is float
        # assert type(share_id) is int
        
        with self.conn:
        
            cursor = self.conn.cursor()
            
            cursor.execute(
                """
                INSERT INTO shares (
                    id, created_at, company_id, stake, purchased_price, purchasable, user_id, sale_price, share_id
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (id,created_at,company_id,stake,purchased_price, purchasable, user_id, sale_price, share_id)
            )
            cursor.close()
           
    def replicate_shares(self):
        
        print("Share Replication Process Beginning")
        
        print("Connection Achieved")
    
        shares_raw = self.supabase.table("shares").select("*").execute().data
        assert shares_raw
        
        print("Data Recieved From Servers")

        rows = [
            (
                s["id"],
                s["created_at"],
                s["company_id"],
                s["stake"],
                s["purchased_price"],
                s["purchasable"],
                s["user_id"],
                s["sale_price"],
                s["share_id"],
            )
            for s in shares_raw
        ]
        
        print("Data Parsed Successfully")

        with self.conn:
            
            print("Starting Share Replication")
            
            self.conn.execute("DELETE FROM shares")
            self.conn.executemany("""
                INSERT INTO shares (
                    id, created_at, company_id, stake,
                    purchased_price, purchasable,
                    user_id, sale_price, share_id
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, rows)

        print("All Shares Replicated")
            

    
        