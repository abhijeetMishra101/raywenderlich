//
//  PhotoCommentViewController.swift
//  PhotoScroll
//
//  Created by Abhijeet Mishra on 16/12/16.
//  Copyright © 2016 raywenderlich. All rights reserved.
//

import UIKit

class PhotoCommentViewController: UIViewController {
  
  @IBOutlet weak var imageView:UIImageView!
  @IBOutlet weak var scrollview:UIScrollView!
  @IBOutlet weak var nameTextField:UITextField!
  
  public var photoName:String!
  
  public var photoIndex:Int!
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    if let photoName = photoName {
      self.imageView.image = UIImage(named: photoName)
    }
    NotificationCenter.default.addObserver(self, selector: #selector(PhotoCommentViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(PhotoCommentViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  public func keyboardWillShow(_ notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
      let window = self.view.window?.frame {
      // We're not just minusing the kb height from the view height because
      // the view could already have been resized for the keyboard before
      self.view.frame = CGRect(x: self.view.frame.origin.x,
                               y: self.view.frame.origin.y,
                               width: self.view.frame.width,
                               height: window.origin.y + window.height - keyboardSize.height)
    } else {
      debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
    }
  }
  public func keyboardWillHide(_ notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      let viewHeight = self.view.frame.height
      self.view.frame = CGRect(x: self.view.frame.origin.x,
                               y: self.view.frame.origin.y,
                               width: self.view.frame.width,
                               height: viewHeight + keyboardSize.height)
    } else {
      debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
    }
  }
//  func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
//    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
//      let window = self.view.window?.frame {
//      // We're not just minusing the kb height from the view height because
//      // the view could already have been resized for the keyboard before
//      self.view.frame = CGRect(x: self.view.frame.origin.x,
//                               y: self.view.frame.origin.y,
//                               width: self.view.frame.width,
//                               height: window.origin.y + window.height - keyboardSize.height)
//    } else {
//      debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
//    }
//    
//  }
  @IBAction func openZoomingController(_ sender: UITapGestureRecognizer) {
    performSegue(withIdentifier: "zooming", sender: nil)
  }
  override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let id = segue.identifier,
      let zoomedPhotoViewController = segue.destination as? ZoomedPhotoViewController {
      if id == "zooming" {
        zoomedPhotoViewController.photoName = photoName
      }
    }
  }
  
  @IBAction func hideKeyboard(_ sender: UITapGestureRecognizer) {
    nameTextField.endEditing(true)
  }
    deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
}
