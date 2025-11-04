class Company:
    def __init__(self, id: int, created_at: str, name: str, reputation: int, is_public: bool, user_id: int, visibility_factor: int, ai: bool, notifications_enabled: bool):
        self.id = id
        self.created_at = created_at
        self.name = name
        self.reputation = reputation
        self.is_public = is_public
        self.user_id = user_id
        self.visibility_factor = visibility_factor
        self.ai = ai
        self.notifications_enabled = notifications_enabled