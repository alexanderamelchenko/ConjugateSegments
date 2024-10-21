//
//  ConjugateMath.swift
//  ConjugateSegments
//
//  Created by Alexander on 21.10.2024.
//

import Foundation

final class MathHelper {
    
    static func distanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    static func degTorad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    static func polygonPointArray(sides: Int,
                                  x: CGFloat,
                                  y: CGFloat,
                                  innerRadius: CGFloat,
                                  outerRadius: CGFloat) -> [CGPoint] {
        let angle = degTorad(360 / CGFloat(sides))
        var i = 0
        var points = [CGPoint]()
        while i <= sides {
            let xpinner = x + innerRadius * cos(angle * CGFloat(i))
            let ypinner = y + innerRadius * sin(angle * CGFloat(i))
            points.append(CGPoint(x: xpinner, y: ypinner))
            let xpouter = x + outerRadius * cos((angle * CGFloat(i)) + angle / 2)
            let ypouter = y + outerRadius * sin((angle * CGFloat(i)) + angle / 2)
            points.append(CGPoint(x: xpouter, y: ypouter))
            i += 1
        }
        return points
    }
    
}
