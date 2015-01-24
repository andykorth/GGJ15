#import "cocos2d.h"

@interface StatusNode : CCNode

@property(nonatomic) CCNode * weaponBar;
@property(nonatomic) CCNode * healthBar;

-(void)setWeaponBarAmount:(float) alpha;
-(void)setHealthBarAmount:(float) alpha;


@end
