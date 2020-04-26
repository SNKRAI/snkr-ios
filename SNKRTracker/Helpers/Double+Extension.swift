import Foundation

extension Double {
    var inKm: Double {
        convert(value: .miles, to: .kilometers)
    }
    
    var inMiles: Double {
        convert(value: .kilometers, to: .miles)
    }
    
    var distanceString: String {
        String(trunc(self * 100) / 100)
    }
    
    private func convert(value: UnitLength, to secondValue: UnitLength) -> Double {
        Measurement(value: self, unit: value).converted(to: secondValue).value
    }
}
