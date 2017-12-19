//
//  SettingsViewController.m
//  TextQuick
//
//  Created by Eric Mansfield on 3/15/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize fontSlider;
@synthesize fontSizeLabel;
@synthesize useNicknameCell;
@synthesize useNicknameTableCell;

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSInteger fontSize = [[NSUserDefaults standardUserDefaults] integerForKey:kDefaultFontSize];
    
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%@pt", @(fontSize)];
    self.fontSlider.value = fontSize;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (self.useNicknameCell.accessoryType == UITableViewCellAccessoryNone) {
            self.useNicknameCell.accessoryType = UITableViewCellAccessoryCheckmark;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultUseNickname];
        }
        else {
            self.useNicknameCell.accessoryType = UITableViewCellAccessoryNone;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDefaultUseNickname];
            
        }

        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (indexPath.section == 2) {
        // make a suggestion
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            [controller setSubject:@"Texting 1-2-3 Suggestion"];
            controller.mailComposeDelegate = self;
            [controller setToRecipients:[NSArray arrayWithObject:@"support@appsontheside.com"]];
            controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            
            [self presentViewController:controller animated:YES completion:nil];
        }
        else {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Texting 1-2-3" message:@"This device cannot send email." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [controller addAction:action];
            [self presentViewController:controller animated:YES completion:nil];
        }
        
        
    }
}

#pragma mark - MFMailComposerViewDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    NSLog(@"..result... %li", (long)result);
    [self dismissViewControllerAnimated:YES completion:nil];
    if (result == MFMailComposeErrorCodeSendFailed) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Texting 1-2-3" message:@"There was an error sending your feeback!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [controller addAction:action];
        [self presentViewController:controller animated:YES completion:nil];

        
    }
}

- (IBAction)fontSliderChanged:(id)sender {
    NSInteger size = [self.fontSlider value];
    
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%@pt", @(size)];
    [[NSUserDefaults standardUserDefaults] setInteger:size forKey:kDefaultFontSize];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
@end
