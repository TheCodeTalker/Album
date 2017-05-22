

import Foundation

struct AppColors {
    static let AppBGColor = UIColor(hexString: "ffffff")
}
struct URLConstants {
    
    static let BaseURL: String                      = "http://192.168.1.23:8000/"
    static let imgDomain : String                   = "http://192.168.1.23/album/"
    
}


var _userLogin = ""
var _userPassword = ""

class AlertView: NSObject {
    
    static func showAlert(_ targetVC: UIViewController, title: String, message: AnyObject) {
        let alertController = UIAlertController(title: title, message: message as? String, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        targetVC.present(alertController, animated: true, completion: nil)
    }
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}
