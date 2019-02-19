//
//  FPSDisplay.m
//  FPSDisplay
//
//  Created by Wendell on 2019/2/19.
//  Copyright © 2019 Wendell. All rights reserved.
//

#import "FPSDisplay.h"

#define kWindow [UIApplication sharedApplication].keyWindow
#define kScreen_Bounds [UIScreen mainScreen].bounds
#define kScreen_Width CGRectGetWidth([UIScreen mainScreen].bounds)
#define kScreen_Height CGRectGetHeight([UIScreen mainScreen].bounds)

@interface FPSDisplay ()

@property (nonatomic, strong) UILabel *displayLabel;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIFont *subFont;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSTimeInterval lastTime;

@end

@implementation FPSDisplay

- (void)dealloc {
    [_displayLink invalidate];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _font = [UIFont fontWithName:@"Menlo" size:14];
        _subFont = [UIFont fontWithName:@"Menlo" size:4];
        _count = 0;
        _lastTime = 0;
        
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [kWindow addSubview:self.displayLabel];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static FPSDisplay *sharedFPSDisplay = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFPSDisplay = [[FPSDisplay alloc] init];
    });
    return sharedFPSDisplay;
}

#pragma mark - Event response
- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    // 记录tick在 1秒内执行的次数
    _count += 1;
    // 计算本次刷新和上次刷新更新FPS的时间间隔
    NSTimeInterval delta = link.timestamp - _lastTime;
    
    // 时间间隔大于等于1秒时，就计算FPS
    if (delta < 1) {
        return;
    }
    
    _lastTime = link.timestamp;
    // FPS = 次数 / 时间（次/秒）
    float fps = _count / delta;
    // 重置次数
    _count = 0;
    
    CGFloat progress = fps / 60.0;
    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS", (int)round(fps)]];
    [text setAttributes:@{NSForegroundColorAttributeName: color} range:NSMakeRange(0, text.length - 3)];
    [text setAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} range:NSMakeRange(text.length - 3, 3)];
    [text setAttributes:@{NSFontAttributeName: _subFont} range:NSMakeRange(text.length - 4, 1)];
    
    self.displayLabel.attributedText = text;
}

#pragma mark - Getters and setters
- (UILabel *)displayLabel {
    if (!_displayLabel) {
        _displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, kScreen_Height - 40, 55, 20)];
        _displayLabel.layer.cornerRadius = 5;
        _displayLabel.layer.masksToBounds = YES;
        _displayLabel.textAlignment = NSTextAlignmentCenter;
        _displayLabel.font = _font;
        _displayLabel.userInteractionEnabled = NO;
        _displayLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.700];
    }
    return _displayLabel;
}

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    }
    return _displayLink;
}
@end
