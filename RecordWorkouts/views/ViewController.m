#import "ViewController.h"
#import "../HealthKitManager.h"
#import "../WorkoutData.h"

#import "AlertBuilder.h"
#import "TypePickerView.h"
#import "DatePickerController.h"
#import "DurationPickerController.h"
#import "ToolbarBuilder.h"
#import "WorkoutTableCell.h"
#import "ShowMoreTableCell.h"

@implementation ViewController {
    NSArray *workoutData;
    NSDate *queryFromDate;
    HKQuantityTypeIdentifier selectedActivity;
    NSDate *selectedDate;
    NSTimeInterval selectedDuration;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self updateWithLocales];
    
    UIToolbar *toolbar = [[self newToolbarBuilder] createDefault];
    [distanceField setInputAccessoryView:toolbar];
    [distanceField addTarget:self action:@selector(checkRecordButtonState) forControlEvents:UIControlEventAllEditingEvents];
    [caloriesField setInputAccessoryView:toolbar];
    [caloriesField addTarget:self action:@selector(checkRecordButtonState) forControlEvents:UIControlEventEditingChanged];

    [self createTypePicker:toolbar];
    [self createDatePicker];
    [self createDurationPicker:toolbar];
    [self createAdbanner];

    [self reloadWorkouts:HKMQueryResetDate];
    [self checkRecordButtonState];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) updateWithLocales {
    if(![WRFormat isMetric]) {
        distanceLabel.text = @"Distance (mi)";
    }
}
// =============== create fields methods =======================
// =============================================================

- (void) createAdbanner {
    bannerView.adUnitID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AdUnitId"];
    bannerView.rootViewController = self;
    [bannerView loadRequest:[GADRequest request]];
}

- (ToolbarBuilder*) newToolbarBuilder {
    return [[ToolbarBuilder alloc] init:CGRectMake(0, 0, self.view.frame.size.width, 44)
         target:self doneAction:@selector(endEditing)];
}

- (void) createTypePicker: (UIToolbar *) toolbar {
    TypePickerView *typePicker = [[TypePickerView alloc]
          init:typeField toolbar:toolbar callback:^(HKQuantityTypeIdentifier typeId) {
            self->selectedActivity = typeId;
            if (typeId == HKQuantityTypeIdentifierActiveEnergyBurned) {
                self->distanceField.enabled = false;
                self->distanceField.text = @"";
                [self checkRecordButtonState];
            } else {
                self->distanceField.enabled = true;
            }
          }];
    [typePicker setNewActivity:0];
}

- (void) createDatePicker {
    ToolbarBuilder *toolbarBuilder = [self newToolbarBuilder];
    DatePickerController *dateController = [[DatePickerController alloc]
        init:dateField toolbarBuilder:toolbarBuilder callback:^(NSDate *date) {
                self->selectedDate = date;
             }];
    [dateController setDateNow];
}

- (void) createDurationPicker: (UIToolbar *) toolbar {
    DurationPickerController *picker = [[DurationPickerController alloc]
            init:durationField toolbar:toolbar callback:^(NSTimeInterval interval) {
                self->selectedDuration = interval;
            }];
    [picker setInitialDuration:3600];
}

// ============== workout action methods =======================
// =============================================================

- (void) reloadWorkouts:(HKMQuerySetting)querySetting {
    workoutData = [[NSArray alloc] init];
    [[HealthKitManager sharedInstance] readWorkouts:querySetting finishBlock:^(NSArray *results, NSDate *queryFromDate) {
        self->workoutData = results;
        self->queryFromDate = queryFromDate;
        [self->workoutTableView reloadData];
    }];
}

- (void) storeWorkout:(HKQuantityTypeIdentifier) activityId
             distance:(float)distance calories:(float)calories startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    [[HealthKitManager sharedInstance]
     writeWorkout:activityId distance:distance calories:calories
     startDate:selectedDate endDate:endDate finishBlock:^(NSError *error) {
         if(error) {
             [AlertBuilder showErrorAlertOn:self title:@"Error writing workout" error:error];
         } else {
             [self reloadWorkouts:HKMQueryNone];
         }
     }];
}

- (void) deleteWorkout:(WorkoutData *)workout {
    [[HealthKitManager sharedInstance]
     deleteWorkout:workout
     finishBlock:^(NSError *error) {
         if(error) {
             [AlertBuilder showErrorAlertOn:self title:@"Error deleting workout" error:error];
         } else {
             [self reloadWorkouts:HKMQueryNone];
         }
     }];
}

// ==================== view methods ===========================
// =============================================================

- (void) endEditing {
    [self.view endEditing:YES];
}

- (void) checkRecordButtonState {
    if([distanceField.text isEqualToString:@""] && [caloriesField.text isEqualToString:@""]) {
        recordButton.enabled = false;
        recordButton.alpha = 0.5;
    } else {
        recordButton.enabled = true;
        recordButton.alpha = 1;
    }
}

#pragma mark - Action Events
- (IBAction) onWriteWorkoutAction:(id)sender {
    [self endEditing];
    float distance = [distanceField.text floatValue];
    float calories = [caloriesField.text floatValue];
    NSDate *endDate = [selectedDate dateByAddingTimeInterval:selectedDuration];

    void (^storeHandler)(UIAlertAction * action) = ^(UIAlertAction * action) {
        [self storeWorkout:self->selectedActivity distance:distance calories:calories
                 startDate:self->selectedDate endDate:endDate];
    };
    
    if(distance || calories) {
        if( distance > 0 || selectedActivity == [WRFormat getEnergyTypeId] ) {
            storeHandler(nil);
        } else {
            AlertBuilder *alertBuilder = [[AlertBuilder alloc] init:@"" message:@"No distance set.\nRecord as 'Calories only' ?"];
            [alertBuilder addCancelAction:nil];
            [alertBuilder addDefaultAction:@"Record" handler:storeHandler];
            [alertBuilder show:self];
        }
        
    }
}

// ================= table-view methods ========================
// =============================================================

- (BOOL) isLastRow:(NSIndexPath *)indexPath {
    return indexPath.row == [workoutData count];
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row != [workoutData count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [workoutData count] + 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if([self isLastRow:indexPath]) {
        cell = [self createTableCell:@"LoadMoreTableCell"];
        [(ShowMoreTableCell *)cell setQueryDate:queryFromDate onShowMore: ^(void) {
            [self reloadWorkouts:HKMQueryIncreasDate];
        }];
    } else {
        cell = [self createTableCell:@"WorkoutTableCell"];
        WorkoutData *workout = [workoutData objectAtIndex:indexPath.row];
        [(WorkoutTableCell *)cell setWorkout:workout];
    }
    return cell;
}

- (UITableViewCell *) createTableCell:(NSString *)cellId {
    UITableViewCell *cell = [workoutTableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WorkoutTableCell *workoutCell = (WorkoutTableCell *)[tableView cellForRowAtIndexPath:indexPath];
        [workoutCell markForDeletion:true];
        WorkoutData *workout = [workoutData objectAtIndex:indexPath.row];

        NSString *title = @"Delete workout?";
        NSString *message = [NSString stringWithFormat:@"%@\nDate:  %@\nDuration:  %@",
                             [WRFormat typeNameFor:workout.type],
                             [WRFormat formatDate:workout.date],
                             [WRFormat formatDuration:workout.duration]];
        AlertBuilder *alertBuilder = [[AlertBuilder alloc] init:title message:message];
        [alertBuilder addCancelAction:^(UIAlertAction * action) {
            [workoutCell markForDeletion:false];
        }];
        [alertBuilder addDefaultAction:@"Delete" handler:^(UIAlertAction * action) {
            [self deleteWorkout:workout];
        }];
        [alertBuilder show:self];
    }
}

@end
