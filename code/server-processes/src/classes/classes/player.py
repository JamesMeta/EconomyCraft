from uuid import UUID


class Player:
    
    def __init__(self, id: int, user_id: UUID, minecraft_username: str, money: int, avatar_url: str, delivery_address: str) -> None:
        self.id = id
        self.user_id = user_id
        self.minecraft_username = minecraft_username
        self.money = money
        self.avatar_url = avatar_url
        self.delivery_address = delivery_address
        