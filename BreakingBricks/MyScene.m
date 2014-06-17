//
//  MyScene.m
//  BreakingBricks
//
//  Created by Luke on 16/06/2014.
//  Copyright (c) 2014 Ceenos. All rights reserved.
//

#import "MyScene.h"
#import "EndScene.h"

// add wider reference to access addPlayer for when react later to touches
// with a Class Extension to the implementation and property added

@interface MyScene ()

@property (nonatomic, strong) SKSpriteNode *paddle;
@property (nonatomic, strong) SKEmitterNode *paddleEngine; // allow reference throughout the scene

@property (nonatomic, strong) SKAction *playSFXPaddle;
@property (nonatomic, strong) SKAction *playSFXBrick;

@end

// define categories to be constant and static across the scene class
// unsigned integers. only allowed 32 categories in Sprite Kit
//static const uint32_t ballCategory      = 1; // 00000000000000000000000000000001
//static const uint32_t paddleCategory    = 2; // 00000000000000000000000000000010
//static const uint32_t brickCategory     = 4; // 00000000000000000000000000000100
//static const uint32_t edgeCategory      = 8; // 00000000000000000000000000001000

// safer to use bitwise operators. takes flipped bits and moves to the left
static const uint32_t ballCategory      = 0x1;      // 00000000000000000000000000000001
static const uint32_t paddleCategory    = 0x1 << 1; // 00000000000000000000000000000010
static const uint32_t brickCategory    = 0x1 << 2; // 00000000000000000000000000000100
static const uint32_t edgeCategory      = 0x1 << 3; // 00000000000000000000000000001000
static const uint32_t bottomEdgeCategory = 0x1 << 4;
static const uint32_t treeCategory      = 0x1 << 5;

BOOL touchingPaddle;

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
    
    // game over if paddle hits edge scene at bottom
    if (contact.bodyA.categoryBitMask == bottomEdgeCategory && contact.bodyB.categoryBitMask == paddleCategory) {
        NSLog(@"paddle hit bottom of screen, you die!");
            
        EndScene *end = [EndScene sceneWithSize:self.size];
            
        [self.view presentScene:end transition:[SKTransition fadeWithColor:[UIColor yellowColor] duration:1.0]];
    }
    if (contact.bodyA.categoryBitMask == paddleCategory && contact.bodyB.categoryBitMask == bottomEdgeCategory) {
        NSLog(@"paddle hit bottom of screen, you die!");
            
        EndScene *end = [EndScene sceneWithSize:self.size];
            
        [self.view presentScene:end transition:[SKTransition fadeWithColor:[UIColor blueColor] duration:1.0]];
    }
    
    
    // test to see if we are touching a brick
    if (notTheBall.categoryBitMask == brickCategory) {
        NSLog(@"It's a brick!");
        
        [self runAction:self.playSFXBrick];
        
        [notTheBall.node removeFromParent];
    }
    
    // test to see if we are touching a paddle
    if (notTheBall.categoryBitMask == paddleCategory) {
        //NSLog(@"Play boing sound!");
        
        // tell the scene to play the sound action
        [self runAction:self.playSFXPaddle];
    }
    
    // test to see if we are touching the bottom edge
    if (notTheBall.categoryBitMask == bottomEdgeCategory) {
        
        // create new instance of End Scene object
        // use convenience method that is available
        
        //EndScene *end = [[EndScene alloc] init];
        EndScene *end = [EndScene sceneWithSize:self.size];
        
        // tell containing SKView object to present the scene
        
        //[self.view presentScene:end];
        [self.view presentScene:end transition:[SKTransition fadeWithColor:[UIColor redColor] duration:1.0]];
        
    }
    
}

// method with size parameter to tell us the size of the scene when it is called
- (void)addBottomEdge:(CGSize)size {
    
    // add Edge-based Physics Body
    // instead of adding to an existing Node
    // (as we already have a Physics Body for the Scene)
    // and instead of adding a new Sprite or Label Node unnecessarily
    // create a Generic SKNode object
    // (will not have visible contents. acts as invisible container)
    // it also has a place for a Physics Body
    SKNode *bottomEdge = [SKNode node];
    bottomEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 1) toPoint:CGPointMake(size.width, 1)];
    bottomEdge.physicsBody.categoryBitMask = bottomEdgeCategory;
    [self addChild:bottomEdge];
    
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
    ball.physicsBody.contactTestBitMask = brickCategory | paddleCategory | bottomEdgeCategory; // want to be notified when current category touches this other category. using a logical OR (so it flips if either of the categories contacted)
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
    for (int i = 0; i < 3; i++) {
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
        int xPos = size.width/4 * (i+1); // divide with of screen by 5
        int yPos = size.height - 50; // same y-position
        brick.position = CGPointMake(xPos, yPos);
        
        // add brick sprite to the scene
        [self addChild:brick];
    }
    
    for (int i = 0; i < 3; i++) {
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
        int xPos = size.width/4 * (i+1); // divide with of screen by 5
        int yPos = size.height - 125; // same y-position
        brick.position = CGPointMake(xPos, yPos);
        
        // add brick sprite to the scene
        [self addChild:brick];
    }
    
    for (int i = 0; i < 3; i++) {
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
        int xPos = size.width/4 * (i+1); // divide with of screen by 5
        int yPos = size.height - 200; // same y-position
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
    self.paddle.position = CGPointMake(size.width/2, 150);
    
    // add a volume-based physics body taking up space on the scene
    self.paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.paddle.frame.size];
    
    // make it static (change from default dynamic) so it does not move
    self.paddle.physicsBody.dynamic = YES;
    
    // add physics body to category
    self.paddle.physicsBody.categoryBitMask = paddleCategory;
    
    // add a different physics body 'brick' to contact test bitmask
    self.paddle.physicsBody.contactTestBitMask = bottomEdgeCategory; // want to be notified when current category touches this other category. using a logical OR (so it flips if either of the categories contacted)
    
    // modify physics body friction Settings (specifically to react if paddle hits bottom edge
//    self.paddle.physicsBody.friction = 0.5;
//    self.paddle.physicsBody.linearDamping = 0.1; // 0.1 by default
//    self.paddle.physicsBody.restitution = 0.1f;
    
    self.paddle.physicsBody.collisionBitMask = edgeCategory | brickCategory | paddleCategory; // collide only with these (i.e. if ball is not mentioned then it would bounce when they collide)
    
    // add paddle property to the scene to make it visible
    [self addChild:self.paddle];
    
}

- (void)addPaddleEngine:(CGSize)size {
    // add particle emitter paddle engine
    // recreates the object with settings
    self.paddleEngine = [[SKEmitterNode alloc] init];
    
    self.paddleEngine = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"PaddleEngine" ofType:@"sks"]];
    
    // add the paddleEngine to Parent of paddle
    // set position relative to centrepoint of paddle
    // paddleEngine inherits settings (i.e. scales down)
    self.paddleEngine.position = CGPointMake(0, -10);
    self.paddleEngine.zPosition = 20;
}

- (void)addEmitterLukeSchoen:(CGSize)size {
    // unarchive SKS file into this object with all default settings
    SKEmitterNode *snow = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"luke_schoen" ofType:@"sks"]];
    
    // set its position at middle top of screen
    snow.position = CGPointMake(size.width/2, size.height);
    
    // advance the simulation of the particle effect
    // to appear as if has already been running for 10 seconds
    //[snow advanceSimulationTime:10];
    
    // add to scene
    [self addChild:snow];
}

- (void)playSFX {
    // create the action object and wait for another node in the game to run it (as the action may animate or change the colour of the node)
    self.playSFXPaddle = [[SKAction alloc] init];
    self.playSFXBrick = [[SKAction alloc] init];
    self.playSFXPaddle = [SKAction playSoundFileNamed:@"blip.caf" waitForCompletion:NO];
    self.playSFXBrick = [SKAction playSoundFileNamed:@"brickhit.caf" waitForCompletion:NO];
}

- (void)addInstructions:(CGSize)size {
    // instructions label
    SKLabelNode *instructionsLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
    instructionsLabel.text = @"Hold Paddle! Plant Tree Wins. Avoid bottom!";
    instructionsLabel.fontColor = [SKColor blueColor];
    instructionsLabel.fontSize = 13;
    instructionsLabel.position = CGPointMake(size.width/2, 0);
    
    SKAction *moveLabel = [SKAction moveToY:(size.height/2 - 40) duration:5.0];
    [instructionsLabel runAction:moveLabel]; // tell the label to run the action
    
    [self addChild:instructionsLabel];
}

- (void)addTree:(CGSize)size {
    // add bonus points platform
    SKSpriteNode *trunk = [SKSpriteNode spriteNodeWithColor:[SKColor brownColor] size:CGSizeMake(200, 10)];
    trunk.position = CGPointMake(size.width/2, size.height - size.height/30);
    // add a volume-based physics body taking up space on the scene
    trunk.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:trunk.frame.size];
    trunk.physicsBody.dynamic = YES;
    // add physics body to category
    trunk.physicsBody.categoryBitMask = treeCategory;
    
    trunk.physicsBody.contactTestBitMask = ballCategory; // want to be notified when current category touches this other category.
    
    trunk.physicsBody.collisionBitMask = edgeCategory | brickCategory | paddleCategory | ballCategory; // collide only with these (i.e. if ball is not mentioned then it would bounce when they collide)
    
    [self addChild:trunk];
    
    
    SKSpriteNode *leaves = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(35, 35)];
    leaves.position = CGPointMake(70, 0); // so appears right of trunk
    leaves.zPosition = 2; // so appears above log
    // add physics body to category
    leaves.physicsBody.dynamic = YES;
    leaves.physicsBody.categoryBitMask = treeCategory;
    
    // add leaves after trunk
    [trunk addChild:leaves];
}

// scene initialiser and setting properties
-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        touchingPaddle = NO;
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:0.8];
        
        // call snow emitter luke schoen method to create, configure, and add the snow emitter to the scene
        [self addEmitterLukeSchoen:size];
        
        // add physics body to scene to serve as an invisible boundary
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        // add physics body to category
        self.physicsBody.categoryBitMask = edgeCategory;
        
        // change gravity settings of the physics world
        // default of simulated earth gravity of 9.82ms^2
        // modified to the moon of 1.6ms^2 by pull down on y-axis
        self.physicsWorld.gravity = CGVectorMake(0, -0.02);
        
        // tell delegating object of Physics World to look back into this same class for the
        // methods didBeginContact or didEndContact
        self.physicsWorld.contactDelegate = self;
        
        // call addBall method to create, configure, and add the ball object to the scene
        [self addBall:size];
        
        // call addPlayer method to create, configure, and add the player object to the scene
        [self addPlayer:size];
        
        [self addPaddleEngine:size];
        
        // add paddleEngine after addPaddle
        [self.paddle addChild:self.paddleEngine];
        
        // call addBricks method to create, configure, and add the bricks objects to the scene
        [self addBricks:size];
        
        [self addTree:size];
        
        [self addBottomEdge:size];
        
        [self playSFX];
        
        [self addInstructions:size];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    touchingPaddle = YES; // boolean
    //self.paddleEngine.hidden = NO;
    self.paddleEngine.numParticlesToEmit = 0; // 0 is infinite particles
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touchingPaddle = NO;
    //self.paddleEngine.hidden = YES;
    self.paddleEngine.numParticlesToEmit = 100; // gradual instead of instant disappearance
    
    // reset paddle position when let go of touch
    CGPoint location = [self.paddle position];
    self.paddle.position = CGPointMake(location.x, 50);
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // apply upwards force
    if (touchingPaddle) {
        [self.paddle.physicsBody applyForce:CGVectorMake(0, 5)];
        CGPoint location = [self.paddle position];
        CGPoint aboveLocation = CGPointMake(location.x, 160);

        // applyImpulse or applyForce alternative
        //[self.paddle.physicsBody applyForce:CGVectorMake(0, -2)];
        
        // stop paddle impulsing too high. return back after each impulse
        if (aboveLocation.y == location.y) {
            NSLog(@"above threshold height");
            self.paddle.position = CGPointMake(location.x, 50);
            [self.paddle.physicsBody applyForce:CGVectorMake(0, -5)];
        }
    }
}

@end
