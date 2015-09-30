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
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation AwesomeFloatingToolbar

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
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UILabel *label = [[UILabel alloc] init];
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = titleForThisLabel;
            label.backgroundColor = colorForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
        }
        
        self.labels = labelsArray;
        
        for (UILabel *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
    }
    
    //call tapFired when tap is detected
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    
    //tells the view (self) to route touch events through this recognizer
    [self addGestureRecognizer:self.tapGesture];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
    [self addGestureRecognizer:self.panGesture];

    
    return self;
}


- (void) layoutSubviews {
    
    // set the frames for the 4 labels
    
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    
    for (UILabel *thisLabel in self.labels) {
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 4;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 4;

        labelX += CGRectGetWidth(self.bounds) / 4;
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

#pragma mark - Touch Handling

//determins which of the labels was touched
- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    //take touch from touch set
    UITouch *touch = [touches anyObject];
    
    //determine screen coordinates
    CGPoint location = [touch locationInView:self];
    
    //find view at that location
    UIView *subview = [self hitTest:location withEvent:event];
    
    //return label
    if ([subview isKindOfClass:[UILabel class]])
    {
        return (UILabel *)subview;
        
    }
    
    else
    {
        
        return nil;
        
    }
}


#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title
{
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound)
    {
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
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
        if ([self.labels containsObject:tappedView])
        {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)])
            {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
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

@end
