#import "ViewController.h"
#import "../HealthKitManager.h"
#import "../WorkoutData.h"

#import "AlertBuilder.h"
#import "TypePickerView.h"
#import "WorkoutTableCell.h"
#import "DatePickerController.h"
#import "DurationPickerController.h"

@implementation ViewController {
    NSArray *workoutData;
    HKQuantityTypeIdentifier selectedActivity;
    NSDate *selectedDate;
    NSTimeInterval selectedDuration;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self updateWithLocales];
    
    UIToolbar *toolbar = [self createToolbar];
    [distanceField setInputAccessoryView:toolbar];
    [caloriesField setInputAccessoryView:toolbar];
    
    [self createTypePicker:toolbar];
    [self createDatePicker:toolbar];
    [self createDurationPicker:toolbar];
    [self createAdbanner];

    [self reloadWorkouts];
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

-(void) endEditing {
    [self.view endEditing:YES];
}

-(void) reloadWorkouts {
    workoutData = [[NSArray alloc] init];
    [[HealthKitManager sharedInstance] readWorkouts:^(NSArray *results) {
        self->workoutData = results;
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
                  [self reloadWorkouts];
              }
          }];
    }
}

-(void) removeWorkout:(WorkoutData *)workout {
    [[HealthKitManager sharedInstance] deleteWorkout:workout
     finishBlock:^(NSError *error) {
         if(error) {
             [AlertBuilder showErrorAlertOn:self title:@"Error deleting workout" error:error];
         } else {
             [self reloadWorkouts];
         }
     }];
}

// ================= table-view methods ========================
// =============================================================

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [workoutData count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WorkoutData *workout = [workoutData objectAtIndex:indexPath.row];
    return [self createWorkoutEntryFrom:workout];
}

-(UITableViewCell *) createWorkoutEntryFrom:(WorkoutData *)workout {
    static NSString *cellId = @"WorkoutTableCell";
    WorkoutTableCell *cell = (WorkoutTableCell *)[workoutTableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WorkoutTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setValues:workout.type date:workout.date duration:workout.duration distance:workout.distance calories:workout.energy];
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
