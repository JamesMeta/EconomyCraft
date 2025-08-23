from classes.subAi.james import James
from classes.subAi.emily import Emily
from classes.subAi.spencer import Spencer
from classes.subAi.jehan import Jehan
from classes.subAi.harsh import Harsh
from classes.subAi.marcelino import Marcelino
from classes.subAi.mark import Mark
from classes.utility.company import Company
from classes.utility.product import Product
from classes.utility.share import Share
import math
import numpy as np
import datetime
import os
import time
import random
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from rich import print 
from rich.progress import Progress

# Constants for analysis time periods
TIME_PERIOD_SHORT = 10  # 10 days
TIME_PERIOD_MEDIUM = 30  # 30 days
TIME_PERIOD_LONG = 90   # 90 days

# Financial constants
SHARE_UNDERCUT_PERCENTAGE = 0.995  # Undercut by 0.5%
NO_MARKET_PRICE_INCREASE = 1.01   # Increase by 1% when no market shares

# Product bucket constants
PRODUCT_BUCKET_SIZE = 2000

# Database placeholders
DEFAULT_RETURN_NO_DATA = -1
DEFAULT_RETURN_NO_CHANGE = 0

class Administration:
    def __init__(self, supabase):
        """
        Initialize the Administration class which manages AI users, products, and companies.
        
        Args:
            supabase: Supabase client instance for database operations
        """
        self.supabase = supabase
        self.company_map = {}
        self.users = self.get_all_users()
        self.product_bucket = self.build_product_bucket()
        self.company_performance_maps = {0:{}, TIME_PERIOD_SHORT:{}, TIME_PERIOD_MEDIUM:{}, TIME_PERIOD_LONG:{}}
        self.company_reputation_maps = {0:{}, TIME_PERIOD_SHORT:{}, TIME_PERIOD_MEDIUM:{}, TIME_PERIOD_LONG:{}}
        self.company_stock_trend_maps = {0:{}, TIME_PERIOD_SHORT:{}, TIME_PERIOD_MEDIUM:{}, TIME_PERIOD_LONG:{}}
        self.company_estimated_value_map = {}
        self.company_listed_value_map = {}
        self.build_company_performance_maps()
        
    #-------------------------------------------------------------------------
    # User Management Functions
    #-------------------------------------------------------------------------
    
    def get_all_users(self):
        """
        Retrieve all AI users from the database and instantiate the appropriate AI class.
        
        Returns:
            List of AI user instances
        """
        response = self.supabase.table("users").select("*").eq("ai", True).execute()
        data = response.data
        users_list = []

        for user in data:
            try:
                if user['ai_type'] == 3:
                    ai = James(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                elif user['ai_type'] == 1:
                    ai = Emily(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                elif user['ai_type'] == 2:
                    ai = Spencer(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                elif user['ai_type'] == 4:
                    ai = Jehan(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                elif user['ai_type'] == 5:
                    ai = Harsh(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                elif user['ai_type'] == 6:
                    ai = Marcelino(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                elif user['ai_type'] == 7:
                    ai = Mark(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                else:
                    print(f"[yellow]Unknown AI type for {user} - skipping.[/yellow]")
                    continue
                
                users_list.append(ai)
            except Exception as e:
                print(f"[bold red]Error creating AI for user {user['minecraft_username']}: {e} [/bold red]")
        
        print(f"[dim white]Loaded {len(users_list)} AI users from the database.[/dim white]")
        return users_list
    
    def get_user_networth_breakdown(self, user_id: int):
        """
        Calculate a user's networth breakdown including liquid assets and share assets.
        
        Args:
            user_id: ID of the user
            
        Returns:
            Dictionary containing liquid assets, share assets, and total networth
        """
        response_shares = self.supabase.table("shares").select("*, company_share:share_id (value, is_public, number_of_shares)").eq("user_id", user_id).execute()
        response_user = self.supabase.table("users").select("*").eq("id", user_id).execute()
        shares = response_shares.data
        user = response_user.data[0]

        liquid_assets = user['money']
        share_assets = 0.0
        for share in shares:
            company_share = share['company_share'] 
            share_assets += company_share['value'] 
            
        
        networth = liquid_assets + share_assets
        networth_breakdown = {
            "LIQUID_ASSETS": liquid_assets,
            "SHARE_ASSETS": share_assets,
            "NETWORTH": networth
        }
        return networth_breakdown
        
    def print_all_users(self):
        """Print information about all AI users for debugging purposes."""
        for user in self.users:
            print(f"ID: {user.id}, Username: {user.minecraft_username}, Money: {user.money}, "
                  f"Delivery Address: {user.delivery_address}, Daily Income: {user.daily_income}, "
                  f"AI Type: {user.ai_type}")

    def get_user_owned_shares(self, user_id):
        """
        Get all shares owned by a specific user.
        
        Args:
            user_id: ID of the user
            
        Returns:
            List of Share objects owned by the user
        """
        response = self.supabase.table("shares").select("*, company_share:share_id (value, is_public, number_of_shares)").eq("user_id", user_id).execute()
        shares = response.data
        user_shares = []
        for share in shares:
            company_share = share['company_share']
            company = self.company_map.get(share['company_id'])
            if not company or company_share['is_public'] is False:
                continue
            
            share_object = Share(
                id=share['id'],
                company=company,
                stake=share['stake'],
                purchased_price=share['purchased_price'],
                value= company_share['value'],
                purchasable=share['purchasable'],
                user_id=share['user_id'],
                is_public = company_share['is_public'],
                sale_price=share['sale_price'],
            )
            user_shares.append(share_object)
        return user_shares


    #-------------------------------------------------------------------------
    # Company and Product Related Functions
    #-------------------------------------------------------------------------
    
    def build_company_performance_maps(self):
        """
        Build maps of company performance and reputation metrics for different time periods.
        Used for AI decision making when investing.
        """
        with Progress() as progress:

            task = progress.add_task("[grey50]Building company performance maps...", total=len(self.company_map))

            for company in self.company_map.values():
                # Build performance (revenue) maps
                self.company_performance_maps[TIME_PERIOD_SHORT][company.id] = self.get_company_rate_of_revenue_change_over_time(company.id, TIME_PERIOD_SHORT)
                self.company_performance_maps[TIME_PERIOD_MEDIUM][company.id] = self.get_company_rate_of_revenue_change_over_time(company.id, TIME_PERIOD_MEDIUM)
                self.company_performance_maps[TIME_PERIOD_LONG][company.id] = self.get_company_rate_of_revenue_change_over_time(company.id, TIME_PERIOD_LONG)
                
                # Build reputation maps
                self.company_reputation_maps[TIME_PERIOD_SHORT][company.id] = self.get_company_rate_of_reputation_change_over_time(company.id, TIME_PERIOD_SHORT)
                self.company_reputation_maps[TIME_PERIOD_MEDIUM][company.id] = self.get_company_rate_of_reputation_change_over_time(company.id, TIME_PERIOD_MEDIUM)
                self.company_reputation_maps[TIME_PERIOD_LONG][company.id] = self.get_company_rate_of_reputation_change_over_time(company.id, TIME_PERIOD_LONG)

                # Build trend and contrarian analysis maps
                self.company_stock_trend_maps[TIME_PERIOD_SHORT][company.id] = self.get_company_share_value_change_over_time(company.id, TIME_PERIOD_SHORT)
                self.company_stock_trend_maps[TIME_PERIOD_MEDIUM][company.id] = self.get_company_share_value_change_over_time(company.id, TIME_PERIOD_MEDIUM)
                self.company_stock_trend_maps[TIME_PERIOD_LONG][company.id] = self.get_company_share_value_change_over_time(company.id, TIME_PERIOD_LONG)

                # Build estimated value map
                self.company_estimated_value_map[company.id] = self.calculate_company_estimated_value(company.id)
                self.company_listed_value_map[company.id] = self.calculate_company_listed_value(company.id)


                progress.update(task, advance=1)
    
    def calculate_company_estimated_value(self, company_id: int):

        """
        Calculate the estimated value of a company based on its revenue

        """

        response = self.supabase.table("orders").select("*").eq("company_id", company_id).execute()
        orders = response.data

        if not orders or len(orders) == 0:
            return DEFAULT_RETURN_NO_DATA
        
        orders_last_30_days = [order for order in orders if (datetime.datetime.now(datetime.timezone.utc) - datetime.datetime.fromisoformat(order['created_at'])).days <= 30]

        if not orders_last_30_days or len(orders_last_30_days) == 0:
            return DEFAULT_RETURN_NO_DATA
        
        total_revenue = sum(order['payment'] for order in orders_last_30_days)

        return total_revenue 

    def calculate_company_listed_value(self, company_id: int):

        """
        Calculate the listed value of a company based on its shares

        """

        response = self.supabase.table("company_share").select("*").eq("company_id", company_id).execute()
        company_shares = response.data

        if not company_shares or len(company_shares) == 0:
            return DEFAULT_RETURN_NO_DATA
        
        company_share = company_shares[0]

        listed_value = company_share['value'] * company_share['number_of_shares']

        return listed_value

    def get_company_rate_of_reputation_change_over_time(self, company_id: int, history_scope: int):
        """
        Calculate the rate of change of a company's reputation over a specific time period.
        
        Args:
            company_id: ID of the company
            history_scope: Number of days to analyze
            
        Returns:
            Rate of reputation change as a decimal (e.g., 0.05 = 5% increase)
        """
        response = self.supabase.table("company_history").select("*").eq("company_id", company_id).order("created_at", desc=False).limit(history_scope).execute()
        company_history = response.data
        
        # If no history data, return no change
        if not company_history or len(company_history) < 2:
            return DEFAULT_RETURN_NO_CHANGE
            
        # --------------------
        # Find slope of reputation change
        # --------------------

        time_dt = [datetime.datetime.fromisoformat(entry['created_at']) for entry in company_history]
        reputation_dx = [entry['reputation'] for entry in company_history]

        start_date = time_dt[0]
        time_numeric = np.array([(dt - start_date).days for dt in time_dt])

        slope, intercept = np.polyfit(time_numeric, reputation_dx, 1)

        return slope
    
    def get_company_rate_of_revenue_change_over_time(self, company_id: int, history_scope: int):
        """
        Calculate the rate of change of a company's revenue over a specific time period.
        
        Args:
            company_id: ID of the company
            history_scope: Number of days to analyze
            
        Returns:
            Rate of revenue change as a decimal (e.g., 0.05 = 5% increase)
        """
        # Get all orders for this company
        response = self.supabase.table("orders").select("*").eq("company_id", company_id).order("created_at", desc=False).execute()
        orders = response.data
        
        # If no orders, return placeholder value
        if not orders or len(orders) <= 1:
            return DEFAULT_RETURN_NO_DATA
            
        # Use timezone-aware datetime for comparison
        now = datetime.datetime.now(datetime.timezone.utc)
        
        # Filter orders within the specified time scope
        orders_within_scope = [
            order for order in orders 
            if (now - datetime.datetime.fromisoformat(order['created_at'])).days <= history_scope
        ]
        
        # If no orders within scope, return placeholder value
        if not orders_within_scope or len(orders_within_scope) == 0:
            return DEFAULT_RETURN_NO_DATA
            
        # Calculate daily revenue totals
        daily_revenue = {}
        for order in orders_within_scope:
            date = order['created_at'].split("T")[0]
            if date not in daily_revenue:
                daily_revenue[date] = 0.0
            daily_revenue[date] += order['payment']
            
        # Need at least 2 days of data to calculate change
        if len(daily_revenue) < 2:
            return DEFAULT_RETURN_NO_DATA
            
        # --------------------
        # Find slope of revenue change
        # --------------------

        dates = list(daily_revenue.keys())
        revenue_values = list(daily_revenue.values())

        start_date = datetime.datetime.fromisoformat(dates[0])
        time_numeric = np.array([(datetime.datetime.fromisoformat(date) - start_date).days for date in dates])
        revenue_numeric = np.array(revenue_values)
        slope, intercept = np.polyfit(time_numeric, revenue_numeric, 1)
        return slope

    def get_company_share_value_change_over_time(self, company_id: int, history_scope: int):
        """
        Calculate the change in share value of a company over a specific time period.
        
        Args:
            company_id: ID of the company
            history_scope: Number of days to analyze
        Returns:
            Change in share value as a decimal (e.g., 0.05 = 5% increase)
        """

        # Get company share history

        response = self.supabase.table("company_share").select("id").eq("company_id", company_id).execute()
        if not response.data:
            return DEFAULT_RETURN_NO_DATA
        company_share_id = response.data[0]['id']

        response = self.supabase.table("share_history").select("*").eq("share_id", company_share_id).order("created_at", desc=False).limit(history_scope * 24).execute()
        share_history = response.data
        if not share_history or len(share_history) < 2:
            return DEFAULT_RETURN_NO_DATA
        # --------------------
        # Find slope of share value change
        # --------------------
        time_dt = [datetime.datetime.fromisoformat(entry['created_at']) for entry in share_history]
        share_value_dx = [entry['value'] for entry in share_history]
        start_date = time_dt[0]
        time_numeric = np.array([(dt - start_date).total_seconds() / 3600 for dt in time_dt])
        slope, intercept = np.polyfit(time_numeric, share_value_dx, 1)
        return slope
    


    #-------------------------------------------------------------------------
    # Product Management Functions
    #-------------------------------------------------------------------------
            
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
    
    def build_product_bucket(self):
        """
        Build a weighted bucket of products based on their popularity.
        Products with higher popularity scores get more entries in the bucket.
        
        Returns:
            List of Product objects representing the weighted distribution
        """
        # Get verified products and companies
        product_response = self.supabase.table("products").select("*").eq("verified", True).execute()
        products = product_response.data

        company_response = self.supabase.table("companies").select("*").eq("verified", True).execute()
        companies = company_response.data
        
        # Create company map
        for company in companies:
            self.company_map[company['id']] = Company(
                id=company['id'],
                created_at=company['created_at'],
                name=company['name'],
                reputation=company['reputation'],
                is_public=company['is_public'],
                user_id=company['user_id'],
                visibility_factor=company['visibility_factor'],
                ai=company['ai'], 
                notifications_enabled=company['notification']
            )
        
        # Build product bucket with weighted entries
        product_bucket = []
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
        np.random.shuffle(product_bucket)

        print(f"[dim white]Built product bucket with {len(product_bucket)} products include {placeholder_count} placeholders.[/dim white]")
        return product_bucket

    #-------------------------------------------------------------------------
    # AI Simulation Functions
    #-------------------------------------------------------------------------
    
    def complete_all_ai_orders(self):
        """Execute database function to complete all AI orders."""
        response = self.supabase.rpc("complete_ai_orders").execute()

    def make_ai_orders(self):
        """
        Simulate AI users making product orders based on their personalities.
        """

        def randomly_distribute_spending_amount(amount, num_draws):
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
                        company = self.company_map.get(product.company_id)
                        if not company.ai and company.notifications_enabled:
                            pass  # Placeholder for future notification system
                        break
                        
            except Exception as e:
                print(f"[bold red]AI {user.minecraft_username} encountered an error while making product orders: {e} [/bold red]")
                continue
        
    def make_ai_share_orders(self):
        """
        Simulate AI users making share trading decisions based on their personalities.
        """
        # Randomize order of users to prevent bias
        user_copies = self.users.copy()
        random.shuffle(user_copies)

        with Progress() as progress:

            task = progress.add_task("[grey50]AI Share Trading Simulation...", total=len(user_copies))

            # Limit to a subset of users for performance

            user_scores_map = {}


            for user in user_copies:
                try:
                    
                    #--------------------------------------------
                    # Get Bot State
                    #--------------------------------------------

                    current_share_market = self.get_current_shares()
                    owned_shares = self.get_user_owned_shares(user.id)
                    user_balance = user.money

                    #--------------------------------------------
                    # Filter current shares for shares not owned by the user and that are purchasable and not for a company owned by the user
                    #--------------------------------------------

                    # current_shares_for_sale = [share for share in current_share_market if share.purchasable and share.company.user_id != user.id]
                    current_shares_for_sale = []
                    for share in current_share_market:
                        if not share.purchasable:
                            continue
                        if share.company.user_id == user.id:
                            continue
                        already_owned = any(owned_share.company.id == share.company.id for owned_share in owned_shares)
                        if already_owned:
                            continue
                        current_shares_for_sale.append(share)

                    #--------------------------------------------
                    # Evaluate and potentially sell existing shares
                    #--------------------------------------------

                    for share in owned_shares:

                        # Check if user is company owner and if so skip share evaluation
                        if share.company.user_id == user.id:
                            continue

                        # Evaluate the share position
                        action = self.evaluate_position(share, user.profit_margin, user.loss_limit)

                        if action == "SELL_PROFIT":
                            # Sell the share above market price
                            market_value = share.value
                            sale_price = market_value * 1.025
                            user.place_share_sell_order(share.id, sale_price)
                            # print(f"[green]AI {user.minecraft_username} placed share ID {share.id} for sale with a profit at price {sale_price}.[/green]")
                        elif action == "SELL_LOSS":
                            # check if any shares are for sale in the market of this type, undercut them
                            # if no shares are for sale sell at market value
                            sale_price = self.undercut_shares_on_market(share)
                            if sale_price is None:
                                sale_price = share.value
                            user.place_share_sell_order(share.id, sale_price)
                            # print(f"[orange]AI {user.minecraft_username} placed share ID {share.id} for sale with a loss at price {sale_price}.[/orange]")
                        elif action == "HOLD":
                            # Hold the share, do nothing
                            # print(f"[dim white]AI {user.minecraft_username} is holding share ID {share.id}.[/dim white]")
                            continue
                    
                    #--------------------------------------------
                    # Evaluate whether to buy new shares
                    #--------------------------------------------

                    if len(current_shares_for_sale) == 0:
                        # print(f"[dim white]AI {user.minecraft_username} found no shares for sale to buy.[/dim white]")
                        progress.update(task, advance=1)
                        continue

                    # Check if liquid assets are sufficient to buy shares
                    if user_balance <= 0:
                        # print(f"[dim white]AI {user.minecraft_username} has no liquid assets to buy shares.[/dim white]")
                        progress.update(task, advance=1)
                        continue

                    # Get users networth breakdown
                    networth_breakdown = self.get_user_networth_breakdown(user.id)
                    networth = networth_breakdown['NETWORTH']
                    liquid_assets = networth_breakdown['LIQUID_ASSETS']
                    share_assets = networth_breakdown['SHARE_ASSETS']
                    share_investment_limit = networth * user.percentage_of_networth_to_invest
                    if share_assets >= share_investment_limit:
                        # print(f"[dim white]AI {user.minecraft_username} has no share investment limit to buy shares.[/dim white]")
                        progress.update(task, advance=1)
                        continue

                    # Calculate maximum amount to invest in shares
                    max_investment = min(share_investment_limit, liquid_assets)
                    if max_investment <= 0:
                        # print(f"[dim white]AI {user.minecraft_username} has no liquid assets to invest in shares.[/dim white]")
                        progress.update(task, advance=1)
                        continue

                    
                    # Select maps based on user history scope
                    reputation_map = self.company_reputation_maps[user.history_scope]
                    performance_map = self.company_performance_maps[user.history_scope]
                    stock_trend_map = self.company_stock_trend_maps[user.history_scope]
                    #--------------------------------------------
                    

                    # Sort shares by performance, reputation, and stock trend

                    sorted_shares = []

                    for share in current_shares_for_sale:
                        company = share.company
                        if not company:
                            continue

                        # Check if company is already too heavily invested in
                        if share_assets / networth > 0.25:

                            users_share_investment_in_company = sum(
                                s.purchased_price for s in owned_shares if s.company.id == company.id
                            )

                            if users_share_investment_in_company / networth > user.diversity_minimum:
                                # print(f"[dim white]AI {user.minecraft_username} is too heavily invested in company {company.name} to buy more shares.[/dim white]")
                                continue
                        
                        
                        # Get metrics for the company
                        reputation = reputation_map.get(company.id, 0)
                        performance = performance_map.get(company.id, 0)
                        stock_trend = stock_trend_map.get(company.id, 0)
                        company_estimated_value = self.company_estimated_value_map.get(company.id)
                        company_listed_value = self.company_listed_value_map.get(company.id)

                        # Calculate weighted score based on user strategy weights
                        score = (
                            user.strategy_weights['sales'] * performance * 0.1 +
                            user.strategy_weights['reputation'] * reputation +
                            user.strategy_weights['trend_analysis'] * stock_trend +
                            user.strategy_weights['contrarian'] * (1 - stock_trend) +  
                            user.strategy_weights['random'] * random.uniform(0, 1) + 
                            user.strategy_weights['listed_value'] * (company_listed_value / company_estimated_value if company_estimated_value and company_estimated_value > 0 else 1)
                        )

                        sorted_shares.append((share, score))

                    # Sort shares by score in descending order
                    sorted_shares.sort(key=lambda x: x[1], reverse=True)

                    # [Debugging]
                    # add scores to scores map based on user type
                    ai_type_name = user.name
                    if ai_type_name not in user_scores_map:
                        user_scores_map[ai_type_name] = {}
                    
                    for share, score in sorted_shares:
                        share_id = share.company.name
                        if share_id not in user_scores_map[ai_type_name]:
                            user_scores_map[ai_type_name][share_id] = {'total_score': 0, 'count': 0}
                        
                        user_scores_map[ai_type_name][share_id]['total_score'] += score
                        user_scores_map[ai_type_name][share_id]['count'] += 1
                    
                    
                    #--------------------------------------------
                    # Buy shares based on sorted scores and investment limits
                    #--------------------------------------------

                    shares_bought = 0
                    investment_limit = user.buy_volume_limit
                    for share, score in sorted_shares:
                        if shares_bought >= investment_limit:
                            break

                        # Check if score is below a threshold
                        if score < 0.1:  # Adjust threshold as needed
                            break # Its sorted so everything after this will be below threshold

                        # Find the lowest share price of this share
                        share_to_buy = self.get_company_stock_for_sale(share.company.id)
                        if not share_to_buy:
                            continue

                        # Check if user can afford this share purchase
                        share_price = share_to_buy.sale_price
                        if share_price > user_balance:
                            continue  # Can't afford this share, skip to next

                        # Place the share order
                        user.place_share_order(share.id)
                        # print(f"[green]AI {user.minecraft_username} bought share ID {share.id} at price {share_price}.[/green]")
                        
                        # Update user's balance and shares bought count
                        user_balance -= share_price
                        shares_bought += 1
                    

                    
                    
                    progress.update(task, advance=1)
                        
                except Exception as e:
                    # print(f"[bold red]AI {user.minecraft_username} encountered an error while making share orders: {e} [/bold red]")
                    progress.update(task, advance=1)
                    continue
            
            # Calculate averages for each AI type and share
            for ai_type in user_scores_map:
                for share_id in user_scores_map[ai_type]:
                    total_score = user_scores_map[ai_type][share_id]['total_score']
                    count = user_scores_map[ai_type][share_id]['count']
                    user_scores_map[ai_type][share_id] = total_score / count if count > 0 else 0
            
            return user_scores_map
        

    #-------------------------------------------------------------------------
    # Share Market Functions
    #-------------------------------------------------------------------------
    
    def get_company_stock_for_sale(self, company_id: int):
        """
        Get the lowest priced share available for purchase for a specific company.
        
        Args:
            company_id: ID of the company
            
        Returns:
            Share object or None if no shares available
        """
        response = self.supabase.table("shares").select("*, company_share:share_id (value, is_public, number_of_shares)").eq("company_id", company_id).eq("purchasable", True).execute()
        shares = response.data
        
        if not shares or len(shares) == 0:
            return None
            
        # Find the lowest priced share
        lowest_price_share = min(shares, key=lambda x: x['sale_price'])

        company_share = lowest_price_share['company_share']
        
        
        return Share(
            id=lowest_price_share['id'],
            company=self.company_map.get(company_id),
            stake=lowest_price_share['stake'],
            purchased_price=lowest_price_share['purchased_price'],
            value= company_share['value'],
            purchasable=lowest_price_share['purchasable'],
            user_id=lowest_price_share['user_id'],
            is_public= company_share['is_public'],
            sale_price=lowest_price_share['sale_price'],
        )

    def evaluate_position(self, position: Share, profit_margin: float, loss_limit: float):
        """
        Evaluate whether to sell, hold, or buy a share based on profit margins and loss limits.
        
        Args:
            position: Share object to evaluate
            profit_margin: Minimum profit percentage required to sell
            loss_limit: Maximum loss percentage before cutting losses
            
        Returns:
            String action recommendation: "SELL_PROFIT", "SELL_LOSS", or "HOLD"
        """
        if position.value >= profit_margin:
            return "SELL_PROFIT"
        elif position.value <= -loss_limit:
            return "SELL_LOSS"
        else:
            return "HOLD"
    
    def under_cut_shares_on_market(self, share: Share):
        """
        Calculate a competitive selling price for a share by undercutting the market.
        
        Args:
            share: Share object to price
            
        Returns:
            Suggested selling price
        """
        response = self.supabase.table("shares").select("*, company_share:share_id (value, is_public, number_of_shares)").eq("company_id", share.company.id).eq("purchasable", True).execute()
        shares = response.data
        
        # If no shares on market, use the share's intrinsic value
        if not shares or len(shares) == 0:
            return share.value
            
        # Find the lowest priced share and undercut it
        lowest_price_share = min(shares, key=lambda x: x['sale_price'])
        return lowest_price_share['sale_price'] * SHARE_UNDERCUT_PERCENTAGE

    def get_share_by_company_share_id(self, share_id: int, company_share):
        """
        Get a share object by its ID.
        
        Args:
            share_id: ID of the share
            
        Returns:
            Share object or None if not found
        """
        response = self.supabase.table("shares").select("*").eq("share_id", share_id).execute()
        shares = response.data
        
        if not shares or len(shares) == 0:
            return None
            
        share_list = []
        for share in shares:

            share_data = share
        
            share_list.append(Share(
                id=share_data['id'],
                company=self.company_map.get(company_share['company_id']),
                stake=share_data['stake'],
                purchased_price=share_data['purchased_price'],
                value= company_share['value'],
                purchasable=share_data['purchasable'],
                user_id=share_data['user_id'],
                is_public= company_share['is_public'],
                sale_price=share_data['sale_price'],
            ))
        return share_list

    def get_current_shares(self):
        """
        Get all public original shares in the market.
        
        Returns:
            List of Share objects
        """
        response = self.supabase.table("company_share").select("*").eq("is_public", True).execute()
        shares = response.data

        share_list = []
        for share in shares:

            # Get the share details
            share_objects = self.get_share_by_company_share_id(share['id'], share)
            share_list.extend(share_objects)
        
        return share_list

    #-------------------------------------------------------------------------
    # Utility Functions
    #-------------------------------------------------------------------------
        
    def log(self, message, log_dir="logs"):
        """
        Writes a message to a daily log file with a timestamp.

        Parameters:
        - message (str): The message to log.
        - log_dir (str): Directory where log files are stored.
        """
        # Ensure the log directory exists
        os.makedirs(log_dir, exist_ok=True)

        # Generate the log file name based on the current date
        date_str = datetime.datetime.now().strftime("%Y-%m-%d")
        log_filename = os.path.join(log_dir, f"{date_str}.log")

        # Generate the timestamp for the log entry
        time_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Write the log entry to the file
        with open(log_filename, "a") as log_file:
            log_file.write(f"[{time_str}] {message}\n")

    def send_email(self, receiver, subject, body):
        """
        Send an email notification.
        
        Args:
            receiver: Email address of the recipient
            subject: Email subject line
            body: Email body text
        """
        sender = 'donotreply.mine.exchange@gmail.com'

        # Create the message
        msg = MIMEMultipart()
        msg['From'] = sender
        msg['To'] = receiver
        msg['Subject'] = subject

        msg.attach(MIMEText(body, 'plain'))

        # Login and send
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
            server.login(sender, 'vcsb rjsd ivna ikpx')
            server.send_message(msg)

    def make_new_company_shares_purchaseable(self, company_id, proportion_of_shares):
        """
        Make a proportion of new shares purchasable for a company.
        
        Args:
            company_id: ID of the company
            proportion_of_shares: Proportion of shares to make purchasable (0-1)
        """
        response = self.supabase.table("company_share").select("*").eq("company_id", company_id).execute()
        company_share = response.data
        share_id =  company_share[0]['id'] if company_share else None
        number_of_shares_to_make_purchasable = int(company_share[0]['number_of_shares'] * proportion_of_shares)

        if share_id is not None:
            response = self.supabase.table("shares").select("*").eq("company_id", company_id).eq("share_id", share_id).execute()
            shares = response.data

            if shares:
                sale_price = company_share[0]['value']
                for i in range(number_of_shares_to_make_purchasable):
                    share = shares[i]
                    if not share['purchasable']:
                        self.supabase.table("shares").update({"purchasable": True,  "sale_price": sale_price}).eq("id", share['id']).execute()
                        # print(f"[green]Made share ID {share['id']} purchasable for company ID {company_id}.[/green]")
                    
                    if i <= number_of_shares_to_make_purchasable // 4:
                        sale_price *=1.00025
                    elif i <= number_of_shares_to_make_purchasable // 2:
                        sale_price *= 1.0005
                    elif i <= (number_of_shares_to_make_purchasable // 1.25):
                        sale_price *= 1.001
                    else:
                        sale_price *= 1.0025

    def modify_ai_companies_reputations(self):
        """
        Modify a company's reputation based on its performance.
        
        Args:
            company_id: ID of the company
        """

        # Get the company's current reputation
        response = self.supabase.table("companies").select("*").eq("ai", True).execute()
        company_data = response.data
        
        if not company_data or len(company_data) == 0:
            print(f"[bold red]Companies not found.[/bold red]")
            return
            
        for company in company_data:
            current_reputation = company['reputation']
            
            # Reputation should stay within the range that it currently is
            # however since we are using it as a rate of change in our share calculations it would be best
            # if it still changed but never permanently changed
            # so we will use a small random factor to adjust it and statistically it will stay within the range
            
            # flip coin to determine if we increase or decrease reputation 
            # change is currently set at 25 points either way
            if random.choice([True, False]):
                new_reputation = current_reputation + 25
            else:
                new_reputation = current_reputation - 25
            # Ensure reputation stays within bounds
            new_reputation = max(0, min(1000, new_reputation))
            # Update the company's reputation in the database
            self.supabase.table("companies").update({"reputation": new_reputation}).eq("id", company['id']).execute()
            print(f"[dim white]Modified reputation for company ID {company['id']} from {current_reputation} to {new_reputation}.[/dim white]")

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
            

        
        