from calendar import c
from supabase import create_client, Client
from classes.administration import Administration
import schedule
import time
import matplotlib.pyplot as plt
from dotenv import load_dotenv
import os
import random
import datetime
from rich import print

if (__name__ == "__main__"):

    load_dotenv()  # Load environment variables from .env file

    SUPABASE_URL = os.getenv("url")  # Get the Supabase URL from environment variables
    SUPABASE_SERVICE_ROLE_KEY = os.getenv("service_key")  # Get the Supabase service role key from environment variables

    if SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY:

        supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    def job_stocks():
        admin = Administration(supabase)
        admin.__stock_init__()
        admin.make_ai_share_orders()
        
    def job_products():
        admin = Administration(supabase)
        admin.__product_init__()
        admin.make_ai_orders()
        admin.complete_all_ai_orders()
        admin.modify_ai_companies_reputations()
    
    def job_buy_orders():
        admin = Administration(supabase)
        admin.__buy_order_init__()
        admin.service_buy_orders()
        
    def job_dividends():
        admin = Administration(supabase)
        admin.__dividend_init__()
        admin.payout_dividends()
        
    schedule.every(24).hours.do(job_dividends)
 
    schedule.every(8).hours.do(job_products)
        
    schedule.every(1).hour.do(job_stocks)
    
    schedule.every(1).minute.do(job_buy_orders)
    
    counter = 0
    
    print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Starting Cron-Job Manager ---------- [/bright_green]")
    
    job_stocks()
    job_products()
    job_dividends()
    job_buy_orders()
    
    while True:
        schedule.run_pending()
        time.sleep(1)  # Sleep for 1 second to avoid overwhelming the server
        
        if counter % 60 == 0:
            print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Running Cron-Job Manager ---------- [/bright_green]")
        
        counter += 1



        
    
    



