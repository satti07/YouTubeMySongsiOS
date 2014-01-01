#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIWebView *webview;
    GADBannerView *bannerView_;
}
@end
