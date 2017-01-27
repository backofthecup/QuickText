//
//  EditMessageViewController.m
//  QuickText
//
//  Created by Eric Mansfield on 3/11/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import "EditMessageViewController.h"
#import "CoreDataDao.h"

@interface EditMessageViewController ()

@end

@implementation EditMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.message) {
        self.textView.text = self.message.body;
        self.saveButton.enabled = YES;
    }
    else {
        self.saveButton.enabled = NO;
    }
    
    [self.textView becomeFirstResponder];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)saveTapped:(id)sender {
    if (!self.message) {
        self.message = [NSEntityDescription insertNewObjectForEntityForName:@"QuickMessage" inManagedObjectContext:[CoreDataDao sharedDao].managedObjectContext];
    }

    self.message.body = self.textView.text;
    self.message.timestamp = [NSDate date];
    [[CoreDataDao sharedDao] save];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)cancelTapped:(id)sender {
    [[CoreDataDao sharedDao] rollback];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    self.saveButton.enabled = [[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 0;
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableCell;
    
}

@end
