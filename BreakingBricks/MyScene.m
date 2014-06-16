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
        
        // add physics body to scene to serve as an invisible boundary
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        // change gravity settings of the physics world
        // default of simulated earth gravity of 9.82ms^2
        // modified to the moon of 1.6ms^2 by pull down on y-axis
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        
        // create new sprite node from image
        SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
        
        // create a CGPoint for sprite position grabbing size parameter
        CGPoint myPoint = CGPointMake(size.width/2, size.height/2);
        ball.position = myPoint;
        
        // add physics body to ball object before add to scene
        // convenience method adds to Physics Body Property of Node
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
