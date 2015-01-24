#import "PlayerPlane.h"

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
    NSLog(@"Key down: %@", theEvent);
    _keyDowns[@(theEvent.keyCode)] = @(true);
}

- (void)keyUp:(NSEvent *)theEvent
{
    [_keyDowns removeObjectForKey:@(theEvent.keyCode)];
}

- (void) update:(CCTime)delta
{
    if(_keyDowns[_playerNumber == 0 ? @(13) : @(126)]){ //w
        GLKVector4 v = GLKMatrix4MultiplyVector4(self.nodeToParentMatrix, GLKVector4Make(1, 0, 0, 0));
        self.physicsBody.velocity = ccp(-v.x * 40.0f, -v.y * 40.0f);
    }
    if(_keyDowns[_playerNumber == 0 ? @(0) : @(123)]){ //a
        self.rotation = self.rotation += delta * -200.0f;
    }
    if(_keyDowns[_playerNumber == 0 ? @(1) : @(125)]){ //s
        // air brake?
    }
    if(_keyDowns[_playerNumber == 0 ? @(2) : @(124)]){ //d
        self.rotation = self.rotation += delta * 200.0f;
    }
    
}

@end
