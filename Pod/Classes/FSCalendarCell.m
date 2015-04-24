//
//  FSCalendarCell.m
//  Pods
//
//  Created by Wenchao Ding on 12/3/15.
//
//

#import "FSCalendarCell.h"
#import "FSCalendar.h"
#import "UIView+FSExtension.h"
#import "NSDate+FSExtension.h"

#define kAnimationDuration 0.15

@interface FSCalendarCell ()

@property (strong,   nonatomic) CAShapeLayer *backgroundLayer;
@property (strong,   nonatomic) CAShapeLayer *eventLayer;
@property (readonly, nonatomic) BOOL         today;
@property (readonly, nonatomic) BOOL         weekend;


- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary;

@end

@implementation FSCalendarCell

#pragma mark - Init and life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor darkTextColor];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleLabel.font = [UIFont systemFontOfSize:10];
        subtitleLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:subtitleLabel];
        self.subtitleLabel = subtitleLabel;
        
        _backgroundLayer = [CAShapeLayer layer];
        _backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
        _backgroundLayer.hidden = YES;
        [self.contentView.layer insertSublayer:_backgroundLayer atIndex:0];
        
        _eventLayer = [CAShapeLayer layer];
        _eventLayer.backgroundColor = [UIColor clearColor].CGColor;
        _eventLayer.fillColor = [UIColor clearColor].CGColor;
        _eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:_eventLayer.bounds].CGPath;
        [self.contentView.layer insertSublayer:_eventLayer atIndex:0];
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    CGFloat diameter = MIN(self.bounds.size.height, self.bounds.size.width) - 5.0;
    _backgroundLayer.frame = CGRectMake((self.bounds.size.width  - diameter) / 2,
                                        (self.bounds.size.height - diameter) / 2,
                                        diameter,
                                        diameter);
    
    _eventLayer.frame = _backgroundLayer.frame;
    _eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:_eventLayer.bounds].CGPath;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [CATransaction setDisableActions:YES];
}

#pragma mark - Public

- (void)showAnimation
{
    _backgroundLayer.hidden = NO;
    _backgroundLayer.path = [UIBezierPath bezierPathWithOvalInRect:_backgroundLayer.bounds].CGPath;
    _backgroundLayer.fillColor = [self colorForCurrentStateInDictionary:_backgroundColors].CGColor;
    CAAnimationGroup *group = [CAAnimationGroup animation];
    CABasicAnimation *zoomOut = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomOut.fromValue = @0.3;
    zoomOut.toValue = @1.2;
    zoomOut.duration = kAnimationDuration/4*3;
    CABasicAnimation *zoomIn = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomIn.fromValue = @1.2;
    zoomIn.toValue = @1.0;
    zoomIn.beginTime = kAnimationDuration/4*3;
    zoomIn.duration = kAnimationDuration/4;
    group.duration = kAnimationDuration;
    group.animations = @[zoomOut, zoomIn];
    [_backgroundLayer addAnimation:group forKey:@"bounce"];
    [self configureCell];
}

- (void)hideAnimation
{
    _backgroundLayer.hidden = YES;
    [self configureCell];
}

#pragma mark - Private

- (void)configureCell
{
    _titleLabel.text = [NSString stringWithFormat:@"%@",@(_date.fs_day)];
    _subtitleLabel.text = _subtitle;
    _titleLabel.textColor = [self colorForCurrentStateInDictionary:_titleColors];
    _subtitleLabel.textColor = [self colorForCurrentStateInDictionary:_subtitleColors];
    _backgroundLayer.fillColor = [self colorForCurrentStateInDictionary:_backgroundColors].CGColor;
    
    CGFloat titleHeight = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].height;
    if (_subtitleLabel.text) {
        _subtitleLabel.hidden = NO;
        CGFloat subtitleHeight = [_subtitleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.subtitleLabel.font}].height;
        CGFloat height = titleHeight + subtitleHeight;
        _titleLabel.frame = CGRectMake(0,
                                       (self.contentView.fs_height*5.0/6.0-height)*0.5,
                                       self.fs_width,
                                       titleHeight);
        
        _subtitleLabel.frame = CGRectMake(0,
                                          _titleLabel.fs_bottom - (_titleLabel.fs_height-_titleLabel.font.pointSize),
                                          self.fs_width,
                                          subtitleHeight);
    } else {
        _titleLabel.frame = CGRectMake(0, 0, self.fs_width, self.contentView.fs_height);
        _subtitleLabel.hidden = YES;
    }
    _backgroundLayer.hidden = !self.selected && !self.isToday;
    _backgroundLayer.path = _cellStyle == FSCalendarCellStyleCircle ?
    [UIBezierPath bezierPathWithOvalInRect:_backgroundLayer.bounds].CGPath :
    [UIBezierPath bezierPathWithRect:_backgroundLayer.bounds].CGPath;
    if (_eventBackgroundColor) {
        _titleLabel.textColor = _eventForegroundColor;
    }
    _eventLayer.fillColor = _eventBackgroundColor.CGColor;
    _eventLayer.hidden = self.isPlaceholder;
}

- (BOOL)isPlaceholder
{
    return ![_date fs_isEqualToDateForMonth:_month];
}

- (BOOL)isToday
{
    return [_date fs_isEqualToDateForDay:_currentDate];
}

- (BOOL)isWeekend
{
    return self.date.fs_weekday == 1 || self.date.fs_weekday == 7;
}

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary
{
    if (self.isSelected) {
        return dictionary[@(FSCalendarCellStateSelected)];
    }
    if (self.isToday) {
        return dictionary[@(FSCalendarCellStateToday)];
    }
    if (self.isPlaceholder) {
        return dictionary[@(FSCalendarCellStatePlaceholder)];
    }
    if (self.isWeekend && [[dictionary allKeys] containsObject:@(FSCalendarCellStateWeekend)]) {
        return dictionary[@(FSCalendarCellStateWeekend)];
    }
    return dictionary[@(FSCalendarCellStateNormal)];
}

@end
