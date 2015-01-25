#import "MainScene.h"
#import "CCScene+Private.h"

#import "Bullet.h"
#import "Bomb.h"

#import "StatusNode.h"
#import "CCParticleSystemBase.h"

@implementation MainScene
{
    // HUD elements
    CCLabelTTF *_player1Label;
    CCLabelTTF *_player2Label;

    int _player1Score;
    int _player2Score;
    
}

enum Z_ORDER {
    Z_BG,
    Z_BG_EFFECTS,
    Z_PLAYER,
    Z_EFFECTS,
    Z_HUD,
};

- (void) didLoadFromCCB
{
    self.director = [CCDirector currentDirector];
    CGRect viewBounds = self.director.view.bounds;
    self.contentSize = viewBounds.size;
    self.contentSizeType = CCSizeTypePoints;
    
    float w = viewBounds.size.width;
    float h = viewBounds.size.height;
    
    [self setUserInteractionEnabled:true];
    _title.string = @"";

//    _physicsNode.debugDraw = YES;
    _physicsNode.collisionDelegate = self;
    
//    _gradient.visible = false;
    _gradient.zOrder = Z_BG;
    
    [self spawnPlayers];

    _player1Status = (StatusNode *)[CCBReader load:@"StatusNode"];
    [_physicsNode addChild:_player1Status];
    
    _player2Status = (StatusNode *)[CCBReader load:@"StatusNode"];
    [_physicsNode addChild:_player2Status];
    
    CCNode *airship = (CCSprite *)[CCBReader load:@"airship"];
    airship.position = ccp(w/2.0f, h/2.0f);
    airship.scale = 3.0f;
    [_physicsNode addChild:airship];
    
    {
    
        CCPhysicsBody *body = [CCPhysicsBody bodyWithShapes:@[
            [CCPhysicsShape pillShapeFrom:ccp(0,  0) to:ccp(0, h) cornerRadius:6.0f],
            [CCPhysicsShape pillShapeFrom:ccp(0,  0) to:ccp(w, 0) cornerRadius:6.0f],
            [CCPhysicsShape pillShapeFrom:ccp(w,  0) to:ccp(w, h) cornerRadius:6.0f],
            [CCPhysicsShape pillShapeFrom:ccp(0,  h) to:ccp(w, h) cornerRadius:6.0f],
            [CCPhysicsShape pillShapeFrom:ccp(0, 100) to:ccp(100, 0) cornerRadius:6.0f],
            [CCPhysicsShape pillShapeFrom:ccp(w, 100) to:ccp(w - 100, 0) cornerRadius:6.0f],
        ]];
        body.collisionType = @"wall";
        
        body.type = CCPhysicsBodyTypeStatic;
        CCNode * bounds = [CCNode node];
        bounds.physicsBody = body;

        [_physicsNode addChild:bounds];
    }
    
    CCNode *hud = [CCBReader load:@"HUD" owner:self];
    [self addChild:hud z:Z_HUD];
    
}

-(void) spawnPlayers
{
    float w = self.director.view.bounds.size.width;
    if(_player1) [_player1 removeFromParentAndCleanup:true];
    
    _player1 = (PlayerPlane *)[CCBReader load:@"RedPlane"];
    _player1.position = ccp(w - 150, 500);
    _player1.playerNumber = 0;
    _player1.scale = 0.5f;
    _player1.mainScene = self;
    [_physicsNode addChild:_player1 z:Z_PLAYER];
    
    if(_player2) [_player2 removeFromParentAndCleanup:true];

    _player2 = (PlayerPlane *)[CCBReader load:@"BluePlane"];
    _player2.position = ccp(150, 500);
    _player2.playerNumber = 1;
    _player2.scale = 0.5f;
    _player2.mainScene = self;
    [_physicsNode addChild:_player2 z:Z_PLAYER];
}

-(void) updateScores
{
    _player1Label.string = [NSString stringWithFormat:@"Player 1: %d", _player1Score];
    _player2Label.string = [NSString stringWithFormat:@"Player 2: %d", _player2Score];
}

-(void)setWeaponBar:(float) alpha forPlayer:(int) player
{
    StatusNode * bar = player == 0 ? _player1Status : _player2Status;
    [bar setWeaponBarAmount:alpha];
}

-(void)setHealthBar:(float) alpha forPlayer:(int) player
{
    StatusNode * bar = player == 0 ? _player1Status : _player2Status;
    [bar setHealthBarAmount:alpha];
}


-(void)onEnter
{
    [super onEnter];
    
    self.scene.scheduler.fixedUpdateInterval = 1.0/240.0;
}

-(void)update:(CCTime)delta
{
    _player1Status.position = _player1.position;
    _player2Status.position = _player2.position;
}

- (void)keyDown:(NSEvent *)theEvent
{
    
}

- (void)keyUp:(NSEvent *)theEvent
{
    if(theEvent.keyCode == 48){
        _physicsNode.debugDraw = !_physicsNode.debugDraw;
    }
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair wall:(CCNode *)wall bullet:(Bullet *)bullet
{
    // TODO this is using duck typing...
    [bullet destroy];
    
    return false;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair player:(PlayerPlane *)player bullet:(Bullet *)bullet
{
    NSLog(@"hit!");
    
    CCNode* explosion = [CCBReader load:@"Particles/BombExplosion"];
    explosion.position = bullet.position;
    [_physicsNode addChild:explosion z:Z_EFFECTS];
    
    [self scheduleBlock:^(CCTimer *timer) {
        [explosion removeFromParent];
    } delay:3.0];
    
    player.health -= 0.2f;
    
    if(player.health < 0.0f && !player.dead)
    {
        [player die];
        CCNode* smoke = [CCBReader load:@"Particles/PersistingSmoke"];
//        CCParticleSystemBase *particles = (CCParticleSystemBase*) smoke.children[0];
//        particles.particlePositionType = CCParticleSystemPositionTypeFree;
//        smoke.position = bullet.position;
        [player.parent addChild:smoke z:Z_BG_EFFECTS];
        
        CCAction * a = [CCActionFollow actionWithTarget:player];
        [smoke runAction:a];
        
        [self scheduleBlock:^(CCTimer *timer) {
            CCNode* playerBoom = [CCBReader load:@"Particles/ShipExplosion"];
            playerBoom.position = player.position;
            [_physicsNode addChild:playerBoom z:Z_EFFECTS];
            [player removeFromParent];
            [smoke removeFromParent];
            
            [self scheduleBlock:^(CCTimer *timer) {
                [playerBoom removeFromParent];
                [self spawnPlayers];
            } delay:2.0];
        } delay:1.0];
        
        if(player == _player1) _player2Score += 1;
        if(player == _player2) _player1Score += 1;
        [self updateScores];
        
    }
    
    [bullet destroy];

    return true;
}

@end
