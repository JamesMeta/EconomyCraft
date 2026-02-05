from datetime import datetime, timedelta, timezone
from supabase import Client

from classes.classes.company import Company
from classes.classes.local_share import LocalShare
from classes.classes.order import Order
from classes.classes.player import Player
from classes.classes.subAi.t_user import T_user

from rich import print
from rich.progress import Progress

from classes.modules.sqlite_assistant import SqliteAssistant

PAYOUT_RATIO = 0.35
MINIMUM_VALUE_TO_PAYOUT = 1.0


class DividendManager:
    
    def __init__(self, supabase: Client, AI_users: list[T_user], player_users: list[Player], companies_map: dict[int, Company]):
        
        self.supabase = supabase
        self.AI_users = AI_users
        self.player_users = player_users
        self.companies_map = companies_map
        
        with SqliteAssistant(self.supabase) as sq:
            self.shares = sq.get_all_local_shares()
    
    def get_orders_completed_today(self) -> list[Order]:
        
        twenty_four_hours_ago = (datetime.now(timezone.utc) - timedelta(hours=24)).isoformat()
        
        response = (
            self.supabase.table("orders")
            .select("*")
            .gte("completed_at", twenty_four_hours_ago)
            .execute()
        )
        
        orders = response.data
        orders_list = []
        
        if(orders):
                
            for order_raw in orders:
                order = Order(order_raw["id"], order_raw["created_at"], order_raw["product_id"], order_raw["company_id"], order_raw["delivery_address"], order_raw["quantity"], order_raw["payment"], order_raw["order_timeout"], order_raw["complete"], order_raw["user_id"], order_raw["received"])
                orders_list.append(order)

                
        return orders_list  
    
    def calculate_today_company_income(self) -> dict[int, float]:
        
        income_map = {c.id: 0.0 for c in self.companies_map.values()}
        
        orders = self.get_orders_completed_today()
            
        for o in orders:
            
            if o.company_id in income_map:
                income_map[o.company_id] += o.payment
            
            else:
                print("[red]Something has gone wrong when calculating today_company_income since order company_id wasn't in the company_map[/red]")
                

                    
                
        return income_map
    
    def calculate_company_user_ownership_spread(self) -> dict[int, dict[int, float]]:
        
        # {company_id: {user_id: total_stake}}
        company_user_ownership_spread: dict[int, dict[int, float]] = {c: {} for c in self.companies_map.keys()}
        
        with Progress() as progress:
        
            task = progress.add_task("[grey50]Calculating User Ownership Spread...", total=len(self.shares))
        
            for share in self.shares:
                
                if share.company_id in company_user_ownership_spread:
                    user_ownership_spread = company_user_ownership_spread[share.company_id]
                    if share.user_id in user_ownership_spread:
                        user_ownership_spread[share.user_id] += share.stake
                    else:
                        user_ownership_spread[share.user_id] = share.stake
                else:
                    print("[red]Something has gone wrong when building company_user_ownership_spread as a shares company id wasn't in the spread[/red]")
                    
                progress.update(task, advance=1)
        
        return company_user_ownership_spread
    
    def calculate_today_company_income_to_payout(self) -> dict[int, float]:
        
        with Progress() as progress:
            
            task = progress.add_task("[grey50]Calculating Company Income To Payout...", total=1)
        
            today_company_incomes = self.calculate_today_company_income()
            
            for company_id in today_company_incomes.keys():
                today_company_incomes[company_id] *= PAYOUT_RATIO
            
            progress.update(task, advance=1)
        
        return today_company_incomes
            
    
    def calculate_user_share_of_income_to_payout(self) -> dict[int, dict[int, float]]:
        
        today_company_incomes_to_payout = self.calculate_today_company_income_to_payout()
        company_user_ownership_spread = self.calculate_company_user_ownership_spread()
        
        # {company_id: {user_id: total_payout}}
        user_share_of_income_to_payout: dict[int, dict[int, float]] = {c: {} for c in self.companies_map.keys()}
        
        with Progress() as progress:
            
            task = progress.add_task("[grey50]Calculating User Share Of Income To Payout...", total=len(company_user_ownership_spread))
        
            for company_id, user_ownership_spread in company_user_ownership_spread.items():
                
                for user_id, stake in user_ownership_spread.items():
                    
                    user_share_of_income_to_payout[company_id][user_id] = today_company_incomes_to_payout[company_id] * stake
            
                progress.update(task, advance=1)
        
        return user_share_of_income_to_payout
    
    def fetch_formatted_payments(self, bonus) -> list[dict]:
        
        # {company_id: {user_id: total_payout}}
        user_share_of_income_to_payout = self.calculate_user_share_of_income_to_payout()
        
        formatted_payments: list[dict] = []
        
        with Progress() as progress:
            
            task = progress.add_task("[grey50]Formatting Payments...", total=len(user_share_of_income_to_payout))
        
            for company_id, user_income_to_payout in user_share_of_income_to_payout.items():
                company_owner_id = self.companies_map[company_id].user_id
                
                for shareholder_id, income_to_payout in user_income_to_payout.items():
                    
                    payment = income_to_payout * bonus
                    
                    if shareholder_id == company_owner_id:
                        continue
                    
                    if payment < MINIMUM_VALUE_TO_PAYOUT:
                        continue
                    
                    payment_to_share_holder = {"payer_id": company_owner_id, "payee_id": shareholder_id, "amount": payment}
                    formatted_payments.append(payment_to_share_holder)
                    
                progress.update(task, advance=1)
        
        return formatted_payments
        
    
    def payout_user_share_of_company_income(self, bonus = 1):
        
        formatted_payments = self.fetch_formatted_payments(bonus)
        
        self.supabase.rpc("make_payments", {"payment_data" : formatted_payments}).execute()
        
        print(f"[purple][{datetime.now().replace(second=0, microsecond=0)}] Shareholders paid successfully[/purple]")
        
        
       
                
                
        
        
        
                
            
            
            
            
            
            
            
            
            
            
            
    
    
    