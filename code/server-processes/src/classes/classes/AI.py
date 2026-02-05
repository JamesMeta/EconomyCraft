from supabase import Client
from classes.classes.buy_order import BuyOrder
from classes.classes.share import Share
from classes.classes.share_group import ShareGroup
from classes.modules.sqlite_assistant import SqliteAssistant



class AI:
    def __init__(self, supabase: Client, id: int, minecraft_username: str, money: int, delivery_address: str, daily_income: int, ai_type: int):
        self.supabase = supabase
        self.id = id
        self.minecraft_username = minecraft_username
        self.money = money
        self.delivery_address = delivery_address
        self.daily_income = daily_income
        self.ai_type = ai_type
        self.shares: list[Share] = [] 
        self.networth_breakdown: dict[str, float] = {}
        
    def place_product_order(self, product_id: int, quantity: int):
        response = self.supabase.rpc("create_order_ai", {"input_row_id": self.id, "input_product_id": product_id, "input_quantity": quantity, "input_delivery_address": self.delivery_address}).execute()

    def place_buy_order(self, buy_order: BuyOrder):
        response = self.supabase.table("buy_orders").insert({"expires_at": buy_order.expires_at,
                                                             "company_share_id": buy_order.company_share_id,
                                                             "user_id": buy_order.user_id,
                                                             "order_quantity": buy_order.order_quantity,
                                                             "maximum_share_price": buy_order.order_maximum
                                                             }).execute()
    
    def place_share_sell_order(self, share_id: int, sale_price: float):
        try:
            with SqliteAssistant(self.supabase) as sq:
                assert (sq.update_local_share_purchasable_status(share_id=share_id, purchasable=True) and sq.update_local_share_sale_price(share_id=share_id, new_sale_price=sale_price)), "SQLite update failed"
            
            response_supabase = self.supabase.table("shares").update({"sale_price": sale_price, "purchasable": True}).eq("id", share_id).execute()
            
            if (not (response_supabase)):
                raise Exception("Supabase update failed")
        except Exception as e:
            print(f"[bold red underline]Error placing share sell order: {e}[/bold red underline]")
    

    def place_share_group_sell_order(self, share_group: ShareGroup, sale_price: float):
        try:
            with SqliteAssistant(self.supabase) as sq:
                assert (sq.update_share_group_purchasable_status(share_group, True) and sq.update_share_group_sale_price(share_group, sale_price)), "SQLite update failed"
            
            updates = list(map(lambda x: {"id": x.id, "sale_price": sale_price, "purchasable": True}, share_group.shares))
            
            response_supabase = self.supabase.rpc("bulk_update_shares", {"updates": updates}).execute()
            
            if (not (response_supabase)):
                raise Exception("Supabase update failed")
            
        except Exception as e:
            print(f"[bold red underline]Error placing share group sell order: {e}[/bold red underline]")
            
        
    def remove_share_for_sale(self, share_id: int):
        
        try:
            with SqliteAssistant(self.supabase) as sq:
                assert sq.update_local_share_purchasable_status(share_id=share_id, purchasable=False), "SQLite update failed"
        
            response_supabase = self.supabase.table("shares").update({"purchasable": True}).eq("id", share_id).execute()
        
        
            if (not (response_supabase)):
                raise Exception("Supabase update failed")
        except Exception as e:
            print(f"[bold red underline]Error removing share from sale: {e}[/bold red underline]")
        
    def remove_share_group_for_sale(self, share_group: ShareGroup):
        
        try:
            with SqliteAssistant(self.supabase) as sq:
                assert (sq.update_share_group_purchasable_status(share_group, False)), "SQLite update failed"
            
            updates = list(map(lambda x: {"id": x.id, "sale_price": x.sale_price, "purchasable": False}, share_group.shares))
            
            response_supabase = self.supabase.rpc("bulk_update_shares", {"updates": updates}).execute()
            
            if (not (response_supabase)):
                raise Exception("Supabase update failed")
            
        except Exception as e:
            print(f"[bold red underline]Error Removing share group for sale: {e}[/bold red underline]")
            
        
    