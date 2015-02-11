#import "GameOverScene.h"
#import "CCScene+Private.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation GameOverScene
{
    CCLabelTTF *_anyKey;
    
    CCNode *_contentNode;
}

- (void) didLoadFromCCB
{
    // TODO: essentially a cocos2d bug
    self.director = [CCDirector currentDirector];
    self.userInteractionEnabled = true;
    
    CGSize _designSize = CGSizeMake(1280.0f, 720.0f);
    
    CCViewportNode * viewport = [CCViewportNode scaleToFit:_designSize];
    _contentNode = viewport.contentNode;
    _contentNode.contentSize = _designSize;
    
    for (CCNode *n in [self.children copy]) {
        [n setParent:_contentNode];
    }
    [self addChild:viewport];
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
