import math
import numpy as np


class Volatility:
    
    def __init__(self, data_points: list[float]):
        
        self.average = np.mean(data_points)
        self.data_max = max(data_points)
        self.data_min = min(data_points)
        self.volatility = self.calculate_volatility(data_points, self.average)
    
    def calculate_volatility(self, data_points: list[float], average):
        
        returns = np.diff(data_points) / data_points[:-1]
        
        hourly_volatility = np.std(returns, ddof=1)
        daily_volatility = hourly_volatility * np.sqrt(24)
        
        if daily_volatility != 0:
            scored_volatility = math.log(0.1/daily_volatility, 10)
        else:
            scored_volatility = 0.6
        
        return scored_volatility
        
    
        
        
            