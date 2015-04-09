#import "MainScene.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "RedBall.h"
#import "BlackBall.h"
#import "EffectBall.h"
#import "Arrow.h"


@implementation MainScene
- (void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"PlayScene"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
@end

