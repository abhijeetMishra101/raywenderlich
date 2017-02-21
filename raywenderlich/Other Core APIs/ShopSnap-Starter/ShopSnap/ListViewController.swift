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

let AddItemSegueIdentifier  = "AddItemSegueIdentifier"

class ListViewController: UITableViewController, DetailViewControllerDelegate {
  
  // MARK: UserActivity Methods
  
  func startUserActivity() {
    let activity = NSUserActivity.init(activityType: ActivityTypeView)
    activity.title = "Viewing Shopping List"
    activity.userInfo = [ActivityItemsKey:items]
    userActivity = activity
    userActivity?.becomeCurrent()
  }
  
  override func updateUserActivityState(_ activity: NSUserActivity) {
    activity.addUserInfoEntries(from: [ActivityItemsKey : items])
    super.updateUserActivityState(activity)
  }
  
  func stopUserActivity()  {
    userActivity?.invalidate()
  }
  
  // MARK: Public
  
  /** IndexPath of a selected item if any or nil. */
  var selectedItemIndexPath: IndexPath?
  
  /** Returns the currently selected item or empty string. */
  func selectedItem() -> String {
    if let indexPath = selectedItemIndexPath {
      return items[indexPath.row]
    }
    return ""
  }
  
  // MARK: Private
  let TableViewCellIdentifier = "TableViewCellIdentifier"
  let EditItemSegueIdentifier = "EditItemSegueIdentifier"
  var items: Array <String> = []
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    title = "Shopping List"
    weak var weakSelf = self
    PersistentStore.defaultStore().fetchItems({ (items:[String]) in
      if let unwrapped = weakSelf {
        unwrapped.items = items
        unwrapped.tableView.reloadData()
        if items.isEmpty == false {
          unwrapped.startUserActivity()
        }
      }
    })
    super.viewDidLoad()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
    let identifier = segue.identifier
    let controller = segue.destination as! DetailViewController
    controller.delegate = self
    if identifier == EditItemSegueIdentifier {
      controller.item = selectedItem()
    }
    else if identifier == AddItemSegueIdentifier {
      if let indexPath = selectedItemIndexPath {
        tableView.deselectRow(at: indexPath, animated: true)
      }
      selectedItemIndexPath = nil
      
      if items.isEmpty {
        stopUserActivity()
      }
      else {
        userActivity?.needsSave = true
      }
    }
  }
  
  // MARK: Helper
  
  /** A helper method to add a new item to items array, if the new item doesn't already exist. */
  func addItemToItemsIfUnique(_ item: String) {
    if item.isEmpty == false && (items as NSArray).contains(item) == false {
      items.append(item)
    }
  }
  
  /** If in a compact size class, e.g. iPhone once Detail View Controller calls back on its delegate, all we have to do is pop Detail View Controller from navigation stack. But for a regualr size class, e.g. iPad, popToViewController is a noop but we still have to clear previous edit. Since we make similar calls from muliple places in the code, this helper method refactors those calls. */
  func endEditingInDetailViewController(_ controller: DetailViewController) {
    navigationController!.popToViewController(self, animated: true)
    controller.item = nil
    controller.stopEditing()
  }
  
  // MARK: IBActions
  
  @IBAction func unwindDetailViewController(_ unwindSegue: UIStoryboardSegue) {
    endEditingInDetailViewController(unwindSegue.source as! DetailViewController)
    if let indexPath = selectedItemIndexPath {
      tableView.deselectRow(at: indexPath, animated: true)
      startUserActivity()
    }
    selectedItemIndexPath = nil
  }
  
  // MARK: UITableViewDataSource
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifier)!
    cell.textLabel?.text = items[indexPath.row]
    return cell
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath {
    // We are going to display detail for an item. So ListViewController is not going to be active anymore. Stop broadcasting.
    selectedItemIndexPath = indexPath
    return indexPath
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .delete
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    // Update data source and UI.
    let index = indexPath.row
    let itemToRemove = items[index]
    items.remove(at: index)
    tableView.deleteRows(at: [indexPath], with: .left)
    
    // Update persistent store.
    PersistentStore.defaultStore().updateStoreWithItems(items)
    PersistentStore.defaultStore().commit()
    
    // If this was the selected index path, we need to do more clean up.
    if indexPath == selectedItemIndexPath {
      selectedItemIndexPath = nil
      if let viewControllers = splitViewController?.viewControllers {
        for controller: AnyObject in viewControllers {
          if controller.isKind(of: DetailViewController.self) {
            endEditingInDetailViewController(controller as! DetailViewController)
            break
          }
        }
      }
    }
  }
  
  // MARK: DetailViewControllerDelegate
  
  func detailViewController(controller: DetailViewController, didFinishWithUpdatedItem item: String) {
    // Did user edit an item, or added a new item?
    if selectedItemIndexPath != nil {
      
      // If item is empty string, treat it as deletion of the item.
      let index = selectedItemIndexPath!.row
      if item.isEmpty {
        items.remove(at: index)
      } else {
        items[index] = item
      }
      
    } else {
      
      // This is a new item. Add it to the list.
      addItemToItemsIfUnique(item)
    }
    
    if items.isEmpty == false {
      startUserActivity()
    }
    
    selectedItemIndexPath = nil
    tableView.reloadData()
    endEditingInDetailViewController(controller)
    
    PersistentStore.defaultStore().updateStoreWithItems(items)
    PersistentStore.defaultStore().commit()
  }
  
}
