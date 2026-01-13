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

from classes.classes.local_share import LocalShare
from classes.classes.share import Share
from classes.modules.sqlite_assistant import SqliteAssistant

if (__name__ == "__main__"):

    load_dotenv()  # Load environment variables from .env file

    SUPABASE_URL = os.getenv("url")  # Get the Supabase URL from environment variables
    SUPABASE_SERVICE_ROLE_KEY = os.getenv("service_key")  # Get the Supabase service role key from environment variables

    if SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY:

        supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)


    admin = Administration(supabase)
    
    print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Starting Database Validation ---------- [/bright_green]")
    supabase_shares_response = supabase.table("shares").select("*").execute()
    print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Fetched Shares from Supabase ---------- [/bright_green]")
    supabase_shares_data = supabase_shares_response.data
    supabase_shares = list(map(lambda x: LocalShare(
        id=x["id"],
        company_id=x["company_id"],
        stake=x["stake"],
        purchased_price=x["purchased_price"],
        purchasable=x["purchasable"],
        company_share_id=x["share_id"],
        sale_price=x["sale_price"],
        user_id=x["user_id"]
        ), supabase_shares_data))
    print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Mapped Shares from Supabase ---------- [/bright_green]")
    
    inaccuracy_count = 0
    with SqliteAssistant(supabase) as sq:
        local_shares = sq.get_all_local_shares()
        print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Fetched Shares from Local SQLite ---------- [/bright_green]")
        
        print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Starting Validation ---------- [/bright_green]")
        for index, local_share in enumerate(local_shares):
            if local_share not in supabase_shares:
                print(f"[bold red underline]Local share ID {local_share.id} not found in Supabase![/bold red underline]")
                inaccuracy_count += 1
            
            if index % 1000 == 0:
                print(f"[bright_blue][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Validated {index} / {len(local_shares)} Shares ---------- [/bright_blue]")
        
    print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Database Validation Complete ---------- [/bright_green]")
    
    print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Total Inaccuracies Found: {inaccuracy_count} ---------- [/bright_green]")
    print(f"[bright_green][{datetime.datetime.now().replace(second=0, microsecond=0)}] -------- Inaccuracies Percentage: {(inaccuracy_count/len(supabase_shares)) * 100}% ---------- [/bright_green]")
        
        
        
   
        
    
    



        
    
    



