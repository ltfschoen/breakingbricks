//
//  WinScene.m
//  BreakingBricks
//
//  Created by Luke on 17/06/2014.
//  Copyright (c) 2014 Ceenos. All rights reserved.
//

#import "WinScene.h"
#import "MyScene.h"

@implementation WinScene

-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor greenColor];
        
        // play game over sound
        SKAction *playSoundEnd = [SKAction playSoundFileNamed:@"youwin.caf" waitForCompletion:NO];
        [self runAction:playSoundEnd];
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        label.text = @"YOU WON!!!";
        label.fontColor = [SKColor purpleColor];
        label.fontSize = 60;
        label.color = [SKColor blackColor];
        label.colorBlendFactor = 0.7;
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        
        SKLabelNode *shadow = [[SKLabelNode alloc] init];
        shadow.text = @"YOU WON!!!";
        shadow.fontColor = [SKColor redColor];
        shadow.fontSize = 60;
        shadow.blendMode = SKBlendModeAlpha;
        [shadow setAlpha:0.7];
        shadow.position = CGPointMake(CGRectGetMidX(self.frame) + 2, CGRectGetMidY(self.frame) - 4);
        shadow.zPosition = -1;
        
        [self addChild:shadow];
        
        [self addChild:label];
        
        // second label
        SKLabelNode *tryAgain = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        tryAgain.text = @"Tap to Play Again";
        tryAgain.fontColor = [SKColor whiteColor];
        tryAgain.fontSize = 24;
        tryAgain.position = CGPointMake(size.width/2, 0);
        
        SKAction *moveLabel = [SKAction moveToY:(size.height/2 - 40) duration:2.0];
        [tryAgain runAction:moveLabel]; // tell the label to run the action
        
        [self addChild:tryAgain];
    }
    return self;
}

// method to respond to touches on this scene
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // instantiate object of first scene and imported, of current size
    MyScene *firstScene = [MyScene sceneWithSize:self.size];
    [self.view presentScene:firstScene transition:[SKTransition doorwayWithDuration:2.0]];
    
}

@end
