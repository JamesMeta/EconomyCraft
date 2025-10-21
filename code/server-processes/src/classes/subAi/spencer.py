from classes.AI import AI
from classes.subAi.level_constants import *
import random
class Spencer(AI):
    def __init__(self, supabase, id: int, minecraft_username: str, money: int, delivery_address: str, daily_income: int, ai_type: int):
        super().__init__(supabase, id, minecraft_username, money, delivery_address, daily_income, ai_type)
        self.name = "Spencer"
        self.description = """
        
        Spending Habbits:
        High Spender
        Low Saver
        
        Holding Evaluations:
        Medium Profit Goals
        Medium loss limits
        Medium Rapid Growth Percentage Confortability
        High Reputation Decline Confortability
        Low Company Growth Decline Confortablity
        
        Share Scoring:
        Low Conformist
        Low Reputation
        High Share Peformance
        High Company Performance
        Low Value Estimation
        Medium Volatility Tolerance
        
        Other:
        Medium Share Diversity Requirements
        Low History Scope
        Medium Percentage of Networth to Invest
        Low Chance of Premature Sell
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

        self.profit_margin = MEDIUM_PROFIT_GOALS * self.randomness
        self.loss_limit = MEDIUM_LOSS_LIMITS * self.randomness
        self.rapid_growth_percentage_confortability = MEDIUM_SHARE_RAPID_GROWTH_PERCENTAGE_CONFORTABILITY * self.randomness  
        self.reputation_point_decline_confortability = HIGH_REPUTATION_POINT_LOSS_CONFORTABILITY * self.randomness  
        self.company_sales_decline_confortability = LOW_COMPANY_SALES_DECLINE_PERCENTAGE_CONFORTABILITY * self.randomness  
        
        # Constants for Share Scoring
        self.strategy_weights = {
            "CONFORMIST": LOW_CONFORMIST_WEIGHT * self.randomness,
            "REPUTATION": LOW_REPUTATION_WEIGHT * self.randomness,
            "SHARE_PERFORMANCE": HIGH_SHARE_PERFORMANCE_WEIGHT * self.randomness,
            "COMPANY_PERFORMANCE": HIGH_COMPANY_PERFORMANCE_WEIGHT * self.randomness,
            "VALUE_ESTIMATION": LOW_VALUE_ESTIMATION_WEIGHT * self.randomness,
            "VOLATILITY_TOLERANCE": MEDIUM_VOLATILITY_TOLERANCE_WEIGHT * self.randomness
        }
        
        # Other Constants
        self.history_scope = LOW_HISTORY_SCOPE 
        self.percentage_of_networth_to_invest = MEDIUM_PERCENTAGE_OF_NETWORTH_TO_INVEST 
        self.range_of_premature_sell = LOW_CHANCE_OF_PREMATURE_SELL_RANGE
        self.diversity_minimum = MEDIUM_PORTFOLIO_DIVERSITY_REQUIREMENTS 