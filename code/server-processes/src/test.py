import matplotlib.pyplot as plt
import random


money = 3040
daily_income = 100


data = []
for day in range(1, 360):
    daily_income *= 1.01
    money += daily_income
    savings_spending_percentage = random.uniform(0.4, 0.6)  
    ranges = [1, random.randint(1, 3)]

    if random.randint(ranges[0],ranges[1]) == 1:
        money -= money * savings_spending_percentage

    data.append(money)

print(f"Final money after 1 year: {money}")
print(f"Final daily income after 1 year: {daily_income}")

plt.figure(figsize=(10, 5))
plt.plot(data, label='Money Over Time', color='blue')
plt.title('Money Over Time with Daily Income and Spending')
plt.xlabel('Days')
plt.ylabel('Money')
plt.grid(True)
plt.legend()
plt.show()
