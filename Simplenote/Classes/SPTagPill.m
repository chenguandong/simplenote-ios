//
//  SPTagPill.m
//  Simplenote
//
//  Created by Tom Witkin on 10/10/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTagPill.h"
#import "SPTagStub.h"

@interface SPTagPill ()

@property (nonatomic) BOOL performDeletionAction;
@property (nonatomic, strong) UIView *deletionOverlayView;
@property (nonatomic, strong) UIImageView *deletionButtonImageView;

@end

@implementation SPTagPill

- (id)initWithTagStub:(SPTagStub *)tagStub target:(id)t action:(SEL)a deletionAction:(SEL)da {
    
    self = [self init];
    
    if (self) {
        
        [self setTitle:tagStub.tag forState:UIControlStateNormal];
        [self setTitleColor:[self color] forState:UIControlStateNormal];
        [self setTitleColor:[self highlightedColor] forState:UIControlStateHighlighted];
        
        self.titleLabel.font = [self.theme fontForKey:@"tagViewFont"];
        
        [self addTarget:t
                    action:a
          forControlEvents:UIControlEventTouchUpInside];
        
        [self sizeToFit];
        
        self.tagStub = tagStub;
        
        target = t;
        deletionAction = da;
    }
    
    return self;
}

- (void)sizeToFit {
    
    [super sizeToFit];
    
    CGRect frame = self.frame;
    frame.size.width += 2 * [self.theme floatForKey:@"tagViewItemSideSpacing"];
    self.frame = frame;
}


- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}

- (UIColor *)color {
    
    return [self.theme colorForKey:@"tagViewFontColor"];
}

- (UIColor *)highlightedColor {
    
    return [self.theme colorForKey:@"tagViewFontColorSelected"];
}


- (NSString *)accessibilityHint {
    
    return NSLocalizedString(@"tag-delete-accessibility-hint", nil);
}

- (void)showDeletionView {
    
    
    if (!_deletionOverlayView) {
        
        CGFloat horizontalSpacing = [self.theme floatForKey:@"tagViewItemSideSpacing"];
        CGFloat verticalSpacing = 10.0;
        
        _deletionOverlayView = [[UIView alloc] initWithFrame:CGRectMake(horizontalSpacing / 2.0,
                                                                        verticalSpacing / 2.0,
                                                                        self.frame.size.width - horizontalSpacing,
                                                                        self.frame.size.height - verticalSpacing)];
        
        _deletionOverlayView.backgroundColor = [self.theme colorForKey:@"tagViewDeletionBackgroundColor"];
        _deletionOverlayView.layer.cornerRadius = 4.0;
        _deletionOverlayView.clipsToBounds = YES;
        _deletionOverlayView.layer.borderColor = [self.theme colorForKey:@"tagViewDeletionBackgroundBorderColor"].CGColor;
        _deletionOverlayView.layer.borderWidth = 1.0 / [[UIScreen mainScreen] scale];
        
        _deletionButtonImageView = [[UIImageView alloc] initWithImage:[self.theme imageForKey:@"tagViewDeletionImage"]];
        [_deletionButtonImageView sizeToFit];
        
        _deletionButtonImageView.center = [self convertPoint:self.center fromView:self.superview];
    }
    
    _showingDeletionView = YES;
    
    _deletionOverlayView.alpha = 0.0;
    _deletionButtonImageView.alpha = 0.0;
    [self insertSubview:_deletionOverlayView belowSubview:self.titleLabel];
    [self addSubview:_deletionButtonImageView];
    [UIView animateWithDuration:0.1
                     animations:^{
                         
                         self.titleLabel.alpha = 0.3;
                         _deletionOverlayView.alpha = 1.0;
                         _deletionButtonImageView.alpha = 1.0;
                     }];
}

- (void)hideDeletionView {
    
    _showingDeletionView = NO;
    
   [UIView animateWithDuration:0.1
                    animations:^{
                        
                        self.titleLabel.alpha = 1.0;
                        _deletionOverlayView.alpha = 0.0;
                        _deletionButtonImageView.alpha = 0.0;
                    } completion:^(BOOL finished) {
                    
                        [_deletionOverlayView removeFromSuperview];
                        [_deletionButtonImageView removeFromSuperview];
                    }];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!_showingDeletionView)
        [super touchesBegan:touches withEvent:event];
    else
        _performDeletionAction = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
 
    _performDeletionAction = NO;
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _performDeletionAction = NO;
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_performDeletionAction) {
        
#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:deletionAction withObject:self];
#       pragma clang diagnostic pop
    
        _performDeletionAction = NO;
    } else
        [super touchesEnded:touches withEvent:event];
    
}


@end
