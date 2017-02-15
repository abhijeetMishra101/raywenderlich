//
//  RWTableViewController.m
//  UDo
//
//  Created by Soheil Azarpour on 12/21/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "RWTableViewController.h"
#import "UIAlertView+RWBlock.h"
#import "UIButton+RWBlock.h"

@import EventKit;

@interface RWTableViewController ()

/** @brief An array of NSString objects, data source of the table view. */
@property (strong, nonatomic) NSMutableArray *todoItems;

@property (nonatomic) EKEventStore* eventStore;

@property (nonatomic) BOOL isAccessToEventStoreGranted;

@property (nonatomic) EKCalendar* calendar;

@property (nonatomic) NSArray* reminders;

@end

@implementation RWTableViewController

#pragma mark - Custom accessors

- (EKEventStore*) eventStore {
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (EKCalendar*) calendar {
    if (!_calendar) {
        NSArray* calendars = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
        
        NSString* calendarTitle = @"UDo!";
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title matches %@",calendarTitle];
        NSArray* filtered = [calendars filteredArrayUsingPredicate:predicate];
        if (filtered.count) {
            self.calendar = filtered.firstObject;
        }
        else {
            _calendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventStore];
            _calendar.title = calendarTitle;
            _calendar.source = self.eventStore.defaultCalendarForNewEvents.source;
            
            NSError* calendarSaveError;
            if (![self.eventStore saveCalendar:_calendar commit:YES error:&calendarSaveError]) {
                return nil;
            }
        }
    }
    return _calendar;
}

- (void) addReminderItemForTODOItem:(NSString*) todoItem {
    if (!self.isAccessToEventStoreGranted) {
        return;
    }
    
    EKReminder* reminder = [EKReminder reminderWithEventStore:self.eventStore];
    reminder.title = todoItem;
    reminder.calendar = self.calendar;
    reminder.dueDateComponents = [self dateComponentsForDefaultDueDate];
    
    NSError* reminderSaveError;
    
    if (![self.eventStore saveReminder:reminder commit:YES error:&reminderSaveError]) {
        [[[UIAlertView alloc] initWithTitle:@"Reminders" message:@"Reminder save operation failed." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (void) fetchReminders {
    if (self.isAccessToEventStoreGranted) {
        
       EKCalendar* calendar = self.calendar;
        
        NSPredicate* predicate = [self.eventStore predicateForRemindersInCalendars:@[self.calendar]];
        [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray<EKReminder *> * _Nullable reminders) {
            self.reminders = reminders;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}

- (void) deleteReminderForToDoItem:(NSString*) item {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title matches %@",item];
    NSArray* filteredArray = [self.reminders filteredArrayUsingPredicate:predicate];
    if (filteredArray.count) {
      [filteredArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          NSError* deleteReminderError;
          [self.eventStore removeReminder:obj commit:YES error:&deleteReminderError];
          [self.eventStore commit:&deleteReminderError];
      }];
    }
}

- (void) updateAuthorizationStatusToAccessEventStore {
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (authorizationStatus) {
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted: {
            self.isAccessToEventStoreGranted = NO;
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"This app doesn't have access to reminders." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
            [self.tableView reloadData];
        }
            break;
            
            case EKAuthorizationStatusAuthorized:
            self.isAccessToEventStoreGranted = YES;
            [self.tableView reloadData];
            
            case EKAuthorizationStatusNotDetermined:
        {
            __weak RWTableViewController* weakSelf = self;
            [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.isAccessToEventStoreGranted = granted;
                    [weakSelf.tableView reloadData];
                });
            }];
        }
        default:
            break;
    }
}

- (NSMutableArray *)todoItems {
  if (!_todoItems) {
    _todoItems = [@[@"Get Milk!", @"Go to gym", @"Breakfast with Rita!", @"Call Bob", @"Pick up newspaper", @"Send an email to Joe", @"Read this tutorial!", @"Pick up flowers"] mutableCopy];
  }
  return _todoItems;
}

- (BOOL) itemHasReminder:(NSString*) itemTitle {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title matches %@",itemTitle];
    NSArray* reminderArray = [self.reminders filteredArrayUsingPredicate:predicate];
    return self.isAccessToEventStoreGranted && reminderArray.count > 0;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
  self.title = @"To Do!";
  
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
  [self.tableView addGestureRecognizer:longPress];
  
  [self updateAuthorizationStatusToAccessEventStore];

  [self fetchReminders];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchReminders) name:EKEventStoreChangedNotification object:nil];
    
  [super viewDidLoad];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.todoItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *kIdentifier = @"Cell Identifier";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier forIndexPath:indexPath];
  
  // Update cell content from data source.
  NSString *object = self.todoItems[indexPath.row];
  cell.backgroundColor = [UIColor whiteColor];
  cell.textLabel.text = object;
  
    if (![self itemHasReminder:object]) {
        // Add a button as accessory view that says 'Add Reminder'.
        UIButton *addReminderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addReminderButton.frame = CGRectMake(0.0, 0.0, 100.0, 30.0);
        [addReminderButton setTitle:@"Add Reminder" forState:UIControlStateNormal];
        
        [addReminderButton addActionblock:^(UIButton *sender) {
            // Add the reminder to the store
            [self addReminderItemForTODOItem:object];
        } forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = addReminderButton;
    }
    else {
        cell.accessoryView = nil;
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title matches %@",self.todoItems[indexPath.row]];
        EKReminder* reminder = [self.reminders filteredArrayUsingPredicate:predicate].firstObject;
        
        cell.imageView.image = [UIImage imageNamed:reminder.isCompleted?@"checkmarkOn":@"checkmarkOff"];
        
        if (reminder.dueDateComponents) {
            NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate* dueDate = [calendar dateFromComponents:reminder.dueDateComponents];
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:dueDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        }
    }
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title matches %@",self.todoItems[indexPath.row]];
    EKReminder* reminder = [self.reminders filteredArrayUsingPredicate:predicate].firstObject;
    
    reminder.completed = !reminder.isCompleted;
    
    NSError* saveError;
    
    [self.eventStore saveReminder:reminder commit:YES error:&saveError];
    
    cell.imageView.image = [UIImage imageNamed:reminder.isCompleted?@"checkmarkOn":@"checkmarkOff"];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  
  NSString *todoItem = self.todoItems[indexPath.row];
  
  // Remove to-do item.
  [self.todoItems removeObject:todoItem];
  [self deleteReminderForToDoItem:todoItem];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - IBActions

- (IBAction)addButtonPressed:(id)sender {
  
  // Display an alert view with a text input.
  UIAlertView *inputAlertView = [[UIAlertView alloc] initWithTitle:@"Add a new to-do item:" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Add", nil];
  
  inputAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
  
  __weak RWTableViewController *weakSelf = self;
  
  // Add a completion block (using our category to UIAlertView).
  [inputAlertView setCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
    
    // If user pressed 'Add'...
    if (buttonIndex == 1) {
      
      UITextField *textField = [alertView textFieldAtIndex:0];
      NSString *string = [textField.text capitalizedString];
      [weakSelf.todoItems addObject:string];
      
      NSUInteger row = [weakSelf.todoItems count] - 1;
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
      [weakSelf.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
  }];
  
  [inputAlertView show];
}

- (IBAction)longPressGestureRecognized:(id)sender {
  
  UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
  UIGestureRecognizerState state = longPress.state;
  
  CGPoint location = [longPress locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
  
  static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
  static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
  
  switch (state) {
    case UIGestureRecognizerStateBegan: {
      if (indexPath) {
        sourceIndexPath = indexPath;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        // Take a snapshot of the selected row using helper method.
        snapshot = [self customSnapshotFromView:cell];
        
        // Add the snapshot as subview, centered at cell's center...
        __block CGPoint center = cell.center;
        snapshot.center = center;
        snapshot.alpha = 0.0;
        [self.tableView addSubview:snapshot];
        [UIView animateWithDuration:0.25 animations:^{
          
          // Offset for gesture location.
          center.y = location.y;
          snapshot.center = center;
          snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
          snapshot.alpha = 0.98;
          
          // Black out.
          cell.backgroundColor = [UIColor blackColor];
        } completion:nil];
      }
      break;
    }
      
    case UIGestureRecognizerStateChanged: {
      CGPoint center = snapshot.center;
      center.y = location.y;
      snapshot.center = center;
      
      // Is destination valid and is it different from source?
      if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
        
        // ... update data source.
        [self.todoItems exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
        
        // ... move the rows.
        [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
        
        // ... and update source so it is in sync with UI changes.
        sourceIndexPath = indexPath;
      }
      break;
    }
      
    default: {
      // Clean up.
      UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
      [UIView animateWithDuration:0.25 animations:^{
        
        snapshot.center = cell.center;
        snapshot.transform = CGAffineTransformIdentity;
        snapshot.alpha = 0.0;
        
        // Undo the black-out effect we did.
        cell.backgroundColor = [UIColor whiteColor];
        
      } completion:^(BOOL finished) {
        
        [snapshot removeFromSuperview];
        snapshot = nil;
        
      }];
      sourceIndexPath = nil;
      break;
    }
  }
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshotFromView:(UIView *)inputView {
  
  UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
  snapshot.layer.masksToBounds = NO;
  snapshot.layer.cornerRadius = 0.0;
  snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
  snapshot.layer.shadowRadius = 5.0;
  snapshot.layer.shadowOpacity = 0.4;
  
  return snapshot;
}

- (NSDateComponents *)dateComponentsForDefaultDueDate {
	NSDateComponents *oneDayComponents = [[NSDateComponents alloc] init];
	oneDayComponents.day = 1;
	
	NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *tomorrow = [gregorianCalendar dateByAddingComponents:oneDayComponents toDate:[NSDate date] options:0];
	
	NSUInteger unitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
	NSDateComponents *tomorrowAt4PM = [gregorianCalendar components:unitFlags fromDate:tomorrow];
	tomorrowAt4PM.hour = 16;
	tomorrowAt4PM.minute = 0;
	tomorrowAt4PM.second = 0;
	
	return tomorrowAt4PM;
}

@end
