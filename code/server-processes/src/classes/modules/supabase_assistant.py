
import random
from typing import Any

from supabase import Client
from classes.classes.company_share import CompanyShare
from classes.classes.share import Share
from classes.modules.sqlite_assistant import SqliteAssistant
from classes.subAi.james import James
from classes.subAi.emily import Emily
from classes.subAi.spencer import Spencer
from classes.subAi.jehan import Jehan
from classes.subAi.harsh import Harsh
from classes.subAi.marcelino import Marcelino
from classes.classes.company import Company
from rich.progress import Progress

from classes.subAi.t_user import T_user


class SupabaseAssistant:

    def __init__(self, supabase: Client):
        self.supabase = supabase
        self.users: list[T_user] = self.get_all_AI_users()
        self.company_map = self.build_company_map()
        self.company_shares = self.get_all_stocks()


    def make_new_company_shares_purchaseable(self, company_id, proportion_of_shares) -> None:
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

    def modify_ai_companies_reputations(self) -> None:
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

    def generate_new_ai_users(self, number_of_users: int) -> None:
        prefixes = [
    "Xx", "The", "Dark", "Shadow", "Epic", "Mr", "Dr", "Silent", "Crazy", "Lone",
    "Omega", "Ultra", "Noob", "Pro", "Ghost", "Cyber", "Iron", "Rapid", "Super", "Hyper",
    "Deadly", "True", "Mega", "Funky", "Lil", "Big", "OG", "Young", "Old", "Swift",
    "Blazing", "Frost", "Fire", "Electric", "Toxic", "Nuclear", "Venom", "Ice", "Stone", "Steel",
    "Bloody", "Eternal", "Divine", "Savage", "Killer", "Mighty", "Legend", "King", "Queen", "Sir",
    "Lord", "General", "Captain", "Major", "Agent", "Professor", "Sensei", "Guru", "Chief", "Commander",
    "Masked", "Phantom", "Turbo", "Atomic", "Galactic", "Solar", "Lunar", "Star", "Cosmic", "Planet",
    "Rusty", "Shiny", "Neon", "Retro", "Pixel", "TurboX", "Dynamic", "Max", "Mini", "Nano",
    "Crimson", "Golden", "Silver", "Bronze", "IronClad", "Jet", "RapidX", "Wild", "Cursed", "Blessed",
    "Hotshot", "Chill", "EpicX", "Sneaky", "Hidden", "Secret", "Ultimate", "Alpha", "Beta", "Gamma"
        ]
        names = [
    "Dragon", "Wolf", "Ninja", "Sniper", "Knight", "Beast", "Hunter", "Wizard", "Samurai", "Assassin",
    "Viper", "Phantom", "Titan", "Rogue", "Zombie", "Reaper", "Crusher", "Jester", "Hawk", "Storm",
    "Panther", "Tiger", "Lion", "Bear", "Shark", "Eagle", "Falcon", "Cobra", "Scorpion", "Serpent",
    "Golem", "Troll", "Orc", "Elf", "Dwarf", "Goblin", "Ghoul", "Wraith", "Demon", "Angel",
    "Devil", "Angelus", "Specter", "Shade", "Ghost", "Shadow", "Revenant", "Banshee", "Witch", "Warlock",
    "Cleric", "Paladin", "Priest", "Monk", "Barbarian", "Gladiator", "Champion", "Soldier", "Warrior", "Fighter",
    "Snorlax", "Pikachu", "Charizard", "Mewtwo", "Raichu", "Kirby", "Yoshi", "Toad", "Luigi", "Mario",
    "Bowser", "Link", "Zelda", "Ganon", "Master", "Chief", "Cortana", "Arbiter", "Kratos", "Zeus",
    "Thor", "Loki", "Hades", "Poseidon", "Apollo", "Ares", "Hermes", "Athena", "Ra", "Anubis",
    "Osiris", "Isis", "Horus", "Set", "Sphinx", "Minotaur", "Hydra", "Cerberus", "Griffin", "Phoenix"
        ]
        suffixes = [
    "99", "2000", "X", "1337", "420", "69", "777", "Alpha", "Beta", "Prime",
    "XL", "Pro", "OG", "IV", "III", "Two", "Zero", "One", "Boss", "King",
    "Queen", "Jr", "Sr", "Legend", "Master", "Lord", "Knight", "Samurai", "Sensei", "Wizard",
    "Overlord", "Destroyer", "Slayer", "Hunter", "Killer", "Beast", "Hero", "Champion", "Warrior", "Guardian",
    "God", "Demon", "Angel", "Fury", "Storm", "Thunder", "Blaze", "Inferno", "Frost", "Ice",
    "Fire", "Venom", "Poison", "Toxic", "Nuclear", "Atomic", "Solar", "Lunar", "Star", "Nova",
    "Eclipse", "Shadow", "Ghost", "Phantom", "Specter", "Spirit", "Reaper", "Zombie", "Ghoul", "Wraith",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "X0", "X1", "X2", "X3", "X4", "X5", "X6", "X7", "X8", "X9",
    "V1", "V2", "V3", "V4", "V5", "Max", "Ultra", "Turbo", "Deluxe", "Elite"
        ]
        avatars = [
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/1746240714126_herobrine.jpg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/1746240847914_steve.png",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/7fe448a1b0a9be8f650273831feefe9f.jpg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/a83c14035cc27a1baa4d4d53e91dea2d.jpg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/alex.png",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/big-sheep-face.png",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/blaize.jpeg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/bob.png",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/coolguy.png",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/creeper.jpg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/d62f2486e6e301b560d362de09d606f317b691dc.webp",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/dude.png",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/girl2.png",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/girl.jpg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/images.jpg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/jeb.jpg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/king.png",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/Minecraft-Chicken-Head.jpg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/steve2.png",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/steve.png",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/V_0iKFHm_400x400.jpg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/villager.jpg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/what-do-you-guys-think-of-my-skin-in-minecraft-1-10-just-v0-uaec73i59fqa1.webp"
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/027914beb4b82a6bd69616b01f003cca.jpg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/19e7806cd29faa7ef65aecf69005d9e7.jpg",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/d4c75958da73.png",
            "https://ylgfgklcypqtbqrkhsba.supabase.co/storage/v1/object/public/avatars/public/dd25ee9eaa92de037492354031983f68.jpg"    
        ]

        bot_type = [1, 2, 3, 4, 5, 6]  # Different AI types
        
        for _ in range(number_of_users):
            prefix = random.choice(prefixes)
            name = random.choice(names)
            suffix = random.choice(suffixes)
            avatar = random.choice(avatars)
            ai = random.choice(bot_type)
            minecraft_username = f"{prefix}{name}{suffix}"
            money = random.randint(1, 10000)
            daily_income = abs(random.normalvariate(500, 250))
            delivery_address = "spawn drop box"
            
            response = self.supabase.table("users").insert({
                "minecraft_username": minecraft_username,
                "money": money,
                "delivery_address": delivery_address,
                "daily_income": int(daily_income),
                "ai": True,
                "ai_type": ai,
                "avatar_url": avatar
            }).execute()
            
            print(f"Created AI user: {minecraft_username} with AI type {ai}, money {money}, daily income {int(daily_income)}, avatar {avatar}.")
            
            
            

    def complete_all_ai_orders(self) -> None:
        self.supabase.rpc("complete_ai_orders").execute()

    def get_all_AI_users(self) -> list:
        """
        Retrieve all AI users from the database and instantiate the appropriate AI class.
        
        Returns:
            List of AI user instances
        """
        response = self.supabase.table("users").select("*").eq("ai", True).execute()
        data = response.data
        users_list: list[Any] = []
        ai: Any = None
        
        with Progress() as progress:
            task = progress.add_task("[grey50]Building User List...", total=len(data))
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
                    else:
                        print(f"[yellow]Unknown AI type for {user} - skipping.[/yellow]")
                        continue
                    progress.advance(task, advance=1)
                    
                    users_list.append(ai)
                except Exception as e:
                    print(f"[bold red]Error creating AI for user {user['minecraft_username']}: {e} [/bold red]")
        return users_list
    
    def build_company_map(self) -> dict[int, Company]:
        company_response = self.supabase.table("companies").select("*").eq("verified", True).execute()
        companies = company_response.data
        
        with Progress() as progress:
            task = progress.add_task("[grey50]Building Company Map...", total=len(companies))
            company_map = {}
            for company in companies:
                company_map[company['id']] = Company(
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
                progress.advance(task, advance=1)
        
        return company_map
    
    
    def get_all_stocks(self) -> list[CompanyShare]:
        response = (
            self.supabase
                .from_("company_share")
                .select(
                    "*"
                )
                .execute()
        )
        
        
        company_shares = response.data
        company_shares_list = []
        for company_share in company_shares:
        
            company_share_object = CompanyShare(
                id = company_share["id"],
                value = company_share["value"],
                number_of_shares = company_share["number_of_shares"],
                company_id= company_share["company_id"],
                is_public=company_share["is_public"]
            )
            
            if company_share_object not in company_shares:
                company_shares_list.append(company_share_object)
            
        
        return company_shares_list
            
            
        