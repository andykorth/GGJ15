#import "MainScene.h"

@implementation MainScene

- (void) didLoadFromCCB
{
    [self setUserInteractionEnabled:true];
    _title.string = @"No key";
    
    _player1 = (PlayerPlane *)[CCBReader load:@"Plane"];
    _player1.position = ccp(0, 0);
    [self addChild:_player1];
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
