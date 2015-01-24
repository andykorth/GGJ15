
#import "cocos2d.h"

@class MainScene;

@interface PlayerPlane : CCSprite

@property(nonatomic) NSMutableDictionary *keyDowns;

@property(nonatomic) int playerNumber;
@property(nonatomic, weak) MainScene *mainScene;



@end
