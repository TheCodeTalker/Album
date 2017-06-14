//
//  CalculationsShape.swift
//  MYAlbum
//
//  Created by Chitaranjan Sahu on 14/06/17.
//  Copyright © 2017 Ithink. All rights reserved.
//

import Foundation

class CalculationsShape{
    static func getSizeWithFloatValue(number:Float,widthConstant widthC:Int,heightConstant heightC:Int) -> NSValue {
        let rootValue = sqrtf(number)
        let width = Float(widthC) * rootValue
        let height = Float(heightC) * rootValue
        
        let newSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        
        return NSValue(cgSize:newSize)
    }
    
}
