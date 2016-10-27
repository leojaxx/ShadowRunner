//
//  GameViewController.m
//  ShadowRunner
//
//  Created by Leonard Jackson on 2016-10-26.
//  Copyright © 2016 Leonard Jackson. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SKView* skView = (SKView *)self.view;
    
    if (!skView.scene) {
        // Load the SKScene from 'GameScene.sks'
        // GameScene *scene = (GameScene *)[SKScene nodeWithFileNamed:@"GameScene"];
        SKScene *scene = [GameScene sceneWithSize:skView.bounds.size];
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene
        [skView presentScene:scene];
    }

    
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
