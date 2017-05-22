//
//  UIColorExtensions.swift
//  Homehapp
//
//  Created by DEVELOPER on 06/01/16.
//  Copyright © 2016 Homehapp. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// homehapp main screen background pattern
    class func lightBackgroundPatternColor() -> UIColor {
        let patternImage = UIImage(named: "bg_gray-light")
        return UIColor(patternImage: patternImage!)
    }
    
    /// homehapp color for active and selected things (close to orange)
    class func homehappColorActive() -> UIColor {
        return UIColor(red: 224.0/255.0, green: 172.0/255.0, blue: 90.0/255.0, alpha: 1.0)
    }
    
    /// homehapp dark grey color for text, etc.
    class func homehappDarkColor() -> UIColor {
        return UIColor(red: 59.0/255.0, green: 48.0/255.0, blue: 49.0/255.0, alpha: 1.0)
    }

    /**
     Convenience initializer for constructing the UIColor with integer components.
     
     - parameter redInt: value for red (0-255)
     - parameter greenInt: value for green (0-255)
     - parameter blueInt: value for blue (0-255)
     - parameter alpha: value for alpha (0-1.0)
     */
    public convenience init(redInt: Int, greenInt: Int, blueInt: Int, alpha: Double) {
        self.init(red: CGFloat(redInt)/255.0, green: CGFloat(greenInt)/255.0, blue: CGFloat(blueInt)/255.0, alpha: CGFloat(alpha))
    }
    
    /**
     Convenience initializer for creating a UIColor from a hex string; accepted formats are
     RRGGBB, RRGGBBAA, #RRGGBB, #RRGGBBAA. If an invalid input is given as the hex string,
     the color is initialized to white.
     
     - parameter hexString: the RGB or RGBA string
     */
    public convenience init(hexString: String) {
        var hexString = hexString;
        
        if hexString.hasPrefix("#") {
//            hexString = hexString.substring(startIndex: 1)
            hexString = hexString.substring(1)
        }
        
        if (hexString.length != 6) && (hexString.length != 8) {
            // Color string is invalid format; return white
            self.init(white: 1.0, alpha: 1.0)
        } else {
            // If the format is RRGGBB instead of RRGGBBAA, use FF as alpha component
            if hexString.length == 6 {
                hexString = "\(hexString)FF"
            }
            
            let scanner = Scanner(string: hexString)
            var rgbaValue: UInt32 = 0
            if scanner.scanHexInt32(&rgbaValue) {
                let red = (rgbaValue & 0xFF000000) >> 24
                let green = (rgbaValue & 0x00FF0000) >> 16
                let blue = (rgbaValue & 0x0000FF00) >> 8
                let alpha = rgbaValue & 0x000000FF
                
                self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0,
                    blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
            } else {
                // Parsing the hex string failed; return white
                self.init(white: 1.0, alpha: 1.0)
            }
        }
    }
    
    
    public func hexColor() -> String {
        let components = self.cgColor.components
        
        let red = Float((components?[0])!)
        let green = Float((components?[1])!)
        let blue = Float((components?[2])!)
        return String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
    }
    
    static func textFieldSeparatorColor() -> UIColor
    {
        return UIColor(red: 102.0/255, green: 102.0/255, blue: 102.0/255, alpha: 1) //HEX Value: #666666
    }
    
    static func navigationBarColor() -> UIColor
    {
        return UIColor(red: 36.0/255.0, green: 35.0/255.0, blue: 41.0/255.0, alpha: 1.0)  //HEX Value: #242329
    }

    
    class func darkerColorForColor(_ color: UIColor) -> UIColor {
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        if color.getRed(&r, green: &g, blue: &b, alpha: &a){
            return UIColor(red: max(r - 0.2, 0.0), green: max(g - 0.2, 0.0), blue: max(b - 0.2, 0.0), alpha: a)
        }
        return UIColor()
    }
    
    class func lighterColorForColor(_ color: UIColor) -> UIColor {
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        if color.getRed(&r, green: &g, blue: &b, alpha: &a){
            return UIColor(red: min(r + 0.2, 1.0), green: min(g + 0.2, 1.0), blue: min(b + 0.2, 1.0), alpha: a)
        }
        return UIColor()
    }

}

extension UIImage {
    var uncompressedPNGData: Data      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: Data { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: Data    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: Data  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: Data     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:Data   { return UIImageJPEGRepresentation(self, 0.0)!  }
    
    class func compressImage(_ image:UIImage) -> Data {
        // Reducing file size to a 10th
        
        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        let maxHeight : CGFloat = 1980.0
        let maxWidth : CGFloat = 1980.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        let maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = 1.0
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
                compressionQuality = 1;
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img!, compressionQuality);
        UIGraphicsEndImageContext();
        
        return imageData!;
    }
}

