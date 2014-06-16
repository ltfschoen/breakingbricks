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

@property (nonatomic, strong) SKAction *playSFXPaddle;
@property (nonatomic, strong) SKAction *playSFXBrick;

@end

// define categories to be constant and static across the scene class
// unsigned integers. only allowed 32 categories in Sprite Kit
//static const uint32_t ballCategory      = 1; // 00000000000000000000000000000001
//static const uint32_t brickCategory     = 2; // 00000000000000000000000000000010
//static const uint32_t paddleCategory    = 4; // 00000000000000000000000000000100
//static const uint32_t edgeCategory      = 8; // 00000000000000000000000000001000

// safer to use bitwise operators. takes flipped bits and moves to the left
static const uint32_t ballCategory      = 0x1;      // 00000000000000000000000000000001
static const uint32_t brickCategory    = 0x1 << 1; // 00000000000000000000000000000010
static const uint32_t paddleCategory    = 0x1 << 2; // 00000000000000000000000000000100
static const uint32_t edgeCategory      = 0x1 << 3; // 00000000000000000000000000001000

@implementation MyScene

// delegate method code of SKPhysicsContactDelegate
// Physics World object calls this method whenever two objects detected as having contacted.
// only if valid contact Bitmask defined for these objects (otherwise this method not called)
// parameter called 'contact' passed into this method, which contains references to both
// Physics Bodies that just touched
-(void)didBeginContact:(SKPhysicsContact *)contact {
    //NSLog(@"boing!");
    
    // to work we inform the delegating object that is going on in the background
    // that it should look to this didBeginContact method to handle this
    // the delegating object that can let us know about these contacts
    // is the Physics World object in our Scene. so added line of code to initWithSize
    
    // create placeholder reference for non-ball object using the value of its constant
    SKPhysicsBody *notTheBall;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        notTheBall = contact.bodyB;
    } else {
        notTheBall = contact.bodyA;
    }
    
    if (notTheBall.categoryBitMask == brickCategory) {
        NSLog(@"It's a brick!");
        
        [self runAction:self.playSFXBrick];
        
        [notTheBall.node removeFromParent];
    }
    
    if (notTheBall.categoryBitMask == paddleCategory) {
        //NSLog(@"Play boing sound!");
        
        // tell the scene to play the sound action
        [self runAction:self.playSFXPaddle];
    }
    
}



- (void)addBall:(CGSize)size {
    // create new sprite node from image
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    
    // create a CGPoint for sprite position grabbing size parameter
    CGPoint myPoint = CGPointMake(size.width/2, size.height/2);
    ball.position = myPoint;
    
    // add physics body to ball object before add to scene
    // convenience method adds to Physics Body Property of Node
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
    
    // modify physics body friction Settings
    ball.physicsBody.friction = 0;
    ball.physicsBody.linearDamping = 0; // 0.1 by default
    ball.physicsBody.restitution = 1.0f;
    
    // add physics body to category
    ball.physicsBody.categoryBitMask = ballCategory; // currently in
    
    // add a different physics body 'brick' to contact test bitmask
    ball.physicsBody.contactTestBitMask = brickCategory | paddleCategory; // want to be notified when current category touches this other category. using a logical OR (so it flips if either of the categories contacted)
    ball.physicsBody.collisionBitMask = edgeCategory | brickCategory | paddleCategory; // collide only with these
    
    // add sprite node to scene
    NSLog(@"%@", ball);
    [self addChild:ball];
    
    // create and define vector as separate variable
    // apply vector impulse to node ball object
    CGVector myVector = CGVectorMake(5, 5); // simple C Struct so no pointer for variable name required with two floats converted to a Vector value at 45 degrees of a magnitude
    [ball.physicsBody applyImpulse:myVector];
}

-(void)addBricks:(CGSize) size {
    // loop to create 4 OFF bricks
    for (int i = 0; i < 4; i++) {
        // instantiate a new Sprite Node object
        SKSpriteNode *brick = [SKSpriteNode spriteNodeWithImageNamed:@"brick"];
        
        // add Static Volume-based Physics Body to attach it to Physics World
        // configure Static so it does not move around
        brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
        brick.physicsBody.dynamic = NO;
        
        // add physics body to category
        brick.physicsBody.categoryBitMask = brickCategory;
        
        // set position of brick sprites evenly aligned across the top of the scene
        // for 4 OFF centred lines
        int xPos = size.width/5 * (i+1); // divide with of screen by 5
        int yPos = size.height - 50; // same y-position
        brick.position = CGPointMake(xPos, yPos);
        
        // add brick sprite to the scene
        [self addChild:brick];
    }
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

// use self. for paddle as its @property is defined
-(void)addPlayer:(CGSize)size {
    // create a new sprite node named paddle (auto applies retina)
    self.paddle = [SKSpriteNode spriteNodeWithImageNamed:@"paddle"];
    
    // position it by grab size parameter
    self.paddle.position = CGPointMake(size.width/2, 100);
    
    // add a volume-based physics body taking up space on the scene
    self.paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.paddle.frame.size];
    
    // make it static (change from default dynamic) so it does not move
    self.paddle.physicsBody.dynamic = NO;
    
    // add physics body to category
    self.paddle.physicsBody.categoryBitMask = paddleCategory;
    
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
        
        
        // add physics body to category
        self.physicsBody.categoryBitMask = edgeCategory;
        
        // change gravity settings of the physics world
        // default of simulated earth gravity of 9.82ms^2
        // modified to the moon of 1.6ms^2 by pull down on y-axis
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        // tell delegating object of Physics World to look back into this same class for the
        // methods didBeginContact or didEndContact
        self.physicsWorld.contactDelegate = self;
        
        // call addBall method to create, configure, and add the ball object to the scene
        [self addBall:size];
        
        // call addPlayer method to create, configure, and add the player object to the scene
        [self addPlayer:size];
        
        // call addBricks method to create, configure, and add the bricks objects to the scene
        [self addBricks:size];
        
        // create the action object and wait for another node in the game to run it (as the action may animate or change the colour of the node)
        self.playSFXPaddle = [[SKAction alloc] init];
        self.playSFXBrick = [[SKAction alloc] init];
        self.playSFXPaddle = [SKAction playSoundFileNamed:@"blip.caf" waitForCompletion:NO];
        self.playSFXBrick = [SKAction playSoundFileNamed:@"brickhit.caf" waitForCompletion:NO];
    }
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
