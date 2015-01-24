#import "Bullet.h"

@implementation Bullet

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
    [self scheduleBlock:^(CCTimer *timer){[self destroy];} delay:1.0];
}

-(void)destroy
{
	[self removeFromParent];
}


@end
