import matplotlib.pyplot as plt
sale_price = 20
iterations = 125
shares_over_time = []
for i in range(iterations):
    if i <= iterations // 4:
        sale_price *=1.00025
    elif i <= iterations // 2:
        sale_price *= 1.0005
    elif i <= (iterations // 1.25):
        sale_price *= 1.001
    else:
        sale_price *= 1.0025
    shares_over_time.append(sale_price)

plt.bar(range(iterations), shares_over_time, color='blue')
plt.xlabel('Iteration')
plt.ylabel('Share Value')
plt.title('Share Value Over Time')
plt.show()
