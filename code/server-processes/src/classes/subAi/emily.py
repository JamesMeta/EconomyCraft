from classes.AI import AI
import random
class Emily(AI):
    def __init__(self, supabase, id: int, minecraft_username: str, money: int, delivery_address: str, daily_income: int, ai_type: int):
        super().__init__(supabase, id, minecraft_username, money, delivery_address, daily_income, ai_type)
        self.name = "Emily"
        self.description = "Emily is a big spender and minimal saver. She loves to buy products and is always looking for the best deals. She is not very good at saving money, but she is great at finding the best products."
        
        # Product buying data
        
        self.percentage_of_savings_to_spend = random.uniform(0.4, 0.6)  
        self.range_of_bucket_draws = [3, random.randint(4, 10)]
        self.range_of_spending = [1, random.randint(2, 5)]

        # Share trading data

        self.profit_margin = random.uniform(0.01, 0.50)  # Marcelino's profit margin for trading
        self.loss_limit = random.uniform(0.1, 0.15)  # Marcelino's loss limit for trading
        self.history_scope = 10 # Marcelino's history scope for trading
        self.percentage_of_networth_to_invest = 0.15  # Percentage of networth Marcelino ideally wants to invest in trades
        self.range_of_premature_sell = [1, 10000]
        self.buy_volume_limit = random.randint(1, 5)  # Emily's limit on the number of shares she can buy in a single transaction
        self.diversity_minimum = 0.50  # Emily's minimum diversity threshold for her portfolio


        # emily strategy weighs
        # Reputation and trend analysis are more important to Emily as she is fairly surface level and doesn't look too deep into the companies
        # Sales is lower since she doesn't care about the company's sales as much
        # Contrarian since the concept of going against the trend is not something she would do
        # Random is higher since she isnt very strategic and is more likely to make random decisions
        self.strategy_weights = {
            "sales": random.uniform(0.1, 0.2),
            "reputation": random.uniform(0.35, 0.45),
            "trend_analysis": random.uniform(0.25, 0.35),
            "contrarian": random.uniform(0.05, 0.1),
            "random": random.uniform(0.15, 0.25)
        }


