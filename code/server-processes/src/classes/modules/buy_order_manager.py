import datetime
from re import L

from supabase import Client
from classes.classes.buy_order import BuyOrder
from classes.classes.share import Share
from rich import print
import datetime


class BuyOrderManager:
    
    def __init__(self, supabase: Client):
        self.supabase = supabase
        self.buy_orders = self.get_buy_orders()
    
    def get_buy_orders(self) -> list[BuyOrder]:
        response = self.supabase.table("buy_orders").select("*").execute()
        orders = []
        
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

        return orders
        
    
    def place_buy_order(self, days_till_expiry, company_share_id, user_id, order_target, order_maximum, order_quantity) -> None:
        
        expires_at = (datetime.datetime.now() + datetime.timedelta(days=days_till_expiry)).isoformat()
        
        self.supabase.table("buy_orders").insert({
            "expires_at": expires_at,
            "company_share_id": company_share_id,
            "user_id": user_id,
            "order_target": order_target,
            "order_maximum": order_maximum,
            "order_quantity": order_quantity
        }).execute()
        
    def cancel_buy_order(self, order_id) -> None:
        self.supabase.table("buy_orders").delete().eq("id", order_id).execute()
    
    def update_buy_order(self, buy_order) -> None:
        buy_order.order_quantity -= 1
        self.supabase.table("buy_orders").update({
            "order_quantity": buy_order.order_quantity
        }).eq("id", buy_order.id).execute()
        self.cancel_buy_order(buy_order.id)
    
    def service_buy_orders(self) -> None:
        
        if not self.buy_orders:
            return
        
        current_time = datetime.datetime.now().isoformat()
        
        # Remove expired orders
        self.supabase.table("buy_orders").delete().lt("expires_at", current_time).execute()
        
        for order in self.buy_orders:
            if order.expires_at < current_time:
                self.buy_orders.remove(order)
            else:
                self.attempt_to_fulfill_order(order)
    
    def attempt_to_fulfill_order(self, order: BuyOrder) -> None:
        shares_response = self.supabase.table("shares").select("*, company_share:share_id (id, value, is_public, number_of_shares)").eq("share_id", order.company_share_id).lt("sale_price", order.order_maximum).eq("purchasable", True).order("sale_price", desc=False).execute()
        
        available_shares = [Share(share_data["id"], share_data["share_id"], share_data["stake"], share_data["purchased_price"], share_data['company_share']['value'], share_data["purchasable"], share_data["user_id"], share_data['company_share']['is_public'], share_data["sale_price"], share_data['company_share']['id']) for share_data in shares_response.data]
        
        filtered_available_shares = filter(lambda x: x.user_id != order.user_id, available_shares)
         
        for share in filtered_available_shares:
            if order.order_quantity > 0:
                self.place_share_order(order, share.id)
                print(f"[blue][{datetime.datetime.now().replace(second=0, microsecond=0)}] Completing buy order for user: {order.user_id} and company share id: {order.company_share_id}[/blue]")
            else:
                self.cancel_buy_order(order.id)
                try:
                    self.buy_orders.remove(order)
                    break
                except ValueError:
                    print(f"[bold red underline] Order {order.id} already removed from list.[/bold red underline]")
        
    
    def place_share_order(self, buy_order, share_id: int) -> None:
        try:
            self.supabase.rpc("purchase_share", {"buyer_id": buy_order.user_id, "input_share_id": share_id}).execute()
            self.update_buy_order(buy_order)
        except Exception as e:
            print(f"[bold red underline]{e}[/bold red underline]") 
            
        