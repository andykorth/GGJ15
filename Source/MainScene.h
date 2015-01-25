
#import "cocos2d.h"
#import "PlayerPlane.h"

#define Z_HUD 10
#define Z_EFFECTS 100


@class StatusNode;

@interface MainScene : CCScene<CCPhysicsCollisionDelegate>

@property (nonatomic,strong) CCLabelTTF* title;

@property (nonatomic,strong) PlayerPlane* player1;
@property (nonatomic,strong) PlayerPlane* player2;
@property (nonatomic, strong) CCPhysicsNode *physicsNode;
@property (nonatomic, strong) CCNodeGradient *gradient;

@property (nonatomic, strong) StatusNode *player1Status;
@property (nonatomic, strong) StatusNode *player2Status;

-(void)setWeaponBar:(float) alpha forPlayer:(int) player;
-(void)setHealthBar:(float) alpha forPlayer:(int) player;

-(void)addExplosionAt:(CCPhysicsBody *)body;

@end
