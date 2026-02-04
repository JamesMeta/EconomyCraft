import datetime
import random

from typing import Any, Optional
from collections import defaultdict

from supabase import Client



from classes.classes import data_log
from classes.classes.buy_order import BuyOrder
from classes.classes.company import Company
from classes.classes.company_share import CompanyShare
from classes.classes.data_log import DataLog
from classes.classes.line_of_best_fit import LineOfBestFit
from classes.classes.share import Share
from classes.classes.share_group import ShareGroup
from classes.classes.volatility import Volatility
from classes.modules import supabase_assistant
from classes.modules import trade_helper
from classes.modules.constants import SHARE_UNDERCUT_PERCENTAGE
from rich.progress import Progress

from classes.modules.local_cache_manager import LocalCacheManager
from classes.modules.sqlite_assistant import SqliteAssistant
from classes.modules.trade_helper import TradeHelper
from classes.subAi.level_constants import FIRST, SECOND
from classes.subAi.t_user import T_user
from classes.modules.constants import *
from rich import print




class StocksAI:
    def __init__(
        self, 
        supabase: Client,
        users: list[T_user],
        company_shares: list[CompanyShare],
        company_map: dict[int, Company], 
        company_performance_maps: dict[int, dict[int, LineOfBestFit]] ,
        company_reputation_maps: dict[int, dict[int, LineOfBestFit]], 
        company_stock_trend_maps: dict[int, dict[int, LineOfBestFit]],
        company_estimated_value_map: dict[int, float],
        company_listed_value_map: dict[int, float],
        company_volatility_map: dict[int, dict[int, LineOfBestFit]],
        logger: DataLog,
        local_cache_manager: LocalCacheManager
        ):

        self.supabase = supabase
        self.ai_users = users
        self.company_shares = company_shares
        self.company_map = company_map
        self.company_performance_maps = company_performance_maps
        self.company_reputation_maps = company_reputation_maps
        self.company_stock_trend_maps = company_stock_trend_maps
        self.company_estimated_value_map = company_estimated_value_map
        self.company_listed_value_map = company_listed_value_map
        self.company_volatility_map = company_volatility_map
        self.logger = logger
        self.local_cache_manager = local_cache_manager
        
        self.trade_helper = TradeHelper(supabase=supabase, local_cache_manager = local_cache_manager)
          

    def make_ai_share_orders(self):

        # Randomize order of ai_users to prevent bias
        user_copies = self.ai_users.copy()
        random.shuffle(user_copies)

        with Progress() as progress:

            task = progress.add_task("[grey50]AI Share Trading Simulation...", total=len(user_copies))

            for user in user_copies:
                try:
                    
                    self.logger.count_user(user)
                    
                    #--------------------------------------------
                    # Get Bot State
                    # Bot's data from performance maps 
                    # Bot's current share groups, 
                    #--------------------------------------------
                    
                    user_company_statistics_maps, user_owned_share_groups, = self.get_bot_state(user)

                    #--------------------------------------------
                    # Evaluate and potentially sell existing shares
                    # Check if shares exceed the goals set by the bot
                    # Check if shares exceed the decline limits set by the bot
                    # Check if shares growth exceeds the bot's bubble confortability constant
                    # Check if company's reputation decline exceeds the bot's reputation confortability constant
                    # Check if company's growth decline exceeds the bot's growth confortability constant
                    #--------------------------------------------
                    
                    self.evaluate_positions(user, user_owned_share_groups, user_company_statistics_maps)
                    
                    #--------------------------------------------
                    # Evaluate whether to buy new shares
                    # Check if the bot's portfolio is below its liquidity constant 
                    #--------------------------------------------  
                    
                    is_portfolio_filled, portfolio = self.evaluate_liquidity(user)
                    
                    if is_portfolio_filled:
                        progress.update(task, advance=1)
                        continue
 
                    #--------------------------------------------
                    # Filter current shares for shares the bot can purchase
                    # Share's that are for sale
                    # Share's that are not owned by the bot
                    # Share's that the bot doesn't exceed their diversity constant for
                    #--------------------------------------------
                    
                    potential_company_shares_to_buy = self.filter_current_shares(user, user_owned_share_groups, self.company_shares, portfolio["SHARE_ASSETS"])
                
                    #--------------------------------------------
                    # Score shares based on bot's constants
                    # Share Past performance
                    # Share Volatility 
                    # Company Value vs Estimated Value
                    # Company Reputation
                    # Randomness
                    #--------------------------------------------  
                
                    scores = self.score_shares(user, potential_company_shares_to_buy, user_company_statistics_maps, **user.strategy_weights)     
                    
                    self.logger.log_users_wins(scores, user)             
                
                    #--------------------------------------------
                    # Buy shares based on sorted scores
                    #--------------------------------------------  
                    
                    self.purchase_shares(user, scores, portfolio, potential_company_shares_to_buy)
                            
                    
                    progress.update(task, advance=1)
                        
                except Exception as e:
                    print(f"[bold red underline][{datetime.datetime.now().replace(second=0, microsecond=0)}] AI {user.minecraft_username} encountered an error while making share orders: {e} [/bold red underline]")
                    progress.update(task, advance=1)
                    continue
            
            self.logger.calculate_averages()
    

    def get_bot_state(self, user: T_user) -> tuple[dict[str, dict[int, LineOfBestFit]], list[ShareGroup]]:
        
        def company_value_bot_estimate(estimated_value_map: dict, random_range: tuple) -> dict:
            
            new_estimated_value_map = {}
            for key, value in estimated_value_map.items():
                randomness = random.uniform(random_range[FIRST], random_range[SECOND])
                new_estimated_value_map[key] = value * randomness
            
            return new_estimated_value_map
                
        
        user_owned_shares = self.get_user_owned_shares(user.id)
        user_owned_share_groups = self.group_user_owned_shares(user_owned_shares)
        user_company_statistics_maps = {
            "TREND_ANALYSIS" : self.company_stock_trend_maps[TIME_PERIOD_TREND_ANALYSIS],
            "SALES" : self.company_performance_maps[user.history_scope],
            "REPUTATION" : self.company_reputation_maps[user.history_scope],
            "SHARE_PERFORMANCE" : self.company_stock_trend_maps[user.history_scope],
            "ESTIMATED_VALUE": company_value_bot_estimate(self.company_estimated_value_map, user.random_range),            
            "LISTED_VALUE" : self.company_listed_value_map,
            "VOLATILITY_TOLERANCE": self.company_volatility_map[user.history_scope]
            }
        
        return user_company_statistics_maps,  user_owned_share_groups
        
        

    def evaluate_positions(self, user: T_user, current_share_groups: list[ShareGroup], user_company_statistics_maps: dict[str, dict[int, LineOfBestFit]]) -> None:
        
        def evaluate_purchasable_position_for_profit_loss_goals(value, sale_price) -> tuple[bool,str]:
            percent_difference = abs(1 - (sale_price / max(value, 0.1)))
            
            if percent_difference > 0.05:
                return True, "N/A"
            else:
                return False, "NO_ACTION"
        
        def evaluate_position_for_profit_loss_goals(value, purchased_price, profit_goals, loss_limits) -> tuple[bool,str]:
            
            change = (value - purchased_price) / max(purchased_price, 1)
            
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
        
        def evalutate_position(share_group: ShareGroup, user: T_user, user_company_statistics_maps: dict[str, dict[int, LineOfBestFit]]) -> str:
            
            share = share_group.head_share
            
            value = share.company_share.value
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
                    user.remove_share_group_for_sale(share_group)
             
            premature_sell = random.randint(user.range_of_premature_sell[FIRST], user.range_of_premature_sell[SECOND]) == 1   
                 
            if (premature_sell):
                
                print(f"[magenta][{datetime.datetime.now().replace(second=0, microsecond=0)}] {user.minecraft_username} is prematurely selling one of his shares for {share.company.name}[\magenta]")
                return "SELL_NOW"
            
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
        
        for share_group in current_share_groups:
            decision = evalutate_position(share_group, user, user_company_statistics_maps)
            
            if decision == "NO_ACTION":
                continue
            
            if decision == "SELL_GAIN":
                self.trade_helper.sell_gain(user=user, share_group=share_group)
                print(f"[green][{datetime.datetime.now().replace(second=0, microsecond=0)}] {user.minecraft_username} is selling {len(share_group.shares)} of their shares in {share_group.head_share.company.name} for some profit[/green]")
            
            if decision == "SELL_NOW":
                self.trade_helper.sell_now(user=user, share_group=share_group)
                print(f"[bright_magenta][{datetime.datetime.now().replace(second=0, microsecond=0)}] {user.minecraft_username} is dumping {len(share_group.shares)} of their shares in {share_group.head_share.company.name} to prevent further loss[/bright_magenta]")
    

    def evaluate_liquidity(self, user: T_user) -> tuple[bool, dict]:
        portfolio = self.get_user_networth_breakdown(user)
        networth_invested = portfolio["SHARE_ASSETS"] / portfolio["NETWORTH"]
        
        return networth_invested > user.percentage_of_networth_to_invest, portfolio
    

    def filter_current_shares(self, user: T_user, user_owned_share_groups: list[ShareGroup], company_shares: list[CompanyShare], user_share_asset_total: float) -> list[CompanyShare]:
        
        diversity_requirement = user.diversity_minimum
        
        invalid_share_list: list[int] = []
        share_totals: dict[int, float] = {}
        
        for share_group in user_owned_share_groups:
            
            if share_group.head_share.company_share.id in share_totals:
                share_totals[share_group.head_share.company_share.id] = (share_group.head_share.company_share.value * len(share_group.shares)) + share_totals[share_group.head_share.company_share.id]
            else:
                share_totals[share_group.head_share.company_share.id] = (share_group.head_share.company_share.value * len(share_group.shares))
            
            if share_totals[share_group.head_share.company_share.id] / user_share_asset_total > diversity_requirement and share_group.head_share.company_share.id not in invalid_share_list:
                invalid_share_list.append(share_group.head_share.company_share.id)
        
        filtered_shares : list[CompanyShare] = []
        
        for company_share in company_shares:
            if company_share.id in invalid_share_list or company_share.id in filtered_shares:
                continue
            else:
                filtered_shares.append(company_share)
        
        return filtered_shares
    

    def score_shares(self, user: T_user, company_shares: list[CompanyShare],
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
        
        for company_share in company_shares:
            
            company_id = company_share.company_id
            
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
            
            score_map = {
                "TREND_ANALYSIS": trend_analysis_weight,
                "PERFORMANCE": performance_weight,
                "REPUTATION": reputation_weight,
                "SHARE_PERFORMANCE": share_performance_weight,
                "VALUE_ESTIMATION": value_estimation_weight,
                "VOLATILITY": volatility_weight,
                "TOTAL_SCORE" : trend_analysis_weight + performance_weight + reputation_weight + share_performance_weight + value_estimation_weight - volatility_weight
                }
            
            self.logger.log_users_scores(score_map, user, self.company_map[company_id].name)
            
            score = trend_analysis_weight + performance_weight + reputation_weight + share_performance_weight + value_estimation_weight - volatility_weight
            
            scores[company_id] = score
        
        return scores
            
    def purchase_shares(self, user: T_user, scores: dict[int, float], portfolio: dict[str, float], company_shares: list[CompanyShare]) -> None:
        
        items_sorted = sorted(scores.items(), key = lambda k: k[SECOND], reverse = True)
        
        top_three_companies = items_sorted[0:3]
        
        if len(top_three_companies) == 3:
            company_id_to_buy = int(random.choices(top_three_companies, weights=[0.6, 0.3, 0.1])[FIRST][FIRST])
        if len(top_three_companies) == 2:
            company_id_to_buy = int(random.choices(top_three_companies, weights=[2/3, 1/3])[FIRST][FIRST])
        if len(top_three_companies) == 1:
            company_id_to_buy = int(top_three_companies[FIRST][FIRST])
        if len(top_three_companies) == 0:
            print(f"[orange][{datetime.datetime.now().replace(second=0, microsecond=0)}] {user.minecraft_username} is returning without a buy order because none of the companies satisfied their diversity requirements or something.[/orange]")
            return
        
        share_to_buy = None
        
        for share in company_shares:
            if share.company_id == company_id_to_buy:
                share_to_buy = share
                break
        
        if share_to_buy == None:
            print(f"[orange][{datetime.datetime.now().replace(second=0, microsecond=0)}] {user.minecraft_username} is returning without a buy order because they share for the company they selected wasn't in the dictionary passed.[/orange]")
            return
        
        max_amount_to_invest_currently = (portfolio["NETWORTH"] * user.percentage_of_networth_to_invest) - portfolio["SHARE_ASSETS"]
        
        if max_amount_to_invest_currently > user.money:
            max_amount_to_invest_currently = user.money
        
        max_amount_to_invest_into_one_stock = portfolio["NETWORTH"] * user.diversity_minimum
        
        if max_amount_to_invest_into_one_stock < max_amount_to_invest_currently:
            max_amount_to_invest_currently = max_amount_to_invest_into_one_stock
        
        quantity_of_shares_to_buy = int(max_amount_to_invest_currently // (share_to_buy.value * 1.1) )
        
        if quantity_of_shares_to_buy <= 0:
            print(f"[yellow][{datetime.datetime.now().replace(second=0, microsecond=0)}] {user.minecraft_username} is returning without a buy order because they cannot afford to purchase a share for {self.company_map[share_to_buy.company_id].name}[/yellow]")
            return
        
        current_buy_orders = self.trade_helper.get_buy_orders_for_share(share_to_buy.id)
        
        current_user_buy_orders = list(filter(lambda x: x.user_id == user.id, current_buy_orders))
        
        if len(current_user_buy_orders) > 0:
            print(f"[yellow][{datetime.datetime.now().replace(second=0, microsecond=0)}] {user.minecraft_username} is returning without a buy order because they already have a buy order for {self.company_map[share_to_buy.company_id].name}[/yellow]")
            return 
        
        buy_order_price = self.decide_buy_order_max_price(user, share_to_buy, current_buy_orders, quantity_of_shares_to_buy)
        
        time_plus_one = datetime.datetime.now() + datetime.timedelta(hours=1)
        
        buy_order = BuyOrder(id = 0, created_at = "", expires_at = time_plus_one.isoformat(), company_share_id = share_to_buy.id, user_id = user.id, order_maximum = buy_order_price, order_quantity = quantity_of_shares_to_buy)
        
        # Update local cache since many ai_users will use it right after placing this order
        self.trade_helper.update_buy_orders_for_share(buy_order = buy_order)
        
        user.place_buy_order(buy_order = buy_order)
        
        print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] {user.minecraft_username} placed a buy order for {self.company_map[share_to_buy.company_id].name} at ${buy_order.order_maximum} with {buy_order.order_quantity} quantity[/bright_green]")
        
        
    
    # TODO
    # This currently is pretty fixed on how AI price shares, it takes nothing into account for how much an AI might actually want the share to start a bidding war
    # In the future this should be changed to allow for the users Share Score to play a part in the pricing aswell as the quanitity the bot wishes to buy
    def decide_buy_order_max_price(self, user: T_user, share: CompanyShare, current_buy_orders: list[BuyOrder], quantity_of_shares_to_buy: int) -> float:
        
        if current_buy_orders:
        
            most_expensive_order = max(current_buy_orders, key = lambda buy_order: buy_order.order_maximum)
            
            isOrderAI = any(u.id == most_expensive_order.user_id for u in self.ai_users)
            
            if most_expensive_order.order_maximum / share.value > 1.1 and not isOrderAI:
                
                print(f"[blue] [{datetime.datetime.now().replace(second=0, microsecond=0)}] {user.minecraft_username} detected that the buy orders are possibly manipulated by a player[/blue]")
                
                return share.value * 1.1
            
            else:
                return most_expensive_order.order_maximum + ((share.value * user.randomness) * (0.005 * (user.randomness**2)))
        
        else:
            return share.value 

    def get_current_available_shares(self) -> list[CompanyShare]:
        
        return self.company_shares
    
    def get_user_owned_shares(self, user_id) -> list[Share]:

        user_local_shares = [] 
        with SqliteAssistant(self.supabase) as sq:
            user_local_shares = sq.get_local_shares_by_user_id(user_id)
        
        user_shares = list(map(
            lambda share:Share(id=share.id, company=self.company_map[share.company_id], stake=share.stake, purchased_price=share.purchased_price, company_share=list(filter(
                lambda company_share: company_share.id == share.company_share_id, self.company_shares))[FIRST],
                               purchasable=share.purchasable, user_id=share.user_id, sale_price=share.sale_price), user_local_shares))
        
        return user_shares
    
    def group_user_owned_shares(self, shares: list[Share]) -> list[ShareGroup]:
        groups: dict[int, dict[int, ShareGroup]] = defaultdict(dict)

        for share in shares:
            company_id = share.company_share.id
            bucket = round(share.purchased_price / (share.purchased_price * 0.01))

            if bucket not in groups[company_id]:
                groups[company_id][bucket] = ShareGroup(share)
            else:
                groups[company_id][bucket].add_share_to_group(share)

        return [
            group
            for company_groups in groups.values()
            for group in company_groups.values()
        ]  

    def get_user_networth_breakdown(self, user: T_user) -> dict[str, float]:

        shares = self.get_user_owned_shares(user.id)

        liquid_assets = user.money
        share_assets = 0.0
        for share in shares:
            share_assets += share.company_share.value
            
        
        networth = liquid_assets + share_assets
        
        networth_breakdown = {
            "LIQUID_ASSETS": liquid_assets,
            "SHARE_ASSETS": share_assets,
            "NETWORTH": networth
        }
        
        user.networth_breakdown = networth_breakdown
        
        return networth_breakdown