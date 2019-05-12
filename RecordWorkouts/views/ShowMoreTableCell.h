#import <UIKit/UIKit.h>

@interface ShowMoreTableCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIButton *showMoreButton;

- (void) setQueryDate: (NSDate *) queryFromDate
           onShowMore: (void (^)(void)) onLoadMore;

@end
