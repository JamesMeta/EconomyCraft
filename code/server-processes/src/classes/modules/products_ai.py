import random
import numpy as np
import math

from supabase import Client
from classes.classes.company import Company
from classes.classes.product import Product
from classes.modules.constants import PRODUCT_BUCKET_SIZE
from rich.progress import Progress
from rich import print

from classes.subAi.t_user import T_user

class ProductsAI:

    def __init__(self, supabase: Client, users: list[T_user], company_map: dict[int, Company]):

        self.supabase = supabase
        self.users = users
        self.company_map = company_map
        self.product_bucket = self.build_product_bucket()

    def make_ai_orders(self) -> None:
        """
        Simulate AI users making product orders based on their personalities.
        """

        def randomly_distribute_spending_amount(amount, num_draws) -> list[int]:
            """
            Randomly distribute a total spending amount across a number of draws.
            
            Args:
                amount: Total amount to spend
                num_draws: Number of draws to distribute the amount
            
            Returns:
                List of amounts for each draw
            """
            if num_draws <= 0:
                return []
            if num_draws == 1:
                return [amount]
            
            # Generate random distribution
            distribution = np.random.dirichlet(np.ones(num_draws)) * amount
            return [round(x) for x in distribution]


        for user in self.users:
            
            try:
                # Random chance to make an order based on user's spending profile
                if (random.randint(user.range_of_spending[0], user.range_of_spending[1]) != 1):
                    continue

                # Skip if user has no money
                if user.money <= 0:
                    continue

                # Calculate amount to spend
                percentage_of_savings_to_spend = user.percentage_of_savings_to_spend
                amount_to_spend_total = user.money * percentage_of_savings_to_spend
                number_of_draws = random.randint(user.range_of_bucket_draws[0], user.range_of_bucket_draws[1])
                amount_to_spend_random_distribution = randomly_distribute_spending_amount(amount_to_spend_total, number_of_draws)

                
                for i in range(number_of_draws):
                    # Select a random product
                    product = random.choice(self.product_bucket)
                    amount_to_spend = amount_to_spend_random_distribution[i]
                    if product.id == 0:  # Skip placeholder products
                        continue

                    if product.price > amount_to_spend:
                       continue
                    else:

                        # Calculate quantity to buy based on budget
                        quantity_to_buy = amount_to_spend // product.price
                        if quantity_to_buy > product.quantity:
                            quantity_to_buy = product.quantity
                            
                        # Place the order
                        user.place_product_order(product.id, int(quantity_to_buy))
                        # print(f"[blue]AI {user.minecraft_username} placed an order for {quantity_to_buy} of product ID {product.id} at price {product.price}.[/blue]")
                        
                        # Notification logic for non-AI company owners
                        company = self.company_map[product.company_id]
                        if not company.ai and company.notifications_enabled:
                            pass  # Placeholder for future notification system
                        break
                        
            except Exception as e:
                print(f"[bold red]AI {user.minecraft_username} encountered an error while making product orders: {e} [/bold red]")
                continue
            
    def f(self, N, V, P, S, R):
        """
        Calculate product popularity score based on various factors.
        
        Args:
            N: Niche coefficient
            V: Value
            P: Price
            S: Visibility factor
            R: Reputation
            
        Returns:
            Popularity score (number of tickets in product bucket)
        """
        return (5 * N * (2 * math.tanh((2 * V / P) - 2) + 1.85) * math.log(S + 1, 1.2)) / (1 + math.e**(-0.5 * (R - 5)))
    
    def build_product_bucket(self) -> list[Product]:
        """
        Build a weighted bucket of products based on their popularity.
        Products with higher popularity scores get more entries in the bucket.
        
        Returns:
            List of Product objects representing the weighted distribution
        """
        # Get verified products and companies
        product_response = self.supabase.table("products").select("*").eq("verified", True).execute()
        products = product_response.data

        
        

        
        # Build product bucket with weighted entries
        product_bucket = []
        
        with Progress() as progress:
            task = progress.add_task("[grey50]Building product bucket...", total=len(products))
            
            for product in products:
                company = self.company_map.get(product['company_id'])
                if not company:
                    continue
                
                # Extract product and company metrics
                niche_coefficient = product['niche_coefficient']
                value = product['value']
                price = product['price']
                reputation = company.reputation
                visibility_factor = company.visibility_factor

                # Calculate popularity score (number of tickets)
                tickets = self.f(niche_coefficient, value, price, visibility_factor, reputation)

                tickets = round(tickets)
                if tickets <= 0:
                    continue
                    
                # Create product entries based on ticket count
                product_object_list = [
                    Product(
                        id=product['id'],
                        created_at=product['created_at'],
                        name=product['name'],
                        minecraft_tag=product['minecraft_tag'],
                        company_id=product['company_id'],
                        price=product['price'],
                        quantity=product['quantity'],
                        value=product['value'],
                        niche_coefficient=product['niche_coefficient']
                    )
                ] * tickets
                product_bucket.extend(product_object_list)
                progress.update(task, advance=1)
            
        # Add placeholder products to fill bucket to fixed size
        placeholder_count = PRODUCT_BUCKET_SIZE - len(product_bucket)
        while len(product_bucket) < PRODUCT_BUCKET_SIZE:
            product_bucket.append(
                Product(
                    id=0,
                    created_at="",
                    name="",
                    minecraft_tag="",
                    company_id=0,
                    price=0.0,
                    quantity=0,
                    value=0.0,
                    niche_coefficient=0.0
                )
            )

        # Shuffle product bucket for randomness
        products_array = np.array(product_bucket, dtype=object)
        np.random.shuffle(products_array)
        return products_array.tolist()