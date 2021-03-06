//
//  FSCalendarCell.h
//  Pods
//
//  Created by Wenchao Ding on 12/3/15.
//
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface FSCalendarCell : UICollectionViewCell

@property (weak,   nonatomic) NSDictionary        *titleColors;
@property (weak,   nonatomic) NSDictionary        *subtitleColors;
@property (weak,   nonatomic) NSDictionary        *backgroundColors;

@property (copy,   nonatomic) NSDate              *date;
@property (copy,   nonatomic) NSDate              *month;
@property (weak,   nonatomic) NSDate              *currentDate;

@property (copy,   nonatomic) NSString            *subtitle;

@property (weak,   nonatomic) UILabel             *titleLabel;
@property (weak,   nonatomic) UILabel             *subtitleLabel;

@property (assign, nonatomic) FSCalendarCellStyle cellStyle;
@property (strong, nonatomic) UIColor               *eventForegroundColor;
@property (strong, nonatomic) UIColor               *eventBackgroundColor;

@property (readonly, getter = isPlaceholder)      BOOL placeholder;

- (void)showAnimation;
- (void)hideAnimation;
- (void)configureCell;

@end
