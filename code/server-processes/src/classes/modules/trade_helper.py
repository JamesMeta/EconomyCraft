
from classes.AI import AI
from classes.classes import buy_order
from classes.classes.buy_order import BuyOrder
from typing import *

from classes.classes.share import Share

FIRST = 0

class TradeHelper:
    
    def __init__(self, supabase):
        self.supabase = supabase
        
    
    
    def get_buy_orders_for_share(self, share_id: int, desc = True) -> List[BuyOrder]:
        response = self.supabase.table("buy_orders").select("*").eq("company_share_id", share_id).execute()
        buy_orders_raw = response.data
        
        if not buy_orders_raw or len(buy_orders_raw) == 0:
            return []
        
        else:
            buy_orders = [
                BuyOrder(
                    id=x["id"],
                    created_at=x["created_at"],
                    expires_at=x["expires_at"],
                    company_share_id=x["company_share_id"],
                    user_id=x["user_id"],
                    order_maximum=x["maximum_share_price"],
                    order_quantity=x["order_quantity"]
                )
                for x in buy_orders_raw
            ]
            
            buy_orders.sort(key=lambda o: o.order_maximum, reverse=desc)
            
            return buy_orders
    
    def get_share_last_sold_for_value(self, share: Share):
        response = self.supabase.table("company_share").select("value").eq("id", share.company_share_id).execute()
        data = response.data
        return data[0]["value"]
    
    def get_lowest_for_sale_share(self, share: Share) -> float:

        response = self.supabase.table("shares").select("*, company_share:share_id (value, is_public, number_of_shares)").eq("company_id", share.company.id).eq("purchasable", True).execute()
        shares = response.data
        
        # If no shares on market, use the share's intrinsic value
        if not shares or len(shares) == 0:
            return share.value
            
        # Find the lowest priced share and undercut it
        lowest_price_share = min(shares, key=lambda x: x['sale_price'])
        return lowest_price_share['sale_price']

    def is_valid_buy_orders(self, share: Share, buy_orders: list[BuyOrder], last_sale_price_margin: float) -> bool:
            
        if not buy_orders or len(buy_orders) == 0:
            return False
        
        highest_value_buy_order: BuyOrder = buy_orders[FIRST]
        
        last_sold_value = self.get_share_last_sold_for_value(share=share)
        
        if highest_value_buy_order.order_maximum < last_sold_value * last_sale_price_margin:
            return False
        
        return True


    # Will try to offload the share asap looking for a buy order within a realistic margin
    # If none are found it will price near the last sold price for slightly less
    def sell_now(self, user: AI, share: Share) -> None:
        
        buy_orders = self.get_buy_orders_for_share(share_id=share.company_share_id)
        
        if self.is_valid_buy_orders(share=share, buy_orders=buy_orders, last_sale_price_margin=0.9):
            
            highest_value_buy_order = buy_orders[FIRST]
            
            user.place_share_sell_order(share.id, highest_value_buy_order.order_maximum * 0.999)
        
        else:
            last_price = self.get_share_last_sold_for_value(share=share)
            user.place_share_sell_order(share.id, last_price * 0.99)
            
    

    # Will try to sell the share for a profit by looking for a buy order within a profitable margin
    # If none are found it will price near the last sold price for slightly more
    def sell_gain(self, user: AI, share: Share) -> None:
    
        buy_orders = self.get_buy_orders_for_share(share_id=share.company_share_id)
        
        if self.is_valid_buy_orders(share=share, buy_orders=buy_orders, last_sale_price_margin=0.985):
            
            highest_value_buy_order = buy_orders[FIRST]
            
            user.place_share_sell_order(share.id, highest_value_buy_order.order_maximum * 0.999)
        
        else:
            last_price = self.get_share_last_sold_for_value(share=share)
            user.place_share_sell_order(share.id, last_price * 1.01)
    