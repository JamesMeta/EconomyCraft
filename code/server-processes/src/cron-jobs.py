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

    # Create an instance of the Administration class

    def job1():
        admin = Administration(supabase)
        admin.make_ai_share_orders()
    
    def job2():
        admin = Administration(supabase)
        admin.make_ai_orders()
        admin.complete_all_ai_orders()
    
    def job3():
        admin = Administration(supabase)
        admin.service_buy_orders()

    
    schedule.every(8).hours.do(job2)
    schedule.every(45).minutes.do(job1)
    schedule.every(1).minute.do(job3)

    while True:
        print("Running scheduled tasks...")
        schedule.run_pending()
        time.sleep(1)  # Sleep for 1 second to avoid overwhelming the server

        
    
    



