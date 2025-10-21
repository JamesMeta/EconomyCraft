class LineOfBestFit:
    def __init__(self, slope: float, b: float) -> None:
        self.slope: float = slope
        self.b: float = b
        
    def __str__(self) -> str:
        return str.format(f"Slope: {self.slope} Y-intercept: {self.b}")
    
    def __mul__(self, scaler: float) -> object:
        return LineOfBestFit(self.slope * scaler, self.b * scaler)