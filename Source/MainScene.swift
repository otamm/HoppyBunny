import Foundation;

class MainScene: CCNode, CCPhysicsCollisionDelegate { // CCPhysicsCollisionDelegate indicates that some methods from CCPhysicsCollision class will be implemented in the class
    
    /*** VARIABLES ***/
    
    /* code connections */
    
    // hero sprite
    weak var hero:CCSprite! ;
    
    // main physics node which affects all elements in screen
    weak var gamePhysicsNode:CCPhysicsNode!;
    
    //first block of ground sprite; blocks will be put one after the other to give the impression of continuous advance.
    weak var ground1:CCSprite!;
    
    // second block of ground sprite
    weak var ground2:CCSprite!;
    
    // makes sure obstacles are not rendered behind the player
    weak var obstaclesLayer:CCNode!;
    
    // invisible restart button, to be shown once game over is triggered.
    weak var restartButton:CCButton!;
    
    // displays score
    weak var scoreLabel:CCLabelTTF!;
    
    /* custom variables */
    
    // time passsed since last touch.
    var sinceTouch:CCTime = 0;
    
    // (arbitrarily defined) horizontal speed of bunny
    var scrollSpeed:CGFloat = 80;
    
    // array of ground sprites to be intercalated; initialized as empty.
    var groundBlocks:[CCSprite] = [];
    
    // array of obstacle nodes
    var obstacles:[Obstacle] = [];
    
    // used to check wheter the game is over or not
    var gameOver = false;
    
    // keeps track of score.
    var score:NSInteger = 0;
    
    // (arbitrarily defined) position at X axis of first obstacle to appear and the distance from one obstacle to another
    let firstObstacleXPosition:CGFloat = 280;
    let distanceBetweenObstaclesX:CGFloat = 160;
    
    
    /*** METHODS ***/
    
    /* native cocos2d methods */
    
    // called every time a CCB file is loaded; see it as an "initializer" for the scene.
    func didLoadFromCCB() {
        self.userInteractionEnabled = true;
        self.groundBlocks.append(self.ground1);
        self.groundBlocks.append(self.ground2);
        
        // creates first obstacle
        let obstacle = CCBReader.load("Obstacle") as! Obstacle;
        obstacle.position = ccp(firstObstacleXPosition, 0);
        obstacle.setupRandomPosition();
        self.obstaclesLayer.addChild(obstacle);
        self.obstacles.append(obstacle);
        
        // adds three more obstacles through custom function
        for i in 0...1 {
            self.spawnNewObstacle();
        }
        
        // assigns the main physics node as collision delegate
        self.gamePhysicsNode.collisionDelegate = self;
        self.scoreLabel.string = "\(self.score)";
    }
    
    // called at every frame; will limit max velocity in the Y axis and move hero through X axis at constant speed.
    override func update(delta: CCTime) {
        // clamp: test and optionally change a value so it won't exceed a given limit.
        // in this case, limits upwards velocity to 200ccp/s. Not limiting the downwards velocity.
        // clampf(maximum value, minimum value);
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200);
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY));
        
        // manages rabbit rotation;
        self.sinceTouch += delta;
        self.hero.rotation = clampf(hero.rotation, -30, 90); // maximum rotation at 30 to left and 90 right
        
        // manages rabbit movement in both X and Y axis
        self.hero.position = ccp(hero.position.x + scrollSpeed * CGFloat(delta), hero.position.y);
        
        // goes "back left" at same speed that hero goes "forward right", maintains position in Y axis constant.
        self.gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - scrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)
        
        // .allowsRotation is set to false when bunny dies
        if (hero.physicsBody.allowsRotation) {
            let angularVelocity = clampf(Float(hero.physicsBody.angularVelocity), -2, 1);
            hero.physicsBody.angularVelocity = CGFloat(angularVelocity);
        }
        // starts rotating
        if (self.sinceTouch > 0.3) {
            let impulse = -18000.0 * delta;
            self.hero.physicsBody.applyAngularImpulse(CGFloat(impulse));
        }
        
        // checks both ground sprites wheter they are out of the screen through the left boundary.
        for ground in self.groundBlocks {
            let groundWorldPosition = self.gamePhysicsNode.convertToWorldSpace(ground.position); // argument = nodePoint:CGPoint
            let groundScreenPosition = convertToNodeSpace(groundWorldPosition); // argument = worldPoint:CGPoint
            if (groundScreenPosition.x <= (-ground.contentSize.width)) {
                ground.position = ccp(ground.position.x + (ground.contentSize.width * 2), ground.position.y); // returns CGPoint with x being the very endpoint of the screen while y remains constant
            }
        }
        
        // removes the obstacle and then loads a new one each time an obstacle leaves the screen.
        for obstacle in self.obstacles.reverse() {
            let obstacleWorldPosition = gamePhysicsNode.convertToWorldSpace(obstacle.position);
            let obstacleScreenPosition = convertToNodeSpace(obstacleWorldPosition);
            
            // obstacle moved past left side of screen?
            if (obstacleScreenPosition.x < (-obstacle.contentSize.width)) {
                obstacle.removeFromParent();
                self.obstacles.removeAtIndex(find(obstacles, obstacle)!);
                
                // for each removed obstacle, add a new one
                self.spawnNewObstacle();
            }
        }
    }
    // collision-handling methods
    
    // triggered when a collision is detected amongst two objects of different collision types ('level' and 'hero')
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, level: CCNode!) -> Bool {
        //println("Implement Game Over");
        // will spawn a sequence of actions: make restart button visible, make hero immobile, make screen freeze, etc.
        self.triggerGameOver();
        return true;
    }
    
    // triggered when a collision is detected amongst two objects of different collision types ('goal' and 'hero' for this game)
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!,hero: CCNode!, goal: CCNode!) -> Bool {
        goal.removeFromParent(); //destroys 'Goal' instance
        self.score++;
        self.scoreLabel.string = "\(self.score)";
        return true;
    }
    
    /* native iOS methods */
    
    // overrides a touch event with impulse being applied to make bunny jump/fly
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if !(gameOver) {
            self.hero.physicsBody.applyImpulse(ccp(0,400)); // goes 0 ccp in X direction and 400 in Y direction. Gravity acceleration is currently 700ccp/s
            // rotates rabbit
            self.hero.physicsBody.applyAngularImpulse(10000);
            self.sinceTouch = 0;
        }
    }
    
    /* custom methods */
    
    // loads a new 'Obstacle' node from SpriteBuilder as an Obstacle class instance.
    func spawnNewObstacle() {
        var prevObstacleXPosition = obstacles.last!.position.x;
        // creates the obstacle and appends it to the array
        let obstacle = CCBReader.load("Obstacle") as! Obstacle; // loads CCBR as an instance of Obstacle class
        obstacle.position = ccp(prevObstacleXPosition + distanceBetweenObstaclesX, 0);
        obstacle.setupRandomPosition(); // assigns a random position to the Y value
        //self.gamePhysicsNode.addChild(obstacle); would be in front of hero like that
        self.obstaclesLayer.addChild(obstacle);
        self.obstacles.append(obstacle);
    }
    
    // reloads game, beginning all over again.
    func restart() {
        let scene = CCBReader.loadAsScene("MainScene");
        CCDirector.sharedDirector().presentScene(scene);
    }
    
    func triggerGameOver() {
        if !(self.gameOver) {
            self.gameOver = true;
            self.restartButton.visible = true;
            self.scrollSpeed = 0;
            self.hero.rotation = 90;
            self.hero.physicsBody.allowsRotation = false;
            
            // just in case
            self.hero.stopAllActions();
            
            let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)));
            let moveBack = CCActionEaseBounceOut(action: move.reverse());
            let shakeSequence = CCActionSequence(array: [move, moveBack]);
            self.runAction(shakeSequence);
        }
    }
}
