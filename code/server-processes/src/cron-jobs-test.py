from supabase import create_client, Client
from classes.administration import Administration
import schedule
import time
import matplotlib.pyplot as plt
from dotenv import load_dotenv
import os
import random

if (__name__ == "__main__"):

    load_dotenv()  # Load environment variables from .env file

    SUPABASE_URL = os.getenv("url")  # Get the Supabase URL from environment variables
    SUPABASE_SERVICE_ROLE_KEY = os.getenv("service_key")  # Get the Supabase service role key from environment variables

    if SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY:

        supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)


    def job1():
        admin = Administration(supabase)
        admin.__stock_init__()
        admin.make_ai_share_orders()
    
    def job2():
        admin = Administration(supabase)
        admin.__product_init__()
        admin.make_ai_orders()
        admin.complete_all_ai_orders()
    
    def job3():
        admin = Administration(supabase)
        admin.__buy_order_init__()
        admin.service_buy_orders()

    def job_test():
        admin = Administration(supabase)
        admin.__stock_init__()
        admin.make_ai_share_orders()
        admin.logger.print_all_tables()
        admin.logger.build_all_charts()
    
    def job_test2():
        admin = Administration(supabase)
        admin.__utility_init__()
        admin.print_user_history_scope_spread()
        admin.get_sum_of_strategy_weights()
    
    job_test()


        
    
    



