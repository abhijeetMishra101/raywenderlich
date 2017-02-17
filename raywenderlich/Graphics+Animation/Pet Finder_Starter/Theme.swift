//
//  Theme.swift
//  Pet Finder
//
//  Created by Abhijeet Mishra on 17/02/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit

enum Theme:Int {
    case Default, Dark, Graphical

    var mainColor: UIColor {
        switch self {
        case .Default:
            return UIColor.init(colorLiteralRed: 87.0/255.0, green: 188.0/255.0, blue: 95.0/255.0, alpha: 1.0)
            
        case .Dark:
            return UIColor.init(colorLiteralRed: 242.0/255.0, green: 101.0/255.0, blue: 34.0/255.0, alpha: 1.0)
     
        case .Graphical:
            return UIColor.init(colorLiteralRed: 10.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 1.0)
        }
    }
    var secondaryColor: UIColor {
        switch self {
        case .Default:
            return UIColor.init(colorLiteralRed: 242.0/255.0, green: 101.0/255.0, blue: 34.0/255.0, alpha: 1.0)
            
        case .Dark:
            return UIColor.init(colorLiteralRed: 34.0/255.0, green: 128.0/255.0, blue: 66.0/255.0, alpha: 1.0)
            
        case .Graphical:
            return UIColor.init(colorLiteralRed: 140.0/255.0, green: 50.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        }
    }
    
    var barStyle: UIBarStyle {
        switch self {
        case .Default, .Graphical:
            return .default
        
        case .Dark:
            return .black
            
        }
    }
    
    var navigationBackgroundImage: UIImage? {
        return self == .Graphical ? UIImage.init(named: "navBackground") : nil
    }
    
    var tabBarBackgroundImage:UIImage? {
        return self == .Graphical ? UIImage.init(named: "tabBarBackground") : nil
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .Default:
            return UIColor.init(colorLiteralRed: 242.0/255.0, green: 101.0/255.0, blue: 34.0/255.0, alpha: 1.0)
            
        case .Dark:
            return UIColor.init(colorLiteralRed: 34.0/255.0, green: 128.0/255.0, blue: 66.0/255.0, alpha: 1.0)
            
        case .Graphical:
            return UIColor.init(colorLiteralRed: 140.0/255.0, green: 50.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        }
    }
}

let SelectedThemeKey = "SelectedTheme"

struct ThemeManager {
    static func currentTheme() -> Theme {
        if let storedTheme = ((UserDefaults.standard.value(forKey: SelectedThemeKey)) as AnyObject).integerValue {
            return Theme.init(rawValue: storedTheme)!
        }
        else {
            return .Default
        }
    }
    static func applyTheme(theme: Theme) {
        UserDefaults.standard.set(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()
        
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        
        //navigation bar
        
        UINavigationBar.appearance().barStyle = theme.barStyle
        UINavigationBar.appearance().setBackgroundImage(theme.navigationBackgroundImage, for: .default)
        
        UINavigationBar.appearance().backIndicatorImage = UIImage.init(named: "backArrow")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage.init(named: "backArrow")
        
        //tab bar
        
        UITabBar.appearance().barStyle = theme.barStyle
        UITabBar.appearance().backgroundImage = theme.tabBarBackgroundImage
        
        let tabIndicator = UIImage.init(named: "tabBarSelectionIndicator")?.withRenderingMode(.alwaysTemplate)
        let tabResizableIndicator = tabIndicator?.resizableImage(withCapInsets: UIEdgeInsets(top:0, left:2, bottom:0, right:2))
        UITabBar.appearance().selectionIndicatorImage = tabResizableIndicator
        
        //segmented control
        
        let controlBackground = UIImage.init(named: "controlBackground")?.withRenderingMode(.alwaysTemplate).resizableImage(withCapInsets: UIEdgeInsets(top:3, left:3, bottom:3, right:3))
        let controlSelectedBackground = UIImage.init(named: "controlSelectedBackground")?.withRenderingMode(.alwaysTemplate).resizableImage(withCapInsets: UIEdgeInsets(top:3, left:3, bottom:3, right:3))
        
        UISegmentedControl.appearance().setBackgroundImage(controlBackground, for: .normal, barMetrics: .default)
        UISegmentedControl.appearance().setBackgroundImage(controlSelectedBackground, for: .selected, barMetrics: .default)
        
        //stepper
        UIStepper.appearance().setBackgroundImage(controlBackground, for:.disabled)
        UIStepper.appearance().setBackgroundImage(controlBackground, for: .highlighted)
        UIStepper.appearance().setBackgroundImage(controlBackground, for: .normal)
        
        UIStepper.appearance().setDecrementImage((UIImage.init(named: "fewerPaws")), for:.normal)
        UIStepper.appearance().setIncrementImage((UIImage.init(named: "morePaws")), for:.normal)
        
        //slider
        UISlider.appearance().setThumbImage((UIImage.init(named: "sliderThumb")), for:.normal)
        UISlider.appearance().setMaximumTrackImage(UIImage.init(named: "maximumTrack")?.withRenderingMode(.alwaysTemplate).resizableImage(withCapInsets: UIEdgeInsets(top:0, left:0, bottom:0, right:6)), for:.normal)
        UISlider.appearance().setMinimumTrackImage(UIImage.init(named: "minimumTrack")?.withRenderingMode(.alwaysTemplate).resizableImage(withCapInsets: UIEdgeInsets(top:0, left:0, bottom:0, right:6)), for:.normal)
        
        //switch
        UISwitch.appearance().onTintColor = theme.mainColor.withAlphaComponent(0.3)
        UISwitch.appearance().thumbTintColor = theme.mainColor
    }
}
