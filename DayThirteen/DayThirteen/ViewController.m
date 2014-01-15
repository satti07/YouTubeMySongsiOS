

#import "ViewController.h"
#import "Reachability.h"
#import <MediaPlayer/MPMediaQuery.h>


@interface ViewController ()

@end

@implementation ViewController

NSArray *itemsArray;
int MAX_QUERY_SONGS = 5;
bool isFullScreen = false;
static NSString *youTubeLandscapeVideoHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady, }, playerVars : {controls: 1, rel: 0, modestbranding: 1, html5: 1, playsinline: 0} }); } function onPlayerReady(event) { /*event.target.playVideo();*/ } </script> </body> </html>";
static NSString *youTubePortraitVideoHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady, }, playerVars : {controls: 1, rel: 0, modestbranding: 1, html5: 1, playsinline: 1, autoplay: 1} }); } function onPlayerReady(event) { /*event.target.playVideo();*/ } </script> </body> </html>";
static NSString* loadingSongsHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;background-color:black}</style></head> <body> <div style='width:100%;height:100%;text-align:center;padding:20px;font-family:\"Helvetica Neue\";font-weight:lighter;font-size:10pt;color:gray'>Please wait, loading songs...</div></body> </html>";
static NSString* noSongFoundHTML = @"<!DOCTYPE html><html><head><style>body {background-repeat:no-repeat;background:-webkit-linear-gradient(top, rgba(1,1,1,1) 0%,rgba(1,1,1,0) 100%) fixed;height: 100%;width: 100%;} .format{text-align:center;font-family:\"Helvetica Neue\";font-weight:lighter;;color:white} #heading{font-size:14pt;font-style:italic;padding:4px} #text{font-size:10pt;font-style:bold;padding:2px}</style></head> <body> <p class=\"format\" id=\"heading\">MyMusicCast</p><p class=\"format\" id=\"text\">Sorry, could not find any video :(</p></body> </html>";
static NSString* welcomeHTML = @"<!DOCTYPE html><html><head><style>body {background-repeat:no-repeat;background:-webkit-linear-gradient(top, rgba(1,1,1,1) 0%,rgba(1,1,1,0) 100%) fixed;height: 100%;width: 100%;} .format{text-align:center;font-family:\"Helvetica Neue\";font-weight:lighter;;color:white} #heading{font-size:14pt;font-style:italic;padding:4px} #text{font-size:10pt;font-style:bold;padding:2px}</style></head> <body> <p class=\"format\" id=\"heading\">MyMusicCast</p><p class=\"format\" id=\"text\">Select a song to watch its video</p><p class=\"format\" id=\"text\">Enjoy! :)</p></body> </html>";
static NSString* noSongsOnPhoneHTML = @"<!DOCTYPE html><html><head><style>body {background-repeat:no-repeat;background:-webkit-linear-gradient(top, rgba(1,1,1,1) 0%,rgba(1,1,1,0) 100%) fixed;height: 100%;width: 100%;} .format{text-align:center;font-family:\"Helvetica Neue\";font-weight:lighter;;color:white} #heading{font-size:14pt;font-style:italic;padding:4px} #text{font-size:10pt;font-style:bold;padding:2px}</style></head> <body> <p class=\"format\" id=\"heading\">MyMusicCast</p><p class=\"format\" id=\"text\">Select a song to watch its video</p><p class=\"format\" id=\"text\">No songs found on your phone!</p></body> </html>";

NSString* currentPortraitHTML = nil;
NSString* currentLandscapeHTML = nil;

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
        [webview loadHTMLString:welcomeHTML baseURL:[[NSBundle mainBundle] resourceURL]];
    else
        [webview loadHTMLString:noSongsOnPhoneHTML baseURL:[[NSBundle mainBundle] resourceURL]];
    
    CGPoint origin = CGPointMake(0.0,
                                 self.view.frame.size.height -
                                 CGSizeFromGADAdSize(kGADAdSizeBanner).height);
    
    // Use predefined GADAdSize constants to define the GADBannerView.
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner
                                                 origin:origin];
    
    
    // Specify the ad unit ID.
    bannerView_.adUnitID = @"a152c34c7891112";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    

    //req.testDevices = [NSArray arrayWithObjects:@"e56a723ec569d203384955f3f299dc52", nil];
    [bannerView_ loadRequest:[GADRequest request]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeStarted:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeFinished:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];

}

- (BOOL) shouldAutorotate
{
    return NO;
}


-(void)youTubeStarted:(NSNotification *)notification{
    //NSLog(@"fullscreen started");
    isFullScreen = true;
}

-(void)youTubeFinished:(NSNotification *)notification{
    //NSLog(@"left fullscreen");
    isFullScreen = false;
    // if we are in landscape mode we want to rotate back to portrait
    [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationPortrait animated:NO];
}

- (NSUInteger)supportedInterfaceOrientations{
    if (!isFullScreen)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskAllButUpsideDown;
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
        //NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        //NSLog(@"%@", html);
        
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
    /*NSLog(@"Rotation triggered");
    if (currentPortraitHTML != nil) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
        if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown)
            [webview loadHTMLString:currentPortraitHTML baseURL:[[NSBundle mainBundle] resourceURL]];
        else
            [webview loadHTMLString:currentLandscapeHTML baseURL:[[NSBundle mainBundle] resourceURL]];
    }*/
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"Number of items : %i", [itemsArray count]);
    
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
    
    Reachability* wifiReach = [Reachability reachabilityWithHostName: @"www.youtube.com"];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"You must be connected to the internet to use this app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    MPMediaItem *item =[itemsArray objectAtIndex:[indexPath row]];
    
    
    NSString *songTitle = [item valueForProperty: MPMediaItemPropertyTitle];
    NSString *songAlbum = [item valueForProperty: MPMediaItemPropertyAlbumTitle];
    NSString *songArtist = [item valueForProperty:MPMediaItemPropertyAlbumArtist];
    
    NSString* videoId = getSongId(songTitle, songAlbum, songArtist);
    
    
    if (videoId != nil) {
        currentPortraitHTML = [NSString stringWithFormat:youTubePortraitVideoHTML, webview.frame.size.width, webview.frame.size.height, videoId];
        currentLandscapeHTML = [NSString stringWithFormat:youTubeLandscapeVideoHTML, webview.frame.size.width, webview.frame.size.height, videoId];
    } else {
        currentLandscapeHTML = noSongFoundHTML;
        currentPortraitHTML = noSongFoundHTML;
    }
   
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown)
        [webview loadHTMLString:currentPortraitHTML baseURL:[[NSBundle mainBundle] resourceURL]];
    else
        [webview loadHTMLString:currentLandscapeHTML baseURL:[[NSBundle mainBundle] resourceURL]];
}


@end
