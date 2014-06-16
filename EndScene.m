//
//  EndScene.m
//  BreakingBricks
//
//  Created by Luke on 16/06/2014.
//  Copyright (c) 2014 Ceenos. All rights reserved.
//

#import "EndScene.h"
#import "MyScene.h"

@implementation EndScene

-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor blackColor];
        
        // play game over sound
        SKAction *playSoundEnd = [SKAction playSoundFileNamed:@"gameover.caf" waitForCompletion:NO];
        [self runAction:playSoundEnd];
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        label.text = @"GAME OVER!";
        label.fontColor = [SKColor whiteColor];
        label.fontSize = 50;
        label.color = [SKColor redColor];
        label.colorBlendFactor = 0.5;
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        
        SKLabelNode *shadow = [[SKLabelNode alloc] init];
        shadow.text = @"GAME OVER";
        shadow.fontColor = [SKColor redColor];
        shadow.fontSize = 50;
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
        tryAgain.position = CGPointMake(size.width/2, size.height/2 - 40);
        
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
