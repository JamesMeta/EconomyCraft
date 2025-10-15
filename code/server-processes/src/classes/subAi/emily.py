from classes.AI import AI
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
        High Bubble Confortability
        Low Reputation Decline Confortability
        High Company Growth Decline Confortablity
        
        Share Scoring:
        High Conformist
        High Reputation
        High Share Peformance
        Low Company Performance
        Low Value Estimation
        High Volatility Tolerance
        
        Other:
        Low Share Diversity Requirements
        High Randomness
        """
        
        self.investor_type = "CONFORMIST"
        
        # Product buying data
        
        self.percentage_of_savings_to_spend = random.uniform(0.4, 0.6)  
        self.range_of_bucket_draws = [3, random.randint(4, 10)]
        self.range_of_spending = [1, random.randint(2, 5)]

        # Share trading data

        self.profit_margin = random.uniform(0.01, 0.50)  
        self.loss_limit = random.uniform(0.1, 0.15)
        self.history_scope = 10 
        self.percentage_of_networth_to_invest = 0.15  
        self.range_of_premature_sell = [1, 10000]
        self.buy_volume_limit = random.randint(1, 5)  
        self.diversity_minimum = 0.50  

        self.strategy_weights = {
            "sales": random.uniform(0.1, 0.2),
            "reputation": random.uniform(0.35, 0.45),
            "trend_analysis": random.uniform(0.25, 0.35),
            "contrarian": random.uniform(0.05, 0.1),
            "random": random.uniform(0.10, 0.20),
            "listed_value": random.uniform(0.05, 0.1)
        }


