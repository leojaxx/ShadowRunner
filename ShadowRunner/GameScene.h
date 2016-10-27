//
//  GameScene.h
//  ShadowRunner
//
//  Created by Leonard Jackson on 2016-10-26.
//  Copyright © 2016 Leonard Jackson. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene {
    
    NSTimeInterval dt;
    NSTimeInterval lastUpdatedTime;
    
    SKSpriteNode *runner;
    NSArray *runningManFrames;
    
    bool isDamaged;
    bool isJumping;
    int speed;
    int hits;
    
    // actions
    SKAction *jumpMovement;
    SKAction *jumpAnimation;
}


@end
