from supabase import create_client, Client
from classes.administration import Administration
import schedule
import time
import matplotlib.pyplot as plt
from dotenv import load_dotenv
import os
import random
from rich import print
import datetime

if (__name__ == "__main__"):

    load_dotenv()  # Load environment variables from .env file

    SUPABASE_URL = os.getenv("url")  # Get the Supabase URL from environment variables
    SUPABASE_SERVICE_ROLE_KEY = os.getenv("service_key")  # Get the Supabase service role key from environment variables

    if SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY:

        supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)


    
    def job():
        admin = Administration(supabase)
        admin.__buy_order_init__()
        admin.service_buy_orders()
    
    counter = 0
    
    while True:
        try:
            job()
            time.sleep(60)
            
            if counter % 60 == 0:
                print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Running Buy Order Manager ---------- [/bright_green]")
            
            counter += 1
        except Exception as e:
            print(f"[bold red underline]Error in Buy Order Manager cron job: {e}[/bold red underline]")

        
    
    



