import datetime
from re import L

from supabase import Client
from classes.classes.buy_order import BuyOrder
from classes.classes.company import Company
from classes.classes.company_share import CompanyShare
from classes.classes.local_share import LocalShare
from classes.classes.share import Share
from rich import print
import datetime

from classes.modules.sqlite_assistant import SqliteAssistant


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
    
    def update_buy_order(self, buy_order: BuyOrder, quantity_purchased: int) -> None:
        buy_order.order_quantity -= quantity_purchased
        
        if buy_order.order_quantity > 0:
        
            self.supabase.table("buy_orders").update({
                "order_quantity": buy_order.order_quantity
            }).eq("id", buy_order.id).execute()
        
        else:
            self.cancel_buy_order(buy_order.id)
    
    def service_buy_orders(self) -> None:
        
        if not self.buy_orders:
            return 
        
        current_time = datetime.datetime.now().isoformat()
        
        try:
            # Remove expired orders
            self.supabase.table("buy_orders").delete().lt("expires_at", current_time).execute()
            self.supabase.table("buy_orders").delete().lt("order_quantity", 1).execute()
            
            for order in self.buy_orders:
                if order.expires_at < current_time:
                    self.buy_orders.remove(order)
                elif order.order_quantity <= 0:
                    self.buy_orders.remove(order)
                else:
                    self.attempt_to_fulfill_order(order)
        except Exception as e:
            print(f"[bold red underline]Error servicing buy orders{e}[/bold red underline]")
        
        
    
    def attempt_to_fulfill_order(self, order: BuyOrder) -> None:
        max_quantity = min(order.order_quantity, 5000)
        shares_response = self.supabase.table("shares").select("*").neq('user_id', order.user_id).eq("share_id", order.company_share_id).lt("sale_price", order.order_maximum).eq("purchasable", True).order("sale_price", desc=False).limit(max_quantity).execute()
        share_data: list[dict] = shares_response.data if shares_response.data is not None else []
        
        available_share_ids = list(map(lambda x: x["id"], share_data))
        
        # # filtered_available_shares = filter(lambda x: x.user_id != order.user_id, available_shares)
        # filtered_available_shares = available_shares
        
        num_available_shares = len(available_share_ids)
        
        if num_available_shares == 0: return
        
        self.place_share_order(order, available_share_ids)
        
        # for share in filtered_available_shares:
        #     if order.order_quantity > 0:
        #         self.place_share_order(order, share.id)
        #         print(f"[blue][{datetime.datetime.now().replace(second=0, microsecond=0)}] Completing buy order for user: {order.user_id} and company share id: {order.company_share_id}[/blue]")
        #     else:
        #         self.cancel_buy_order(order.id)
        #         try:
        #             self.buy_orders.remove(order)
        #             break
        #         except ValueError:
        #             print(f"[bold red underline] Order {order.id} already removed from list.[/bold red underline]")
        
    
    def place_share_order(self, buy_order: BuyOrder, share_ids: list[int]) -> None:
        try:
            with SqliteAssistant(self.supabase) as sq: 
                assert sq.update_local_shares_owner(share_ids, buy_order.user_id)
                assert sq.update_local_shares_purchased_price_post_transaction(share_ids)
                
            self.supabase.rpc(
                "purchase_list_of_shares",
                {
                    "buyer_id": buy_order.user_id,
                    "input_shares": share_ids
                }
            ).execute()
            self.update_buy_order(buy_order, len(share_ids))
            print(f"[blue][{datetime.datetime.now().replace(second=0, microsecond=0)}] Completing buy order for user: {buy_order.user_id} and company share id: {buy_order.company_share_id} by purchasing shares with Ids {share_ids}[/blue]")
        except Exception as e:
            print(f"[bold red underline]Something went wrong when when placing the share order with id: {buy_order.id} error: {e}[/bold red underline]") 
            
        