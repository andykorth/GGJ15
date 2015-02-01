
#import "cocos2d.h"

@class MainScene;
@class GCController;

@interface PlayerPlane : CCSprite

@property(nonatomic) NSMutableDictionary *keyDowns;

@property(nonatomic) int playerNumber;
@property(nonatomic, retain) GCController *controller;
@property(nonatomic, weak) MainScene *mainScene;

@property(nonatomic) float health;

@property(nonatomic) bool dead;

-(void) die;
-(void) takeDamage:(float) dmg;

@end
