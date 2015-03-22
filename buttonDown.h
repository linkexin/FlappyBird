//
//  buttonDown.h
//  MyFlappy
//
//  Created by apple on 14-11-14.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class buttonDown;
@protocol buttonDownDelegate <NSObject>
- (void)restartView:(buttonDown *)buttonDown;
@end


@interface buttonDown : SKSpriteNode
@property (weak, nonatomic) id <buttonDownDelegate> delegate;

+ (buttonDown *)initWithSize:(CGSize)size;
- (void)showInScene:(SKScene *)scene;
- (void)setNum:(int)num withBest:(int)best;
@end
