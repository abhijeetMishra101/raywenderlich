//
//  ManagePageViewController.swift
//  PhotoScroll
//
//  Created by Abhijeet Mishra on 16/12/16.
//  Copyright © 2016 raywenderlich. All rights reserved.
//

import UIKit

class ManagePageViewController: UIPageViewController {

  var photos = ["photo1", "photo2", "photo3", "photo4", "photo5"];
  var currentIndex: Int!
  
  override func viewDidLoad() {
     super.viewDidLoad()
    
    dataSource = self
    
    if let viewController = viewPhotoCommentController(index: currentIndex ?? 0) {
      let viewControllers = [viewController]
      setViewControllers(viewControllers, direction:.forward, animated: true, completion:nil)
    }
  }
  func viewPhotoCommentController(index: Int) -> PhotoCommentViewController? {
    if let page = storyboard?.instantiateViewController(withIdentifier: "PhotoCommentViewController") as? PhotoCommentViewController
      {
      page.photoName = photos[index]
      page.photoIndex = index
      return page
    }
    return nil
  }
}

extension ManagePageViewController: UIPageViewControllerDataSource {
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let viewController = viewController as? PhotoCommentViewController {
      var index = viewController.photoIndex!
      guard index != 0 else {
        return nil
      }
      index = index - 1
      return viewPhotoCommentController(index: index)
    }
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if let viewController = viewController as? PhotoCommentViewController {
      var index = viewController.photoIndex!
      index = index + 1
      guard index != photos.count else {
        return nil
      }
      return viewPhotoCommentController(index: index)
    }
    return nil
  }
  
  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return photos.count
  }
  
  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    return currentIndex ?? 0
  }
}
