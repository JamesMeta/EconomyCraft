
class LocalShare:
    def __init__(self, id: int, company_id: int, stake: float, purchased_price: float, company_share_id: int, purchasable: bool, user_id: int, sale_price: float,):
        self.id = id
        self.company_id = company_id
        self.stake = stake
        self.purchased_price = purchased_price
        self.purchasable = purchasable
        self.user_id = user_id
        self.sale_price = sale_price
        self.company_share_id = company_share_id