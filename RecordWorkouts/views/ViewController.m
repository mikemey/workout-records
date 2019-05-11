#import "ViewController.h"
#import "HealthKitManager.h"
#import "WorkoutData.h"
#import "WorkoutTableCell.h"
#import "TypePickerView.h"
#import "WorkoutAlertBuilder.h"

@implementation ViewController
    UIDatePicker *datePicker;
    UIDatePicker *durationPicker;

    NSArray *workoutData;
    HKQuantityTypeIdentifier selectedActivity;
    NSDate *selectedDate;
    NSTimeInterval selectedDuration;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self createTypePicker];
    [self createDatePicker];
    [self createDurationPicker];
    [distanceField setInputAccessoryView:[self createDoneToolbar]];
    [caloriesField setInputAccessoryView:[self createDoneToolbar]];
    
    [self readCycling];
    workoutTableView.allowsMultipleSelectionDuringEditing = NO;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// =============== create pickers for fields ===================
// =============================================================

- (void) createTypePicker {
    TypePickerView *typePicker = [[TypePickerView alloc] init:typeField toolbar:[self createDoneToolbar]];
    [typePicker onPicked:^(HKQuantityTypeIdentifier typeId) {
        if(typeId == HKQuantityTypeIdentifierActiveEnergyBurned) {
            self->distanceField.enabled = false;
            self->distanceField.text = @"";
        } else {
            self->distanceField.enabled = true;
            selectedActivity = typeId;
        }
    }];
    [typePicker setNewActivity:0];
}

- (void) createDatePicker {
    datePicker = [[UIDatePicker alloc] init];
    [datePicker addTarget:self action:@selector(updateDateField:)
         forControlEvents:UIControlEventValueChanged];
    
    [dateField setInputView:datePicker];
    [dateField setInputAccessoryView:[self createDoneToolbar]];
    dateField.tintColor = [UIColor clearColor];
    
    NSDate *now = [NSDate date];
    [self setSelectedDate:now];
}

- (void) createDurationPicker {
    durationPicker = [[UIDatePicker alloc] init];
    durationPicker.datePickerMode = UIDatePickerModeCountDownTimer;
    [durationPicker addTarget:self action:@selector(updateDurationField:)
             forControlEvents:UIControlEventValueChanged];
    
    [durationField setInputView:durationPicker];
    [durationField setInputAccessoryView:[self createDoneToolbar]];
    durationField.tintColor = [UIColor clearColor];
    
    NSTimeInterval hour = 3600;
    [self setDuration:hour];
    durationPicker.countDownDuration = hour;
}

- (UIToolbar*) createDoneToolbar {
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(endEditing)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    return toolBar;
}

-(void) setSelectedDate:(NSDate *)date {
    selectedDate = date;
    dateField.text = [WorkoutTableCell formatDate:date];
}

-(void) setDuration:(NSTimeInterval)dur {
    selectedDuration = dur;
    durationField.text = [WorkoutTableCell formatDuration:dur];
}

-(void) updateDateField:(UIDatePicker *)sender {
    [self setSelectedDate:sender.date];
}

-(void) updateDurationField:(UIDatePicker *)sender {
    [self setDuration:sender.countDownDuration];
}

-(void) endEditing {
    [self.view endEditing:YES];
}

- (void) showErrorAlert: (NSString *)title error:(NSError *)error {
    NSString *message = error.code == HKErrorAuthorizationDenied
        ? @"Please enable access in\nSettings -> Privacy -> Health"
        : error.userInfo[NSLocalizedDescriptionKey];
    WorkoutAlertBuilder *alertBuilder = [[WorkoutAlertBuilder alloc] init:self title:title message:message];
    [alertBuilder addOKAction];
    [alertBuilder show];
}

// ================= actions methods ===========================
// =============================================================

-(void) readCycling {
    workoutData = [[NSArray alloc] init];
    [[HealthKitManager sharedInstance] readWorkouts:^(NSArray *results) {
        workoutData = results;
        [self->workoutTableView reloadData];
    }];
}

-(void) removeWorkout:(WorkoutData *)workout {
    [[HealthKitManager sharedInstance] deleteWorkout:workout
     finishBlock:^(NSError *error) {
         if(error) {
             [self showErrorAlert:@"Error deleting workout" error:error];
         } else {
             [self readCycling];
         }
     }];
}

#pragma mark - Action Events
- (IBAction) onWriteWorkoutAction:(id)sender {
    [self endEditing];
    float distance = [distanceField.text floatValue] * 1000;
    float calories = [caloriesField.text floatValue];
    
    NSDate *endDate = [selectedDate dateByAddingTimeInterval:selectedDuration];
    
    if(distance || calories) {
        [[HealthKitManager sharedInstance] writeWorkout:selectedActivity distance:distance calories:calories
          startDate:selectedDate endDate:endDate finishBlock:^(NSError *error) {
              if(error) {
                  [self showErrorAlert:@"Error writing workout" error:error];
              } else {
                  [self readCycling];
              }
          }];
    }
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

        NSString *title = @"Delete workout entry?";
        NSString *message = [NSString stringWithFormat:@"%@\nDate:  %@\nDuration:  %@",
                             @"NOT YET IMPLEMENTED!",
//                             [TypePickerView textForType:workout.type],
                             [WorkoutTableCell formatDate:workout.date],
                             [WorkoutTableCell formatDuration:workout.duration]];
        WorkoutAlertBuilder *alertBuilder = [[WorkoutAlertBuilder alloc] init:self title:title message:message];
        [alertBuilder addCancelAction];
        [alertBuilder addDefaultAction:@"Delete" handler:^(UIAlertAction * action) {
            [self removeWorkout:workout];
        }];
        [alertBuilder show];
    }
}

@end
