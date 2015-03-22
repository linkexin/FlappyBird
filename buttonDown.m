//
//  buttonDown.m
//  MyFlappy
//
//  Created by apple on 14-11-14.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "buttonDown.h"
#define NAME_BUTTON @"start"
#define NAME_LABEL @"label"

@interface buttonDown()

@property (strong, nonatomic)SKSpriteNode *start;
@property (strong, nonatomic)SKSpriteNode *gameover;
@property (strong, nonatomic)SKSpriteNode *rank;
@property (strong, nonatomic)SKSpriteNode *board;
@end

@implementation buttonDown

-(instancetype)initWithColor:(UIColor *)color size:(CGSize)size
{
    //NSLog(@"%f %f", size.width, size.height);
    if(self = [super initWithColor:color size:size])
    {
        self.userInteractionEnabled = NO;//该属性决定UIView是否接受并响应用户的交互
        //当值设置为NO后，UIView会忽略那些原本应该发生在其自身的诸如touch和keyboard等用户事件，并将这些事件从消息队列中移除出去。
        //当值设置为YES后，这些用户事件会正常的派发至UIView本身(前提事件确实发生在该view上)，UIView会按照之前注册的事件处理方法来响应这些事件。
        
        //self.buttonbackgroud = [SKSpriteNode spriteNodeWithColor:[SKColor yellowColor] size:CGSizeMake(100, 65)];
        
        self.gameover = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"gameover"] size:CGSizeMake(210, 60)];
        self.gameover.position = CGPointMake(size.width / 2, -self.gameover.size.height / 2);
        [self addChild:self.gameover];
        [self.gameover runAction:[SKAction sequence:@[[SKAction waitForDuration:0.2], [SKAction moveToY:size.height * 0.7 duration:0.3]]]];
        //[self runAction:[SKAction sequence:@[[SKAction waitForDuration:0.22], [SKAction playSoundFileNamed:@"sfx_wing.caf" waitForCompletion:YES]]]];
        
        
        self.board = [SKSpriteNode spriteNodeWithTexture: [SKTexture textureWithImageNamed:@"score"] size:CGSizeMake(250, 150)];
        self.board.position = CGPointMake(self.frame.size.width / 2, -self.board.size.height / 2);
        [self addChild:self.board];
        [self.board runAction:[SKAction sequence:@[[SKAction waitForDuration:0.34], [SKAction moveToY:self.frame.size.height / 2 - 25 duration:0.3]]]];
        //[self runAction:[SKAction sequence:@[[SKAction waitForDuration:0.37], [SKAction playSoundFileNamed:@"sfx_wing.caf" waitForCompletion:YES]]]];

        
        self.start = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"start"] size:CGSizeMake(100, 60)];
        self.start.position = CGPointMake(self.frame.size.width / 2 - 75, self.frame.size.height / 2 - 150);
        self.start.name = NAME_BUTTON;
        self.start.alpha = 0;
        [self.start runAction:[SKAction sequence:@[[SKAction waitForDuration:.4], [SKAction fadeInWithDuration:0.1]]]];
        [self addChild:self.start];
        
        
        self.rank = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"rank"] size:CGSizeMake(100, 60)];
        self.rank.position = CGPointMake(self.frame.size.width / 2 + 75, self.frame.size.height / 2 - 150);
        self.rank.alpha = 0;
        [self addChild:self.rank];
        [self.rank runAction:[SKAction sequence:@[[SKAction waitForDuration:.4], [SKAction fadeInWithDuration:0.1]]]];
        
        /*
        self.label = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Thin"];
        self.label.name = NAME_LABEL;
        self.label.text = @"Try again";
        self.label.fontColor = [SKColor blackColor];
        self.label.fontSize = 20;
        self.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        self.label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        self.label.position = CGPointMake(0, 0);
        [self.buttonbackgroud addChild:self.label];
         */
        SKAction *action = [SKAction sequence:@[[SKAction waitForDuration:.5], [SKAction performSelector:@selector(beginAction) onTarget:self]]];
        [self runAction:action];
    }
    return self;
}

-(void)beginAction
{
    self.userInteractionEnabled = YES;
}

+ (buttonDown *)initWithSize:(CGSize)size 
{
    buttonDown *restartView = [buttonDown spriteNodeWithColor:[SKColor colorWithRed:255 green:255 blue:255 alpha:0] size:size];//这里只能用类方法
    restartView.anchorPoint = CGPointMake(0, 0);
    //buttonDown *restartView = [[buttonDown alloc]init];
    return restartView;
}

- (void)setNum:(int)num withBest:(int)best
{
    SKLabelNode *score = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Thin"];
    score.name = @"score";
    score.text = [NSString stringWithFormat:@"%d", num];
    score.fontSize = 30;
    score.fontColor = [SKColor whiteColor];
    score.alpha = 0;
    score.position = CGPointMake(self.size.width * 0.75, self.size.height * 0.47);
    [self addChild:score];
    [score runAction:[SKAction sequence:@[[SKAction waitForDuration:0.5], [SKAction fadeInWithDuration:0.5]]]];
    
    SKLabelNode *bestscore = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Thin"];
    bestscore.name = @"bestscore";
    bestscore.text = [NSString stringWithFormat:@"%d", best];
    bestscore.fontSize = 30;
    bestscore.fontColor = [SKColor whiteColor];
    bestscore.alpha = 0;
    bestscore.position = CGPointMake(self.size.width * 0.75, self.size.height * 0.37);
    [self addChild:bestscore];
    [bestscore runAction:[SKAction sequence:@[[SKAction waitForDuration:0.5], [SKAction fadeInWithDuration:0.5]]]];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *touchNode = [self nodeAtPoint:location];//确定触摸点处存在的节点
    
    if([[touchNode name]isEqualToString:NAME_BUTTON])// || [[touchNode name]isEqualToString:NAME_LABEL])
    {
        [self removeFromParent];
        [self.delegate restartView:self];//等于[MyScence restartView:self],
    }
}

-(void)showInScene:(SKScene *)scene
{
    [scene addChild:self];
}


@end
