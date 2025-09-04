import random
from classes.classes.share import Share
from classes.modules.constants import SHARE_UNDERCUT_PERCENTAGE
from rich.progress import Progress


class StocksAI:
    def __init__(
        self, 
        supabase,
        users,
        company_map, 
        company_performance_maps,
        company_reputation_maps, 
        company_stock_trend_maps,
        company_estimated_value_map,
        company_listed_value_map
        ):

        self.supabase = supabase
        self.users = users
        self.company_map = company_map
        self.company_performance_maps = company_performance_maps
        self.company_reputation_maps = company_reputation_maps
        self.company_stock_trend_maps = company_stock_trend_maps
        self.company_estimated_value_map = company_estimated_value_map
        self.company_listed_value_map = company_listed_value_map
        
        self.current_shares = self.get_current_shares()    

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

                    current_share_market = self.current_shares
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
                    # ai_type_name = user.name
                    # if ai_type_name not in user_scores_map:
                    #     user_scores_map[ai_type_name] = {}
                    
                    # for share, score in sorted_shares:
                    #     share_id = share.company.name
                    #     if share_id not in user_scores_map[ai_type_name]:
                    #         user_scores_map[ai_type_name][share_id] = {'total_score': 0, 'count': 0}
                        
                    #     user_scores_map[ai_type_name][share_id]['total_score'] += score
                    #     user_scores_map[ai_type_name][share_id]['count'] += 1
                    
                    # progress.update(task, advance=1)
                    # continue
                    
                
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