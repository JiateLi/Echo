//
//  EndScene.m
//  PushBall
//
//  Created by Jiate Li on 15/4/8.
//  Copyright (c) 2015年 Apportable. All rights reserved.
//

#import "EndScene.h"
#import "MainScene.h"
#import "PlayScene.h"
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKShareKit/FBSDKShareKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>

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
//
//-(void) shareToFacebook {
//    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//    
//    // this should link to FB page for your app or AppStore link if published
//    content.contentURL = [NSURL URLWithString:@"https://www.facebook.com/lijiate"];
//    // URL of image to be displayed alongside post
//    content.imageURL = [NSURL URLWithString:@"https://github.com/JiateLi/Echo/blob/master/background.png"];
//    // title of post
//    content.contentTitle = [NSString stringWithFormat:@"My score of Curling game is %@!", PlayScene.highScore];
//    // description/body of post
//    content.contentDescription = @"Check out My Score of Curling game.";
//    
//    [FBSDKShareDialog showFromViewController:[CCDirector sharedDirector]
//                                 withContent:content
//                                    delegate:nil];
//}
@end
