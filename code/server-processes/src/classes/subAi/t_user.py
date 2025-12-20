from classes.AI import AI
from classes.subAi.level_constants import *
import random
class T_user(AI):
    def __init__(self, supabase, sqlite_assistant, id: int, minecraft_username: str, money: int, delivery_address: str, daily_income: int, ai_type: int):
        super().__init__(supabase, sqlite_assistant, id, minecraft_username, money, delivery_address, daily_income, ai_type)
        self.name = "Null User"
        self.description = """Blank User for type checking"""
        self.investor_type = ""

# Product buying data
        
        self.randomness = random.uniform(LOW_RANDOMNESS_RANGE[FIRST], LOW_RANDOMNESS_RANGE[SECOND]) 
        self.random_range = (LOW_RANDOMNESS_RANGE[FIRST], LOW_RANDOMNESS_RANGE[SECOND]) 
        self.percentage_of_savings_to_spend = LOW_PERCENTAGE_OF_SAVINGS_TO_SPEND * self.randomness  
        self.range_of_bucket_draws = LOW_SPENDING_RANGE_OF_BUCKET_DRAWS  # Amount of purchases one will make when spending money, --> saving to spend / [3-10] = max money on singular product
        self.range_of_spending = LOW_CHANCE_TO_SPEND_MONEY # Chance to buy something --> 1/5 chance to save money on turn

        # Share evaluation data

        self.profit_margin = HIGH_PROFIT_GOALS * self.randomness
        self.loss_limit = HIGH_LOSS_LIMITS * self.randomness
        self.rapid_growth_percentage_confortability = HIGH_SHARE_RAPID_GROWTH_PERCENTAGE_CONFORTABILITY * self.randomness  
        self.reputation_point_decline_confortability = HIGH_REPUTATION_POINT_LOSS_CONFORTABILITY * self.randomness  
        self.company_sales_decline_confortability = HIGH_COMPANY_SALES_DECLINE_PERCENTAGE_CONFORTABILITY * self.randomness  
        
        # Constants for Share Scoring
        self.strategy_weights = {
            "TREND_ANALYSIS": LOW_CONTRARIAN_WEIGHT * self.randomness,
            "REPUTATION": LOW_REPUTATION_WEIGHT * self.randomness,
            "SHARE_PERFORMANCE": LOW_SHARE_PERFORMANCE_WEIGHT * self.randomness,
            "COMPANY_PERFORMANCE": LOW_COMPANY_PERFORMANCE_WEIGHT * self.randomness,
            "VALUE_ESTIMATION": LOW_VALUE_ESTIMATION_WEIGHT * self.randomness,
            "VOLATILITY_TOLERANCE": LOW_VOLATILITY_TOLERANCE_WEIGHT * self.randomness
        }
        
        # Other Constants
        self.history_scope = LOW_HISTORY_SCOPE 
        self.percentage_of_networth_to_invest = HIGH_PERCENTAGE_OF_NETWORTH_TO_INVEST 
        self.range_of_premature_sell = LOW_CHANCE_OF_PREMATURE_SELL_RANGE
        self.diversity_minimum = HIGH_PORTFOLIO_DIVERSITY_REQUIREMENTS 
