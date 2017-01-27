//
//  SettingsViewController.h
//  TextQuick
//
//  Created by Eric Mansfield on 3/15/12.
//  Copyright (c) 2012 AppsOnTheSide, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SettingsViewController : UITableViewController<MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UISlider *fontSlider;
@property (strong, nonatomic) IBOutlet UILabel *fontSizeLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *useNicknameCell;
@property (strong, nonatomic) IBOutlet UILabel *useNicknameTableCell;

- (IBAction)fontSliderChanged:(id)sender;

@end
