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
        admin.make_ai_share_orders()
    
    def job2():
        admin = Administration(supabase)
        admin.make_ai_orders()
        admin.complete_all_ai_orders()
    
    def job3():
        admin = Administration(supabase, lite=True)
        admin.service_buy_orders()

    def job_test():
        admin = Administration(supabase)
        maps = admin.performance.company_performance_maps
        
        for map, item in maps.items():
            print(f"_______{map}______")
            for company, slope in item.items():
                print(f"{company}:{slope}")
    
    job_test()


        
    
    



