from classes.AI import AI
import random
class James(AI):
    def __init__(self, supabase, id: int, minecraft_username: str, money: int, delivery_address: str, daily_income: int, ai_type: int):
        super().__init__(supabase, id, minecraft_username, money, delivery_address, daily_income, ai_type)
        self.name = "James"
        self.description = """
        
        Spending Habbits:
        Low Spender
        High Saver
        
        Holding Evaluations:
        Low Profit Goals
        Low loss limits
        Low Bubble Confortability
        Low Reputation Decline Confortability
        Low Company Growth Decline Confortablity
        
        Share Scoring:
        Medium Contrarian
        Medium Reputation
        High Share Peformance
        Medium Company Performance
        Low Value Estimation
        Low Volatility Tolerance
        
        Other:
        Medium Share Diversity Requirements
        Low Randomness
        """
        self.investor_type = "CONTRARIAN"
        
        # Product buying data
        self.percentage_of_savings_to_spend = random.uniform(0.05, 0.2)
        self.range_of_bucket_draws = [2, random.randint(3, 5)]  
        self.range_of_spending = [1, random.randint(4, 8)]


        # Share trading data
        self.profit_margin = random.uniform(0.35, 0.50)  # Marcelino's profit margin for trading
        self.loss_limit = random.uniform(0.1, 0.15)  # Marcelino's loss limit for trading
        self.history_scope = 90 # Marcelino's history scope for trading
        self.percentage_of_networth_to_invest = 0.85  # Percentage of networth Marcelino ideally wants to invest in trades
        self.range_of_premature_sell = [1, 10000]
        self.buy_volume_limit = random.randint(1, 10)
        self.diversity_minimum = 0.15

        # James strategy weights
        # James is a long-term trader and prefers to save money, so he values sales and reputation more 
        # he is a contrarian trader, so he values contrarian strategies more
        # he is not a short-term trader, so he values trend analysis and random strategies less
        self.strategy_weights = {
            "sales": random.uniform(0.25, 0.35),
            "reputation": random.uniform(0.2, 0.3),
            "trend_analysis": random.uniform(0.05, 0.1),
            "contrarian": random.uniform(0.2, 0.3),
            "random": random.uniform(0.05, 0.1),
            "listed_value": random.uniform(0.05, 0.15)
        }