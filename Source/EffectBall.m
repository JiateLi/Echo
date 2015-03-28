//
//  EffectBall.m
//  PushBall
//
//  Created by Jiate Li on 15/3/28.
//  Copyright (c) 2015年 Apportable. All rights reserved.
//

#import "EffectBall.h"

@implementation EffectBall

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"effect";
}
@end
