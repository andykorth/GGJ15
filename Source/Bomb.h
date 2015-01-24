#import "cocos2d.h"

@class PlayerPlane;

@interface Bomb : CCSprite

-(void) setup:(PlayerPlane *)plane;
-(void)destroy;

@end
