#import "Bullet.h"
#import "PlayerPlane.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Bullet


-(void)setup:(PlayerPlane *)plane
{
    self.physicsBody.collisionGroup = plane;
    self.physicsBody.collisionType = @"bullet";
    
    self.physicsBody.allowsRotation = false;
    
    cpVect baseVelocity = plane.physicsBody.velocity;
    cpVect muzzleVelocity = cpTransformVect(plane.physicsBody.body.transform, cpv(600.0, 0.0));
    self.physicsBody.velocity = cpvadd(baseVelocity, muzzleVelocity);
    
    self.position = plane.position;
    self.rotation = plane.rotation;
    self.scale = 2.0f;
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
