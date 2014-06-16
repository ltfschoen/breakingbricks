//
//  EndScene.m
//  BreakingBricks
//
//  Created by Luke on 16/06/2014.
//  Copyright (c) 2014 Ceenos. All rights reserved.
//

#import "EndScene.h"

@implementation EndScene

-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor blackColor];
        
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
    }
    return self;
}

@end
