from supabase import Client

from classes.classes.buy_order import BuyOrder
from classes.classes.share import Share


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
        response = self.supabase.table("shares").update({"sale_price": sale_price, "purchasable": True}).eq("id", share_id).execute()
        
    def remove_share_for_sale(self, share_id: int):
        response =  self.supabase.table("shares").update({"purchasable": True}).eq("id", share_id).execute()
        
    