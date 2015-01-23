#import "MainScene.h"

@implementation MainScene

- (void) didLoadFromCCB
{
    [self setUserInteractionEnabled:true];
    _title.string = @"No key";
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
