import SceneKit

// MARK: - SCNVector3 Math

extension SCNVector3 {
    static func + (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    static func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }

    static func * (lhs: SCNVector3, rhs: Float) -> SCNVector3 {
        return SCNVector3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }

    var length: Float {
        return sqrt(x * x + y * y + z * z)
    }

    var normalized: SCNVector3 {
        let len = length
        guard len > 0 else { return SCNVector3Zero }
        return SCNVector3(x / len, y / len, z / len)
    }

    func distance(to other: SCNVector3) -> Float {
        return (self - other).length
    }
}

// MARK: - Float Helpers

extension Float {
    func lerp(to target: Float, amount: Float) -> Float {
        return self + (target - self) * amount
    }

    func clamped(min minVal: Float, max maxVal: Float) -> Float {
        return Swift.max(minVal, Swift.min(maxVal, self))
    }
}

// MARK: - Int Formatting

extension Int {
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
