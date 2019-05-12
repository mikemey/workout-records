#import "ShowMoreTableCell.h"
#import "../WRFormat.h"

@implementation ShowMoreTableCell {
    void (^_callbackHandler)(void);
}

static UIColor *defaultTextColor;

@synthesize dateLabel;
@synthesize showMoreButton;

+ (void) initialize {
    defaultTextColor = [UIColor colorWithRed:210.0f/255.0f
                                       green:210.0f/255.0f
                                        blue:210.0f/255.0f
                                       alpha:1.0f];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) setQueryDate: (NSDate *)queryFromDate onShowMore: (void (^)(void)) onShowMore; {
    [self setTextOn:dateLabel text:[WRFormat formatDate:queryFromDate] size:12];
    _callbackHandler = onShowMore;
}

- (IBAction) onShowMoreClick: (id)sender {
    if(_callbackHandler) {
        _callbackHandler();
    }
}

- (void)setTextOn:(UILabel *)lbl text:(NSString *)text size:(int)size {
    lbl.font = [UIFont fontWithName:@"Verdana" size:size];
    [lbl setTextColor:defaultTextColor];
    [lbl setText:text];
}

@end
