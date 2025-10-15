import datetime
from classes.classes.buy_order import BuyOrder
from classes.classes.share import Share
from rich.progress import Progress



class BuyOrderManager:
    
    def __init__(self, supabase):
        self.supabase = supabase
        self.buy_orders = self.get_buy_orders()
    
    def get_buy_orders(self):
        response = self.supabase.table("buy_orders").select("*").execute()
        orders = []
        
        with Progress() as progress:
            task = progress.add_task("[grey50]Loading buy orders...", total=len(response.data))
            for order_data in response.data:
                order = BuyOrder(
                    id = order_data["id"],
                    created_at=order_data["created_at"],
                    expires_at=order_data["expires_at"],
                    company_share_id=order_data["company_share_id"],
                    user_id=order_data["user_id"],
                    order_maximum=order_data["maximum_share_price"],
                    order_quantity=order_data["order_quantity"]
                )
                orders.append(order)
                progress.update(task, advance=1)
        return orders
        
    
    def place_buy_order(self, days_till_expiry, company_share_id, user_id, order_target, order_maximum, order_quantity):
        
        expires_at = (datetime.datetime.now() + datetime.timedelta(days=days_till_expiry)).isoformat()
        
        response = self.supabase.table("buy_orders").insert({
            "expires_at": expires_at,
            "company_share_id": company_share_id,
            "user_id": user_id,
            "order_target": order_target,
            "order_maximum": order_maximum,
            "order_quantity": order_quantity
        }).execute()
        
    def cancel_buy_order(self, order_id):
        response = self.supabase.table("buy_orders").delete().eq("id", order_id).execute()
        return response
    
    def update_buy_order(self, buy_order):
        buy_order.order_quantity -= 1
        response = self.supabase.table("buy_orders").update({
            "order_quantity": buy_order.order_quantity
        }).eq("id", buy_order.id).execute()
        self.cancel_buy_order(buy_order.id)
    
    def service_buy_orders(self):
        
        if not self.buy_orders:
            return
        
        current_time = datetime.datetime.now().isoformat()
        
        # Remove expired orders
        expired_response = self.supabase.table("buy_orders").delete().lt("expires_at", current_time).execute()
        
        for order in self.buy_orders:
            if order.expires_at < current_time:
                self.buy_orders.remove(order)
            else:
                self.attempt_to_fulfill_order(order)
    
    def attempt_to_fulfill_order(self, order: BuyOrder):
        shares_response = self.supabase.table("shares").select("*").eq("share_id", order.company_share_id).lt("sale_price", order.order_maximum).eq("purchasable", True).order("sale_price", desc=False).execute()
        available_shares = [Share(share_data["id"], share_data["share_id"], share_data["stake"], share_data["purchased_price"], None, share_data["purchasable"], share_data["user_id"], None, share_data["sale_price"]) for share_data in shares_response.data]
         
        for share in available_shares:
            if order.order_quantity > 0:
                self.place_share_order(order, share.id)
            else:
                self.cancel_buy_order(order.id)
                try:
                    self.buy_orders.remove(order)
                    break
                except ValueError:
                    print(f"Order {order.id} already removed from list.")
        
    
    def place_share_order(self, buy_order, share_id: int):
        response = self.supabase.rpc("purchase_share", {"buyer_id": buy_order.user_id, "input_share_id": share_id}).execute()
        self.update_buy_order(buy_order)