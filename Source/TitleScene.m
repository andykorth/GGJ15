#import "TitleScene.h"
#import "CCScene+Private.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation TitleScene
{

    float _noInputTimer;
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
    
    _winner.visible = false;
    _noInputTimer = 0.0f;
    
    for (CCNode *n in [self.children copy]) {
        [n setParent:_contentNode];
    }
    [self addChild:viewport];
}

-(void) winnerMessage:(NSString*) winText
{
    _winner.visible = true;
    _winner.string = winText;
    
    _anyKey.string = @"Press any key to play again!";
    _winner.visible = true;
    
    _noInputTimer = 3.0f;
}

- (void)keyDown:(NSEvent *)theEvent
{
    
}

-(void)update:(CCTime)delta
{
    _noInputTimer -= delta;
}

- (void)keyUp:(NSEvent *)theEvent
{
    if(_noInputTimer > 0.0f){
        return;
    }
    
    // load scene
    [self.director presentScene:(CCScene*)[CCBReader load:@"MainScene"] withTransition:[CCTransition transitionCrossFadeWithDuration:0.3f]];
}

@end
