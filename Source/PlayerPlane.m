#import "PlayerPlane.h"

@implementation PlayerPlane




- (void) didLoadFromCCB
{
    self.userInteractionEnabled= true;
    self.physicsBody.allowsRotation = false;
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSLog(@"Key down: %@", theEvent);
}

- (void)keyUp:(NSEvent *)theEvent
{
    GLKVector4 v = GLKMatrix4MultiplyVector4(self.nodeToParentMatrix, GLKVector4Make(1, 0, 0, 0));
    
    self.physicsBody.velocity = ccp(-v.x * 40.0f, -v.y * 40.0f);
}

- (void) update:(CCTime)delta
{
    
    
}

@end
