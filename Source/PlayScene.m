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
static const float MIN_SPEED = 2.f;

@implementation PlayScene{
    CCPhysicsNode *_physicsNode;
    RedBall *_currentball;
    //the following CCNode are labels
    CCNode *_redturn;
    CCNode *_greenturn;
    CCNode *_disappear;
    CCNode *_fix;
    CCNode *_force;
    CCNode *_expand;
    
    CCAction *_followBall;
    CCNode *_contentNode;
    Arrow *_arrow;
    BOOL isBallStop;
    BOOL isEffectBallExist;
    BOOL isEffectOccur;
    
    int effectTimeCount;
    int num;
    int numOfBall;
    NSMutableArray *_mySpriteArray;
    
    EffectBall *_effectball;
}

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    _physicsNode.physicsBody.friction = 200;
    //这句可以增加球和桌面的摩擦力
    [_physicsNode.space setDamping:0.8f];
    //判断是不是球停了
    isBallStop = true;
    isEffectOccur = false;
    //局数
    num = 1;
    //球的个数
    numOfBall = 0;
    //回合提醒关显示
    _redturn.visible = true;
    _greenturn.visible = false;
    _disappear.visible = false;
    _expand.visible = false;
    _fix.visible = false;
    _force.visible = false;
    
    _physicsNode.collisionDelegate = self;
    
    //存球的数组
    _mySpriteArray=[[NSMutableArray alloc] init];
    _effectball =[CCBReader load:@"EffectBall"];
    _effectball.state = [self getRandomNumberBetweenMin:1 andMax:4];
    _effectball.position = ccp([self getRandomNumberBetweenMin:100 andMax:540],[self getRandomNumberBetweenMin:15 andMax:280]);   //特效球
    [_physicsNode addChild:_effectball];
    isEffectBallExist = true;
    //NSLog(@"The state of effect ball is=%d",_effectball.state);
    
    _arrow = [CCBReader load:@"Arrow"];
    _arrow.position = ccp(30, 150);
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
    
    //看球的类型，如果是类型1，就移走小球
    if(nodeA.state == 1){
        _disappear.visible = true;
        [[_physicsNode space] addPostStepBlock:^{
            [self ballRemoved:nodeA andBall:nodeB];
        } key:nodeA];
    }
    //如果是特效2，给碰到的小球一个超大的力
    else if(nodeA.state == 2){
        _force.visible = true;
        [[_physicsNode space] addPostStepBlock:^{
            [self moveQuick:nodeA andBall:nodeB];
        } key:nodeA];
    }
    //如果是特效3，给碰到的小球加密度，使他不会再动
    else if(nodeA.state == 3){
        _fix.visible = true;
        [[_physicsNode space] addPostStepBlock:^{
            [self addDensity:nodeA andBall:nodeB];
        } key:nodeA];
    }
    //类型4，变大球，加密度
    else if(nodeA.state == 4){
        _expand.visible = true;
        [[_physicsNode space] addPostStepBlock:^{
            [self becomeBigger:nodeA andBall:nodeB];
        } key:nodeA];
    }
    //特效球暂时没有了，等球停下来后，特效求再次出现
    isEffectBallExist = false;
    
}

//特效球加特效方法
- (void)becomeBigger:(CCNode *)effectone andBall: (CCNode *)ball{
    [effectone removeFromParent];
    ball.scale = 2.f;
    
    [ball.physicsBody setDensity:1000.f];
}

- (void)addDensity:(CCNode *)effectone andBall: (CCNode *)ball{
    [effectone removeFromParent];
    [ball.physicsBody setDensity:2000.f];
}

- (void)moveQuick:(CCNode *)effectone andBall: (CCNode *)ball{
    [effectone removeFromParent];
    [ball.physicsBody applyImpulse:ccp(2000.f,2000.3f)];
    
}

- (void)ballRemoved:(CCNode *)effectone andBall: (CCNode *)ball{
    [effectone removeFromParent];
    [_mySpriteArray removeObject:ball];
    [ball removeFromParent];
    [self nextAttempt];
}

-(void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{

}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // whenever touches move, update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    if(isBallStop){
        if(num % 2 == 1){
            _currentball = [CCBReader load:@"RedBall"];
        }else{
            _currentball = [CCBReader load:@"BlackBall"];
        }
        
        _greenturn.visible = false;
        _redturn.visible = false;
        //添加到数组里
        [_mySpriteArray insertObject:_currentball atIndex:_mySpriteArray.count];
        numOfBall++;
        num++;
        _currentball.position = ccp(30,150);
        //添加到数组里
        [_physicsNode addChild:_currentball];
        CGPoint delta = ccpSub(touchLocation, _currentball.position);
        [_currentball.physicsBody applyImpulse:ccp(delta.x * 0.3f,delta.y * 0.3f)];
        //让属性改变
        _currentball.launched = TRUE;
        isBallStop = false;
    }
    
}


- (void)update:(CCTime)delta{
    //实时更新，这里可以用来读取球的位置update分数
    // NSLog(@"The state of effect ball is=%d",_effectball.state);
    NSLog(@"The number in the array is =%lu",(unsigned long)_mySpriteArray.count);

    //如果特效发生，产生通知并定时消失
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
    
    //用来读取每个球的位置，并计算分数
    for (int i=0; i<_mySpriteArray.count; i++) // Opponents is NSMutableArray
    {
        CCNode* ball = [_mySpriteArray objectAtIndex:i];
        
        //NSLog(@"The number in the array is =%lu",(unsigned long)_mySpriteArray.count);
        
        
    }
    
    //判断这个球是否停止运动了，如果是就可以开始下一次了
    if(_currentball.launched) {
        // if speed is below minimum speed, assume this attempt is over
        if (ccpLength(_currentball.physicsBody.velocity) < MIN_SPEED){
            isBallStop = true;
            
            //下一轮的提示
            if(num % 2 == 0){
                _greenturn.visible = true;
            }else{
                _redturn.visible = true;
            }
            
            //游戏结束
            if(numOfBall == 10){
                CCScene *endScene = [CCBReader loadAsScene:@"EndScene"];
                [[CCDirector sharedDirector] replaceScene:endScene];
            }
            
            //特效球如果不存在
            if(!isEffectBallExist){
                _effectball =[CCBReader load:@"EffectBall"];
                _effectball.state = [self getRandomNumberBetweenMin:1 andMax:4];
                _effectball.position = ccp([self getRandomNumberBetweenMin:100 andMax:540],[self getRandomNumberBetweenMin:15 andMax:280]);   //特效球
                [_physicsNode addChild:_effectball];
                isEffectBallExist = true;
            }
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


@end
