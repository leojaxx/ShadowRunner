//
//  GameOverScene.m
//  ShadowRunner
//
//  Created by Leonard Jackson on 2016-10-26.
//  Copyright © 2016 Leonard Jackson. All rights reserved.
//

#import "GameOverScene.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        [self setBackground];
        
    }
    
    return self;
}

-(void)setBackground {
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"game-over-background"];
    background.anchorPoint = CGPointZero;
    background.position = CGPointMake(self.size.width / 100, self.size.height / 100);
    background.name = @"background";
    
    [self addChild:background];
}

@end
