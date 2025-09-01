class Utility:
    def __init__(self, users):
        self.users = users

    def get_sum_of_strategy_weights(self):

        """        Calculate the sum of all strategy weights for all AI users.
        Returns:
            Total sum of strategy weights
        """

        strategy_weights = {
            "sales": 0.0,
            "reputation": 0.0,
            "trend_analysis": 0.0,
            "contrarian": 0.0,
            "random": 0.0,
        }

        for user in self.users:
            strategy_weights["sales"] += user.strategy_weights["sales"]
            strategy_weights["reputation"] += user.strategy_weights["reputation"]
            strategy_weights["trend_analysis"] += user.strategy_weights["trend_analysis"]
            strategy_weights["contrarian"] += user.strategy_weights["contrarian"]
            strategy_weights["random"] += user.strategy_weights["random"]
        

        return strategy_weights
    
    def print_all_users(self):
        """Print information about all AI users for debugging purposes."""
        for user in self.users:
            print(f"ID: {user.id}, Username: {user.minecraft_username}, Money: {user.money}, "
                  f"Delivery Address: {user.delivery_address}, Daily Income: {user.daily_income}, "
                  f"AI Type: {user.ai_type}")