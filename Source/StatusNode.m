#import "StatusNode.h"

@implementation StatusNode


-(void)destroy
{
	[self removeFromParent];
}

-(void)setWeaponBarAmount:(float) alpha
{
    CGSize size = _healthBar.contentSize;
    float width = alpha*size.width;
    _healthBar.contentSize = CGSizeMake(width, size.height);
}

-(void)setHealthBarAmount:(float) alpha
{
    CGSize size = _weaponBar.parent.contentSize;
    float width = alpha*size.width;
    _weaponBar.contentSize = CGSizeMake(width, size.height);
}


@end
