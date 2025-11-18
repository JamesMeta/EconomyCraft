class CompanyShare:
  def __init__(self, id: int, company_id: int, value: float, number_of_shares: int, is_public: bool):
    self.id = id
    self.company_id = company_id
    self.value = value
    self.number_of_shares = number_of_shares
    self.is_public = is_public

  def __eq__(self, other):
    if not isinstance(other, CompanyShare):
        return NotImplemented
    return self.id == other.id

  def __hash__(self):
    return hash(self.id)
