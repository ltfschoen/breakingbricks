//
//  MyScene.m
//  BreakingBricks
//
//  Created by Luke on 16/06/2014.
//  Copyright (c) 2014 Ceenos. All rights reserved.
//

#import "MyScene.h"

// add wider reference to access addPlayer for when react later to touches
// with a Class Extension to the implementation and property added

@interface MyScene ()

@property (nonatomic, strong) SKSpriteNode *paddle;

@end

@implementation MyScene

- (void)addBall:(CGSize)size {
    // create new sprite node from image
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    
    // create a CGPoint for sprite position grabbing size parameter
    CGPoint myPoint = CGPointMake(size.width/2, size.height/2);
    ball.position = myPoint;
    
    // add physics body to ball object before add to scene
    // convenience method adds to Physics Body Property of Node
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
    
    // modify friction Settings
    ball.physicsBody.friction = 0;
    ball.physicsBody.linearDamping = 0; // 0.1 by default
    ball.physicsBody.restitution = 1.0f;
    
    // add sprite node to scene
    NSLog(@"%@", ball);
    [self addChild:ball];
    
    // create and define vector as separate variable
    // apply vector impulse to node ball object
    CGVector myVector = CGVectorMake(5, 5); // simple C Struct so no pointer for variable name required with two floats converted to a Vector value at 45 degrees of a magnitude
    [ball.physicsBody applyImpulse:myVector];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        // get a specific touch location and details of it
        // coordination system orientation we are interested in
        // is the touch point on the Scene (hence we use 'self')
        // to refer to the Current Scene with (0,0) point at bottom left
        CGPoint location = [touch locationInNode:self];
        
        // create a new CGPoint object to set the new position
        // grab the x position of the touch location
        // use same value for y position so it paddle object stays constrained
        CGPoint newPosition = CGPointMake(location.x, 100);
        
        // stop paddle from going too far with constraints before setting paddle
        // condition of half width of paddle (100/2=50)
        if (newPosition.x < self.paddle.size.width / 2) {
            newPosition.x = self.paddle.size.width / 2;
        }
        // condition of width of screen minus half width of paddle (320-(100/2)=270)
        if (newPosition.x > self.size.width - (self.paddle.size.width / 2)) {
            newPosition.x = self.size.width - (self.paddle.size.width / 2);
        }
        
        // change the position of the paddle object to new position
        self.paddle.position = newPosition;
    }
}

-(void)addPlayer:(CGSize)size {
    // create a new sprite node named paddle (auto applies retina)
    self.paddle = [SKSpriteNode spriteNodeWithImageNamed:@"paddle"];
    
    // position it by grab size parameter
    self.paddle.position = CGPointMake(size.width/2, 100);
    
    // add a volume-based physics body taking up space on the scene
    self.paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.paddle.frame.size];
    
    // make it static (change from default dynamic) so it does not move
    self.paddle.physicsBody.dynamic = NO;
    
    // add paddle property to the scene to make it visible
    [self addChild:self.paddle];
    
}


// scene initialiser and setting properties
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
        
        // call addBall method to create, configure, and add the ball object to the scene
        [self addBall:size];
        
        // call addPlayer method to create, configure, and add the player object to the scene
        [self addPlayer:size];
        
    }
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
