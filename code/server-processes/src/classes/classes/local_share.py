import numpy as np

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
        
    def __eq__(self, other):
        if not isinstance(other, LocalShare):
            return NotImplemented
        return self.id == other.id and self.company_id == other.company_id and self.stake == other.stake and np.floor(self.purchased_price) == np.floor(other.purchased_price) and self.purchasable == other.purchasable and self.user_id == other.user_id and np.floor(self.sale_price) == np.floor(other.sale_price) and self.company_share_id == other.company_share_id