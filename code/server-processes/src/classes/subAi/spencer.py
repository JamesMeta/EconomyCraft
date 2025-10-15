from classes.AI import AI
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
        Medium Bubble Confortability
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
        High Randomness
        """
        self.investor_type = "CONFORMIST"

        # Product buying data
        self.percentage_of_savings_to_spend = random.uniform(0.2, 0.4)  
        self.range_of_bucket_draws = [2, random.randint(4, 8)]
        self.range_of_spending = [1, random.randint(3, 6)]

        # Share trading data
        self.profit_margin = random.uniform(0.01, 0.50)  # Marcelino's profit margin for trading
        self.loss_limit = random.uniform(0.1, 0.15)  # Marcelino's loss limit for trading
        self.history_scope = 30 # Marcelino's history scope for trading
        self.percentage_of_networth_to_invest = 0.25  # Percentage of networth Marcelino ideally wants to invest in trades
        self.range_of_premature_sell = [1, 10000]
        self.buy_volume_limit = random.randint(1, 10)
        self.diversity_minimum = 0.30

        # Spencer strategy weights
        self.strategy_weights = {
            "sales": random.uniform(0.2, 0.3),
            "reputation": random.uniform(0.25, 0.35),
            "trend_analysis": random.uniform(0.2, 0.3),
            "contrarian": random.uniform(0.05, 0.15),
            "random": random.uniform(0.1, 0.2),
            "listed_value": random.uniform(0.1, 0.2)
        }