#import "TitleScene.h"
#import "CCScene+Private.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation TitleScene
{
    CCLabelTTF *_anyKey;
    
}

- (void) didLoadFromCCB
{
    // TODO: essentially a cocos2d bug
    self.director = [CCDirector currentDirector];
    self.userInteractionEnabled = true;
}

- (void)keyDown:(NSEvent *)theEvent
{
    
}

- (void)keyUp:(NSEvent *)theEvent
{
    // load scene
    [self.director presentScene:(CCScene*)[CCBReader load:@"MainScene"] withTransition:[CCTransition transitionCrossFadeWithDuration:0.3f]];
}

@end
