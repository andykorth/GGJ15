#import "Bomb.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "PlayerPlane.h"
#import "MainScene.h"

@implementation Bomb

-(void)onEnter
{
    [super onEnter];
    [self scheduleBlock:^(CCTimer *timer){[self destroy];} delay:5.0];
}

-(void) setup:(PlayerPlane *)plane
{
    self.physicsBody.collisionGroup = plane.physicsBody.collisionGroup;
    self.physicsBody.collisionType = @"bullet";
    self.physicsBody.allowsRotation = false;

    self.position = plane.position;
    self.rotation = fmod(plane.rotation + 360.0f, 360.0f);
    self.scale = 1.0f;
    
    // boost it out the back of the plane:
    self.physicsBody.velocity = ccpAdd(plane.physicsBody.velocity, cpTransformVect(plane.physicsBody.body.transform, cpv(-200.0, 0.0)));
}

-(void)fixedUpdate:(CCTime)delta
{
    CCPhysicsBody *body = self.physicsBody;
    
    body.velocity = cpvmult(body.velocity, pow(0.75, delta));
    
    // rotate down
    self.rotation = cpflerp(self.rotation, 90.0f, delta * 2.5f); // should go coujnterclickwise too.
    
    CCPhysicsNode *physics = body.physicsNode;
    
    [physics pointQueryAt:body.absolutePosition within:40.0 block:^(CCPhysicsShape *shape, CGPoint nearest, CGFloat distance) {
        CCNode *node = shape.node;
        if(shape.collisionGroup != body.collisionGroup && [node isKindOfClass:[PlayerPlane class]]){
            NSLog(@"Bomb hit player");
            [((PlayerPlane *)node) takeDamage:0.2];
            [self destroy];
        }
    }];
}

-(void)destroy
{
    [(MainScene *)self.scene addExplosionAt:self.physicsBody];
	[self removeFromParent];
}


@end
