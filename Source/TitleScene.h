#import "cocos2d.h"

@interface TitleScene : CCScene

@property CCLabelTTF *anyKey;
@property CCLabelTTF *winner;

-(void) winnerMessage:(NSString*) winText;

@end
