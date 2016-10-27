//
//  GameScene.m
//  ShadowRunner
//
//  Created by Leonard Jackson on 2016-10-26.
//  Copyright © 2016 Leonard Jackson. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "GameScene.h"
#import "GameOverScene.h"

static const float BACKGROUND_POINTS_PER_SEC = 5;
static const float FOREGROUND_POINTS_PER_SEC = 100;
static const float MONSTER_POINTS_PER_SEC = 125;

@implementation GameScene

static inline CGPoint CGPointMultiplyScalar(const CGPoint A, const CGFloat B) {
    
    return CGPointMake(A.x * B, A.y * B);
}

static inline CGPoint CGPointAdd(const CGPoint A, const CGPoint B) {
    return CGPointMake(A.x + B.x, A.y + B.y);
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        isDamaged = NO;
        speed = 25;
        
        [self animateRunner];
        [self setImages];
        [self setActions];
    }
    
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    if (lastUpdatedTime) {
        dt = currentTime - lastUpdatedTime;
    } else {
        dt = 0;
    }
    
    lastUpdatedTime = currentTime;
    
    [self moveBackground];
    [self moveForeground];
    [self moveMonster];
}

-(void)moveBackground {
    [self enumerateChildNodesWithName:@"background" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *background = (SKSpriteNode *) node;
        CGPoint backgroundVelocity = CGPointMake(((-1) * BACKGROUND_POINTS_PER_SEC), 0);
        CGPoint amountToMove = CGPointMultiplyScalar(backgroundVelocity, dt);
        background.position = CGPointAdd(background.position, amountToMove);
        
        if (background.position.x <= -background.size.width) {
            background.position = CGPointMake(background.position.x + background.size.width * 2, background.position.y);
        }
        
    }];
}

-(void)moveForeground {
    [self enumerateChildNodesWithName:@"foreground" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *foreground = (SKSpriteNode *) node;
        CGPoint backgroundVelocity = CGPointMake((-1) * FOREGROUND_POINTS_PER_SEC, 0);
        CGPoint amountToMove = CGPointMultiplyScalar(backgroundVelocity, dt);
        foreground.position = CGPointAdd(foreground.position, amountToMove);
        
        if (foreground.position.x <= -foreground.size.width) {
            foreground.position = CGPointMake(foreground.position.x + foreground.size.width * 2, foreground.position.y);
        }
    }];
}

-(void)moveMonster {
    SKNode* runningMan = [self childNodeWithName:@"shadowRunner"];
    
    [self enumerateChildNodesWithName:@"monster" usingBlock:^(SKNode *node, BOOL *stop) {
        // animate monster and remove it when it leaves the scene
        if (node.position.x < 0 || node.position.y < 0) {
            [node removeFromParent];
        } else {
            node.position = CGPointMake(node.position.x - speed, node.position.y);
        }
        
        // detect colision of monster and Shadow Runner
        if ([runningMan intersectsNode:node] && isDamaged == NO) {
            [self damage:runningMan];
            NSLog(@"Damaged");
        }
    }];
}

-(void)damage:(SKNode*) runningMan {
    isDamaged = YES;
    hits++;
    SKAction* push = [SKAction moveByX:-35 y:0 duration:0.2];
    [runningMan runAction:push];
    
    SKAction *hitIndicator = [SKAction sequence:@[
                                                  [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.3],
                                                  [SKAction colorizeWithColorBlendFactor:0.0 duration:0.3],
                                                  [SKAction performSelector:@selector(damaged) onTarget:self]
                                                  ]];
    [runningMan runAction:hitIndicator];
}

-(void)damaged {
    isDamaged = NO;
    if (hits == 3) {
        [self gameOver];
    }
}

-(void)gameOver {
    SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
    [self.view presentScene:gameOverScene transition:doors];
}

-(void)animateRunner {
    NSMutableArray *runningFrames = [NSMutableArray array];
    SKTextureAtlas *runnerAnimatedAtlas = [SKTextureAtlas atlasNamed:@"runnerImages"];
    
    NSUInteger numOfImages = runnerAnimatedAtlas.textureNames.count;
    
    for (int i = 1; i <= numOfImages / 2; i++) {
        NSString *nameOfTexture = [NSString stringWithFormat:@"RunningMan%d", i];
        SKTexture *temp = [runnerAnimatedAtlas textureNamed:nameOfTexture];
        
        [runningFrames addObject:temp];
    }
    
    runningManFrames = runningFrames;
}

-(void)setImages {
    [self setBackground];
    [self setForeground];
    [self addRunner];
    [self performSelector:@selector(addMonster) withObject:nil afterDelay:1.5];
    
}

-(void)setBackground {
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"backgroundOne"];
        background.anchorPoint = CGPointZero;
        background.position = CGPointMake(i * background.size.width, 0);
        background.name = @"background";
        
        [self addChild:background];
    }
}

-(void)setForeground {
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *foreground = [SKSpriteNode spriteNodeWithImageNamed:@"backgroundTwo"];
        foreground.anchorPoint = CGPointZero;
        foreground.position = CGPointMake(i * foreground.size.width, 0);
        foreground.name = @"foreground";
        
        [self addChild:foreground];
    }
}

-(void)addRunner {
    SKTexture *temp = runningManFrames[0];
    runner = [SKSpriteNode spriteNodeWithTexture:temp];
    runner.position = CGPointMake(self.size.width / 8, 70);
    runner.name = @"shadowRunner";
    [self addChild:runner];
    [self runningMan];
}

-(void)runningMan {
    [runner runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures:runningManFrames
                                       timePerFrame:0.2f
                                       resize: NO
                                       restore:YES]] withKey:@"theShaddowRunner"];
}

-(void)addMonster {
    CGPoint startingPoint = CGPointMake(568, 50);
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    monster.position = CGPointMake(startingPoint.x, startingPoint.y);
    monster.zPosition = 1;
    monster.name = @"monster";
    
    [self addChild:monster];
    
    float randomNum = arc4random_uniform(1) + 2;
    [self performSelector:@selector(addMonster) withObject:nil afterDelay:randomNum];
}

-(void)setActions {
    NSMutableArray *jumpingFrames = [NSMutableArray array];
    SKTextureAtlas *jumpingAnimatedAtlas = [SKTextureAtlas atlasNamed:@"jumpingImages"];
    
    NSUInteger numOfImages = jumpingAnimatedAtlas.textureNames.count;
    for (int i = 1; i <= numOfImages / 2; i++) {
        NSString *nameOfTexture = [NSString stringWithFormat:@"ManJumping%d", i];
        SKTexture *temp = [jumpingAnimatedAtlas textureNamed:nameOfTexture];
        
        [jumpingFrames addObject:temp];
        
    }
    
    SKAction* atlasAnimation = [SKAction animateWithTextures:jumpingFrames timePerFrame:0.1];
    jumpAnimation = [SKAction sequence:@[atlasAnimation]];
    
    SKAction* jumpUp = [SKAction moveByX:0 y:90 duration:0.3];
    SKAction* jumpUpTwo = [SKAction moveByX:0 y:35 duration:0.3];
    SKAction* jumpDown = [SKAction moveByX:0 y:-125 duration:0.4];
    SKAction* done = [SKAction performSelector:@selector(jumpDone) onTarget:self];
    jumpMovement = [SKAction sequence:@[jumpUp, jumpUpTwo, jumpDown, done]];
}

-(void)jumpDone {
    isJumping = NO;
    NSLog(@"Finished");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isJumping == NO) {
        isJumping = YES;
        SKSpriteNode* runningMan = (SKSpriteNode*)[self childNodeWithName:@"shadowRunner"];
        [runningMan runAction:jumpAnimation];
        [runningMan runAction:jumpMovement];
    }
}

@end























