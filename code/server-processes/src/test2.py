# Generate 10 numbers from a normal distribution with mean=0 and stddev=1

import random
for _ in range(10):
    daily_income = random.normalvariate(500, 250)
    print(daily_income)