//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Melissa Boring on 9/28/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;


@end

@implementation AwesomeFloatingToolbar

BOOL longPress = NO;

- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 buttons
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];

            [button setTitle:titleForThisLabel forState:UIControlStateNormal];
            [button setBackgroundColor:colorForThisLabel];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         //   [button addTarget:self action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];

            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
    }
    
    
    //call tapFired when tap is detected
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    
    //tells the view (self) to route touch events through this recognizer
    [self addGestureRecognizer:self.tapGesture];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
    [self addGestureRecognizer:self.panGesture];
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
    [self addGestureRecognizer:self.pinchGesture];
    
//    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
//    [self.longPressGesture setMinimumPressDuration:2];
//    [self addGestureRecognizer:self.longPressGesture];
//    
    return self;
}


- (void) layoutSubviews {
    
    // set the frames for the 4 labels
    
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        // adjust labelX and labelY for each label
        if (currentButtonIndex < 2) {
            // 0 or 1, so on top
            buttonY = 0;
        } else {
            // 2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentButtonIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            buttonX = 0;
        } else {
            // 1 or 3, so on the right
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }

}

#pragma mark - Touch Handling

////determins which of the labels was touched
//- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    //take touch from touch set
//    UITouch *touch = [touches anyObject];
//    
//    //determine screen coordinates
//    CGPoint location = [touch locationInView:self];
//    
//    //find view at that location
//    UIView *subview = [self hitTest:location withEvent:event];
//    
//    //return label
//    if ([subview isKindOfClass:[UILabel class]])
//    {
//        return (UILabel *)subview;
//        
//    }
//    
//    else
//    {
//        
//        return nil;
//        
//    }
//}


#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title
{
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound)
    {
        
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}


- (void) tapFired:(UITapGestureRecognizer *)recognizer
{
    // a tap gesture has been recognized
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        //records x,y coordinate with respect to view.bounds
        CGPoint location = [recognizer locationInView:self];
        
        //determine which view received the tap
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        //we check if the view that was tapped was in fact one of our toolbar labels and if so, we verify our delegate for compatibility before performing the appropriate method call.
        if ([self.buttons containsObject:tappedView])
        {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)])
            {
               // [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UIButton *)tappedView).currentTitle];

            }
        }
    }
}

- (void) panFired:(UIPanGestureRecognizer *)recognizer
{
    //recognizes a pan gesture
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        //how far finger moved in each direction after touch event
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)])
        {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        //reset to zero so get difference of each minipan
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer
{
    //recognizes a pinch gesture
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        
        NSLog(@"pinch");
        
        //records x,y coordinate with respect to view.bounds
     //   CGPoint location = [recognizer locationInView:self];
        
        //determine which view received the tap
   //     UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)])
        {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:recognizer.scale];
        }
        
        [recognizer setScale:1.0f];
    }
}


- (void) longPressFired:(UILongPressGestureRecognizer *)recognizer
{
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        //depending on if a longPress has been performed, the button colors will change
        NSLog(longPress ? @"Yes" : @"No");
        
        if (longPress == NO )
        {
            NSInteger i = ( self.colors.count - 1 );
            
            while (i >= 0 && i < 4 )
            {
                
             for (UIButton *thisButton in self.buttons)
             {

                UIColor *colorForThisLabel = [self.colors objectAtIndex:i];
                [thisButton setBackgroundColor:colorForThisLabel];
                --i;
                     
             }
                
            }
             longPress = YES;
        }
        else
        {
            NSInteger i = 0;
            
            while (i >= 0 && i < self.colors.count )
            {
            
                for (UIButton *thisButton in self.buttons)
                {
                    
                    UIColor *colorForThisLabel = [self.colors objectAtIndex:i];
                    [thisButton setBackgroundColor:colorForThisLabel];
                    ++i;
                    
                }
                
            }
           longPress = NO;
        }
     
    }

}
@end
