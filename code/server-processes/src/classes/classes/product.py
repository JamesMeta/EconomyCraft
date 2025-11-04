class Product:
    def __init__(self, id: int, created_at: str, name: str, minecraft_tag: str, company_id: int, price: float, quantity: int, value: float, niche_coefficient: float):
        self.id = id
        self.created_at = created_at
        self.name = name
        self.minecraft_tag = minecraft_tag
        self.company_id = company_id
        self.price = price
        self.quantity = quantity
        self.value = value
        self.niche_coefficient = niche_coefficient

    def __repr__(self):
        return f"Product(id={self.id}, name={self.name}, company_id={self.company_id}, price={self.price}, quantity={self.quantity}, value={self.value}, niche_coefficient={self.niche_coefficient})"
    def __str__(self):
        return f"Product: {self.name} (ID: {self.id}, Company ID: {self.company_id}, Price: {self.price}, Quantity: {self.quantity}, Value: {self.value}, Niche Coefficient: {self.niche_coefficient})"