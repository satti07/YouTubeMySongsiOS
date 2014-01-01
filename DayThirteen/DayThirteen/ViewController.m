

#import "ViewController.h"
#import <MediaPlayer/MPMediaQuery.h>


@interface ViewController ()

@end

@implementation ViewController

NSArray *itemsArray;
int MAX_QUERY_SONGS = 5;
static NSString *youTubeVideoHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady, }, playerVars : {controls: 1, rel: 0, modestbranding: 1, html5: 1, playsinline: 0} }); } function onPlayerReady(event) { /*event.target.playVideo();*/ } </script> </body> </html>";
static NSString* loadingSongsHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;background-color:black}</style></head> <body> <div style='width:100%;height:100%;text-align:center;padding:20px;font-family:\"Helvetica Neue\";font-weight:lighter;font-size:10pt;color:gray'>Please wait, loading songs...</div></body> </html>";
static NSString* noSongFoundHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;background-color:black}</style></head> <body> <div style='width:100%;height:100%;text-align:center;padding:20px;font-family:\"Helvetica Neue\";font-weight:lighter;font-size:10pt;color:gray'>Sorry! Could not find video! :(</div></body> </html>";
static NSString* welcomeHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;background-color:black}</style></head> <body> <div style='width:100%;height:100%;text-align:center;padding:20px;font-family:\"Helvetica Neue\";font-weight:lighter;font-size:10pt;color:gray'>Click on a song to play</div></body> </html>";
static NSString* noSongsOnPhoneHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;background-color:black}</style></head> <body> <div style='width:100%;height:100%;text-align:center;padding:20px;font-family:\"Helvetica Neue\";font-weight:lighter;font-size:10pt;color:gray'>No songs found!</div></body> </html>";
static NSString* noDataConnectionHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;background-color:black}</style></head> <body> <div style='width:100%;height:100%;text-align:center;padding:20px;font-family:\"Helvetica Neue\";font-weight:lighter;font-size:10pt;color:gray'>No data connection!</div></body> </html>";
NSString* currentHTML = nil;

static NSString* YOUTUBE_VIDEO_INFORMATION_URL = @"http://www.youtube.com/get_video_info?&video_id=";

-(void)loadView {
    [super loadView];
    //[webview loadHTMLString:loadingSongsHTML baseURL:[[NSBundle mainBundle] resourceURL]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // assign a playback queue containing all media items on the device
    MPMediaQuery* allSongs =  [MPMediaQuery songsQuery];
    
    itemsArray = [allSongs items];
    
    if ([itemsArray count] != 0)
        currentHTML = welcomeHTML;
    else
        currentHTML = noSongsOnPhoneHTML;
    [webview loadHTMLString:currentHTML baseURL:[[NSBundle mainBundle] resourceURL]];
    
    
    /*
    // Use predefined GADAdSize constants to define the GADBannerView.
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    

    
    // Specify the ad unit ID.
    bannerView_.adUnitID = @"a152c34c7891112";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];*/
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

NSArray* getResults(NSString* query) {
    NSMutableArray *myArray = [NSMutableArray array];
    if ([query rangeOfString:@"<unknown>"].location == NSNotFound)
    {
        // TODO: Get short and medium duration only, exclude long videos
        NSMutableString* urlString = [NSMutableString stringWithString: @"http://gdata.youtube.com/feeds/api/videos?q="];
        [urlString appendString: query];
        [urlString appendString: @"&max-results="];
        [urlString appendString: [NSString stringWithFormat:@"%d", MAX_QUERY_SONGS]];
        [urlString appendString: @"&v=2&alt=jsonc"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        /* set headers, etc. on request if needed */
        [request setURL:[NSURL URLWithString: urlString]];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
        if (data == nil)
            return myArray;
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", html);
        
        NSError *error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if(error) { return myArray; }
        if([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *results = object;
            results = [results objectForKey:@"data"];
            NSArray* ret =  [results objectForKey:@"items"];
            return ret;
            
        }
        else
        {
            return myArray;
        }
    }
    return myArray;

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"Rotation triggered");
    if (currentHTML != nil) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [webview loadHTMLString:currentHTML baseURL:[[NSBundle mainBundle] resourceURL]];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Number of items : %i", [itemsArray count]);
    
    return [itemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    MPMediaItem *item =[itemsArray objectAtIndex:[indexPath row]];
    
    
    
    NSString *songTitle = [item valueForProperty: MPMediaItemPropertyTitle];
    NSString *songAlbum = [item valueForProperty: MPMediaItemPropertyAlbumTitle];
    NSString *songArtist = [item valueForProperty:MPMediaItemPropertyAlbumArtist];
    
    //NSLog(@"%@", songTitle);
    
    
    UILabel *labelOne = (UILabel *)[cell viewWithTag:1];
    UILabel *labelTwo = (UILabel *)[cell viewWithTag:2];
    
    labelOne.text = songTitle;
    labelTwo.text = songArtist;
    
    return cell;
}

bool IsProtected(NSString* videoId) {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    /* set headers, etc. on request if needed */
    [request setURL:[NSURL URLWithString: [YOUTUBE_VIDEO_INFORMATION_URL stringByAppendingString:videoId]]];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
    if (data == nil)
        return true;
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([html rangeOfString:@"fail"].location == NSNotFound)
        return false;
    return true;
}

NSString* extractVideoId(NSDictionary* song) {
    NSString* videoId = [song objectForKey:@"id"];
    /*NSDictionary* accessControl = [song objectForKey:@"accessControl"];
    for(NSString *key in [accessControl allKeys]) {
        NSLog(@"Key: %@", key);
        NSLog(@"%@",[accessControl objectForKey:key]);
    }*/
    return videoId;
}

NSString* getSongId(NSString* title, NSString* album, NSString* artist) {
    NSArray* results1 = nil;
    NSArray* results2 = nil;
    NSArray* results3 = nil;
    if (title != nil)
        results1 = getResults([title stringByReplacingOccurrencesOfString:@" " withString:@"%20"]);
    if (album != nil && ![album isEqualToString:@""])
        results2 = getResults([[[title stringByAppendingString:@" "]stringByAppendingString:album]stringByReplacingOccurrencesOfString:@" " withString:@"%20"]);
    if (artist != nil && ![artist isEqualToString:@""])
        results3 = getResults([[[title stringByAppendingString:@" "]stringByAppendingString:artist]stringByReplacingOccurrencesOfString:@" " withString:@"%20"]);
    for(int i = 0; i < MAX_QUERY_SONGS; ++i) {
        if(results1 != nil && [results1 count] > i) {
            NSString* ret = extractVideoId(results1[i]);
            if (!IsProtected(ret))
                return ret;
        }
        if(results2 != nil && [results2 count] > i) {
            NSString* ret = extractVideoId(results2[i]);
            if (!IsProtected(ret))
                return ret;
        }
        if(results3 != nil && [results3 count] > i) {
            NSString* ret = extractVideoId(results3[i]);
            if (!IsProtected(ret))
                return ret;
        }
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Row tapped at %i", [indexPath row]);
    
    MPMediaItem *item =[itemsArray objectAtIndex:[indexPath row]];
    
    
    NSString *songTitle = [item valueForProperty: MPMediaItemPropertyTitle];
    NSString *songAlbum = [item valueForProperty: MPMediaItemPropertyAlbumTitle];
    NSString *songArtist = [item valueForProperty:MPMediaItemPropertyAlbumArtist];
    
    NSString* videoId = getSongId(songTitle, songAlbum, songArtist);
    
    NSString* html = noSongFoundHTML;
    
    if (videoId != nil)
        html = [NSString stringWithFormat:youTubeVideoHTML, webview.frame.size.width, webview.frame.size.height, videoId];
   
    currentHTML = html;
    [webview loadHTMLString:currentHTML baseURL:[[NSBundle mainBundle] resourceURL]];
}


@end
