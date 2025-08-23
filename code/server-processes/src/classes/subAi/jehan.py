from classes.AI import AI
import random
class Jehan(AI):
    def __init__(self, supabase, id: int, minecraft_username: str, money: int, delivery_address: str, daily_income: int, ai_type: int):
        super().__init__(supabase, id, minecraft_username, money, delivery_address, daily_income, ai_type)
        self.name = "Jehan"
        self.description = "Jehan is a risky and active trader who is a moderate consumer."


        # Product buying data

        self.percentage_of_savings_to_spend = random.uniform(0.2, 0.4)  
        self.range_of_bucket_draws = [2, random.randint(3, 5)]  
        self.range_of_spending = [1, random.randint(3, 6)]


        # Share trading data

        self.profit_margin = random.uniform(0.01, 0.05)  # Jehan's profit margin for trading
        self.loss_limit = random.uniform(0.005, 0.025)  # Jehan's loss limit for trading
        self.history_scope = 10
        self.percentage_of_networth_to_invest = 0.5  # Percentage of networth Jehan ideally wants to invest in trades
        self.range_of_premature_sell = [1, 2500]
        self.buy_volume_limit = random.randint(1, 20)
        self.diversity_minimum = 0.25  # Jehans portfolio at any time can only be 25% in one company

        # Jehan strategy weighs 
        # Balanced between sales, reputation, trend analysis 
        # Contrarian is lower since he is a short-term trader
        # Random is lower since he is a strategic trader
        self.strategy_weights = {
            "sales": random.uniform(0.2, 0.30),
            "reputation": random.uniform(0.2, 0.30),
            "trend_analysis": random.uniform(0.2, 0.4),
            "contrarian": random.uniform(0.05, 0.1),
            "random": random.uniform(0.05, 0.1),
            "listed_value": random.uniform(0.05, 0.15)
        }
