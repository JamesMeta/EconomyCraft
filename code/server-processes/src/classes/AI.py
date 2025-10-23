from supabase import Client

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
        self.networth_breakdown: dict[str, int] = {}
        
    def place_product_order(self, product_id: int, quantity: int):
        response = self.supabase.rpc("create_order_ai", {"input_row_id": self.id, "input_product_id": product_id, "input_quantity": quantity, "input_delivery_address": self.delivery_address}).execute()
        print(f"Order placed for product ID {product_id} with quantity {quantity}. Response: {response}")

    def place_share_order(self, share_id: int):
        response = self.supabase.rpc("purchase_share", {"buyer_id": self.id, "input_share_id": share_id}).execute()
    
    def place_share_sell_order(self, share_id: int, sale_price: float):
        response = self.supabase.table("shares").update({"sale_price": sale_price, "purchasable": True}).eq("id", share_id).execute()
        
    def remove_share_for_sale(self, share_id: int):
        response =  self.supabase.table("shares").update({"purchasable": True}).eq("id", share_id).execute()
        
    