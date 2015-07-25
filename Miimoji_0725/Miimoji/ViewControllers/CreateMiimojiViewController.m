//
//  CreateMiimojiViewController.m
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "CreateMiimojiViewController.h"
#import "MiimojiViewController.h"

@interface CreateMiimojiViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate> {
    
    UITapGestureRecognizer *tap;
    UITextField* activeField;
}

@property (weak, nonatomic) IBOutlet UITextField *txtGlossary;
@property (weak, nonatomic) IBOutlet UITextField *lblSelectedMenuItem;
@property (weak, nonatomic) IBOutlet UIButton *btnMenuArrow;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UITableView *tbvMenu;

@end

@implementation CreateMiimojiViewController
NSArray* glossaryArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    glossaryArray = [NSArray arrayWithObjects:@"Happy", @"Sad", @"Angry", @"Surprised", @"Excited", @"Grumpy", @"Tired", @"Lonely", @"Scared", @"Custom", nil];
    
    [self.btnMenu setTitle:glossaryArray[0] forState:UIControlStateNormal];
    [self.tbvMenu selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                              animated:YES
                        scrollPosition:(UITableViewScrollPositionTop)];
    self.tbvMenu.hidden = YES;

//    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewForMenu:)];
//    tap.delegate = self;
//    tap.enabled = YES;
//    [self.view addGestureRecognizer:tap];
    
    self.txtGlossary.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu:(id)sender
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MiimojiViewController* destViewController = [segue destinationViewController];
    
    NSInteger selectedRow = self.tbvMenu.indexPathForSelectedRow.row;
    if (selectedRow == glossaryArray.count - 1) {
        if ([self.txtGlossary.text isEqualToString:@""]) {
            destViewController.glossary = [NSString stringWithFormat:@"%@", @"No Title"];
        } else {
            destViewController.glossary = [NSString stringWithFormat:@"%@", self.txtGlossary.text];
        }
    } else {
        destViewController.glossary = [glossaryArray objectAtIndex:selectedRow];
    }    
}

#pragma mark - Button Event
- (IBAction)onBtnDDMenu:(id)sender {
    [self.view endEditing:YES];
    
    CGRect tbvFrame = self.tbvMenu.frame;
    tbvFrame.size.height = 30 * glossaryArray.count;
    self.tbvMenu.frame = tbvFrame;
    
    if (self.btnMenu.tag == 0) {
        // Show Menu
        self.btnMenu.tag = 1;
        self.tbvMenu.hidden = NO;
    } else if (self.btnMenu.tag == 1) {
        // Hide Menu
        self.btnMenu.tag = 0;
        self.tbvMenu.hidden = YES;
    }
}

- (IBAction)onBtnCreateMiimoji:(id)sender {
    
    if (self.btnMenu.tag == 1) {
        [self onBtnDDMenu:self.btnMenu];
    }
    
    NSInteger selectedRow = self.tbvMenu.indexPathForSelectedRow.row;
    MiimojiViewController* viewController = nil;

    if (selectedRow == glossaryArray.count - 1) {
        if ([self.txtGlossary.text isEqualToString:@""]) {
            
            [[[UIAlertView alloc] initWithTitle:@""
                                        message:@"Please type in the glossary"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        } else {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MiimojiController"];
            viewController.glossary = [NSString stringWithFormat:@"%@", self.txtGlossary.text];
        }
    } else {
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MiimojiController"];
        viewController.glossary = [glossaryArray objectAtIndex:selectedRow];
    }
    
    if (viewController != nil) {
        [[self navigationController] pushViewController:viewController animated:YES];
    }
}

#pragma mark - Tap Methods
- (void)tapViewForMenu:(UITapGestureRecognizer *)tapRecognizer
{
    if (self.btnMenu.tag == 1) {
        // Hide Menu
        self.btnMenu.tag = 0;
        self.tbvMenu.hidden = YES;
    }
}

#pragma mark - UITextFieldDelegate
//-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    activeField = textField;
//    tap.enabled = YES;
//    return YES;
//}
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSUInteger tag = textField.tag;
    if (tag == self.txtGlossary.tag) { // Last textField
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UIPickerView Delegate
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return glossaryArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [glossaryArray objectAtIndex:row];
}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return glossaryArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"GlossaryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = glossaryArray[indexPath.row];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.contentView.backgroundColor = [UIColor colorWithRed:227.0f/255 green:14.0f/255 blue:2.0f/255 alpha:1.0];
//    cell.backgroundColor = [UIColor colorWithRed:227.0f/255 green:14.0f/255 blue:2.0f/255 alpha:1.0];
//}
//
//- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.contentView.backgroundColor = [UIColor whiteColor];
//    cell.backgroundColor = [UIColor whiteColor];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.btnMenu setTitle:glossaryArray[indexPath.row] forState:UIControlStateNormal];

//    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//    cell.contentView.backgroundColor = [UIColor colorWithRed:227.0f/255 green:14.0f/255 blue:2.0f/255 alpha:1.0];
//    cell.backgroundColor = [UIColor colorWithRed:227.0f/255 green:14.0f/255 blue:2.0f/255 alpha:1.0];
//
    self.btnMenu.tag = 0;
    self.tbvMenu.hidden = YES;
    
    if (indexPath.row == glossaryArray.count - 1) {
        self.txtGlossary.enabled = YES;
        self.txtGlossary.textColor = [UIColor blackColor];
        self.txtGlossary.placeholder = @"";
    } else {
        
        self.txtGlossary.enabled = NO;
        self.txtGlossary.textColor = [UIColor grayColor];
        if ([self.txtGlossary.text isEqualToString:@""]) {
            self.txtGlossary.placeholder = @"Available for custom glossary";
        }
    }
}

@end
