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

    # Create the Supabase client using the service role key
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)



    # Create an instance of the Administration class

    def job1():
        admin = Administration(supabase)
        admin.make_ai_share_orders()
    
    def job2():
        admin = Administration(supabase)
        admin.make_ai_orders()
        admin.complete_all_ai_orders()

    
    # schedule.every(1).day.do(job2)
    # #schedule.every(60).minutes.do(job1)

    #job2()
    # while True:
    #     print("Running scheduled tasks...")
    #     schedule.run_pending()
    #     time.sleep(60)  # Sleep for 1 minute to avoid overwhelming the server

    # admin = Administration(supabase)
    # admin.make_ai_orders()
    # admin.complete_all_ai_orders()
    
    admin = Administration(supabase)
    
    admin.supabase_assistant.generate_new_ai_users(1)
    
    # scores = admin.make_ai_share_orders()
    
    # for item in scores.items():
    #     user, scores_map = item
    #     print(user)
    #     for name, score in scores_map.items():
    #         print(f"  {name}: {score}")
        
    #     print("\n")
        
    
    



