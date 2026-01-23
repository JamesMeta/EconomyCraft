
from cachetools import TTLCache
from supabase import Client
from classes.AI import AI
from classes.classes import buy_order
from classes.classes.buy_order import BuyOrder
from typing import *
from rich import print

from classes.classes.share import Share
from classes.classes.share_group import ShareGroup
from classes.modules.local_cache_manager import LocalCacheManager

FIRST = 0

class TradeHelper:
    
    def __init__(self, supabase: Client, local_cache_manager : LocalCacheManager):
        self.supabase = supabase
        self.local_cache_manager = local_cache_manager
        
    
    
    def get_buy_orders_for_share(self, company_share_id: int) -> List[BuyOrder]:
        
        buy_orders = self.local_cache_manager.get(f"buy_order:by_company_share:{company_share_id}")
        
        # If there is a cache hit return early
        if type(buy_orders) is list:
            return buy_orders
        
        print(f"[yellow][GET_BUY_ORDERS_FOR_SHARE]Cache Missed for company_share_id: {company_share_id}[/yellow]")
        response = self.supabase.table("buy_orders").select("*").eq("company_share_id", company_share_id).execute()
        buy_orders_raw = response.data
        
        if not buy_orders_raw or len(buy_orders_raw) == 0:
            self.local_cache_manager.set(f"buy_order:by_company_share:{company_share_id}", [], ttl=60)
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
            
            self.local_cache_manager.set(f"buy_order:by_company_share:{company_share_id}", buy_orders)
            
            return buy_orders
    
    def get_share_last_sold_for_value(self, share: Share) -> Optional[float]:
        
        price : Optional[float] = self.local_cache_manager.get(f"value:for_company_share_id:{share.company_share.id}")
        
        if (type(price) is float):
            return price
        
        print(f"[yellow][GET_SHARE_LAST_SOLD_FOR_VALUE]Cache Missed for company_share_id: {share.company_share.id}[/yellow]")
        response = self.supabase.table("company_share").select("value").eq("id", share.company_share.id).execute()
        data = response.data
        
        if (data is None or len(data) == 0):
            return None
        
        price = float(data[0]["value"])
        
        self.local_cache_manager.set(f"value:for_company_share_id:{share.company_share.id}", price, ttl=60)
        
        return price
    
    def get_lowest_for_sale_share(self, share: Share) -> Optional[float]:
        
        price : Optional[float] = self.local_cache_manager.get(f"price:for_cheapest_share_by_company_id:{share.company.id}")
        
        if (type(price) is float):
            return price

        print(f"[yellow][GET_LOWEST_FOR_SALE_SHARE]Cache Missed for share by company_id: {share.company.id}[/yellow]")
        response = self.supabase.table("shares").select("*, company_share:share_id (value, is_public, number_of_shares)").eq("company_id", share.company.id).eq("purchasable", True).execute()
        shares = response.data
        
        # If no shares on market, use the share's intrinsic value
        if not shares or len(shares) == 0:
            self.local_cache_manager.set(f"price:for_cheapest_share_by_company_id:{share.company.id}", share.company_share.value, ttl=60)
            return share.company_share.value
            
        # Find the lowest priced share and undercut it
        lowest_price_share = min(shares, key=lambda x: x['sale_price'])
        self.local_cache_manager.set(f"price:for_cheapest_share_by_company_id:{share.company.id}", float(lowest_price_share['sale_price']), ttl=60)
        return lowest_price_share['sale_price']
    
    def update_buy_orders_for_share(self, buy_order: BuyOrder):
        
        buy_orders : Optional[list[BuyOrder]] = self.local_cache_manager.get(f"buy_order:by_company_share:{buy_order.company_share_id}")
        
        # If there is a cache miss return early
        if type(buy_orders) is not list:
            print(f"[yellow][UPDATE_BUY_ORDERS_FOR_SHARE]Cache Missed for company_share_id: {buy_order.company_share_id}[/yellow]")
            return
        
        buy_orders.append(buy_order)
            
        self.local_cache_manager.set(f"buy_order:by_company_share:{buy_order.company_share_id}", buy_orders)
            

    def is_valid_buy_orders(self, share: Share, buy_orders: list[BuyOrder], last_sale_price_margin: float) -> bool:
            
        if not buy_orders or len(buy_orders) == 0:
            return False
        
        highest_value_buy_order: BuyOrder = buy_orders[FIRST]
        
        last_sold_value = self.get_share_last_sold_for_value(share=share)
        
        if last_sold_value is None:
            return False
        
        if highest_value_buy_order.order_maximum < (last_sold_value * last_sale_price_margin):
            return False
        
        return True


    # Will try to offload the share asap looking for a buy order within a realistic margin
    # If none are found it will price near the last sold price for slightly less
    def sell_now(self, user: AI, share_group: ShareGroup) -> None:
        
        buy_orders = self.get_buy_orders_for_share(company_share_id = share_group.head_share.company_share.id)
        
        if self.is_valid_buy_orders(share = share_group.head_share, buy_orders=buy_orders, last_sale_price_margin=0.9):
            
            highest_value_buy_order = buy_orders[FIRST]
            
            user.place_share_group_sell_order(share_group, highest_value_buy_order.order_maximum * 0.999)
        
        else:
            last_price = self.get_share_last_sold_for_value(share = share_group.head_share)
            
            # This shouldn't ever happen but if it somehow does just sell it somewhere near its value
            if last_price is None:
                last_price = share_group.head_share.company_share.value 
                print("[RED]SOMETHING SERIOUSLY HAS GONE WRONG WITH get_share_last_sold_for_value at trade_helper.py AS IT RETURNED NONE[/RED]")
            
            user.place_share_group_sell_order(share_group, last_price * 0.99)
            
    

    # Will try to sell the share for a profit by looking for a buy order within a profitable margin
    # If none are found it will price near the last sold price for slightly more
    def sell_gain(self, user: AI, share_group: ShareGroup) -> None:
    
        buy_orders = self.get_buy_orders_for_share(company_share_id=share_group.head_share.company_share.id)
        
        if self.is_valid_buy_orders(share=share_group.head_share, buy_orders=buy_orders, last_sale_price_margin=0.985):
            
            highest_value_buy_order = buy_orders[FIRST]

            user.place_share_group_sell_order(share_group, highest_value_buy_order.order_maximum * 0.999)
        
        else:
            last_price = self.get_share_last_sold_for_value(share=share_group.head_share)
            
            # This shouldn't ever happen but if it somehow does just sell it somewhere near its value
            if last_price is None:
                last_price = share_group.head_share.company_share.value 
                print("[RED]SOMETHING SERIOUSLY HAS GONE WRONG WITH get_share_last_sold_for_value at trade_helper.py AS IT RETURNED NONE[/RED]")
            
            user.place_share_group_sell_order(share_group, last_price * 1.01)
    