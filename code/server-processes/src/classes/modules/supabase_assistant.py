
import random
from classes.subAi.james import James
from classes.subAi.emily import Emily
from classes.subAi.spencer import Spencer
from classes.subAi.jehan import Jehan
from classes.subAi.harsh import Harsh
from classes.subAi.marcelino import Marcelino
from classes.subAi.mark import Mark
from classes.classes.company import Company


class SupabaseAssistant:

    def __init__(self, supabase):
        self.supabase = supabase
        self.users = self.get_all_users()
        self.company_map = {}
        self.build_company_map()

    def make_new_company_shares_purchaseable(self, company_id, proportion_of_shares):
        """
        Make a proportion of new shares purchasable for a company.
        
        Args:
            company_id: ID of the company
            proportion_of_shares: Proportion of shares to make purchasable (0-1)
        """
        response = self.supabase.table("company_share").select("*").eq("company_id", company_id).execute()
        company_share = response.data
        share_id =  company_share[0]['id'] if company_share else None
        number_of_shares_to_make_purchasable = int(company_share[0]['number_of_shares'] * proportion_of_shares)

        if share_id is not None:
            response = self.supabase.table("shares").select("*").eq("company_id", company_id).eq("share_id", share_id).execute()
            shares = response.data

            if shares:
                sale_price = company_share[0]['value']
                for i in range(number_of_shares_to_make_purchasable):
                    share = shares[i]
                    if not share['purchasable']:
                        self.supabase.table("shares").update({"purchasable": True,  "sale_price": sale_price}).eq("id", share['id']).execute()
                        # print(f"[green]Made share ID {share['id']} purchasable for company ID {company_id}.[/green]")
                    
                    if i <= number_of_shares_to_make_purchasable // 4:
                        sale_price *=1.00025
                    elif i <= number_of_shares_to_make_purchasable // 2:
                        sale_price *= 1.0005
                    elif i <= (number_of_shares_to_make_purchasable // 1.25):
                        sale_price *= 1.001
                    else:
                        sale_price *= 1.0025

    def modify_ai_companies_reputations(self):
        """
        Modify a company's reputation based on its performance.
        
        Args:
            company_id: ID of the company
        """

        # Get the company's current reputation
        response = self.supabase.table("companies").select("*").eq("ai", True).execute()
        company_data = response.data
        
        if not company_data or len(company_data) == 0:
            print(f"[bold red]Companies not found.[/bold red]")
            return
            
        for company in company_data:
            current_reputation = company['reputation']
            
            # Reputation should stay within the range that it currently is
            # however since we are using it as a rate of change in our share calculations it would be best
            # if it still changed but never permanently changed
            # so we will use a small random factor to adjust it and statistically it will stay within the range
            
            # flip coin to determine if we increase or decrease reputation 
            # change is currently set at 25 points either way
            if random.choice([True, False]):
                new_reputation = current_reputation + 25
            else:
                new_reputation = current_reputation - 25
            # Ensure reputation stays within bounds
            new_reputation = max(0, min(1000, new_reputation))
            # Update the company's reputation in the database
            self.supabase.table("companies").update({"reputation": new_reputation}).eq("id", company['id']).execute()
            print(f"[dim white]Modified reputation for company ID {company['id']} from {current_reputation} to {new_reputation}.[/dim white]")

    def generate_new_ai_users(self, number_of_users: int):
        pass

    def complete_all_ai_orders(self):
        """Execute database function to complete all AI orders."""
        response = self.supabase.rpc("complete_ai_orders").execute()

    def get_all_users(self):
        """
        Retrieve all AI users from the database and instantiate the appropriate AI class.
        
        Returns:
            List of AI user instances
        """
        response = self.supabase.table("users").select("*").eq("ai", True).execute()
        data = response.data
        users_list = []

        for user in data:
            try:
                if user['ai_type'] == 3:
                    ai = James(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                elif user['ai_type'] == 1:
                    ai = Emily(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                elif user['ai_type'] == 2:
                    ai = Spencer(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                elif user['ai_type'] == 4:
                    ai = Jehan(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                elif user['ai_type'] == 5:
                    ai = Harsh(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                elif user['ai_type'] == 6:
                    ai = Marcelino(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                elif user['ai_type'] == 7:
                    ai = Mark(self.supabase, user['id'], user['minecraft_username'], user['money'], user['delivery_address'], user['daily_income'], user['ai_type'])
                else:
                    print(f"[yellow]Unknown AI type for {user} - skipping.[/yellow]")
                    continue
                
                users_list.append(ai)
            except Exception as e:
                print(f"[bold red]Error creating AI for user {user['minecraft_username']}: {e} [/bold red]")
        
        print(f"[dim white]Loaded {len(users_list)} AI users from the database.[/dim white]")
        return users_list
    
    def build_company_map(self):
        company_response = self.supabase.table("companies").select("*").eq("verified", True).execute()
        companies = company_response.data
                
        for company in companies:
            self.company_map[company['id']] = Company(
                id=company['id'],
                created_at=company['created_at'],
                name=company['name'],
                reputation=company['reputation'],
                is_public=company['is_public'],
                user_id=company['user_id'],
                visibility_factor=company['visibility_factor'],
                ai=company['ai'], 
                notifications_enabled=company['notification']
            )