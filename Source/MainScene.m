#import "MainScene.h"
#import "CCScene+Private.h"

#import "Bullet.h"
#import "Bomb.h"

#import "StatusNode.h"

@implementation MainScene
{
    // HUD elements
    CCLabelTTF *_player1Label;
    CCLabelTTF *_player2Label;

}

#define Z_HUD 10
#define Z_EFFECTS 100

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
    _gradient.zOrder = -10;
    
    _player1 = (PlayerPlane *)[CCBReader load:@"Plane"];
    _player1.position = ccp(w - 150, 500);
    _player1.playerNumber = 0;
    _player1.scale = 2.0f;
    _player1.mainScene = self;
    [_physicsNode addChild:_player1];

    _player2 = (PlayerPlane *)[CCBReader load:@"Plane"];
    _player2.position = ccp(150, 500);
    _player2.playerNumber = 1;
    _player2.scale = 2.0f;
    _player2.mainScene = self;
    [_physicsNode addChild:_player2];

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


static const float MinBarWidth = 5.0;

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
    
    [bullet destroy];

    return true;
}

@end
