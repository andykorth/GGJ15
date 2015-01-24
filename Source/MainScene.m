#import "MainScene.h"

@implementation MainScene



- (void) didLoadFromCCB
{
    
    [self setUserInteractionEnabled:true];
    _title.string = @"No key";

    _physicsNode.debugDraw = YES;
    _gradient.visible = false;
    
    _player1 = (PlayerPlane *)[CCBReader load:@"Plane"];
    _player1.position = ccp(30, 30);
    [_physicsNode addChild:_player1];
    
    {
        float w = 1000;
        float h = 800;
    CCPhysicsBody *body = [CCPhysicsBody bodyWithShapes:
    @[
        [CCPhysicsShape pillShapeFrom:ccp(0,  0) to:ccp(0, h) cornerRadius:1.0f],
        [CCPhysicsShape pillShapeFrom:ccp(0,  0) to:ccp(w, 0) cornerRadius:1.0f],
        [CCPhysicsShape pillShapeFrom:ccp(w,  0) to:ccp(w, h) cornerRadius:1.0f],
        [CCPhysicsShape pillShapeFrom:ccp(0,  h) to:ccp(w, h) cornerRadius:1.0f],
    ]];
    body.type = CCPhysicsBodyTypeStatic;
    CCNode * bounds = [CCNode node];
    bounds.physicsBody = body;
    
    [_physicsNode addChild:bounds];
    }
    
    
}


-(void)update:(CCTime)delta
{
    
}

- (void)keyDown:(NSEvent *)theEvent
{
    _title.string = [NSString stringWithFormat:@"KeyDown: %@", theEvent.characters];
}

- (void)keyUp:(NSEvent *)theEvent
{
    _title.string = [NSString stringWithFormat:@"KeyUp: %@", theEvent.characters];
}

@end
