//
//  ViewController.m
//  BlocBrowser
//
//  Created by Melissa Boring on 9/23/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "AwesomeFloatingToolbar.h"

@interface ViewController ()<WKNavigationDelegate, UITextFieldDelegate,AwesomeFloatingToolbarDelegate>

@property(nonatomic,strong) WKWebView *webView;
@property(nonatomic,strong) UITextField *textField;
@property(nonatomic,strong) AwesomeFloatingToolbar *awesomeToolbar;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

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
    self.textField.placeholder = NSLocalizedString(@"Enter Website URL or Search Terms", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.awesomeToolbar = [[AwesomeFloatingToolbar alloc]initWithFourTitles:@[kWebBrowserBackString,kWebBrowserForwardString,kWebBrowserRefreshString,kWebBrowserStopString]];
    
    //add the objects to the mainView
    NSArray *viewArray = @[self.webView,self.textField,self.awesomeToolbar];
    for (UIView *viewToAdd in viewArray)
    {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;

}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self showWelcomeAlert];
    
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
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - ( itemHeight );
    
    // Now, assign the frames to the textfield and webview
    // CGRectMake(howFarFromTheLeft, howFarFromTheTop, howWide, howTall)
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    
    //CGRectGetMaxY determines the max Y of the textfield frame
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    self.awesomeToolbar.frame = CGRectMake(20,100,280,60);

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
    
    NSURL *URL = [self setURLForWebOrQueryTerms:URLString];
    
    //load the request
    if (URL)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
    
    return NO;

}

//determines is a URL or search terms were entered and format the URL appropriately
-(NSURL *)setURLForWebOrQueryTerms:(NSString *)textString
{
    NSString *URLString = textString;
    NSURL *URL = [NSURL URLWithString:URLString];
    
    //Identify query or URL entered by checking for .
    NSUInteger periodLocation = [URLString rangeOfString:@"."].location;
    
    //If no . then query term entered
    if (periodLocation == NSNotFound)
    {
        
        NSString *queryString = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSString *newURLString = [NSString stringWithFormat:@"http://www.google.com/search?q=%@", queryString];
        
        URL = [NSURL URLWithString:newURLString];
        
    }
    
    //check that user entered scheme (http or https); if not format correctly
    if (!URL.scheme)
    {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    
    return URL;
    
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

#pragma mark - AwesomeFloatingToolbarDelegate

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqual:NSLocalizedString(@"Back", @"Back command")]) {
        [self.webView goBack];
    } else if ([title isEqual:NSLocalizedString(@"Forward", @"Forward command")]) {
        [self.webView goForward];
    } else if ([title isEqual:NSLocalizedString(@"Stop", @"Stop command")]) {
        [self.webView stopLoading];
    } else if ([title isEqual:NSLocalizedString(@"Refresh", @"Reload command")]) {
        [self.webView reload];
    }
}

#pragma mark - button methods

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
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:[self.webView isLoading] forButtonWithTitle:kWebBrowserStopString];
    [self.awesomeToolbar setEnabled:![self.webView isLoading] && self.webView.URL forButtonWithTitle:kWebBrowserRefreshString];
}

//remove existing webView from hierarchy and create a new webView
//this is for clearing history when the app becomes inactive
- (void) resetWebView {
    [self.webView removeFromSuperview];
    
    WKWebView *newWebView = [[WKWebView alloc] init];
    newWebView.navigationDelegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    self.textField.text = nil;
    
    [self updateButtonsAndTitle];
}



#pragma mark misc methods

-(void)showWelcomeAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Welcome to BlocBrowser"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
