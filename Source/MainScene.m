#import "MainScene.h"
#import "CCScene+Private.h"
#import "CCPhysics+ObjectiveChipmunk.h"

#import "Bullet.h"
#import "Bomb.h"

#import "StatusNode.h"
#import "CCParticleSystemBase.h"

#import "CCController.h"

@implementation MainScene
{
    // HUD elements
    CCLabelTTF *_player1Label;
    CCLabelTTF *_player2Label;

    int _player1Score;
    int _player2Score;
    
    CCNode *_contentNode;
    CCNode *_camera;
    
    CGSize _designSize;
    
}

- (void) didLoadFromCCB
{
    self.director = [CCDirector currentDirector];
    self.contentSize = self.director.view.bounds.size;
    self.contentSizeType = CCSizeTypePoints;

    _designSize = CGSizeMake(1280.0f, 720.0f);
    float w = _designSize.width;
    float h = _designSize.height;

    CCViewportNode * viewport = [CCViewportNode scaleToFit:_designSize];
    _contentNode = viewport.contentNode;
    _contentNode.contentSize = _designSize;
    _camera = viewport.camera;
    

    
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
    [_contentNode addChild:hud z:Z_HUD];
    for (CCNode *n in [self.children copy]) {
        [n setParent:_contentNode];
    }
    [self addChild:viewport];
}

-(void) spawnPlayers
{
    // Set up controllers
    // This is kind of a dumb hack.
    NSArray *controllers = [CCController controllers];
    GCController *controller1 = (controllers.count >= 1 ? controllers[0] : nil);
    GCController *controller2 = (controllers.count >= 2 ? controllers[1] : nil);
    
    float w = _designSize.width;
    if(_player1) [_player1 removeFromParentAndCleanup:true];
    
    _player1 = (PlayerPlane *)[CCBReader load:@"RedPlane"];
    _player1.position = ccp(150, 500);
    _player1.playerNumber = 0;
    _player1.controller = controller1;
    _player1.scale = 0.3f;
    _player1.mainScene = self;
    [_physicsNode addChild:_player1 z:Z_PLAYER];
    
    _player1Status.visible = true;

    if(_player2) [_player2 removeFromParentAndCleanup:true];

    _player2 = (PlayerPlane *)[CCBReader load:@"BluePlane"];
    _player2.position = ccp(w - 150, 500);
    _player2.playerNumber = 1;
    _player2.controller = controller2;
    _player2.scale = 0.3f;
    _player2.mainScene = self;
    _player2.rotation = 180.0;
    [_physicsNode addChild:_player2 z:Z_PLAYER];
    
    _player2Status.visible = true;
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

-(void)addExplosionAt:(CCPhysicsBody *)body
{
    [[OALSimpleAudio sharedInstance] playEffect:@"explode.wav" volume:0.25 pitch:1.0f pan:0.0 loop:NO];

    CCNode* explosion = [CCBReader load:@"Particles/BombExplosion"];
    explosion.position = body.absolutePosition;
    [_physicsNode addChild:explosion z:Z_EFFECTS];
    
    [self scheduleBlock:^(CCTimer *timer) {
        [explosion removeFromParent];
    } delay:3.0];
}

// Quick and dirty way to disable bullet-bullet collisions without fiddling with filtering.
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)nodeA bullet:(CCNode *)nodeB
{
    return false;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair wall:(CCNode *)wall bullet:(Bullet *)bullet
{
    // TODO this is using duck typing...
    [bullet destroy];
    
    return false;
}

-(void) playerDied:(PlayerPlane *)player
{
    if(player == _player1){
        _player1Status.visible = false;
    }else{
        _player2Status.visible = false;
    }
    if(player == _player1) _player2Score += 1;
    if(player == _player2) _player1Score += 1;
    [self updateScores];
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair player:(PlayerPlane *)player bullet:(Bullet *)bullet
{
    NSLog(@"hit!");
    
    [self addExplosionAt:bullet.physicsBody];
    [player takeDamage:0.2f];
    
    [bullet destroy];

    return true;
}

@end
