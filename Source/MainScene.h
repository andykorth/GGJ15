
#import "cocos2d.h"
#import "PlayerPlane.h"


enum Z_ORDER {
    Z_BG,
    Z_BG_EFFECTS,
    Z_PLAYER,
    Z_EFFECTS,
    Z_HUD,
};


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

-(void) playerDied:(PlayerPlane *)player;
-(void) spawnPlayers;

@end
