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

-(void) shareToFacebook {
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    
    // this should link to FB page for your app or AppStore link if published
    content.contentURL = [NSURL URLWithString:@"https://www.facebook.com/lijiate"];
    // URL of image to be displayed alongside post
    content.imageURL = [NSURL URLWithString:@"https://git.makeschool.com/MakeSchool-Tutorials/News/f744d331484d043a373ee2a33d63626c352255d4//663032db-cf16-441b-9103-c518947c70e1/cover_photo.jpeg"];
    // title of post
    content.contentTitle = [NSString stringWithFormat:@"My lucky number is %@!", _luckyNumberLabel.string];
    // description/body of post
    content.contentDescription = @"Check out My Lucky Number to get your own.";
    
    [FBSDKShareDialog showFromViewController:[CCDirector sharedDirector]
                                 withContent:content
                                    delegate:nil];
}
@end
