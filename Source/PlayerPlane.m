#import "CCPhysics+ObjectiveChipmunk.h"
#import "MainScene.h"
#import "PlayerPlane.h"

#import "Bullet.h"
#import "Bomb.h"
#import "CCEffectLineFactory.h"
#import "CCEffectLine.h"

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
    
    float _thrust;
    float _turn;
    
    CCEffectLine *_trail;
}


- (void) didLoadFromCCB
{
    _keyDowns = [NSMutableDictionary dictionary];
    
    _shootTimer = 1.0f;
    _shootChargeRate = 0.3f;
    _shootCostPerGun = 0.1f;
    _shootCostPerBomb = 0.1f;
    
    _health = 1.0f;
    
    self.physicsBody.friction = 0.0;
    self.physicsBody.collisionGroup = self;
    
    self.userInteractionEnabled= true;
}

-(void)onEnter
{
    [super onEnter];
    
    // TODO this is a terrible hack
    [self scheduleBlock:^(CCTimer *timer) {
        _trail = [CCEffectLine lineWithDictionary:@{
            @"name"               : @"Free Hand Drawing",
            @"image"              : @"effects.png",
            @"lineMode"           : @(CCEffectLineModePointToPoint),
            @"widthMode"          : @(CCEffectLineWidthSpeed),
            @"widthStart"         : @(2.0),
            @"widthEnd"           : @(50.0),
            // textures used
            @"textureCount"       : @(8),
            @"textureIndex"       : @(2),
            @"textureList"        : @[],
            @"textureMix"         : @(CCEffectLineTextureSimple),
            @"textureAnimation"   : @(CCEffectLineAnimationScroll),
            @"textureScroll"      : @(0.00f),
            @"textureMixTime"     : @(1.00f),
            @"textureScale"       : @(1.0),
            // texture mixing
            @"life"               : @(1.0f),
            @"autoRemove"         : @(YES),
            @"smooth"             : @(YES),
            @"speedMultiplyer"    : @(0.50f),
            @"granularity"        : @(1.0f),
            @"drawLineStart"      : @(YES),
            @"drawLineEnd"        : @(YES),
            @"wind"               : @"{0, 0}",
            @"gravity"            : @"{0, 0}",
            @"colorStart"         : @"{1.0, 1.0, 0.3, 1.0}",
            @"colorEnd"           : @"{0.5, 0.5, 0.0, 0.0}",
       }];
        
        [_trail start:self.position timestamp:self.scene.scheduler.currentTime];
        
        [self.parent addChild:_trail];
    } delay:0.0];
}

-(void)onExit
{
    [super onExit];
    
    [self cancelBombs];
    [_trail removeFromParent];
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
            
            if(_shootTimer <= _shootCostPerBomb){
                return;
            }
            _shootTimer -= _shootCostPerBomb;
            
            Bomb *bomb = (Bomb*)  [CCBReader load:self.playerNumber == 0 ? @"RedBomb" : @"BlueBomb"];
            [bomb setup:self];

            [self.parent addChild:bomb];
            [timer repeatOnceWithInterval:0.1];
        } delay:0];
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

-(void)updateInput:(CCTime)delta
{
    const float thrustInterval = 0.25;
    const float turnInterval = 0.25;
    
    // Update input values.
    _thrust = cpflerpconst(_thrust, _keyDowns[_thrustKey] ? 1.0 : 0.0, delta/thrustInterval);
    
    cpFloat turn = 0.0;
    if(_keyDowns[_leftKey]) turn += 1.0;
    if(_keyDowns[_rightKey]) turn -= 1.0;
    
    _turn = cpflerpconst(_turn, turn, delta/turnInterval);
}

-(void) updateShootBar
{
    [_mainScene setWeaponBar:_shootTimer forPlayer:_playerNumber];
}

-(void) updateHealthBar
{
    [_mainScene setHealthBar:_health forPlayer:_playerNumber];
}

- (void) fixedUpdate:(CCTime)delta
{
    _shootTimer = MIN(1.0f, _shootTimer + delta * _shootChargeRate);
    [self updateShootBar];
    [self updateHealthBar];
    
    const cpFloat forwardAcceleration = 800.0;
    const cpFloat maxForwardSpeed = 800.0;
    
    // Maximum rotation speed when traveling at the maximum speed.
    const cpFloat maxRotationSpeed = 5.0;
    
    // Offset in points of the center of drag relative to the center of gravity.
    const cpFloat codOffset = 5.0;
    
    const cpVect linearDrag = cpv(0.95, 0.1);
    
    [self updateInput:delta];
    
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
    
    // Now handle the rotational velocity.
    // This gets pretty hairy to make it "Feel right".
    cpFloat angularVelocity = body.angularVelocity;
    
    // Plane turns better the faster you are going.
    cpFloat controlCoefficient = fmax(fabs(velocity.x/maxForwardSpeed), 0.4);
    cpFloat controlRotation = maxRotationSpeed*_turn*controlCoefficient;
    
    // Rotation due to the movement of the center of drag.
    cpFloat dragRotation = (1.0 - _thrust)*velocity.y/codOffset;
    
    body.angularVelocity = cpflerp(
        cpflerp(dragRotation, angularVelocity, pow(0.2, delta)),
        controlRotation,
        fabs(_turn)
    );
}

-(void)update:(CCTime)delta
{
    [_trail add:self.position timestamp:self.scene.scheduler.currentTime];
}

@end
