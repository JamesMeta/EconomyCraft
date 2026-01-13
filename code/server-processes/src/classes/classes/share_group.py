from classes.classes.share import Share

class ShareGroup:
    def __init__(self, first_share: Share):
        self.head_share = first_share
        self.shares: list[Share] = [first_share]
    
    def add_share_to_group(self, share: Share):
        self.shares.append(share)
    
    def check_if_share_fits_in_group(self, share: Share, tol = 0.01) -> bool:
        
        highest_possible_price = self.head_share.purchased_price * (1 + tol)
        lowest_possible_price = self.head_share.purchased_price * (1 - tol)
        
        return min([share.purchased_price, highest_possible_price], default = 0) == share.purchased_price and max([share.purchased_price, lowest_possible_price], default = 0) == share.purchased_price
    
    