from classes.classes.company import Company

class Share:
    def __init__(self, id: int, company: Company, stake: float, purchased_price: float, value: float, purchasable: bool, user_id: int, is_public: bool, sale_price: float, company_share_id: int):
        self.id = id
        self.company = company
        self.stake = stake
        self.purchased_price = purchased_price
        self.value = value
        self.purchasable = purchasable
        self.user_id = user_id
        self.is_public = is_public
        self.sale_price = sale_price
        self.company_share_id = company_share_id
    def __repr__(self):
        return f"Share(id={self.id}, company_id={self.company.id}, stake={self.stake}, purchased_price={self.purchased_price}, value={self.value}, purchaseable={self.purchasable}, user_id={self.user_id}, is_public={self.is_public}, sale_price={self.sale_price}"
    def __str__(self):
        return f"Share ID: {self.id}, Company ID: {self.company.id}, Stake: {self.stake}, Purchased Price: {self.purchased_price}, Value: {self.value}, Purchaseable: {self.purchasable}, User ID: {self.user_id}, Is Public: {self.is_public}, Sale Price: {self.sale_price}"
        

