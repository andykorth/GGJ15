#import "PlayerPlane.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation PlayerPlane{

}


- (void) didLoadFromCCB
{
    _keyDowns = [NSMutableDictionary dictionary];
    
    self.userInteractionEnabled= true;
//    self.physicsBody.allowsRotation = false;
}

- (void)keyDown:(NSEvent *)theEvent
{
//    NSLog(@"Key down: %@", theEvent);
    _keyDowns[@(theEvent.keyCode)] = @(true);
}

- (void)keyUp:(NSEvent *)theEvent
{
    [_keyDowns removeObjectForKey:@(theEvent.keyCode)];
}

- (void) update:(CCTime)delta
{
    const cpFloat forwardAcceleration = 600.0;
    const cpFloat maxForwardSpeed = 400.0;
    
    // Maximum rotation speed when traveling at the maximum speed.
    const cpFloat maxRotationSpeed = 5.0;
    
    // Offset in points of the center of drag relative to the center of gravity.
    const cpFloat codOffset = 5.0;
    
    const cpVect linearDrag = cpv(0.95, 0.1);
    
    CCPhysicsBody *body = self.physicsBody;
    cpTransform transform = body.body.transform;
//        cpVect forward = cpv(-transform.a, -transform.b);
//        cpVect up = cpv(transform.c, transform.d);
    
    // Stupid hack to flip the transform since the ship points against the x-axis.
    transform.a = -transform.a;
    transform.b = -transform.b;
    
    // Get the local velocity. (+x is forward, +y is up)
    cpVect velocity = cpTransformVect(cpTransformInverse(transform), body.velocity);
    
    // Apply small amount of forward drag, lots of lateral drag.
    velocity.x *= pow(linearDrag.x, delta);
    velocity.y *= pow(linearDrag.y, delta);
    
    if(_keyDowns[_playerNumber == 0 ? @(13) : @(126)]){ //w
        // Apply simple forward acceleration.
        velocity.x = cpflerpconst(velocity.x, maxForwardSpeed, forwardAcceleration*delta);
        
    }
//    if(_keyDowns[_playerNumber == 0 ? @(1) : @(125)]){ //s
//        // air brake?
//    }
    
    self.physicsBody.velocity = cpTransformVect(transform, velocity);
    
    // Direction of rotation to apply to the player.
    cpFloat rotation = 0.0;
    
    if(_keyDowns[_playerNumber == 0 ? @(0) : @(123)]){ //a
        rotation += 1.0;
    }
    if(_keyDowns[_playerNumber == 0 ? @(2) : @(124)]){ //d
        rotation -= 1.0;
    }
    
    // Now handle the rotational velocity.
    cpFloat angularVelocity = body.angularVelocity;
    
    // Plane turns better the faster you are going.
    cpFloat controlCoefficient = fmax(fabs(velocity.x/maxForwardSpeed), 0.1);
    cpFloat controlRotation = maxRotationSpeed*rotation*controlCoefficient;
    
    // Rotation due to the movement of the center of drag.
    cpFloat dragRotation = -velocity.y/codOffset;
    
    cpFloat targetAngularVelocity = cpflerp(dragRotation, controlRotation, fabs(rotation));
    body.angularVelocity = cpflerp(
        cpflerp(dragRotation, angularVelocity, pow(0.8, delta)),
        controlRotation,
        fabs(rotation)
    );
}

@end
