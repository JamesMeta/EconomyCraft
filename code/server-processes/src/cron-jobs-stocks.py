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

    def job():
        admin = Administration(supabase)
        admin.__stock_init__()
        admin.make_ai_share_orders()
        
    schedule.every(1).hours.do(job)
    
    counter = 0
    
    job()
    while True:
        schedule.run_pending()
        time.sleep(1)  # Sleep for 1 second to avoid overwhelming the server
        
        if counter % 60 == 0:
            print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Running Stock Manager ---------- [/bright_green]")
        
        counter += 1



        
    
    



