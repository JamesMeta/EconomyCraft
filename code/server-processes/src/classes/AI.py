from supabase import Client

from classes.classes.buy_order import BuyOrder
from classes.classes.share import Share
from classes.modules.sqlite_assistant import SqliteAssistant



class AI:
    def __init__(self, supabase: Client, sqlite_assistant: SqliteAssistant, id: int, minecraft_username: str, money: int, delivery_address: str, daily_income: int, ai_type: int):
        self.supabase = supabase
        self.sqlite_assistant = sqlite_assistant
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
        response_supabase = self.supabase.table("shares").update({"sale_price": sale_price, "purchasable": True}).eq("id", share_id).execute()
        response_sqlite = self.sqlite_assistant.update_local_share_purchasable_status(share_id=share_id, purchasable=True) and self.sqlite_assistant.update_local_share_sale_price(share_id=share_id, new_sale_price=sale_price)
        
        if (not (response_sqlite and response_supabase)):
            print("Something went wrong when placing sell order")
        
        
    def remove_share_for_sale(self, share_id: int):
        response_supabase = self.supabase.table("shares").update({"purchasable": True}).eq("id", share_id).execute()
        response_sqlite = self.sqlite_assistant.update_local_share_purchasable_status(share_id=share_id, purchasable=False)
        
        if (not (response_sqlite and response_supabase)):
            print("Something went wrong when removing share for sale")
        
        
        
    