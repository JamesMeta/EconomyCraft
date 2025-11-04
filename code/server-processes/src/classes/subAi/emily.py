from classes.AI import AI
from classes.subAi.level_constants import *
import random
class Emily(AI):
    def __init__(self, supabase, id: int, minecraft_username: str, money: int, delivery_address: str, daily_income: int, ai_type: int):
        super().__init__(supabase, id, minecraft_username, money, delivery_address, daily_income, ai_type)
        self.name = "Emily"
        self.description = """
        
        Spending Habbits:
        High Spender
        low Saver
        
        Holding Evaluations:
        Low Profit Goals
        High loss limits
        High Rapid Growth Percentage Confortability
        Low Reputation Point Decline Confortability
        High Company Growth Decline Confortablity
        
        Share Scoring:
        High Conformist
        High Reputation
        Medium Share Peformance
        Low Company Performance
        Low Value Estimation
        High Volatility Tolerance
        
        Other:
        Low Share Diversity Requirements
        Low History Scope
        Low Percentage of Networth to Invest
        High Chance of Premature Sell
        High Randomness
        """
        
        self.investor_type = "CONFORMIST"
        
        # Product buying data
        
        self.randomness = random.uniform(HIGH_RANDOMNESS_RANGE[FIRST], HIGH_RANDOMNESS_RANGE[SECOND]) 
        self.random_range = (HIGH_RANDOMNESS_RANGE[FIRST], HIGH_RANDOMNESS_RANGE[SECOND])
        self.percentage_of_savings_to_spend = HIGH_PERCENTAGE_OF_SAVINGS_TO_SPEND * self.randomness  
        self.range_of_bucket_draws = HIGH_SPENDING_RANGE_OF_BUCKET_DRAWS  # Amount of purchases one will make when spending money, --> saving to spend / [3-10] = max money on singular product
        self.range_of_spending = HIGH_CHANCE_TO_SPEND_MONEY # Chance to buy something --> 1/5 chance to save money on turn

        # Share evaluation data

        self.profit_margin = LOW_PROFIT_GOALS * self.randomness
        self.loss_limit = HIGH_LOSS_LIMITS * self.randomness
        self.rapid_growth_percentage_confortability = HIGH_SHARE_RAPID_GROWTH_PERCENTAGE_CONFORTABILITY * self.randomness  
        self.reputation_point_decline_confortability = LOW_REPUTATION_POINT_LOSS_CONFORTABILITY * self.randomness  
        self.company_sales_decline_confortability = HIGH_COMPANY_SALES_DECLINE_PERCENTAGE_CONFORTABILITY * self.randomness  
        
        # Constants for Share Scoring
        self.strategy_weights = {
            "TREND_ANALYSIS": HIGH_CONFORMIST_WEIGHT * self.randomness,
            "REPUTATION": HIGH_REPUTATION_WEIGHT * self.randomness,
            "SHARE_PERFORMANCE": MEDIUM_SHARE_PERFORMANCE_WEIGHT * self.randomness,
            "COMPANY_PERFORMANCE": LOW_COMPANY_PERFORMANCE_WEIGHT * self.randomness,
            "VALUE_ESTIMATION": LOW_VALUE_ESTIMATION_WEIGHT * self.randomness,
            "VOLATILITY_TOLERANCE": HIGH_VOLATILITY_TOLERANCE_WEIGHT * self.randomness
        }
        
        # Other Constants
        self.history_scope = LOW_HISTORY_SCOPE 
        self.percentage_of_networth_to_invest = LOW_PERCENTAGE_OF_NETWORTH_TO_INVEST 
        self.range_of_premature_sell = HIGH_CHANCE_OF_PREMATURE_SELL_RANGE
        self.diversity_minimum = LOW_PORTFOLIO_DIVERSITY_REQUIREMENTS 

        


