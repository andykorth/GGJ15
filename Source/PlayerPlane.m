#import "CCPhysics+ObjectiveChipmunk.h"
#import "MainScene.h"
#import "PlayerPlane.h"

#import "Bullet.h"
#import "Bomb.h"

@implementation PlayerPlane{
    NSNumber *_thrustKey;
    NSNumber *_leftKey;
    NSNumber *_rightKey;
    NSNumber *_fire1;
    NSNumber *_fire2;

    float _shootTimer;
    float _shootCostPerGun;
    float _shootCostPerBomb;
    float _shootChargeRate;
    
    CCTimer *_bombTimer;
}


- (void) didLoadFromCCB
{
    _keyDowns = [NSMutableDictionary dictionary];
    
    _shootTimer = 1.0f;
    _shootChargeRate = 0.2f;
    _shootCostPerGun = 0.1f;
    _shootCostPerBomb = 0.2f;
    
    self.physicsBody.friction = 0.0;
    self.physicsBody.collisionGroup = self;
    
    self.userInteractionEnabled= true;
}

-(void)onExit
{
    [super onExit];
    [self cancelBombs];
}

-(void)setPlayerNumber:(int)playerNumber
{
    _playerNumber = playerNumber;
    
    if(_playerNumber == 0){
        _thrustKey = @13;
        _leftKey = @0;
        _rightKey = @2;
        _fire1 = @38;
        _fire2 = @40;
    } else {
        _thrustKey = @126;
        _leftKey = @123;
        _rightKey = @124;
        _fire1 = @83;
        _fire2 = @84;
    }
}

- (void)keyDown:(NSEvent *)theEvent
{
    if(theEvent.isARepeat) return;
    
//    NSLog(@"Key down: %@", theEvent);
    NSNumber *keyCode = @(theEvent.keyCode);
    
    _keyDowns[keyCode] = @(true);
    
    if([keyCode isEqualTo:_fire1]){
        [self shoot];
    }
    
    if([keyCode isEqualTo:_fire2]){
        _bombTimer = [self scheduleBlock:^(CCTimer *timer) {
            
            if(_shootTimer <= _shootCostPerGun){
                return;
            }
            _shootTimer -= _shootCostPerGun;
            
            Bomb *bomb = [[Bomb alloc] initWithGroup:self];
            bomb.position = self.position;
            
            bomb.physicsBody.velocity = self.physicsBody.velocity;
            [self.parent addChild:bomb];
        } delay:0];
        
        _bombTimer.repeatCount = 5;
        _bombTimer.repeatInterval = 0.05;
    }
}

-(void) shoot
{
    if(_shootTimer <= _shootCostPerGun){
        return;
    }
    _shootTimer -= _shootCostPerGun;
    Bullet *bullet = [[Bullet alloc] initWithGroup:self];
    bullet.position = self.position;
    
    cpVect baseVelocity = self.physicsBody.velocity;
    cpVect muzzleVelocity = cpTransformVect(self.physicsBody.body.transform, cpv(600.0, 0.0));
    bullet.physicsBody.velocity = cpvadd(baseVelocity, muzzleVelocity);
    [self.parent addChild:bullet];
}

- (void)keyUp:(NSEvent *)theEvent
{
    NSNumber *keyCode = @(theEvent.keyCode);
    
    [_keyDowns removeObjectForKey:keyCode];
    
    if([keyCode isEqualTo:_fire2]){
        [self cancelBombs];
    }
}

-(void)cancelBombs
{
    [_bombTimer invalidate];
    _bombTimer = nil;
}

-(void) updateShootBar
{
    [_mainScene setWeaponBar:_shootTimer forPlayer:_playerNumber];
}

- (void) fixedUpdate:(CCTime)delta
{
    _shootTimer = MIN(1.0f, _shootTimer + delta * _shootChargeRate);
    [self updateShootBar];
    
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
    
    // Get the local velocity. (+x is forward, +y is up)
    cpVect velocity = cpTransformVect(cpTransformInverse(transform), body.velocity);
    
    // Apply small amount of forward drag, lots of lateral drag.
    velocity.x *= pow(linearDrag.x, delta);
    velocity.y *= pow(linearDrag.y, delta);
    
    if(_keyDowns[_thrustKey]){
        // Apply simple forward acceleration.
        velocity.x = cpflerpconst(velocity.x, maxForwardSpeed, forwardAcceleration*delta);
        
    }
//    if(_keyDowns[_playerNumber == 0 ? @(1) : @(125)]){ //s
//        // air brake?
//    }
    
    self.physicsBody.velocity = cpTransformVect(transform, velocity);
    
    // Direction of rotation to apply to the player.
    cpFloat rotation = 0.0;
    
    if(_keyDowns[_leftKey]){ //a
        rotation += 1.0;
    }
    if(_keyDowns[_rightKey]){ //d
        rotation -= 1.0;
    }
    
    // Now handle the rotational velocity.
    cpFloat angularVelocity = body.angularVelocity;
    
    // Plane turns better the faster you are going.
    cpFloat controlCoefficient = fmax(fabs(velocity.x/maxForwardSpeed), 0.1);
    cpFloat controlRotation = maxRotationSpeed*rotation*controlCoefficient;
    
    // Rotation due to the movement of the center of drag.
    cpFloat dragRotation = velocity.y/codOffset;
    
    cpFloat targetAngularVelocity = cpflerp(dragRotation, controlRotation, fabs(rotation));
    body.angularVelocity = cpflerp(
        cpflerp(dragRotation, angularVelocity, pow(0.8, delta)),
        controlRotation,
        fabs(rotation)
    );
}


@end
