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
    if(_keyDowns[@(13)]){ //w
        GLKVector4 v = GLKMatrix4MultiplyVector4(self.nodeToParentMatrix, GLKVector4Make(1, 0, 0, 0));
        self.physicsBody.velocity = ccp(-v.x * 40.0f, -v.y * 40.0f);
    }
    if(_keyDowns[@(0)]){ //a
        self.rotation = self.rotation += delta * -200.0f;
    }
    if(_keyDowns[@(1)]){ //s
        // air brake?
    }
    if(_keyDowns[@(2)]){ //d
        self.rotation = self.rotation += delta * 200.0f;
    }
    
}

@end
