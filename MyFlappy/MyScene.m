//
//  MyScene.m
//  MyFlappy
//
//  Created by apple on 14-11-10.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "MyScene.h"
#import "buttonDown.h"

#define ARC4RANDOM_MAX 0x100000000
#define WALL_WIDE 55
#define WALL_HIGH 500
#define BIRD_WIDE 50
#define BIRD_HIGH 50
#define GROUND_HIGH 70
#define BLANK_HIGH 30 * 4.5

#define NAME_WALL @"wall"
#define NAME_BLANK @"blank"
#define NAME_BIRD @"bird"
#define NAME_START @"start"
#define NAME_RANK @"rank"
#define NAME_RATE @"rate"
#define NAME_READY @"ready"
#define NAME_GROUND @"ground"
#define ACTION_WALLMOVE @"wallmove"
#define ACTION_HEADMOVE @"headmove"
#define ACTION_ADDWALL @"addwall"
#define ACTION_FTYUPDOWN @"fly"
#define ACTION_GROUND @"groundmove"

#define ZPOSITION_WHITE 5;
#define ZPOSTTION_RESTART 4;
#define ZPOSITION_BIRD 3;
#define ZPOSITION_GROUND 2;
#define ZPOSITION_WALL 1;
#define ZPOSITION_WORLD 0;

static const uint32_t birdCategory = 0x1 << 0;
static const uint32_t wallCategory = 0x1 << 1;
static const uint32_t blankCategory = 0x1 << 2;
static const uint32_t groundCategory = 0x2 << 3;


@interface MyScene()<SKPhysicsContactDelegate, buttonDownDelegate>
@property (strong, nonatomic)SKSpriteNode *worldNode;
@property (strong, nonatomic)SKSpriteNode *writeWorld;
@property (strong, nonatomic)SKSpriteNode *bird;
@property (strong, nonatomic)SKSpriteNode *ground;
@property (strong, nonatomic)SKSpriteNode *ready;
@property (strong, nonatomic)SKSpriteNode *rate;
@property (strong, nonatomic)SKSpriteNode *start;
@property (strong, nonatomic)SKSpriteNode *rank;
@property (strong, nonatomic)SKLabelNode *score;

@property (nonatomic)int num;
@property (nonatomic)int bestnum;

@property (strong, nonatomic)SKAction *moveWallAction;
@property (strong, nonatomic)SKAction *moveHeadAction;
@property (strong, nonatomic)SKAction *actionFly;
@property (strong, nonatomic)SKAction *moveGround;
@property (strong, nonatomic)SKAction *worldshake;
@property (strong, nonatomic)SKAction *clickBegin;

@property (nonatomic)BOOL IsgameStart;
@property (nonatomic)BOOL IsgameOver;
@end

@implementation MyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.physicsWorld.contactDelegate = self;
        self.IsgameStart = NO;
        self.IsgameOver = NO;
        self.num = 0;
        self.bestnum = 0;
        self.userInteractionEnabled = NO;
        [self initStartNode];
        [self initAction];
        [self addLableNode];
        [self addBirdNode];
        [self addGroundNode];
        
        [self runAction:self.clickBegin];
        //NSLog(@"%f  %f", self.frame.size.width, self.frame.size.height);
    }
    return self;
}
-(void)beginAction
{
    self.userInteractionEnabled = YES;
}

#pragma -- mark－－－－初始化－－－－－

-(void)initStartNode
{
    self.worldNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"bg.jpg"] size:CGSizeMake(330, 570)];
    self.worldNode.position = CGPointMake(self.size.width / 2, self.size.height / 2 + 15);
   // [self addChild:self.worldNode];
    
    self.writeWorld = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:255 green:0 blue:0 alpha:1] size:CGSizeMake(100, 100)];
    self.writeWorld.position = CGPointMake(100, 100);
    self.writeWorld.zPosition = ZPOSITION_BIRD;
    
    //ready
    self.ready = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"ready"] size:CGSizeMake(200, 70)];
    self.ready.name = NAME_READY;
    self.ready.position = CGPointMake(self.frame.size.width / 2, -35);
    self.ready.zPosition = ZPOSITION_BIRD;
    [self addChild:self.ready];
    SKAction *readyMove = [SKAction moveTo:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 100) duration:.8];
    [self.ready runAction:readyMove];
    
    //rate
    self.rate = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"rate"] size:CGSizeMake(100, 60)];
    self.rate.name = NAME_RATE;
    self.rate.position = CGPointMake(self.frame.size.width / 2, -60);
    [self addChild:self.rate];
    SKAction *readyMove2 = [SKAction moveTo:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 50) duration:.8];
    [self.rate runAction:readyMove2];
    
    self.start = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"start"] size:CGSizeMake(100, 60)];
    self.start.name = NAME_START;
    self.start.zPosition = ZPOSITION_BIRD;
    self.start.position = CGPointMake(self.frame.size.width / 2 - 75, self.frame.size.height / 2 - 150);
    self.start.alpha = 0;
    [self addChild:self.start];
    [self.start runAction:[SKAction sequence:@[[SKAction waitForDuration:.8], [SKAction fadeInWithDuration:1]]]];
    
    self.rank = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"rank"] size:CGSizeMake(100, 60)];
    self.rank.name = NAME_RANK;
    self.rank.position = CGPointMake(self.frame.size.width / 2 + 75, self.frame.size.height / 2 - 150);
    self.rank.alpha = 0;
    [self addChild:self.rank];
    [self.rank runAction:[SKAction sequence:@[[SKAction waitForDuration:.8], [SKAction fadeInWithDuration:1]]]];
    
    self.clickBegin = [SKAction sequence:@[[SKAction waitForDuration:1], [SKAction performSelector:@selector(beginAction) onTarget:self]]];
    
}

-(void)initAction
{
    self.moveWallAction = [SKAction moveToX:-40 duration:4];
    
    //小鸟转动角度
    SKAction *headup = [SKAction rotateToAngle:M_PI / 6 duration:0.2];
    SKAction *headdown = [SKAction rotateToAngle:-M_PI / 2 duration:0.8];
    self.moveHeadAction = [SKAction sequence: @[headup, headdown]];
    
    //飞行时小鸟的纹理切换
    NSMutableArray *textures = [[NSMutableArray alloc]initWithCapacity:3];
    
    for(int i = 0; i < 3; i++)
    {
        NSString *str = [NSString stringWithFormat:@"%@%d.png", NAME_BIRD, i + 1];
        SKTexture *tex = [SKTexture textureWithImageNamed:str];
        [textures addObject:tex];
    }
    
    SKAction *actionFlyOne = [SKAction setTexture:[textures objectAtIndex:0]];
    SKAction *actionFlyTwo = [SKAction setTexture:[textures objectAtIndex:1]];
    SKAction *actionFlyThree = [SKAction setTexture:[textures objectAtIndex:2]];
    SKAction *wait = [SKAction waitForDuration:0.2];
    self.actionFly = [SKAction sequence:@[actionFlyOne, wait, actionFlyTwo, wait, actionFlyThree]];
    
    SKAction *shake1 = [SKAction moveToY:self.worldNode.position.y + 0.5 duration:0.001];
    shake1.timingMode = SKActionTimingEaseOut;
    SKAction *shake2 = [SKAction moveToY:self.worldNode.position.y - 0.5 duration:0.001];
    shake2.timingMode = SKActionTimingEaseOut;
    SKAction *shake3 = [SKAction moveToX:self.worldNode.position.x + 0.5 duration:0.001];
    shake3.timingMode = SKActionTimingEaseOut;
    SKAction *shake4 = [SKAction moveToX:self.worldNode.position.x - 0.5 duration:0.001];
    shake4.timingMode = SKActionTimingEaseOut;
    
    SKAction *worldshake1 = [SKAction sequence:@[shake1, shake2, shake1, shake2, shake1, shake2]];
    SKAction *worldshake2 = [SKAction sequence:@[shake3, shake4, shake3, shake4, shake3, shake4]];
    self.worldshake = [SKAction group: @[worldshake1, worldshake2]];
    //self.worldshake = worldshake2;
}

#pragma -- mark－－－－添加节点－－－－

-(void)addLableNode
{
    self.score = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Thin"];
    self.score.text = @"0";
    self.score.fontColor = [SKColor whiteColor];
    self.score.fontSize = 35;
    self.score.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - 100);
    self.score.zPosition = ZPOSITION_BIRD;
    [self addChild:self.score];
}

-(void)addBirdNode
{
    //self.bird = [SKSpriteNode spriteNodeWithColor:[SKColor lightGrayColor] size:CGSizeMake(BIRD_WIDE, BIRD_HIGH)];
    self.bird = [[SKSpriteNode alloc]init];
    self.bird.size = CGSizeMake(BIRD_WIDE, BIRD_HIGH);
    self.bird.name = NAME_BIRD;
    self.bird.anchorPoint = CGPointMake(0.5, 0.5);
    self.bird.position = CGPointMake(-BIRD_WIDE, self.frame.size.height / 2 + 20);
    self.bird.zPosition = ZPOSITION_BIRD;
    self.bird.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(BIRD_WIDE, BIRD_HIGH) center:CGPointMake(0.5, 0.5)];
    self.bird.physicsBody.dynamic = YES;
    self.bird.physicsBody.categoryBitMask = birdCategory;
    self.bird.physicsBody.contactTestBitMask = wallCategory | groundCategory | blankCategory;
    self.bird.physicsBody.collisionBitMask = wallCategory | groundCategory;//接触是会有相互碰撞的力
    self.bird.physicsBody.allowsRotation = YES;
    self.bird.physicsBody.affectedByGravity = NO;
    self.bird.physicsBody.restitution = 0.2;
    
    [self addChild:self.bird];
    SKAction *comeIntoView = [SKAction moveTo:CGPointMake(self.frame.size.width * 0.3, self.frame.size.height / 2 + 20) duration:1];
    [self.bird runAction:comeIntoView];
    [self.bird runAction:[SKAction repeatActionForever:self.actionFly]];
}

-(void)addGroundNode
{
    //self.ground = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(self.frame.size.width, GROUND_HIGH)];
    //SKTexture *groundtext = [SKTexture textureWithImageNamed:@"ground.png"];
    //self.ground = [SKSpriteNode spriteNodeWithImageNamed:@"ground.png"];
    //self.ground = [SKSpriteNode spriteNodeWithTexture:groundtext size:CGSizeMake(self.frame.size.width, GROUND_HIGH)];
    self.ground = [SKSpriteNode spriteNodeWithImageNamed:@"gd.png"];
    self.ground.name = NAME_GROUND;
    self.ground.size = CGSizeMake(self.frame.size.width * 2, GROUND_HIGH);
    self.ground.position = CGPointMake(self.frame.size.width / 2, GROUND_HIGH / 2);
    self.ground.zPosition = ZPOSITION_GROUND;
    self.ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width * 2, GROUND_HIGH / 2 + 5)];
    self.ground.physicsBody.dynamic = NO;
    self.ground.physicsBody.categoryBitMask = groundCategory;
    self.ground.physicsBody.contactTestBitMask = birdCategory;
    self.ground.physicsBody.collisionBitMask = 1;
    
    SKAction *move1 = [SKAction moveTo:CGPointMake(0, GROUND_HIGH / 2) duration:1.5];
    SKAction *move2 = [SKAction moveTo:CGPointMake(self.frame.size.width / 2, GROUND_HIGH / 2) duration:0];
    self.moveGround = [SKAction repeatActionForever:[SKAction sequence:@[move1, move2]]];
    [self addChild:self.ground];
    [self.ground runAction:self.moveGround withKey:ACTION_GROUND];
    
}

-(void)addWallNode
{
    float high1 = floorf(((double)arc4random() / ARC4RANDOM_MAX) * (self.frame.size.height - BLANK_HIGH));
    if(high1 < 50)
        high1 += 100;
    if(high1 > 300)
        high1 -= 100;
    
    //NSLog(@"%f", high1);
    //SKSpriteNode *upwall = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(WALL_WIDE, high1)];
    SKSpriteNode *upwall = [SKSpriteNode spriteNodeWithImageNamed:@"pipe.png"];
    upwall.size = CGSizeMake(WALL_WIDE, WALL_HIGH);
    upwall.name = NAME_WALL;
    //upwall.anchorPoint = CGPointMake(1, 0);
    upwall.position = CGPointMake(self.frame.size.width + WALL_WIDE / 2, self.frame.size.height - (high1 - WALL_HIGH / 2));
    upwall.zPosition = ZPOSITION_WALL;
    upwall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(WALL_WIDE - 10, WALL_HIGH - BIRD_HIGH) center:CGPointMake(0, 0)];
    upwall.physicsBody.dynamic = NO;
    upwall.physicsBody.categoryBitMask = wallCategory;
    upwall.physicsBody.contactTestBitMask = birdCategory;
    
    [upwall runAction:self.moveWallAction withKey:ACTION_WALLMOVE];
    
    SKSpriteNode *blank = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(WALL_WIDE, BLANK_HIGH)];
    blank.position = CGPointMake(self.frame.size.width + WALL_WIDE * 3, self.frame.size.height - high1 - BLANK_HIGH / 2);
    blank.zPosition = ZPOSITION_WALL;
    blank.name = NAME_WALL;
    blank.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(WALL_WIDE, BLANK_HIGH)];
    blank.physicsBody.dynamic = NO;
    blank.physicsBody.categoryBitMask = blankCategory;
    blank.physicsBody.contactTestBitMask = birdCategory;
    [blank runAction:self.moveWallAction withKey:ACTION_WALLMOVE];
    
    float high2 = self.frame.size.height - high1 - BLANK_HIGH;
    //NSLog(@"%f", high2);
    //SKSpriteNode *downwall = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(WALL_WIDE, high2)];
    SKSpriteNode *downwall = [SKSpriteNode spriteNodeWithImageNamed:@"pipe.png"];
    downwall.size = CGSizeMake(WALL_WIDE, WALL_HIGH);
    //downwall.anchorPoint = CGPointMake(1, 0);
    downwall.position = CGPointMake(self.frame.size.width + WALL_WIDE / 2, -(WALL_HIGH / 2 - high2));
    downwall.zPosition = ZPOSITION_WALL;
    downwall.name = NAME_WALL;
   // NSLog(@"%f  %f", downwall.frame.origin.x, downwall.frame.origin.y);
    downwall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(WALL_WIDE - 10, WALL_HIGH - BIRD_HIGH) center:CGPointMake(0, 0)];
    downwall.physicsBody.dynamic = NO;
    downwall.physicsBody.categoryBitMask = wallCategory;
    downwall.physicsBody.contactTestBitMask = birdCategory;
    [downwall runAction:self.moveWallAction withKey:ACTION_WALLMOVE];
    
    [self addChild:upwall];
    [self addChild:downwall];
    [self addChild:blank];
}

-(SKAction *)flyUpDown
{
    SKAction *up = [SKAction moveTo:CGPointMake(self.bird.position.x, self.bird.position.y + 10) duration:0.4];
    up.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *down = [SKAction moveTo:CGPointMake(self.bird.position.x, self.bird.position.y - 10) duration:0.4];
    down.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *upDown = [SKAction sequence: @[up, down]];

    return upDown;
}

#pragma -- mark－－－－委托函数－－－－
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.IsgameOver)
        return ;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    if(!self.IsgameStart && node == self.start)
    {
        self.IsgameStart = YES;
        self.IsgameOver = NO;
        [self.ready removeFromParent];
        [self.rank removeFromParent];
        [self.rate removeFromParent];
        [self.start removeFromParent];
        
        [self.bird removeActionForKey:ACTION_FTYUPDOWN];
        self.bird.physicsBody.affectedByGravity = YES;
        //[self addWallNode];
        
        SKAction *wait = [SKAction waitForDuration:2.3];
        SKAction *add = [SKAction performSelector:@selector(addWallNode) onTarget:self];
        SKAction *addWall = [SKAction sequence:@[add, wait]];
        [self runAction:[SKAction repeatActionForever:addWall]withKey:ACTION_ADDWALL];
    }
    else if(self.IsgameStart)
    {
        [self.bird runAction:self.moveHeadAction withKey:ACTION_HEADMOVE];
        self.bird.physicsBody.velocity = CGVectorMake(0, 400);
        //[self runAction:[SKAction playSoundFileNamed:@"sfx_wing.caf" waitForCompletion:YES]];
    }
}

-(void)update:(NSTimeInterval)currentTime
{
    __block int wallcount = 0;
    [self enumerateChildNodesWithName:NAME_WALL usingBlock:^(SKNode *node, BOOL *stop)
     {
         if(wallcount >= 2)
         {
             *stop = YES;
             return;
         }
         if(node.position.x < -WALL_WIDE / 2)
         {
             wallcount --;
             [node removeFromParent];
         }
     }];
    
    [self enumerateChildNodesWithName:NAME_BLANK usingBlock:^(SKNode *node, BOOL *stop)
     {
         if(node.position.x < -WALL_WIDE / 2)
         {
             [node removeFromParent];
             *stop = YES;
         }
     }];
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    if(self.IsgameOver)//别漏这一句
        return ;
    
    SKPhysicsBody *birdBody, *otherBody;
    
    birdBody = contact.bodyA.categoryBitMask == birdCategory ? contact.bodyA : contact.bodyB;
    otherBody = contact.bodyA.categoryBitMask == birdCategory ? contact.bodyB : contact.bodyA;
    
    if(birdBody.categoryBitMask & birdCategory && otherBody.categoryBitMask & blankCategory)
    {
        self.num ++;
        self.score.text = [NSString stringWithFormat:@"%d", self.num];
        //[self runAction:[SKAction playSoundFileNamed:@"sfx_point.caf" waitForCompletion:YES]];
    }
    else
    {
        [self.scene addChild:self.writeWorld];
        [self.writeWorld runAction:[SKAction waitForDuration:2]];
        [self.writeWorld removeFromParent];
        [self.worldNode runAction:self.worldshake];
        [self gameOver];
        //[self runAction:[SKAction playSoundFileNamed:@"sfx_hit.caf" waitForCompletion:YES]];
    }
}

#pragma -- mark－－－－游戏结束－－－－
-(void)gameOver
{
    self.IsgameStart = NO;
    self.IsgameOver = YES;
    [self enumerateChildNodesWithName:NAME_BLANK usingBlock:^(SKNode *node, BOOL *stop)
    {
        [node removeActionForKey:ACTION_WALLMOVE];
    }];
    
    [self enumerateChildNodesWithName:NAME_WALL usingBlock:^(SKNode *node, BOOL *stop)
     {
         [node removeActionForKey:ACTION_WALLMOVE];
     }];
    
    [self enumerateChildNodesWithName:NAME_GROUND usingBlock:^(SKNode *node, BOOL *stop)
     {
         [node removeActionForKey:ACTION_GROUND];
     }];
    
    
    [self removeActionForKey:ACTION_ADDWALL];
    [self.bird removeAllActions];
    if(self.num > self.bestnum)
        self.bestnum = self.num;
    
    buttonDown *restartView = [buttonDown initWithSize:self.size];
    restartView.delegate = self;
    [restartView setNum:self.num withBest:self.bestnum];
    restartView.zPosition = ZPOSTTION_RESTART;
    [restartView showInScene:self];
}

-(void)restart
{
    self.userInteractionEnabled = NO;
    
    self.IsgameOver = NO;
    self.IsgameStart = NO;
    
    [self enumerateChildNodesWithName:NAME_BLANK usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    
    [self enumerateChildNodesWithName:NAME_WALL usingBlock:^(SKNode *node, BOOL *stop)
     {
         [node removeFromParent];
     }];
    
    [self enumerateChildNodesWithName:NAME_BIRD usingBlock:^(SKNode *node, BOOL *stop)
     {
         [node removeFromParent];
     }];
    
    [self addBirdNode];
    [self initStartNode];
    [self.ground runAction:self.moveGround withKey:ACTION_GROUND];
    self.score.text = @"0";
    self.num = 0;
    
    [self runAction:self.clickBegin];
}

//协议函数
- (void)restartView:(buttonDown *)buttonDown
{
   // [buttonDown dispeal];
    [self restart];
}


@end
