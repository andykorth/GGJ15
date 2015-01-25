#import "CCPhysics+ObjectiveChipmunk.h"
#import "MainScene.h"
#import "PlayerPlane.h"

#import "Bullet.h"
#import "Bomb.h"
#import "CCEffectLineFactory.h"
#import "CCEffectLine.h"

@implementation PlayerPlane{
 
    NSNumber *_thrustKey;
    NSNumber *_reverseKey;
    NSNumber *_leftKey;
    NSNumber *_rightKey;
    NSNumber *_fire1;
    NSNumber *_fire2;

    float _shootTimer;
    float _shootCostPerGun;
    float _shootCostPerBomb;
    float _shootChargeRate;
    
    CCTimer *_bulletTimer;
    CCTimer *_bombTimer;
    
    float _thrust;
    float _turn;
    
    CCSpriteFrame *_topFrame;
    CCSpriteFrame *_sideFrame;
    
    CCSprite *_topSprite;
    
    CCSprite *_flame;

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
    
    self.physicsBody.body.moment *= 3.0f;
    
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
            @"widthMode"          : @(CCEffectLineWidthSimple),
            @"widthStart"         : @(5),
            @"widthEnd"           : @(30),
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
            @"life"               : @(0.5f),
            @"autoRemove"         : @(YES),
            @"smooth"             : @(YES),
            @"speedMultiplyer"    : @(0.50f),
            @"granularity"        : @(1.0f),
            @"drawLineStart"      : @(NO),
            @"drawLineEnd"        : @(NO),
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
    
    [self cancelBullets];
    [self cancelBombs];
    [_trail removeFromParent];
}

static NSString const * PLAYER1_GROUP = @"Player1Group";
static NSString const * PLAYER2_GROUP = @"Player2Group";

-(void)setPlayerNumber:(int)playerNumber
{
    _playerNumber = playerNumber;
    
    _sideFrame = self.spriteFrame;
    NSString* top = _playerNumber == 1 ? @"Art/Plane2BLUE-TOP.psd" : @"Art/RedPlaneTop.psd";
    _topFrame = ((CCSprite*)[CCSprite spriteWithImageNamed:top]).spriteFrame;
    
    
    if(_playerNumber == 0){
        _reverseKey = @1;
        _thrustKey = @13;
        _leftKey = @0;
        _rightKey = @2;
        _fire1 = @38;
        _fire2 = @40;
    } else {
        _reverseKey = @125;
        _thrustKey = @126;
        _leftKey = @123;
        _rightKey = @124;
        _fire1 = @83;
        _fire2 = @84;
    }
    
    self.physicsBody.collisionGroup = (playerNumber == 0 ? PLAYER1_GROUP : PLAYER2_GROUP);
}

- (void)keyDown:(NSEvent *)theEvent
{
    if(theEvent.isARepeat) return;
    
//    NSLog(@"Key down: %@", theEvent);
    NSNumber *keyCode = @(theEvent.keyCode);
    
    _keyDowns[keyCode] = @(true);
    
    if([keyCode isEqualTo:_fire1]){
        _bulletTimer = [self scheduleBlock:^(CCTimer *timer) {
            if(_shootTimer <= _shootCostPerGun){
                return;
            }
            _shootTimer -= _shootCostPerGun;
            
            
            [[OALSimpleAudio sharedInstance] playEffect:@"GunPow.wav" volume:0.25 pitch:CCRANDOM_0_1() * 0.2f + 0.9f pan:0.0 loop:NO];
            
            
            Bullet *bullet = (Bullet*) [CCBReader load:self.playerNumber == 0 ? @"RedBullet" : @"BlueBullet"];
            [bullet setup:self];
            [self.parent addChild:bullet];
            
            //recoil
            CCPhysicsBody *body = self.physicsBody;
            [body applyImpulse:cpTransformVect(body.body.transform, cpv(-400, 0.0))];
            
            [timer repeatOnceWithInterval:0.1];
        } delay:0];
    }
    
    if([keyCode isEqualTo:_fire2]){
        _bombTimer = [self scheduleBlock:^(CCTimer *timer) {
            
            if(_shootTimer <= _shootCostPerBomb || _dead){
                return;
            }
            NSArray *ar = @[@"BombDrop1.wav",@"BombDrop2.wav",@"BombDrop3.wav"];
            
            [[OALSimpleAudio sharedInstance] playEffect:ar[(int)(CCRANDOM_0_1() * 3)] volume:0.25 pitch:1.0f pan:0.0 loop:NO];
            
            _shootTimer -= _shootCostPerBomb;
            
            Bomb *bomb = (Bomb*) [CCBReader load:self.playerNumber == 0 ? @"RedBomb" : @"BlueBomb"];
            [bomb setup:self];

            [self.parent addChild:bomb];
            [timer repeatOnceWithInterval:0.1];
        } delay:0];
    }
}

-(void) shoot
{
    if(_dead) return;
    
    if(_shootTimer <= _shootCostPerGun){
        return;
    }
    _shootTimer -= _shootCostPerGun;
    Bullet *bullet = (Bullet*) [CCBReader load:self.playerNumber == 0 ? @"RedBullet" : @"BlueBullet"];
    [bullet setup:self];
    [self.parent addChild:bullet];
}

- (void)keyUp:(NSEvent *)theEvent
{
    NSNumber *keyCode = @(theEvent.keyCode);
    
    [_keyDowns removeObjectForKey:keyCode];
    
    if([keyCode isEqualTo:_fire1]){
        [self cancelBullets];
    } else if([keyCode isEqualTo:_fire2]){
        [self cancelBombs];
    }
}

-(void)cancelBullets
{
    [_bulletTimer invalidate];
    _bulletTimer = nil;
}

-(void)cancelBombs
{
    [_bombTimer invalidate];
    _bombTimer = nil;
}

-(void) takeDamage:(float) dmg
{
    self.health -= dmg;
    if(self.health <= 0.0f && !self.dead)
    {
        [self die];
        [_mainScene playerDied:self];
        
        CCNode* smoke = [CCBReader load:@"Particles/PersistingSmoke"];
        //        CCParticleSystemBase *particles = (CCParticleSystemBase*) smoke.children[0];
        //        particles.particlePositionType = CCParticleSystemPositionTypeFree;
        //        smoke.position = bullet.position;
        [_mainScene addChild:smoke z:Z_BG_EFFECTS];
        
        CCAction * a = [CCActionFollow actionWithTarget:self];
        [smoke runAction:a];
        
        [self scheduleBlock:^(CCTimer *timer) {
            __block CCNode* playerBoom = [CCBReader load:@"Particles/ShipExplosion"];
            [[OALSimpleAudio sharedInstance] playEffect:@"explode.wav" volume:0.25 pitch:1.0f pan:0.0 loop:NO];

            playerBoom.position = self.position;
            [_mainScene.physicsNode addChild:playerBoom z:Z_EFFECTS];
            [smoke removeFromParent];
            
            // need to retain these for the block since self gets removed from parent.
            __block MainScene* blockScene = _mainScene;
            
            [_mainScene scheduleBlock:^(CCTimer *timer) {
                [[OALSimpleAudio sharedInstance] playEffect:@"levelup.wav" volume:0.35 pitch:1.0f pan:0.0 loop:NO];
            } delay:1.0f];
            
            [_mainScene scheduleBlock:^(CCTimer *timer) {
                [playerBoom removeFromParent];
                [blockScene spawnPlayers];
            } delay:2.0];
            
            [self removeFromParent];
            
        } delay:1.0];
        
        
        
    }
}

-(void) die
{
    _dead = true;
    [self cancelBombs];
    [self cancelBullets];
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
    
    if(_dead){
        turn = -1.0f;//= fmod(self.scene.scheduler.currentTime, 1.0f) > 0.5 ? 1.0 : -1.0;
        _thrust = 1.0;
    }
    
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
    
    const cpFloat forwardAcceleration = 1000.0;
    const cpFloat maxForwardSpeed = 550.0;
    
    // Maximum rotation speed when traveling at the maximum speed.
    const cpFloat maxRotationSpeed = 5.0;
    
    // Offset in points of the center of drag relative to the center of gravity.
    const cpFloat codOffset = 5.0;
    
    const cpVect linearDrag = cpv(0.95, 0.1);
    const float airBrakeDrag = 0.15f;
    
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
    
    if(_dead || _keyDowns[_thrustKey]){
        // Apply simple forward acceleration.
        velocity.x = cpflerpconst(velocity.x, maxForwardSpeed, forwardAcceleration*delta);
        _flame.scale = 2.5f + 0.5f * sinf(self.scene.scheduler.currentTime * 40.0f);
    }else{
        _flame.scale = 0.8f + 0.3f * sinf(self.scene.scheduler.currentTime * 40.0f);
    }
    if(!_dead && _keyDowns[_reverseKey] && velocity.x > 0.0){
        // air brake!
        velocity.x *= pow(airBrakeDrag, delta);
    }
    
    self.physicsBody.velocity = cpTransformVect(transform, velocity);
    
    // Now handle the rotational velocity.
    // This gets pretty hairy to make it "Feel right".
    cpFloat angularVelocity = body.angularVelocity;
    
    // Plane turns better the faster you are going.
    cpFloat controlCoefficient = fmax(fabs(velocity.x/maxForwardSpeed), 0.4);
    cpFloat controlRotation = maxRotationSpeed*_turn*controlCoefficient;
    
    // Rotation due to the movement of the center of drag.
    cpFloat dragRotation = (1.0 - _thrust)*velocity.y/codOffset;
    
    // andy disabled this:
    dragRotation = angularVelocity * 0.95;
    
    body.angularVelocity = cpflerp(
        dragRotation,
//        cpflerp(dragRotation, angularVelocity, pow(0.8, delta)),
        controlRotation,
        fabs(_turn)
    );
    
    // necessary?
    self.rotation = fmod((float) self.rotation + 360.0f, 360.0f);
    
    // TODO: extra crappy. Should animate.
    float foo = MIN(abs(self.rotation - 90.0), abs(self.rotation - 270.0))/30.0;
    if(foo < 1.0){
        self.opacity = 0.0;
        _topSprite.visible = true;
        _topSprite.scaleY = cpflerp(1.0, 0.4, foo);
//        NSLog(@"%@, %@", NSStringFromPoint(self.anchorPoint), NSStringFromPoint(self.anchorPointInPoints));
    }else{
        self.opacity = 1.0;
        _topSprite.visible = false;
    }
    
    self.flipY = (self.rotation > 90.0 && self.rotation < 270.0);
    
}

-(void)update:(CCTime)delta
{
    [_trail add:self.position timestamp:self.scene.scheduler.currentTime];
}

@end
