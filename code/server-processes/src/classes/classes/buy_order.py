class BuyOrder:
    def __init__(self, id : int, created_at: str, expires_at: str, company_share_id: int, user_id: int, order_maximum: float, order_quantity: int) -> None:
        self.id = id 
        self.created_at = created_at
        self.expires_at = expires_at
        self.company_share_id = company_share_id
        self.user_id = user_id
        self.order_maximum = order_maximum
        self.order_quantity = order_quantity
        
    def __repr__(self):
        return f"BuyOrder(created_at={self.created_at}, expires_at={self.expires_at}, company_share_id={self.company_share_id}, user_id={self.user_id}, order_maximum={self.order_maximum}, order_quantity={self.order_quantity})"
    
    def __str__(self):
        return f"BuyOrder Created At: {self.created_at}, Expires At: {self.expires_at}, Company Share ID: {self.company_share_id}, User ID: {self.user_id}, Order Maximum: {self.order_maximum}, Order Quantity: {self.order_quantity}"