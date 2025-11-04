import datetime
from typing import Any
import numpy as np
from supabase import Client
from classes.AI import AI
from classes.classes.company import Company
from classes.classes.volatility import Volatility
from classes.classes.line_of_best_fit import LineOfBestFit
from classes.modules.constants import TIME_PERIOD_SHORT, TIME_PERIOD_MEDIUM, TIME_PERIOD_LONG, TIME_PERIOD_TREND_ANALYSIS, DEFAULT_RETURN_NO_DATA, DEFAULT_RETURN_NO_CHANGE

from rich.progress import Progress

from classes.subAi.t_user import T_user

class Performance:

    def __init__(self, supabase: Client, users: list[T_user], company_map: dict[int, Company]):
        self.supabase = supabase
        self.company_map = company_map
        self.users = users
        self.company_performance_maps: dict[int, dict[int, LineOfBestFit]] = {0:{}, TIME_PERIOD_SHORT:{}, TIME_PERIOD_MEDIUM:{}, TIME_PERIOD_LONG:{}}
        self.company_reputation_maps: dict[int, dict[int, LineOfBestFit]] = {0:{}, TIME_PERIOD_SHORT:{}, TIME_PERIOD_MEDIUM:{}, TIME_PERIOD_LONG:{}}
        self.company_stock_trend_maps: dict[int, dict[int, LineOfBestFit]] = {0:{}, TIME_PERIOD_SHORT:{}, TIME_PERIOD_MEDIUM:{}, TIME_PERIOD_LONG:{}, TIME_PERIOD_TREND_ANALYSIS:{}}
        self.company_estimated_value_map: dict[int, float] = {}
        self.company_listed_value_map: dict[int, float] = {}
        self.company_volatility_maps: dict[int, dict[int, Volatility]] = {0:{}, TIME_PERIOD_SHORT:{}, TIME_PERIOD_MEDIUM:{}, TIME_PERIOD_LONG:{}}
        self.order_history_cache: dict[int, list[dict[str, Any]]] = {}
        self.share_history_cache: dict[int, list[dict[str, Any]]] = {}
        self.company_history_cache: dict[int, list[dict[str, Any]]] = {}
        self.get_company_data_for_performance_maps()
        self.build_company_performance_maps()
    
    def build_company_performance_maps(self) -> None:
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
                self.company_stock_trend_maps[TIME_PERIOD_TREND_ANALYSIS][company.id] = self.get_company_share_value_change_over_time(company.id, TIME_PERIOD_TREND_ANALYSIS)

                # Build estimated value map
                self.company_estimated_value_map[company.id] = self.calculate_company_estimated_value(company.id)
                self.company_listed_value_map[company.id] = self.calculate_company_listed_value(company.id)
                
                # Build VOLATILITY map
                self.company_volatility_maps[TIME_PERIOD_SHORT][company.id] = self.build_company_volatility(company.id, TIME_PERIOD_SHORT)
                self.company_volatility_maps[TIME_PERIOD_MEDIUM][company.id] = self.build_company_volatility(company.id, TIME_PERIOD_MEDIUM)
                self.company_volatility_maps[TIME_PERIOD_LONG][company.id] = self.build_company_volatility(company.id, TIME_PERIOD_LONG)


                progress.update(task, advance=1)
    
    def get_company_data_for_performance_maps(self) -> None:
        with Progress() as progress:
            task = progress.add_task("[grey50]Caching company history data...", total=len(self.company_map))
            for company in self.company_map.values():
                # Cache order history
                response = self.supabase.table("orders").select("*").eq("company_id", company.id).order("created_at", desc=True).execute()
                self.order_history_cache[company.id] = response.data
                # Cache share history
                response = self.supabase.table("company_share").select("id").eq("company_id", company.id).execute()
                if response.data:
                    company_share_id = response.data[0]['id']
                    response = self.supabase.table("share_history").select("*").eq("share_id", company_share_id).order("created_at", desc=True).execute()
                    self.share_history_cache[company.id] = response.data
                # Cache company history
                response = self.supabase.table("company_history").select("*").eq("company_id", company.id).order("created_at", desc=True).execute()
                self.company_history_cache[company.id] = response.data
                progress.update(task, advance=1)
            

    def get_company_rate_of_reputation_change_over_time(self, company_id: int, history_scope: int) -> LineOfBestFit:

        
        company_history = self.company_history_cache[company_id][0:history_scope]
        
        # If no history data, return no change
        if not company_history or len(company_history) < 2:
            return LineOfBestFit()
            
        # --------------------
        # Find slope of reputation change
        # --------------------

        time_dt = [datetime.datetime.fromisoformat(entry['created_at']) for entry in company_history]
        reputation_dx = [entry['reputation'] for entry in company_history]

        start_date = time_dt[0]
        time_numeric = np.array([(dt - start_date).days for dt in time_dt])

        slope, intercept = np.polyfit(time_numeric, reputation_dx, 1)

        best_fit = LineOfBestFit(slope, intercept)
        return best_fit
    
    def get_company_rate_of_revenue_change_over_time(self, company_id: int, history_scope: int) -> LineOfBestFit:

        # Get all orders for this company
        
        orders = self.order_history_cache.get(company_id)
        
        # If no orders, return placeholder value
        if not orders or len(orders) <= 1:
            return LineOfBestFit()
            
        # Use timezone-aware datetime for comparison
        now = datetime.datetime.now(datetime.timezone.utc)
        
        # Filter orders within the specified time scope
        orders_within_scope = [
            order for order in orders 
            if (now - datetime.datetime.fromisoformat(order['created_at'])).days <= history_scope
        ]
        
        # If no orders within scope, return placeholder value
        if not orders_within_scope or len(orders_within_scope) == 0:
            return LineOfBestFit()
            
        # Calculate daily revenue totals
        daily_revenue = {}
        for order in orders_within_scope:
            date = order['created_at'].split("T")[0]
            if date not in daily_revenue:
                daily_revenue[date] = order['payment']
            daily_revenue[date] += order['payment']
            
        # Need at least 2 days of data to calculate change
        if len(daily_revenue) < 2:
            return LineOfBestFit()
        
        # Need to account for days where no sales were made
        if len(daily_revenue) < history_scope:
            today = datetime.datetime.today()
            
            date_iterator = today - datetime.timedelta(days=history_scope)
            
            for i in range(history_scope):
                date_iterator_string = (str(date_iterator)).split()[0]
                
                if date_iterator_string not in daily_revenue:
                    daily_revenue[date_iterator_string] = 0.0
                    
                date_iterator = date_iterator + datetime.timedelta(days=1)
            
        # --------------------
        # Find slope of revenue change
        # --------------------

        dates = list(daily_revenue.keys())
        revenue_values = list(daily_revenue.values())

        start_date = datetime.datetime.fromisoformat(dates[0])
        time_numeric = np.array([(datetime.datetime.fromisoformat(date) - start_date).days for date in dates])
        revenue_numeric = np.array(revenue_values)
        slope, intercept = np.polyfit(time_numeric, revenue_numeric, 1)
        best_fit = LineOfBestFit(slope,intercept)
        return best_fit

    def get_company_share_value_change_over_time(self, company_id: int, history_scope: int) -> LineOfBestFit:


        # Get company share history

        share_history = self.share_history_cache[company_id][0:history_scope * 24]  # Assuming hourly data
        if not share_history or len(share_history) < 2:
            return LineOfBestFit()
        # --------------------
        # Find slope of share value change
        # --------------------
        time_dt = [datetime.datetime.fromisoformat(entry['created_at']) for entry in share_history]
        share_value_dx = [entry['value'] for entry in share_history]
        start_date = time_dt[0]
        time_numeric = np.array([(dt - start_date).total_seconds() / 3600 for dt in time_dt])
        slope, intercept = np.polyfit(time_numeric, share_value_dx, 1)
        best_fit = LineOfBestFit(slope,intercept)
        return best_fit
    
    def calculate_company_estimated_value(self, company_id: int) -> float:

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

    def calculate_company_listed_value(self, company_id: int) -> float:

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
    
    def build_company_volatility(self, company_id: int, history_scope: int) -> Volatility:
        share_history = self.share_history_cache[company_id][0:history_scope * 24]  # Assuming hourly data
        if not share_history or len(share_history) < 2:
            return Volatility([1,1])
        
        else:
            dataset: list[float] = list(filter(lambda x:x != 0, map(lambda x:x['value'],share_history)))
            
            return Volatility(dataset)
        

    
    
    