#import "UIView+ViewController.h"

@implementation UIView (ViewController)

-(UIViewController*)viewController {
    
    //Go up in responder hierarchy until we reach a ViewController or return nil
    //if we don't find one
    id object = [self nextResponder];
    
    while (![object isKindOfClass:[UIViewController class]] &&
           object != nil) {
        object = [object nextResponder];
    }
    
    return object;
}

@end