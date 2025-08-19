from supabase import create_client, Client
from classes.administration import Administration
from classes.subAi.james import James
from classes.subAi.emily import Emily
from classes.subAi.spencer import Spencer
from classes.subAi.jehan import Jehan
from classes.subAi.harsh import Harsh
from classes.subAi.marcelino import Marcelino
from classes.subAi.mark import Mark
import schedule
import time
import matplotlib.pyplot as plt

if (__name__ == "__main__"):
    SUPABASE_URL = ""
    SUPABASE_SERVICE_ROLE_KEY = ""

    # Create the Supabase client using the service role key
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    # Create an instance of the Administration class

    # def job1():
    #     admin = Administration(supabase)
    #     admin.make_ai_share_orders()
    
    def job2():
        admin = Administration(supabase)
        admin.make_ai_orders()

    
    schedule.every(1).day.do(job2)

    job2()
    while True:
        schedule.run_pending()
        time.sleep(60)  # Sleep for 1 minute to avoid overwhelming the server

    # admin = Administration(supabase)
    # admin.make_ai_orders()
    # admin.complete_all_ai_orders()

    # iterations = 1
    admin = Administration(supabase)
    score_map = admin.make_ai_share_orders()

    for ai_type, shares in score_map.items():
        print(f"AI Type: {ai_type}")
        for share, score in shares.items():
            print(f"  Share: {share}, Score: {score:.4f}")


    # shares_over_time = {15: [], 16: [],}

    # for i in range(iterations):
    #     print(f"Iteration {i + 1}/{iterations}")
    #     admin.make_ai_share_orders()
    #     current_shares = admin.get_current_shares()
    #     for share in current_shares:
    #         if share.company.id in shares_over_time:
    #             shares_over_time[share.company.id].append(share.value)
    #         else:
    #             shares_over_time[share.company.id] = [share.value]

    # # Plotting the share values over time
    # plt.figure(figsize=(10, 5))
    # for company_id, values in shares_over_time.items():
    #     plt.plot(values, label=f'Company {company_id}')
    # plt.xlabel('Iteration')
    # plt.ylabel('Share Value')
    # plt.title('Share Values Over Time')
    # plt.legend()
    # plt.show()

    # Make new companies shares purchaseable
    # admin = Administration(supabase)
    # admin.make_new_company_shares_purchaseable(15, 0.49)
    # admin.make_new_company_shares_purchaseable(16, 0.49)
    # admin.make_new_company_shares_purchaseable(21, 0.49)
    # admin.make_new_company_shares_purchaseable(22, 0.55)
    # admin.make_new_company_shares_purchaseable(23, 0.65)
    # admin.make_new_company_shares_purchaseable(24, 0.65)
        
    # modify company reputation
    # admin = Administration(supabase)
    # admin.modify_ai_companies_reputations()

    # get strategy weights distribution
    # admin = Administration(supabase)
    # strategy_weights = admin.get_sum_of_strategy_weights()

    # plt.figure(figsize=(10, 5))
    # plt.bar(strategy_weights.keys(), strategy_weights.values())
    # plt.xlabel('Strategy')
    # plt.ylabel('Total Weight')
    # plt.title('Strategy Weights Distribution')
    # plt.xticks(rotation=45)
    # plt.tight_layout()
    # plt.show()


