from supabase import Client
from classes.modules.performance import Performance
from classes.modules.products_ai import ProductsAI
from classes.modules.services import Services
from classes.modules.stocks_ai import StocksAI
from classes.modules.buy_order_manager import BuyOrderManager
from classes.modules.supabase_assistant import SupabaseAssistant
from classes.modules.utility import Utility

class Administration:
    def __init__(self, supabase: Client):
        self.supabase = supabase  
        self.services = Services()
                      
    def __product_init__(self):
        self.supabase_assistant = SupabaseAssistant(self.supabase)
        self.products_ai = ProductsAI(self.supabase, self.supabase_assistant.users, self.supabase_assistant.company_map)
    
    def __stock_init__(self):
        self.supabase_assistant = SupabaseAssistant(self.supabase)
        self.performance = Performance(self.supabase, self.supabase_assistant.users, self.supabase_assistant.company_map)
        self.stocks_ai = StocksAI(
                self.supabase, 
                self.supabase_assistant.users, 
                self.supabase_assistant.company_map, 
                self.performance.company_performance_maps, 
                self.performance.company_reputation_maps, 
                self.performance.company_stock_trend_maps, 
                self.performance.company_estimated_value_map, 
                self.performance.company_listed_value_map
                )
    
    def __buy_order_init__(self):
        self.buy_order_manager = BuyOrderManager(self.supabase)
    
    def __utility_init__(self):
        self.supabase_assistant = SupabaseAssistant(self.supabase)
        self.utility = Utility(self.supabase_assistant.users)
        
    def make_ai_orders(self):
        self.products_ai.make_ai_orders()
        
    def complete_all_ai_orders(self):
        self.supabase_assistant.complete_all_ai_orders() 
        
    def make_ai_share_orders(self):
        self.stocks_ai.make_ai_share_orders()
    
    def get_current_shares(self):
        return self.stocks_ai.get_current_available_shares()
    
    def make_new_company_shares_purchaseable(self, company_id, proportion_of_shares):
        self.supabase_assistant.make_new_company_shares_purchaseable(company_id, proportion_of_shares)
        
    def modify_ai_companies_reputations(self):
        self.supabase_assistant.modify_ai_companies_reputations()
        
    def get_sum_of_strategy_weights(self):
        return self.utility.get_sum_of_strategy_weights(self.supabase_assistant.users)
    
    def service_buy_orders(self):
        self.buy_order_manager.service_buy_orders()
    
    def print_all_users(self):
        self.utility.print_all_users(self.supabase_assistant.users)
        