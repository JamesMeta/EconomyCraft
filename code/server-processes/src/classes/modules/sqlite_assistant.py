import sqlite3
from threading import local
from typing import Optional


from supabase import Client

from classes.classes.buy_order import BuyOrder
from classes.classes.local_share import LocalShare
from rich.progress import Progress

from classes.classes.share_group import ShareGroup

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
            CREATE TABLE IF NOT EXISTS buy_orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                expires_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                company_share_id INTEGER,
                user_id INTEGER,
                maximum_share_price REAL NOT NULL DEFAULT 0,
                order_quantity INTEGER
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
            
            cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_buy_orders_company_share_id
            ON buy_orders(company_share_id);
            """)
            
            cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_buy_orders_user_id
            ON buy_orders(user_id);
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
    
    def update_share_group_purchasable_status(self, share_group: ShareGroup, purchasable: bool) -> bool:
        
        with self.conn:
            
            cursor = self.conn.cursor()
            
            for share in share_group.shares:
                cur = cursor.execute(
                """
                UPDATE shares
                SET purchasable = ?
                WHERE id = ?
                """,
                (purchasable, share.id)
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
            
    def update_share_group_sale_price(self, share_group : ShareGroup, new_sale_price : float) -> bool:
       
        with self.conn:
            
            cursor = self.conn.cursor()
            
            for share in share_group.shares:
                cur = cursor.execute(
                """
                UPDATE shares
                SET sale_price = ?
                WHERE id = ?
                """,
                (new_sale_price, share.id)
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


    #
    # I do not plan on using this infrastructure for buyorders but in the future I might so ill leave it here
    #
    def insert_buy_order(self, buy_order: BuyOrder) -> bool:
        
        with self.conn:
        
            cursor = self.conn.cursor()
            
            cursor.execute(
                """
                INSERT INTO buy_orders (
                    id, created_at, expires_at, company_share_id, user_id, maximum_share_price, order_quantity
                )
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                (buy_order.id, buy_order.created_at, buy_order.expires_at, buy_order.company_share_id, buy_order.user_id, buy_order.order_maximum, buy_order.order_quantity)
            )
            cursor.close()
           
        return True
    
    #
    # I do not plan on using this infrastructure for buyorders but in the future I might so ill leave it here
    #
    def delete_buy_order_by_order_id(self, order_id: int) -> bool:
        
        with self.conn:
            
            cursor = self.conn.cursor()
            
            cur = cursor.execute(
                """
                DELETE FROM buy_orders
                WHERE id = ?
                """,
                (order_id,)
            )
            
            cursor.close()
        
        return cur.rowcount > 0
    
    #
    # I do not plan on using this infrastructure for buyorders but in the future I might so ill leave it here
    #
    def get_all_buy_orders(self) -> list[BuyOrder]:
        
        cursor = self.conn.cursor()
        
        cursor.execute("SELECT * FROM buy_orders")
        
        buy_order_results = cursor.fetchall()
        
        cursor.close()
        
        buy_order_list = []
        
        for buy_order_raw in buy_order_results:
        
            buy_order = BuyOrder(
                id = buy_order_raw ["id"],
                created_at = buy_order_raw ["created_at"],
                expires_at = buy_order_raw ["expires_at"],
                company_share_id = buy_order_raw ["company_share_id"],
                user_id = buy_order_raw ["user_id"],
                order_maximum = buy_order_raw ["maximum_share_price"],
                order_quantity = buy_order_raw ["order_quantity"]
            )
            
            buy_order_list.append(buy_order)
        
        return buy_order_list
    
    #
    # I do not plan on using this infrastructure for buyorders but in the future I might so ill leave it here
    #    
    def get_buy_orders_by_user_id(self, user_id: int) -> list[BuyOrder]:
        
        cursor = self.conn.cursor()
        
        cursor.execute("SELECT * FROM buy_orders WHERE user_id = ?", (user_id,))
        
        buy_order_results = cursor.fetchall()
        
        cursor.close()
        
        buy_order_list = []
        
        for buy_order_raw in buy_order_results:
        
            buy_order = BuyOrder(
                id = buy_order_raw ["id"],
                created_at = buy_order_raw ["created_at"],
                expires_at = buy_order_raw ["expires_at"],
                company_share_id = buy_order_raw ["company_share_id"],
                user_id = buy_order_raw ["user_id"],
                order_maximum = buy_order_raw ["maximum_share_price"],
                order_quantity = buy_order_raw ["order_quantity"]
            )
            
            buy_order_list.append(buy_order)
        
        return buy_order_list

    
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
            
    
    
        