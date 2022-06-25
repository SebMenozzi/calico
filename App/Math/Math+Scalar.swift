extension FloatingPoint {
    
    var degreesToRadians: Self { 
        self * .pi / 180
    }
    var radiansToDegrees: Self {
        self * 180 / .pi
    }

    static var randomSign: Self {
        if Bool.random() {
            return 1
        } else {
            return -1
        }
    }
}
