from classes.AI import AI
from classes.subAi.level_constants import *
import random
class Harsh(AI):
    def __init__(self, supabase, id: int, minecraft_username: str, money: int, delivery_address: str, daily_income: int, ai_type: int):
        super().__init__(supabase, id, minecraft_username, money, delivery_address, daily_income, ai_type)
        self.name = "Harsh"
        self.description = """
        
        Spending Habbits:
        Low Spender
        Medium Saver
        
        Holding Evaluations:
        Medium Profit Goals
        Low loss limits
        Medium Rapid Growth Percentage Confortability
        High Reputation Decline Confortability
        Low Company Growth Decline Confortablity
        
        Share Scoring:
        High Contrarian
        Low Reputation
        Medium Share Peformance
        Medium Company Performance
        High Value Estimation
        Medium Volatility Tolerance
        
        Other:
        Medium Share Diversity Requirements
        Medium History Scope
        High Percentage of Networth to Invest
        Low Chance of Premature Sell
        Low Randomness
        """
        self.investor_type = "CONTRARIAN"


        # Product buying data
        
        self.randomness = random.uniform(LOW_RANDOMNESS_RANGE[FIRST], LOW_RANDOMNESS_RANGE[SECOND]) 
        self.percentage_of_savings_to_spend = MEDIUM_PERCENTAGE_OF_SAVINGS_TO_SPEND * self.randomness  
        self.range_of_bucket_draws = LOW_SPENDING_RANGE_OF_BUCKET_DRAWS  # Amount of purchases one will make when spending money, --> saving to spend / [3-10] = max money on singular product
        self.range_of_spending = MEDIUM_CHANCE_TO_SPEND_MONEY # Chance to buy something --> 1/5 chance to save money on turn

        # Share evaluation data

        self.profit_margin = MEDIUM_PROFIT_GOALS * self.randomness
        self.loss_limit = LOW_LOSS_LIMITS * self.randomness
        self.rapid_growth_percentage_confortability = MEDIUM_SHARE_RAPID_GROWTH_PERCENTAGE_CONFORTABILITY * self.randomness  
        self.reputation_point_decline_confortability = HIGH_REPUTATION_POINT_LOSS_CONFORTABILITY * self.randomness  
        self.company_sales_decline_confortability = LOW_COMPANY_SALES_DECLINE_PERCENTAGE_CONFORTABILITY * self.randomness  
        
        # Constants for Share Scoring
        self.strategy_weights = {
            "CONTRARIAN": HIGH_CONTRARIAN_WEIGHT * self.randomness,
            "REPUTATION": LOW_REPUTATION_WEIGHT * self.randomness,
            "SHARE_PERFORMANCE": MEDIUM_SHARE_PERFORMANCE_WEIGHT * self.randomness,
            "COMPANY_PERFORMANCE": MEDIUM_COMPANY_PERFORMANCE_WEIGHT * self.randomness,
            "VALUE_ESTIMATION": HIGH_VALUE_ESTIMATION_WEIGHT * self.randomness,
            "VOLATILITY_TOLERANCE": MEDIUM_VOLATILITY_TOLERANCE_WEIGHT * self.randomness
        }
        
        # Other Constants
        self.history_scope = MEDIUM_HISTORY_SCOPE 
        self.percentage_of_networth_to_invest = HIGH_PERCENTAGE_OF_NETWORTH_TO_INVEST 
        self.range_of_premature_sell = HIGH_CHANCE_OF_PREMATURE_SELL_RANGE
        self.diversity_minimum = MEDIUM_PORTFOLIO_DIVERSITY_REQUIREMENTS 

