from datetime import datetime
from typing import Optional


class Order:
    
    def __init__(self, id: int, created_at: str, product_id: int, company_id: int, delivery_address: str, quantity: int, payment: float, order_timeout: str, complete: bool, user_id: int, received: bool,) -> None:
        self.id = id
        self.created_at = datetime.fromisoformat(created_at)
        self.product_id = product_id
        self.company_id = company_id
        self.delivery_address = delivery_address
        self.quantity = quantity
        self.payment = payment
        self.order_timeout = datetime.fromisoformat(order_timeout)
        self.complete = complete
        self.user_id = user_id
        self.received = received
        
        