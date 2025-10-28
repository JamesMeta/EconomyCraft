import random

from typing import Any, Optional

from supabase import Client



from classes.classes.company import Company
from classes.classes.line_of_best_fit import LineOfBestFit
from classes.classes.share import Share
from classes.classes.volatility import Volatility
from classes.modules import supabase_assistant
from classes.modules import trade_helper
from classes.modules.constants import SHARE_UNDERCUT_PERCENTAGE
from rich.progress import Progress

from classes.modules.trade_helper import TradeHelper
from classes.subAi.level_constants import FIRST, SECOND
from classes.subAi.t_user import T_user
from classes.modules.constants import *




class StocksAI:
    def __init__(
        self, 
        supabase: Client,
        users: list[T_user],
        company_map: dict[int, Company], 
        company_performance_maps: dict[int, dict[int, LineOfBestFit]] ,
        company_reputation_maps: dict[int, dict[int, LineOfBestFit]], 
        company_stock_trend_maps: dict[int, dict[int, LineOfBestFit]],
        company_estimated_value_map: dict[int, float],
        company_listed_value_map: dict[int, float],
        company_volatility_map: dict[int, dict[int, LineOfBestFit]],
        ):

        self.supabase = supabase
        self.users = users
        self.company_map = company_map
        self.company_performance_maps = company_performance_maps
        self.company_reputation_maps = company_reputation_maps
        self.company_stock_trend_maps = company_stock_trend_maps
        self.company_estimated_value_map = company_estimated_value_map
        self.company_listed_value_map = company_listed_value_map
        self.company_volatility_map = company_volatility_map
        
        self.trade_helper = TradeHelper(supabase=supabase)
        
        self.current_shares = self.get_current_available_shares()    

    def make_ai_share_orders(self) -> None:

        # Randomize order of users to prevent bias
        user_copies = self.users.copy()
        random.shuffle(user_copies)

        with Progress() as progress:

            task = progress.add_task("[grey50]AI Share Trading Simulation...", total=len(user_copies))

            for user in user_copies[:1]:
                # try:
                    
                    #--------------------------------------------
                    # Get Bot State
                    # Bot's data from performance maps 
                    # Bot's current shares, 
                    #--------------------------------------------
                    
                    user_company_statistics_maps, user_owned_shares, = self.get_bot_state(user)

                    #--------------------------------------------
                    # Evaluate and potentially sell existing shares
                    # Check if shares exceed the goals set by the bot
                    # Check if shares exceed the decline limits set by the bot
                    # Check if shares growth exceeds the bot's bubble confortability constant
                    # Check if company's reputation decline exceeds the bot's reputation confortability constant
                    # Check if company's growth decline exceeds the bot's growth confortability constant
                    #--------------------------------------------
                    
                    # self.evaluate_positions(user, user_owned_shares, user_company_statistics_maps)
                    
                    #--------------------------------------------
                    # Evaluate whether to buy new shares
                    # Check if the bot's portfolio is below its liquidity constant 
                    #--------------------------------------------  
                    
                    is_portfolio_filled, portfolio = self.evaluate_liquidity(user)
                    
                    if is_portfolio_filled:
                        print("portfolio full skipping...")
                        progress.update(task, advance=1)
                        continue
 
                    #--------------------------------------------
                    # Filter current shares for shares the bot can purchase
                    # Share's that are for sale
                    # Share's that are not owned by the bot
                    # Share's that the bot doesn't exceed their diversity constant for
                    #--------------------------------------------
                    
                    shares = self.filter_current_shares(user, user_owned_shares, self.current_shares, portfolio["SHARE_ASSETS"])
                
                    #--------------------------------------------
                    # Score shares based on bot's constants
                    # Share Past performance
                    # Share Volatility 
                    # Company Value vs Estimated Value
                    # Company Reputation
                    # Randomness
                    #--------------------------------------------  
                
                    scores = self.score_shares(user, shares, user_company_statistics_maps, **user.strategy_weights)
                
                    #--------------------------------------------
                    # Buy shares based on sorted scores
                    #--------------------------------------------  
                    
                    self.purchase_shares(user, scores)
                            
                    
                    progress.update(task, advance=1)
                        
                # except Exception as e:
                #     print(f"[bold red]AI {user.minecraft_username} encountered an error while making share orders: {e} [/bold red]")
                #     progress.update(task, advance=1)
                #     continue
    

    def get_bot_state(self, user: T_user) -> tuple[dict[str, dict[int, LineOfBestFit]], list[Share]]:
        
        def company_value_bot_estimate(estimated_value_map: dict, random_range: tuple) -> dict:
            
            new_estimated_value_map = {}
            for key, value in estimated_value_map.items():
                randomness = random.uniform(random_range[FIRST], random_range[SECOND])
                new_estimated_value_map[key] = value * randomness
            
            return new_estimated_value_map
                
        
        user_owned_shares = self.get_user_owned_shares(user.id)
        user_company_statistics_maps = {
            "TREND_ANALYSIS" : self.company_stock_trend_maps[TIME_PERIOD_TREND_ANALYSIS],
            "SALES" : self.company_performance_maps[user.history_scope],
            "REPUTATION" : self.company_reputation_maps[user.history_scope],
            "SHARE_PERFORMANCE" : self.company_stock_trend_maps[user.history_scope],
            "ESTIMATED_VALUE": company_value_bot_estimate(self.company_estimated_value_map, user.random_range),            
            "LISTED_VALUE" : self.company_listed_value_map,
            "VOLATILITY_TOLERANCE": self.company_volatility_map[user.history_scope]
            }
        
        return user_company_statistics_maps,  user_owned_shares
        
        

    def evaluate_positions(self, user: T_user, current_shares: list[Share], user_company_statistics_maps: dict[str, dict[int, LineOfBestFit]]) -> None:
        
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
            
            percent_diff = (y2-y1) / y1
            
            if percent_diff > rapid_growth_percentage_confortability:
                return True, "SELL_NOW"
            
            else:
                return False, "N/A"       
        
        def evaluate_position_for_reputation_point_decline(reputation_point_decline_confortability, user_company_reputation_line, history_scope) -> tuple[bool,str]:
            slope, b = user_company_reputation_line.slope, user_company_reputation_line.b
            
            x1 = 0
            x2 = history_scope
            
            y1 = slope*x1 + b
            y2 = slope*x2 + b
            
            diff = y2 - y1
            
            if diff > reputation_point_decline_confortability:
                return True, "SELL_NOW"
            else:
                return False, "N/A"
        
        def evaluate_position_for_company_growth_decline(company_sales_decline_confortability, user_company_sales_line, history_scope) -> tuple[bool,str]:
            slope, b = user_company_sales_line.slope, user_company_sales_line.b
            
            x1 = 0
            x2 = history_scope
            
            y1 = slope*x1 + b
            y2 = slope*x2 + b
            
            percent_diff = (y2-y1) / y1
            
            if percent_diff > company_sales_decline_confortability:
                return True, "SELL_NOW"
            
            else:
                return False, "N/A"
        
        def evalutate_position(share: Share, user: T_user, user_company_statistics_maps: dict[str, dict[int, LineOfBestFit]]) -> str:
            
            value = share.value
            purchased_price = share.purchased_price
            purchasable = share.purchasable
            sale_price = share.sale_price
            
            profit_goals = user.profit_margin
            loss_limits = user.loss_limit
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
            
            is_bubble, decision = evaluate_position_for_rapid_share_value_growth_confortability(rapid_growth_percentage_confortability, user_company_stock_trend_line, user.history_scope)
            
            if is_bubble:
                return decision
            
            is_losing_support, decision = evaluate_position_for_reputation_point_decline(reputation_point_decline_confortability, user_company_reputation_line, user.history_scope)
            
            if is_losing_support:
                return decision
            
            sales_declining, decision = evaluate_position_for_company_growth_decline(company_sales_decline_confortability, user_company_performance_line, user.history_scope)
            if sales_declining:
                return decision
            
            
            return "NO_ACTION"
        
        for share in current_shares:
            decision = evalutate_position(share, user, user_company_statistics_maps)
            
            if decision == "NO_ACTION":
                continue
            
            if decision == "SELL_GAIN":
                self.trade_helper.sell_gain(user=user, share=share)
            
            if decision == "SELL_NOW":
                self.trade_helper.sell_now(user=user, share=share)
    

    def evaluate_liquidity(self, user: T_user) -> tuple[bool, dict]:
        portfolio = self.get_user_networth_breakdown(user.id)
        networth_invested = portfolio["SHARE_ASSETS"] / portfolio["NETWORTH"]
        
        return networth_invested > user.percentage_of_networth_to_invest, portfolio
    

    def filter_current_shares(self, user: T_user, user_owned_shares: list[Share], all_shares: list[Share], user_share_asset_total: float) -> dict[int, Share]:
        
        diversity_requirement = user.diversity_minimum
        
        invalid_share_list: list[int] = []
        share_totals: dict[int, float] = {}
        
        for share in user_owned_shares:
            
            if share.company_share_id in share_totals:
                share_totals[share.company_share_id] = share.value + share_totals[share.company_share_id]
            else:
                share_totals[share.company_share_id] = share.value
            
            if share_totals[share.company_share_id] / user_share_asset_total > diversity_requirement and share.company_share_id not in invalid_share_list:
                invalid_share_list.append(share.company_share_id)
        
        filtered_shares : dict[int, Share] = {}
        
        for share in all_shares:
            if share.company_share_id in invalid_share_list or share.company_share_id in filtered_shares:
                continue
            else:
                filtered_shares[share.company_share_id] = share
        
        return filtered_shares
    

    def score_shares(self, user: T_user, shares: dict[int, Share],
                     user_companies_statistics_maps: dict[str, dict[int, Any]],
                     TREND_ANALYSIS: float,
                     REPUTATION: float,
                     SHARE_PERFORMANCE: float,
                     COMPANY_PERFORMANCE: float,
                     VALUE_ESTIMATION: float, 
                     VOLATILITY_TOLERANCE: float) -> dict[int, float]:
        
        
        def percentage_change(line: LineOfBestFit, history_scope: int = user.history_scope) -> float:
            slope = line.slope
            b = line.b
            
            y1 = slope * 0 + b
            y2 = slope * history_scope + b
            
            return (y2 - y1) / y1 
        
        is_contrarian = user.investor_type == "CONTRARIAN"
        
        user_companies_trend_analysis_map = user_companies_statistics_maps["TREND_ANALYSIS"]
        user_companies_performance_map = user_companies_statistics_maps["SALES"]
        user_companies_reputation_map = user_companies_statistics_maps["REPUTATION"]
        user_companies_stock_trend_map = user_companies_statistics_maps["SHARE_PERFORMANCE"]
        user_companies_estimated_value_map = user_companies_statistics_maps["ESTIMATED_VALUE"]
        user_companies_listed_value_map = user_companies_statistics_maps["LISTED_VALUE"]
        user_companies_volatility_map = user_companies_statistics_maps["VOLATILITY_TOLERANCE"]
        
        scores: dict[int, float] = {}
        
        for company_share_id, share in shares.items():
            
            company_id = share.company.id
            
            trend_analysis_line: LineOfBestFit = user_companies_trend_analysis_map[company_id]
            performance_line: LineOfBestFit = user_companies_performance_map[company_id]
            reputation_line: LineOfBestFit = user_companies_reputation_map[company_id]
            stock_line: LineOfBestFit = user_companies_stock_trend_map[company_id]
            estimated_value: float = user_companies_estimated_value_map[company_id]
            listed_value: float = user_companies_listed_value_map[company_id]
            company_volatility: Volatility = user_companies_volatility_map[company_id]
            
            trend_analysis_change = percentage_change(trend_analysis_line, TIME_PERIOD_TREND_ANALYSIS)
            performance_change = percentage_change(performance_line)
            reputation_change = percentage_change(reputation_line)
            stock_line_change = percentage_change(stock_line)
            
            real_value_difference = listed_value / estimated_value
            
            
            
            if is_contrarian:
                trend_analysis_change *= -1
            
            trend_analysis_weight = trend_analysis_change * TREND_ANALYSIS
            performance_weight = performance_change * COMPANY_PERFORMANCE
            reputation_weight = reputation_change * REPUTATION
            share_performance_weight = stock_line_change * SHARE_PERFORMANCE
            value_estimation_weight = real_value_difference * VALUE_ESTIMATION
            volatility_weight = company_volatility.volatility * VOLATILITY_TOLERANCE
            
            score = trend_analysis_weight + performance_weight + reputation_weight + share_performance_weight + value_estimation_weight + volatility_weight
            
            print("---------GIVEN SCORES-----------")
            print(f"\t{share.company.name}")
            print("Trend Analysis Weight: ", trend_analysis_weight)
            print("Performance Weight: ", performance_weight)
            print("Reputation Weight: ", reputation_weight)
            print("Share Performance Weight: ", share_performance_weight)
            print("Value Estimation Weight: ", value_estimation_weight)
            print("Volatility Weight: ", volatility_weight)
            print("Total Score: ", score)
            print("-------------------------------")
            
            scores[company_id] = score
        
        return scores
            
        
    
    ## TODO:
    def purchase_shares(self, user: T_user, scores: dict[int, float]) -> None:
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
            company = self.company_map[company_id],
            stake = lowest_price_share['stake'],
            purchased_price = lowest_price_share['purchased_price'],
            value = company_share['value'],
            purchasable = lowest_price_share['purchasable'],
            user_id = lowest_price_share['user_id'],
            is_public = company_share['is_public'],
            sale_price = lowest_price_share['sale_price'],
            company_share_id=company_share['id']
        )    

    def get_shares_by_company_share_id(self, share_id: int, company_share) -> Optional[Share]:

        response = self.supabase.table("shares").select("*").eq("share_id", share_id).limit(1).single().execute()

        share_data = response.data
    
        try:
            share = Share(
                id=share_data['id'],
                company=self.company_map[company_share['company_id']],
                stake=share_data['stake'],
                purchased_price=share_data['purchased_price'],
                value= company_share['value'],
                purchasable=share_data['purchasable'],
                user_id=share_data['user_id'],
                is_public= company_share['is_public'],
                sale_price=share_data['sale_price'],
                company_share_id=company_share['id']
                
            )
            
            return share
        except:
            return None

    def get_current_available_shares(self) -> list[Share]:

        response = self.supabase.table("company_share").select("*").eq("is_public", True).execute()
        shares = response.data

        share_list: list[Share] = []
        for share in shares:

            # Get the share details
            share_object = self.get_shares_by_company_share_id(share['id'], share)
            
            if share_object == None:
                continue
            
            share_list.append(share_object)
        
        return share_list
    
    def get_user_owned_shares(self, user_id) -> list:

        response = self.supabase.table("shares").select("*, company_share:share_id (id, value, is_public, number_of_shares)").eq("user_id", user_id).execute()
        shares = response.data
        user_shares = []
        for share in shares:
            company_share = share['company_share']
            company = self.company_map[share['company_id']]
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
                company_share_id=company_share['id']
            )
            user_shares.append(share_object)
        return user_shares

    def get_user_networth_breakdown(self, user_id: int) -> dict[str, float]:

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