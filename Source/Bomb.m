#import "Bomb.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Bomb

-(id)initWithGroup:(id)group;
{
    if((self = [super init])){
        CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:5.0 andCenter:CGPointZero];
        body.collisionGroup = group;
        body.collisionType = @"bullet";
        
        self.physicsBody = body;
    }
    
    return self;
}

-(void)onEnter
{
    [super onEnter];
    [self scheduleBlock:^(CCTimer *timer){[self destroy];} delay:5.0];
}

-(void)fixedUpdate:(CCTime)delta
{
    CCPhysicsBody *body = self.physicsBody;
    
    body.velocity = cpvmult(body.velocity, pow(0.75, delta));
}

-(void)destroy
{
	[self removeFromParent];
}


@end
