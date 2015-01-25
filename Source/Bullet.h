#import "cocos2d.h"

@class PlayerPlane;

@interface Bullet : CCSprite

-(void)setup:(PlayerPlane *)group;
-(void)destroy;

@end
