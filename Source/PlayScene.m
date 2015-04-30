//
//  PlayScene.m
//  PushBall
//
//  Created by Jiate Li on 15/4/3.
//  Copyright (c) 2015年 Apportable. All rights reserved.
//

#import "PlayScene.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "RedBall.h"
#import "BlackBall.h"
#import "EffectBall.h"
#import "Arrow.h"
static const float MIN_SPEED = 5.f;
static const int First_Line = 166;
static const int Second_Line = 246;
static const int Third_Line = 328;
static const int Forth_Line = 408;

@implementation PlayScene{
    CCPhysicsNode *_physicsNode;
    //RedBall *_currentball;
    CCNode *_currentball;
    //the following CCNode are labels
    CCNode *_redturn;
    CCNode *_greenturn;
    CCNode *_redwin;
    CCNode *_greenwin;
    CCNode *_disappear;
    CCNode *_fix;
    CCNode *_force;
    CCNode *_expand;
    
    CCLabelTTF *_blackScoreLabel;
    CCLabelTTF *_redScoreLabel;
    
    CCAction *_followBall;
    CCNode *_contentNode;
    Arrow *_arrow;
    
    BOOL isBallStop;
    BOOL isEffectBallExist;
    BOOL isEffectOccur;
    BOOL isBallLaunched;
    BOOL isGameOn;
    
    int effectTimeCount;
    int num;
    int numOfBall;
    int scoreOfRed;
    int scoreOfBlack;
    int finalScoreOfRed;
    int finalScoreOfBlack;
    int endCount;
    NSMutableArray *_mySpriteArray;
    
    EffectBall *_effectball;
}

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    _physicsNode.physicsBody.friction = 200;
    //add friction between the balls and background
    [_physicsNode.space setDamping:0.6f];
    //if the ball is stopped
    isBallStop = true;
    //if the effect ball collides with balls
    isEffectOccur = false;
    //number of rounds
    num = 1;
    //number of balls
    numOfBall = 0;
    //notification of round
    _redturn.visible = true;
    _greenturn.visible = false;
    _disappear.visible = false;
    _expand.visible = false;
    _fix.visible = false;
    _force.visible = false;
    _redwin.visible = false;
    _greenwin.visible = false;
    isGameOn = true;
    
    scoreOfBlack = 0;
    scoreOfRed = 0;
    endCount = 0;
    _physicsNode.collisionDelegate = self;
    
    //array to store all the balls to calculate the score
    _mySpriteArray=[[NSMutableArray alloc] init];
    _effectball =[CCBReader load:@"EffectBall"];
    _effectball.state = [self getRandomNumberBetweenMin:1 andMax:4];
    _effectball.position = ccp([self getRandomNumberBetweenMin:100 andMax:540],[self getRandomNumberBetweenMin:15 andMax:280]);   //特效球
    [_physicsNode addChild:_effectball];
    isEffectBallExist = true;
    //NSLog(@"The state of effect ball is=%d",_effectball.state);
    
    _arrow = [CCBReader load:@"Arrow"];
    _arrow.position = ccp(30, 150);
    
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    // play background sound
    [audio playBg:@"TheEntertainer.mp3" loop:YES];
    
    _arrow.visible = false;
    [_contentNode addChild:_arrow];
    
}


//generate random number
- (int) getRandomNumberBetweenMin:(int)min andMax:(int)max {
    return ( (arc4random() % (max-min+1)) + min );
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair effect:(EffectBall *)nodeA wildcard:(CCNode *)nodeB
{
    isEffectOccur = true;
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"CollideEffect"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the seals position
    explosion.position = nodeA.position;
    // add the particle effect to the same node the seal is on
    [nodeA.parent addChild:explosion];
    //if the type of effect ball is 1, remove the ball collides with it
    if(nodeA.state == 1){
        _disappear.visible = true;
        [[_physicsNode space] addPostStepBlock:^{
            [self ballRemoved:nodeA andBall:nodeB];
        } key:nodeA];
    }
    //if the type of effect ball is 2, add a force to the ball
    else if(nodeA.state == 2){
        _force.visible = true;
        [[_physicsNode space] addPostStepBlock:^{
            [self moveQuick:nodeA andBall:nodeB];
        } key:nodeA];
    }
    //if the type of effect ball is 3, fix that ball
    else if(nodeA.state == 3){
        _fix.visible = true;
        [[_physicsNode space] addPostStepBlock:^{
            [self addDensity:nodeA andBall:nodeB];
        } key:nodeA];
    }
    //if the type of effect ball is 4, expand that ball
    else if(nodeA.state == 4){
        _expand.visible = true;
        [[_physicsNode space] addPostStepBlock:^{
            [self becomeBigger:nodeA andBall:nodeB];
        } key:nodeA];
    }
    //set the effect does not exist, when the ball stops, new effect ball would appear
    isEffectBallExist = false;
    
}

//the method to add effect to effect ball
- (void)becomeBigger:(CCNode *)effectone andBall: (CCNode *)ball{
    [effectone removeFromParent];
   // ball.scale = 2.f;
    [ball setScale:2.f];
    [ball.physicsBody setDensity:1000.f];
}

- (void)addDensity:(CCNode *)effectone andBall: (CCNode *)ball{
    [effectone removeFromParent];
    [ball.physicsBody setDensity:2000.f];
}

- (void)moveQuick:(CCNode *)effectone andBall: (CCNode *)ball{
    [effectone removeFromParent];
    [ball.physicsBody applyImpulse:ccp(800.f,800.3f)];
    
}

- (void)ballRemoved:(CCNode *)effectone andBall: (CCNode *)ball{
    [effectone removeFromParent];
    [_mySpriteArray removeObject:ball];
    [ball removeFromParent];
    [self nextAttempt];
}

-(void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{

}

//when touch ended, shot a ball
- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if(isGameOn){
    // whenever touches move, update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    if(isBallStop){
        if(num % 2 == 1){
            _currentball = [CCBReader load:@"RedBall"];
            
            //_currentball.isRed = true;
        }else{
            _currentball = [CCBReader load:@"BlackBall"];
            //_currentball.isRed = false;
        }
        
        _greenturn.visible = false;
        _redturn.visible = false;
        //add the ball to the array
        [_mySpriteArray insertObject:_currentball atIndex:_mySpriteArray.count];
        numOfBall++;
        num++;
        _currentball.position = ccp(30,150);
        //add that ball to physical node
        [_physicsNode addChild:_currentball];
        CGPoint delta = ccpSub(touchLocation, _currentball.position);
        [_currentball.physicsBody applyImpulse:ccp(delta.x * 0.9f,delta.y * 0.9f)];
        //set isBallLaunched to true
        isBallLaunched = true;
        //_currentball.launched = TRUE;
        isBallStop = false;
    }
    }
}


- (void)update:(CCTime)delta{
    //update in a fixed interval
    // NSLog(@"The state of effect ball is=%d",_effectball.state);
    //NSLog(@"The number in the array is =%lu",(unsigned long)_mySpriteArray.count);

    //when effect occurs, show the notification to tell the type of effect ball
    if(isEffectOccur){
        effectTimeCount++;
        if(effectTimeCount == 20){
            effectTimeCount = 0;
            isEffectOccur = false;
            _disappear.visible = false;
            _force.visible = false;
            _fix.visible = false;
            _expand.visible = false;
        }
    }
    
    //read all the balls in the screen and calculate the score
    scoreOfRed = 0;
    scoreOfBlack = 0;
    for (int i=0; i<_mySpriteArray.count; i++) // Opponents is NSMutableArray
    {
        CCNode* ball = [_mySpriteArray objectAtIndex:i];
        int curScore = 0;
        if(ball.position.x > First_Line && ball.position.x < Second_Line){
            curScore = 1;
        }else if(ball.position.x > Second_Line && ball.position.x < Third_Line){
            curScore = 2;
        }else if(ball.position.x > Third_Line && ball.position.x < Forth_Line){
            curScore = 4;
        }else if(ball.position.x > Forth_Line){
            curScore = -1;
        }
        //ball.position.x
        if([ball isKindOfClass:[RedBall class]]){
            scoreOfRed = scoreOfRed + curScore;
        }else{
            scoreOfBlack = scoreOfBlack + curScore;
        }

        //NSLog(@"The number in the array is =%lu",(unsigned long)_mySpriteArray.count);
        
        
    }
    finalScoreOfBlack = scoreOfBlack;
    finalScoreOfRed = scoreOfRed;
    _blackScoreLabel.string = [NSString stringWithFormat:@"%d",scoreOfBlack];
    _redScoreLabel.string = [NSString stringWithFormat:@"%d",scoreOfRed];
    
    
    
    //if game ends, show the result and change to the end scene
    if(isGameOn == false){
        endCount++;
        if(endCount == 50){
        if(finalScoreOfRed > finalScoreOfBlack){
            _redwin.visible = true;
        }else{
            _greenwin.visible = true;
        }
        }
        if(endCount == 200){
        
        CCScene *endScene = [CCBReader loadAsScene:@"EndScene"];
        
            [[CCDirector sharedDirector] replaceScene:endScene];
        }
    }
    
    //check if a ball is stopped after launched, if yes, trun to new round
    if(isBallLaunched) {
        // if speed is below minimum speed, assume this attempt is over
        if (ccpLength(_currentball.physicsBody.velocity) < MIN_SPEED){
            isBallStop = true;
            
            
            if(numOfBall == 10){
                isGameOn = false;
            }
            //notification of next round
            if(isGameOn){
            if(num % 2 == 0){
                _greenturn.visible = true;
            }else{
                _redturn.visible = true;
            }
            }
            
            //if the effect ball does not exist, generate a new one
            if(!isEffectBallExist){
                _effectball =[CCBReader load:@"EffectBall"];
                _effectball.state = [self getRandomNumberBetweenMin:1 andMax:4];
                _effectball.position = ccp([self getRandomNumberBetweenMin:100 andMax:540],[self getRandomNumberBetweenMin:15 andMax:280]);   //特效球
                [_physicsNode addChild:_effectball];
                isEffectBallExist = true;
            }
            
            isBallLaunched = false;
            [self nextAttempt];
            
            return;
        }
        
    }
}

- (void)nextAttempt {
    _currentball = nil;
    [_contentNode stopAction:_followBall];
    
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:1.f position:ccp(0, 0)];
    [_contentNode runAction:actionMoveTo];
    isBallStop = true;
}

- (void) goback{
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}

- (void) tryagain{
    CCScene *playScene = [CCBReader loadAsScene:@"PlayScene"];
    [[CCDirector sharedDirector] replaceScene:playScene];
}
@end
