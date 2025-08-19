from classes.AI import AI
import random
class Harsh(AI):
    def __init__(self, supabase, id: int, minecraft_username: str, money: int, delivery_address: str, daily_income: int, ai_type: int):
        super().__init__(supabase, id, minecraft_username, money, delivery_address, daily_income, ai_type)
        self.name = "Harsh"
        self.description = "Harsh is a moderate trader and a light consumer. He is cautious with his spending and prefers to save money for future investments."


        # Product buying data

        self.percentage_of_savings_to_spend = random.uniform(0.05, 0.2)  
        self.range_of_bucket_draws = [2, random.randint(4, 8)]
        self.range_of_spending = [1, random.randint(3, 7)]


        # Share trading data

        self.profit_margin = random.uniform(0.15, 0.25)  # Harsh's profit margin for trading
        self.loss_limit = random.uniform(0.05, 0.1)  # Harsh's loss limit for trading
        self.history_scope = 30
        self.percentage_of_networth_to_invest = 0.7  # Percentage of networth Harsh ideally wants to invest in trades
        self.range_of_premature_sell = [1, 5000]
        self.buy_volume_limit = random.randint(1, 15)
        self.diversity_minimum = 0.20
        
        # Harsh strategy weights
        # balanced between sales, reputation, and contrarian since harsh is a medium term trader
        # less value on trend analysis and random since he is not a short-term trader and makes strategic decisions
        self.strategy_weights = {
            "sales": random.uniform(0.25, 0.35),
            "reputation": random.uniform(0.2, 0.3),
            "trend_analysis": random.uniform(0.1, 0.20),
            "contrarian": random.uniform(0.2, 0.3),
            "random": random.uniform(0.05, 0.1)
        }
