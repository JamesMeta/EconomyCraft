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
        admin.__product_init__()
        admin.make_ai_orders()
        admin.complete_all_ai_orders()
 
    schedule.every(8).hours.do(job)
 
    counter = 0
    
    job()
    while True:
        schedule.run_pending()
        time.sleep(1)
        
        if counter % 60 == 0:
            print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Running Product Manager ---------- [/bright_green]")

        counter += 1
        
    
    



