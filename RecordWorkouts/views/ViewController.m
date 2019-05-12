#import "ViewController.h"
#import "../HealthKitManager.h"
#import "../WorkoutData.h"

#import "AlertBuilder.h"
#import "TypePickerView.h"
#import "DatePickerController.h"
#import "DurationPickerController.h"
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
    
    UIToolbar *toolbar = [self createToolbar];
    [distanceField setInputAccessoryView:toolbar];
    [distanceField addTarget:self action:@selector(checkCanRecord) forControlEvents:UIControlEventAllEditingEvents];
    [caloriesField setInputAccessoryView:toolbar];
    [caloriesField addTarget:self action:@selector(checkCanRecord) forControlEvents:UIControlEventEditingChanged];

    [self createTypePicker:toolbar];
    [self createDatePicker:toolbar];
    [self createDurationPicker:toolbar];
    [self createAdbanner];

    [self reloadWorkouts:HKMQueryResetDate];
    [self checkCanRecord];
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

- (UIToolbar*) createToolbar {
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(endEditing)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    return toolBar;
}

- (void) createTypePicker: (UIToolbar *) toolbar {
    TypePickerView *typePicker = [[TypePickerView alloc]
                                  init:typeField
                                  toolbar:toolbar
                                  callback:^(HKQuantityTypeIdentifier typeId) {
        if (typeId == HKQuantityTypeIdentifierActiveEnergyBurned) {
            self->distanceField.enabled = false;
            self->distanceField.text = @"";
        } else {
            self->distanceField.enabled = true;
            self->selectedActivity = typeId;
        }
    }];
    [typePicker setNewActivity:0];
}

- (void) createDatePicker: (UIToolbar *) toolbar {
    DatePickerController *dateController = [[DatePickerController alloc]
            init:dateField toolbar:toolbar callback:^(NSDate *date) {
                self->selectedDate = date;
             }];
    [dateController setNewDate:[NSDate date]];
}

- (void) createDurationPicker: (UIToolbar *) toolbar {
    DurationPickerController *picker = [[DurationPickerController alloc]
            init:durationField toolbar:toolbar callback:^(NSTimeInterval interval) {
                self->selectedDuration = interval;
            }];
    [picker setInitialDuration:3600];
}

// ================= actions methods ===========================
// =============================================================

- (void) endEditing {
    [self.view endEditing:YES];
}

- (void) reloadWorkouts:(HKMQuerySetting)querySetting {
    workoutData = [[NSArray alloc] init];
    [[HealthKitManager sharedInstance] readWorkouts:querySetting finishBlock:^(NSArray *results, NSDate *queryFromDate) {
        self->workoutData = results;
        self->queryFromDate = queryFromDate;
        [self->workoutTableView reloadData];
    }];
}

#pragma mark - Action Events
- (IBAction) onWriteWorkoutAction:(id)sender {
    [self endEditing];
    float distance = [distanceField.text floatValue];
    float calories = [caloriesField.text floatValue];

    NSDate *endDate = [selectedDate dateByAddingTimeInterval:selectedDuration];

    if(distance || calories) {
        [[HealthKitManager sharedInstance] writeWorkout:selectedActivity distance:distance calories:calories
          startDate:selectedDate endDate:endDate finishBlock:^(NSError *error) {
              if(error) {
                  [AlertBuilder showErrorAlertOn:self title:@"Error writing workout" error:error];
              } else {
                  [self reloadWorkouts:HKMQueryNone];
              }
          }];
    }
}

- (void) removeWorkout:(WorkoutData *)workout {
    [[HealthKitManager sharedInstance] deleteWorkout:workout
     finishBlock:^(NSError *error) {
         if(error) {
             [AlertBuilder showErrorAlertOn:self title:@"Error deleting workout" error:error];
         } else {
             [self reloadWorkouts:HKMQueryNone];
         }
     }];
}

- (void) checkCanRecord {
    recordButton.enabled = ![distanceField.text isEqualToString:@""] || ![caloriesField.text isEqualToString:@""];
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
        WorkoutData *workout = [workoutData objectAtIndex:indexPath.row];

        NSString *title = @"Delete workout?";
        NSString *message = [NSString stringWithFormat:@"%@\nDate:  %@\nDuration:  %@",
                             [WRFormat typeNameFor:workout.type],
                             [WRFormat formatDate:workout.date],
                             [WRFormat formatDuration:workout.duration]];
        AlertBuilder *alertBuilder = [[AlertBuilder alloc] init:title message:message];
        [alertBuilder addCancelAction];
        [alertBuilder addDefaultAction:@"Delete" handler:^(UIAlertAction * action) {
            [self removeWorkout:workout];
        }];
        [alertBuilder show:self];
    }
}

@end
