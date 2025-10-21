import random

from typing import Dict, List, Tuple, Optional, Iterable



from classes.classes.share import Share
from classes.modules import supabase_assistant
from classes.modules.constants import SHARE_UNDERCUT_PERCENTAGE
from rich.progress import Progress

from classes.subAi.level_constants import FIRST, SECOND


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
        
        self.current_shares = self.get_current_available_shares()    

    def make_ai_share_orders(self):

        # Randomize order of users to prevent bias
        user_copies = self.users.copy()
        random.shuffle(user_copies)

        with Progress() as progress:

            task = progress.add_task("[grey50]AI Share Trading Simulation...", total=len(user_copies))

            for user in user_copies:
                try:
                    
                    #--------------------------------------------
                    # Get Bot State
                    # Bot's data from performance maps 
                    # Bot's current shares, 
                    #--------------------------------------------
                    
                    user_company_statistics_maps, current_shares, = self.get_bot_state(user)

                    #--------------------------------------------
                    # Evaluate and potentially sell existing shares
                    # Check if shares exceed the goals set by the bot
                    # Check if shares exceed the decline limits set by the bot
                    # Check if shares growth exceeds the bot's bubble confortability constant
                    # Check if company's reputation decline exceeds the bot's reputation confortability constant
                    # Check if company's growth decline exceeds the bot's growth confortability constant
                    #--------------------------------------------
                    
                    self.evaluate_positions(user, current_shares, user_company_statistics_maps)
                    
                    #--------------------------------------------
                    # Evaluate whether to buy new shares
                    # Check if the bot's portfolio is below its liquidity constant 
                    #--------------------------------------------  
                    
                    portfolio_filled = self.evaluate_liquidity(user)
                    
                    if portfolio_filled:
                        progress.update(task, advance=1)
                        continue

                    #--------------------------------------------
                    # Filter current shares for shares for shares the bot can purchase
                    # Share's that are for sale
                    # Share's that are not owned by the bot
                    # Share's that the bot doesn't exceed their diversity constant for
                    #--------------------------------------------
                    
                    shares = self.filter_current_shares(user)
                
                    #--------------------------------------------
                    # Score shares based on bot's constants
                    # Share Past performance
                    # Share Volatility 
                    # Company Value vs Estimated Value
                    # Company Reputation
                    # Randomness
                    #--------------------------------------------  
                
                    scores = self.score_shares(user)
                
                    #--------------------------------------------
                    # Buy shares based on sorted scores
                    #--------------------------------------------  
                    
                    self.purchase_shares(user, shares)
                            
                    
                    progress.update(task, advance=1)
                        
                except Exception as e:
                    # print(f"[bold red]AI {user.minecraft_username} encountered an error while making share orders: {e} [/bold red]")
                    progress.update(task, advance=1)
                    continue
    
    ## TODO:
    def get_bot_state(self, user) -> Tuple:
        
        def company_value_bot_estimate(estimated_value_map: Dict, random_range: Tuple) -> Dict:
            
            new_estimated_value_map = {}
            for key, value in estimated_value_map.items():
                randomness = random.uniform(random_range[FIRST], random_range[SECOND])
                new_estimated_value_map[key] = value * randomness
            
            return new_estimated_value_map
                
        
        user_owned_shares = self.get_user_owned_shares(user.id)
        user_company_statistics_maps = {
            "SALES" : self.company_performance_maps[user.history_scope],
            "REPUTATION" : self.company_reputation_maps[user.history_scope],
            "SHARE_PERFORMANCE" : self.company_stock_trend_maps[user.history_scope],
            "ESTIMATED_VALUE": company_value_bot_estimate(self.company_estimated_value_map, user.random_range),            
            "LISTED_VALUE" : self.company_listed_value_map,
            }
        
        return user_company_statistics_maps,  user_owned_shares
        
        

    ## TODO:
    def evaluate_positions(self, user, current_shares, user_company_statistics_maps):
        
        def evaluate_purchasable_position_for_profit_loss_goals(value, sale_price) -> tuple[bool,str]:
            percent_difference = abs(1 - (sale_price / value))
            
            if percent_difference > 0.05:
                return True, "N/A"
            else:
                return False, "NO_ACTION"
        
        def evaluate_position_for_profit_loss_goals(value, purchased_price, profit_goals, loss_limits) -> tuple[bool,str]:
            
            change = (value - purchased_price) / purchased_price
            
            if change >= profit_goals:
                return True, "SELL_GAIN"
            elif change <= loss_limits:
                return True,  "SELL_NOW"
            else:
                return False, "N/A"
        
        def evaluate_position_for_rapid_share_value_growth_confortability(rapid_growth_percentage_confortability, user_company_performance_line, history_scope) -> tuple[bool,str]:
            slope, b = user_company_performance_line.slope, user_company_performance_line.b
            
            x1 = 0
            x2 = history_scope
            
            y1 = slope*x1 + b
            y2 = slope*x2 + b
            
            diff = (y2-y1) / y1
            
            if diff > rapid_growth_percentage_confortability:
                return True, "SELL_NOW"
            
            else:
                return False, "N/A"
            
        
        # TODO: 
        def evaluate_position_for_reputation_point_decline(reputation_point_decline_confortability, user_company_reputation_line, history_scope) -> tuple[bool,str]:
        
        # TODO: 
        def evaluate_position_for_company_growth_decline(company_sales_decline_confortability, user_company_sales_line, history_scope) -> tuple[bool,str]:
            
        
        def evalutate_position(share, user, user_company_statistics_maps) -> str:
            
            value = share.value
            purchased_price = share.purchased_price
            purchasable = share.purchasable
            sale_price = share.sale_price
            
            profit_goals = user.profit_goals
            loss_limits = user.loss_limits
            rapid_growth_percentage_confortability = user.rapid_growth_percentage_confortability
            reputation_point_decline_confortability = user.reputation_point_decline_confortability
            company_sales_decline_confortability = user.company_sales_decline_confortability
            
            user_company_performance_line = user_company_statistics_maps["SALES"][share.company.id]
            user_company_reputation_line = user_company_statistics_maps["REPUTATION"][share.company.id]
            user_company_stock_trend_line = user_company_statistics_maps["SHARE_PERFORMANCE"][share.company.id]
            
            company_id : int = share.company.id
            
            
            if (purchasable):
                
                to_re_evaluate, decision = evaluate_purchasable_position_for_profit_loss_goals(value, sale_price)
                
                if not to_re_evaluate:
                    return decision
                
                else:
                    user.remove_share_for_sale(share.id)
            
            to_sell, decision = evaluate_position_for_profit_loss_goals(value, purchased_price, profit_goals, loss_limits)
            
            if to_sell:
                return decision
            
            is_bubble, decision = evaluate_position_for_rapid_share_value_growth_confortability(rapid_growth_percentage_confortability, user_company_performance_line, user.history_scope)
            
            if is_bubble:
                return decision
            
            return "NO_ACTION"
        
        for share in current_shares:
            decision = evalutate_position(share, user, user_company_statistics_maps)
            
            if decision == "HOLD":
                pass
    
    
    ## TODO:
    def evaluate_liquidity(self, user) -> bool:
        return True
    
    ## TODO:
    def filter_current_shares(self, user) -> List:
        return []
    
    ## TODO:
    def score_shares(self, user) -> Dict:
        return {}
    
    ## TODO:
    def purchase_shares(self, user, shares):
        pass

    def get_company_stock_for_sale(self, company_id: int) -> Optional[Share]:

        response = self.supabase.table("shares").select("*, company_share:share_id (value, is_public, number_of_shares)").eq("company_id", company_id).eq("purchasable", True).execute()
        shares = response.data
        
        if not shares or len(shares) == 0:
            return None
            
        # Find the lowest priced share
        lowest_price_share = min(shares, key=lambda x: x['sale_price'])

        company_share = lowest_price_share['company_share']
        
        return Share(
            id = lowest_price_share['id'],
            company = self.company_map.get(company_id),
            stake = lowest_price_share['stake'],
            purchased_price = lowest_price_share['purchased_price'],
            value = company_share['value'],
            purchasable = lowest_price_share['purchasable'],
            user_id = lowest_price_share['user_id'],
            is_public = company_share['is_public'],
            sale_price = lowest_price_share['sale_price'],
        )    

    def under_cut_shares_on_market(self, share: Share) -> float:

        response = self.supabase.table("shares").select("*, company_share:share_id (value, is_public, number_of_shares)").eq("company_id", share.company.id).eq("purchasable", True).execute()
        shares = response.data
        
        # If no shares on market, use the share's intrinsic value
        if not shares or len(shares) == 0:
            return share.value
            
        # Find the lowest priced share and undercut it
        lowest_price_share = min(shares, key=lambda x: x['sale_price'])
        return lowest_price_share['sale_price'] * SHARE_UNDERCUT_PERCENTAGE

    def get_shares_by_company_share_id(self, share_id: int, company_share) -> Optional[List[Share]]:

        response = self.supabase.table("shares").select("*").eq("share_id", share_id).eq("purchasable", True).execute()
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

    def get_current_available_shares(self) -> List:

        response = self.supabase.table("company_share").select("*").eq("is_public", True).execute()
        shares = response.data

        share_list: list[Share] = []
        for share in shares:

            # Get the share details
            share_objects = self.get_shares_by_company_share_id(share['id'], share)
            
            if not share_objects:
                continue
            
            share_list.extend(share_objects)
        
        return share_list
    
    def get_user_owned_shares(self, user_id) -> List:

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

    def get_user_networth_breakdown(self, user_id: int) -> Dict:

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