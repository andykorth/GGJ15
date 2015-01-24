#import "StatusNode.h"

@implementation StatusNode


-(void)destroy
{
	[self removeFromParent];
}

-(void)setWeaponBarAmount:(float) alpha
{
    alpha = MAX(0, alpha);
    
    CGSize size = _weaponBar.parent.contentSize;
    float width = alpha*size.width;
    _weaponBar.contentSize = CGSizeMake(width, size.height);
}

-(void)setHealthBarAmount:(float) alpha
{
    alpha = MAX(0, alpha);

    CGSize size = _healthBar.parent.contentSize;
    float width = alpha*size.width;
    _healthBar.contentSize = CGSizeMake(width, size.height);
}


@end
