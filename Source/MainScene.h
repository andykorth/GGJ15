
#import "cocos2d.h"
#import "PlayerPlane.h"

@interface MainScene : CCScene

@property (nonatomic,strong) CCLabelTTF* title;

@property (nonatomic,strong) PlayerPlane* player1;
@property (nonatomic,strong) PlayerPlane* player2;
@property (nonatomic, strong) CCPhysicsNode *physicsNode;
@property (nonatomic, strong) CCNodeGradient *gradient;

@property (nonatomic, strong) CCNode *shieldBar1;
@property (nonatomic, strong) CCNode *shieldBar2;

@property (nonatomic, strong) CCNode *weaponBar1;
@property (nonatomic, strong) CCNode *weaponBar2;

-(void)setWeaponBar:(float) alpha forPlayer:(int) player;


@end
