#import "Bullet.h"

@implementation Bullet

-(id)initWithGroup:(id)group;
{
    if((self = [super init])){
        CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:2.0 andCenter:CGPointZero];
        body.collisionGroup = group;
        body.collisionType = @"bullet";
    }
    
    return self;
}

-(void)onEnter
{
    [super onEnter];
    [self scheduleBlock:^(CCTimer *timer){[self destroy];} delay:0.2];
}

-(void)destroy
{
	[self removeFromParent];
}


@end
