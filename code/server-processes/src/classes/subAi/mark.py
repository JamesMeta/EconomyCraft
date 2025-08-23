from classes.AI import AI
import random
class Mark(AI):
    def __init__(self, supabase, id: int, minecraft_username: str, money: int, delivery_address: str, daily_income: int, ai_type: int):
        super().__init__(supabase, id, minecraft_username, money, delivery_address, daily_income, ai_type)
        self.name = "Mark"
        self.description = "Mark is a private equity investor and a light consumer"

        # Product buying data
        self.percentage_of_savings_to_spend = random.uniform(0.1, 0.2)  
        self.range_of_spending = [1, random.randint(4, 10)]
        self.range_of_bucket_draws = [1, random.randint(1, 2)]  

        # Share trading data
        self.profit_margin = random.uniform(0.60, 0.80)  # Marcelino's profit margin for trading
        self.loss_limit = random.uniform(0.3, 0.5)  # Marcelino's loss limit for trading
        self.history_scope = 90 # Marcelino's history scope for trading
        self.percentage_of_networth_to_invest = 0.90  # Percentage of networth Marcelino ideally wants to invest in trades
        self.range_of_premature_sell = [1, 5000]
        self.buy_volume_limit = random.randint(1, 30)
        self.diversity_minimum = 0.20

        # Mark strategy weights
        # Mark is a portfolio manager and a private equity investor he does not care about sales or reputation 
        # he is a contrarian investor and a long-term investor
        # he is also a strategic investor and does not rely on random decisions
        self.strategy_weights = {
            "sales": random.uniform(0.2, 0.3),
            "reputation": random.uniform(0.1, 0.2),
            "trend_analysis": random.uniform(0.05, 0.1),
            "contrarian": random.uniform(0.4, 0.5),
            "random": random.uniform(0.05, 0.1),
            "listed_value": random.uniform(0.1, 0.2)
        }