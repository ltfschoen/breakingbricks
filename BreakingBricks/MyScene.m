//
//  MyScene.m
//  BreakingBricks
//
//  Created by Luke on 16/06/2014.
//  Copyright (c) 2014 Ceenos. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
    
        self.backgroundColor = [SKColor whiteColor];
        
        // create new sprite node from image
        SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
        
        // create a CGPoint for sprite position grabbing size parameter
        CGPoint myPoint = CGPointMake(size.width/2, size.height/2);
        ball.position = myPoint;
        
        // create SKPhysicsBody object before add to scene
        // use convenience method to add to Physics Body Property
        // of a specific Node
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
        
        // add sprite node to scene
        NSLog(@"%@", ball);
        [self addChild:ball];
        
    }
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
