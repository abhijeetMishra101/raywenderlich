/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
  
  // MARK: View Life Cycle
  
  override func viewDidLoad()  {
    delegate = self
    preferredDisplayMode = .allVisible
    super.viewDidLoad()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    
    // Regular layout: it is a master-detail where master is on the left
    // and detail is on the right.
    if traitCollection.horizontalSizeClass == .regular {
      
      let navController = viewControllers.first as! UINavigationController
      let listViewController = navController.viewControllers.first as! ListViewController
      
      if let detailViewController = viewControllers.last as? DetailViewController {
        detailViewController.delegate = listViewController
      }
    }
    
    super.traitCollectionDidChange(previousTraitCollection)
  }
  
  // MARK: UISplitViewControllerDelegate
  
  func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController!, onto primaryViewController: UIViewController!) -> Bool {
    
    // If the secondary view controller is Detail View Controller...
    if secondaryViewController.isKind(of: DetailViewController.self) {
      
      // If Detail View Controller is editing something, default behavior is OK, so return NO.
      let detailViewController = secondaryViewController as! DetailViewController
      if detailViewController.item?.isEmpty == false {
        detailViewController.startEditing()
        return false
      }
    }
    
    // Otherwise we handle the collapse.
    if primaryViewController.isKind(of: UINavigationController.self) {
      
      // If there is modally presented view controller, pop.
      if primaryViewController.presentedViewController != nil {
        (primaryViewController as! UINavigationController).popToRootViewController(animated: true)
      }
    }
    
    // Return YES because we handled the collapse.
    return true;
  }
  
  // MARK: Helper
  
  func viewControllerForViewing () -> UIViewController {
    let navController = viewControllers.first as! UINavigationController
    let listViewController = navController.viewControllers.first as! ListViewController
    
    // If in Compact layout, cancel everything, go to the root of the navigation stack.
    if traitCollection.horizontalSizeClass == .compact {
      navController.popToViewController(listViewController, animated: true)
    }
    return listViewController
  }
  
  func viewControllerForEditing () -> UIViewController {
    if traitCollection.horizontalSizeClass == .regular {
      
      // If it is the Regular layout, find DetailViewController.
      let detailViewController = viewControllers.last as! DetailViewController
      return detailViewController
      
    } else {
      
      let navController = viewControllers.first as! UINavigationController
      
      // Otherwise, is DetailViewController already active?
      let lastViewController: AnyObject? = navController.viewControllers.last
      if lastViewController is DetailViewController {
        
        // Pass it on.
        let detailViewController = lastViewController as! DetailViewController
        return detailViewController
        
      } else {
        
        // Make DetailViewController active via ListViewController.
        let listViewController = navController.viewControllers.first as! ListViewController
        listViewController.performSegue(withIdentifier: AddItemSegueIdentifier, sender: nil)
        let detailViewController = navController.viewControllers.last as! DetailViewController
        return detailViewController
      }
    }
  }
  
}
