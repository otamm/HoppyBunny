import Foundation;

class MainScene: CCNode {
    
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
    
    
    /* custom variables */
    
    // time passsed since last touch.
    var sinceTouch:CCTime = 0;
    
    // (arbitrarily defined) horizontal speed of bunny
    var scrollSpeed:CGFloat = 80;
    
    // array of ground sprites to be intercalated; initialized as empty.
    var groundBlocks:[CCSprite] = [];
    
    // array of obstacle nodes
    var obstacles:[CCNode] = [];
    
    // (arbitrarily defined) position at X axis of first obstacle to appear and the distance from one obstacle to another
    let firstObstacleXPosition:CGFloat = 280;
    let xDistanceBetweenObstacles:CGFloat = 160;
    
    
    /*** METHODS ***/
    
    /* native cocos2d methods */
    
    // called every time a CCB file is loaded; see it as an "initializer" for the scene.
    func didLoadFromCCB() {
        self.userInteractionEnabled = true;
        self.groundBlocks.append(self.ground1);
        self.groundBlocks.append(self.ground2);
        
        // creates first obstacle
        let obstacle = CCBReader.load("Obstacle");
        obstacle.position = ccp(firstObstacleXPosition, 0);
        self.gamePhysicsNode.addChild(obstacle);
        self.obstacles.append(obstacle);
        
        // adds three more obstacles through custom function
        for i in 0...1 {
            self.spawnNewObstacle();
        }
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
    
    /* native iOS methods */
    
    // overrides a touch event with impulse being applied to make bunny jump/fly
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        hero.physicsBody.applyImpulse(ccp(0,400)); // goes 0 ccp in X direction and 400 in Y direction. Gravity acceleration is currently 700ccp/s
        // rotates rabbit
        hero.physicsBody.applyAngularImpulse(10000);
        sinceTouch = 0;
    }
    
    /* custom methods */
    
    func spawnNewObstacle() {
        var prevObstaclePosition = obstacles.last!.position.x;
        // creates the obstacle and appends it to the array
        let obstacle = CCBReader.load("Obstacle");
        obstacle.position = ccp(firstObstacleXPosition, 0);
        self.gamePhysicsNode.addChild(obstacle);
        self.obstacles.append(obstacle);
    }
}
