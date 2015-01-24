#import "PlayerPlane.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation PlayerPlane{

}


- (void) didLoadFromCCB
{
    _keyDowns = [NSMutableDictionary dictionary];
    
    self.userInteractionEnabled= true;
    self.physicsBody.allowsRotation = false;
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
    cpVect drag = cpv(0.95, 0.2);
    velocity.x *= pow(drag.x, delta);
    velocity.y *= pow(drag.y, delta);
    
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
    
    // Plane turns better the faster you are going.
    cpFloat controlCoefficient = fmax(fabs(velocity.x/maxForwardSpeed), 0.25);
    
    cpFloat rotationSpeed = maxRotationSpeed*rotation*controlCoefficient;
    body.absoluteRadians += rotationSpeed*delta;
}

@end
