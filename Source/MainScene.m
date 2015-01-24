#import "MainScene.h"
#import "CCScene+Private.h"

@implementation MainScene
{
    // HUD elements
    CCLabelTTF *_player1Label;
    CCLabelTTF *_player2Label;
    CCNode *_shieldBar;
    CCNode *_weaponBar;
}


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

    _physicsNode.debugDraw = YES;
//    _gradient.visible = false;
    _gradient.zOrder = -10;
    
    _player1 = (PlayerPlane *)[CCBReader load:@"Plane"];
    _player1.position = ccp(500, 500);
    _player1.playerNumber = 0;
    _player1.scale = 2.0f;
    [_physicsNode addChild:_player1];

    _player2 = (PlayerPlane *)[CCBReader load:@"Plane"];
    _player2.position = ccp(100, 500);
    _player2.playerNumber = 1;
    _player2.scale = 2.0f;
    [_physicsNode addChild:_player2];

    {
    
        CCPhysicsBody *body = [CCPhysicsBody bodyWithShapes:@[
            [CCPhysicsShape pillShapeFrom:ccp(0,  0) to:ccp(0, h) cornerRadius:6.0f],
            [CCPhysicsShape pillShapeFrom:ccp(0,  0) to:ccp(w, 0) cornerRadius:6.0f],
            [CCPhysicsShape pillShapeFrom:ccp(w,  0) to:ccp(w, h) cornerRadius:6.0f],
            [CCPhysicsShape pillShapeFrom:ccp(0,  h) to:ccp(w, h) cornerRadius:6.0f],
        ]];
        
        body.type = CCPhysicsBodyTypeStatic;
        CCNode * bounds = [CCNode node];
        bounds.physicsBody = body;

        [_physicsNode addChild:bounds];
    }
    
    CCNode *hud = [CCBReader load:@"HUD" owner:self];
    [self addChild:hud z:Z_HUD];
    
}


static const float MinBarWidth = 5.0;

-(void)onEnter
{
    [super onEnter];
    
    self.scene.scheduler.fixedUpdateInterval = 1.0/240.0;
}

-(void)update:(CCTime)delta
{
    
}

- (void)keyDown:(NSEvent *)theEvent
{
    
}

- (void)keyUp:(NSEvent *)theEvent
{
    
}

@end
