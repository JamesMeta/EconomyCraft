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
        
        self.conn = sqlite3.connect("local.db")
        self.conn.row_factory = sqlite3.Row
        self.cursor = self.conn.cursor()
        
        self.__init_tables__()
    
    
    def __init_tables__(self):
        
        self.cursor.execute("""
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
        
    def get_local_share_by_local_share_id(self, share_id: int) -> LocalShare:
        
        self.cursor.execute("SELECT * FROM shares WHERE id = ?", (share_id,))
        
        local_share_results = self.cursor.fetchmany()
        
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
        
        self.cursor.execute("SELECT * FROM shares WHERE id = ?", (share_id,))
        
        local_share_results = self.cursor.fetchone()
        
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
        
        self.cursor.execute("SELECT * FROM shares WHERE share_id = ?", (company_share_id,))
        
        local_share_results = self.cursor.fetchall()
        
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
        
        self.cursor.execute("SELECT * FROM shares WHERE user_id = ?", (user_id,))
        
        local_share_results = self.cursor.fetchall()
        
        assert len(local_share_results) >= 1, f"No share by company share id {user_id}"
        
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
        
        self.cursor.execute("SELECT * FROM shares")
        
        local_share_results = self.cursor.fetchall()
        
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
        
        local_share = self.try_get_local_share_by_local_share_id(share_id)
        
        if local_share is not None:
            
            self.cursor.execute(
                """
                UPDATE shares
                SET purchasable = ?
                WHERE id = ?
                """,
                (purchasable, share_id)
            )
            
            return True
        
        return False
    
    def update_local_share_sale_price(self, share_id : int, new_sale_price : float) -> bool:
        
        local_share = self.try_get_local_share_by_local_share_id(share_id)
        
        if local_share is not None:
            
            self.cursor.execute(
                """
                UPDATE shares
                SET sale_price = ?
                WHERE id = ?
                """,
                (new_sale_price, share_id)
            )
            
            return True
        
        return False
    
    def update_local_share_owner(self, share_id : int, new_owner_id : int) -> bool:
        
        local_share = self.try_get_local_share_by_local_share_id(share_id)
        
        if local_share is not None:
            
            self.cursor.execute(
                """
                UPDATE shares
                SET user_id = ?, purchasable = ?
                WHERE id = ?
                """,
                (new_owner_id, False, share_id)
            )
            
            return True
        
        return False
    
    def update_local_share_purchased_price_post_transaction(self, share_id: int,):
        local_share = self.try_get_local_share_by_local_share_id(share_id)
        
        if local_share is not None:
            
            self.cursor.execute(
                """
                UPDATE shares
                SET purchased_price = ?
                WHERE id = ?
                """,
                (local_share.sale_price, share_id)
            )
            
            return True
        
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
        
        self.cursor.execute(
            """
            INSERT INTO shares (
                id, created_at, company_id, stake, purchased_price, purchasable, user_id, sale_price, share_id
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (id,created_at,company_id,stake,purchased_price, purchasable, user_id, sale_price, share_id)
        )
        
        self.conn.commit()
           
    def replicate_current_share_table(self) :
        
        shares_table_result = self.supabase.table("shares").select("*").execute()
        shares_raw = shares_table_result.data
        
        assert shares_raw
        assert len(shares_raw) > 0
        
        
        with Progress() as progress:
            task = progress.add_task("[green]Replicating shares...", total=len(shares_raw))
            for share_raw in shares_raw:
                self.insert_local_share(**share_raw)
                progress.update(task, advance=1)
        print("Replication of shares table complete.")
        

    
        