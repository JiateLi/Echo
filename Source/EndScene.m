//
//  EndScene.m
//  PushBall
//
//  Created by Jiate Li on 15/4/8.
//  Copyright (c) 2015年 Apportable. All rights reserved.
//

#import "EndScene.h"
#import "MainScene.h"

@implementation EndScene

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
}

- (void) gohome{
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}

- (void) retry{
    CCScene *playScene = [CCBReader loadAsScene:@"PlayScene"];
    [[CCDirector sharedDirector] replaceScene:playScene];
}
@end
