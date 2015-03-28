#import "MainScene.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "RedBall.h"
#import "BlackBall.h"
#import "EffectBall.h"

static const float MIN_SPEED = 2.f;

@implementation MainScene{
    CCPhysicsNode *_physicsNode;
    RedBall *_currentball;
    //CCNode* redball;
    CCAction *_followBall;
    CCNode *_contentNode;
    BOOL isBallStop;
    int num;
    int numOfBall;
    NSMutableArray *_mySpriteArray;
    
    EffectBall *_effectball;
}

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    //  _physicsNode.collisionDelegate = self;
    _physicsNode.physicsBody.friction = 200;
    //这句可以增加球和桌面的摩擦力
    [_physicsNode.space setDamping:0.8f];
    //判断是不是球停了
    isBallStop = true;
    //局数
    num = 1;
    //球的个数
    numOfBall = 0;
    
    _physicsNode.collisionDelegate = self;
    
    //存球的数组
    _mySpriteArray=[[NSMutableArray alloc] init];
    _effectball =[CCBReader load:@"EffectBall"];
    _effectball.state = [self getRandomNumberBetweenMin:1 andMax:4];
    _effectball.position = ccp(500,150);   //特效球测试
    [_physicsNode addChild:_effectball];
    NSLog(@"The state of effect ball is=%d",_effectball.state);
}


- (int) getRandomNumberBetweenMin:(int)min andMax:(int)max {
    return ( (arc4random() % (max-min+1)) + min );
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair effect:(EffectBall *)nodeA wildcard:(CCNode *)nodeB
{
    
    
   //看球的类型，如果是类型1，就移走小球
    if(nodeA.state == 1){
        [[_physicsNode space] addPostStepBlock:^{
            [self ballRemoved:nodeA andBall:nodeB];
        } key:nodeA];
    //CCLOG(@"Something collided with a effect!");
    }
    //如果是特效2，给碰到的小球一个超大的力
    else if(nodeA.state == 2){
        [[_physicsNode space] addPostStepBlock:^{
            [self moveQuick:nodeA andBall:nodeB];
        } key:nodeA];
    }
    //如果是特效3，给碰到的小球加密度，使他不会再动
    else if(nodeA.state == 3){
        [[_physicsNode space] addPostStepBlock:^{
            [self addDensity:nodeA andBall:nodeB];
        } key:nodeA];
    }
    //类型4，变大球，加密度
    else if(nodeA.state == 4){
        [[_physicsNode space] addPostStepBlock:^{
            [self becomeBigger:nodeA andBall:nodeB];
        } key:nodeA];
    }
}

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
    //当上一个球停止了才可以发射新的球
   // if(isBallStop){  !!!!!!!
    //CCNode* redball = [CCBReader load:@"RedBall"];
//        if(num % 2 == 1){  !!!!!!!
            //根据局数决定发射什么颜色的球
// !!!!!!!            _currentball = [CCBReader load:@"RedBall"];
// !!!!!!!        }else{
// !!!!!!!            _currentball = [CCBReader load:@"BlackBall"];
// !!!!!!!        }
        //添加到数组里
// !!!!!!!        [_mySpriteArray insertObject:_currentball  atIndex:numOfBall];
// !!!!!!!        numOfBall++;
// !!!!!!!        num++;
    //redball.position = ccp(30,150);
    //设置球的初始位置
// !!!!!!!    _currentball.position = ccp(30,150);
    //添加到数组里
// !!!!!!!    [_physicsNode addChild:_currentball];
    //[_physicsNode addChild:redball];
// !!!!!!!    CGPoint touchPos = [touch locationInNode:_contentNode];
    //CGPoint delta = ccpSub(touchPos, redball.position);
// !!!!!!!    CGPoint delta = ccpSub(touchPos, _currentball.position);
// !!!!!!!     CGPoint launchDirection = ccp(delta.x,delta.y);
// !!!!!!!    CGPoint force = ccpMult(launchDirection,20);
    //[redball.physicsBody applyForce:force];
// !!!!!!!    [_currentball.physicsBody applyForce:force];
    
    
// !!!!!!!    _followBall = [CCActionFollow actionWithTarget:_currentball worldBoundary:self.boundingBox];
// !!!!!!!    [_contentNode runAction:_followBall];
    //让属性改变
// !!!!!!!    _currentball.launched = TRUE;
// !!!!!!!        isBallStop = false;
    //[self launchRedBall];
// !!!!!!!    }
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

-(void) launchRedBall{
    //暂时没有用上
   // CCNode* redball = [CCBReader load:@"RedBall"];
   // redball.position = ccp(30,150);
   // [_physicsNode addChild:redball];
   // CGPoint launchDirection = ccp(1,0);
    //CGPoint force = ccpMult(launchDirection,1000);
  //  redball.physicsBody.friction = 200;
    
    //[redball.physicsBody applyForce:force];
   // [redball.physicsBody applyImpulse:ccp(200.f,0.f)];
}


- (void)update:(CCTime)delta{
    //实时更新，这里可以用来读取球的位置update分数
   // NSLog(@"The state of effect ball is=%d",_effectball.state);
    NSLog(@"The number in the array is =%lu",(unsigned long)_mySpriteArray.count);

    for (int i=0; i<_mySpriteArray.count; i++) // Opponents is NSMutableArray
    {
        CCNode* ball = [_mySpriteArray objectAtIndex:i];
        
        //NSLog(@"The number in the array is =%lu",(unsigned long)_mySpriteArray.count);

        
    }
    
    //这个判断是后加的,判断这个球是否停止运动了，如果是就可以开始下一次了
    if(_currentball.launched) {
        // if speed is below minimum speed, assume this attempt is over
        if (ccpLength(_currentball.physicsBody.velocity) < MIN_SPEED){
            isBallStop = true;
            [self nextAttempt];
            
            return;
        }
        
        int xMin = _currentball.boundingBox.origin.x;
        
        if (xMin < self.boundingBox.origin.x) {
            isBallStop = true;
            [self nextAttempt];
            return;
        }
        
        int xMax = xMin + _currentball.boundingBox.size.width;
        
        if (xMax > (self.boundingBox.origin.x + self.boundingBox.size.width)) {
            
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

