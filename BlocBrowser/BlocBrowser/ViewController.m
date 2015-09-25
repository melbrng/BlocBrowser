//
//  ViewController.m
//  BlocBrowser
//
//  Created by Melissa Boring on 9/23/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKNavigationDelegate, UITextFieldDelegate>

@property(nonatomic,strong) WKWebView *webView;
@property(nonatomic,strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;


@end

@implementation ViewController


//create the main view
- (void)loadView {
    
    UIView *mainView = [UIView new];

    
    self.webView = [[WKWebView alloc]init];
    self.webView.navigationDelegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
    
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled:NO];
    
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];
    
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back command") forState:UIControlStateNormal];
    [self.backButton addTarget:self.webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward command") forState:UIControlStateNormal];
    [self.forwardButton addTarget:self.webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop command") forState:UIControlStateNormal];
    [self.stopButton addTarget:self.webView action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    
    [self.reloadButton setTitle:NSLocalizedString(@"Refresh", @"Reload command") forState:UIControlStateNormal];
    [self.reloadButton addTarget:self.webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    
    //add the objects tot he mainView
    NSArray *viewArray = @[self.webView,self.textField,self.backButton, self.forwardButton, self.stopButton, self.reloadButton];
    for (UIView *viewToAdd in viewArray)
    {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;

}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //prevents objects from being pushed up under the nav bar and underneath the status bar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //activity indicator and add to right of the navigation bar
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];


}

-(void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    // set height of textfield to 50 and width to equal that of the view
    // browser height will be set to remaining view area
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    //additional itemHeight to allow room for buttons
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - ( itemHeight * 2.0 );
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    // Now, assign the frames to the textfield and webview
    // CGRectMake(howFarFromTheLeft, howFarFromTheTop, howWide, howTall)
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    
    //CGRectGetMaxY determines the max Y of the textfield frame
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    //place the buttons
    CGFloat currentButtonX = 0;
    
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webView.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
    }

}


#pragma mark UITextField delegate

//highlight all text in textField when clicked on
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.textField selectAll:self];
}

//delegate method to handle changes to the textfield and load request
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    //check that user entered scheme (http or https)
    if (!URL.scheme)
    {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    
    
    if (URL)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
    
    return NO;
}


#pragma mark WKNavigationDelegates

//error occurs when starting to load
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *) navigation withError:(NSError *)error
{

    [self webView:webView didFailNavigation:navigation withError:error];

}

//error occurs on loading
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self updateButtonsAndTitle];
}

//error occurs
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self updateButtonsAndTitle];
}

//error occurs during main frame navigation
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    //NSURLErrorCancelled called when a URL loading request is cancelled, so we are not monitoring for this message
    if (error.code != NSURLErrorCancelled)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
        [self updateButtonsAndTitle];
}


- (void) updateButtonsAndTitle
{
    //set the title of the navigation bar to entered url
    NSString *webpageTitle = [self.webView.title copy];
    
    if ([webpageTitle length])
    {
        self.title = webpageTitle;
    }
    else
    {
        self.title = self.webView.URL.absoluteString;
    }
    
    //start activity indicator when loading
    if (self.webView.isLoading)
    {
        [self.activityIndicator startAnimating];
    }
    else
    {
        [self.activityIndicator stopAnimating];
    }

    
    //enable/disable buttons depending on state of webView
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
    self.stopButton.enabled = self.webView.isLoading;
    self.reloadButton.enabled = !self.webView.isLoading;
}

@end