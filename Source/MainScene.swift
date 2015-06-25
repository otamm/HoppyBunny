import Foundation;

class MainScene: CCNode {
    /* code connections */
    
    // hero sprite
    weak var hero:CCSprite! ;
    
    /* custom variables */
    
    // time passsed since last touch.
    var sinceTouch:CCTime = 0;
    
    // horizontal speed of bunny
    var scrollSpeed:CGFloat = 80;
    
    /* native cocos2d methods */
    
    // called every time a CCB file is loaded
    func didLoadFromCCB() {
        userInteractionEnabled = true;
    }
    
    // called at every frame; will limit max velocity in the Y axis and move hero through X axis at constant speed.
    override func update(delta: CCTime) {
        // clamp: test and optionally change a value so it won't exceed a given limit.
        // in this case, limits upwards velocity to 200ccp/s. Not limiting the downwards velocity.
        // clampf(maximum value, minimum value);
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200);
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY));
        
        // manages rabbit rotation;
        sinceTouch += delta;
        hero.rotation = clampf(hero.rotation, -30, 90); // maximum rotation at 30 to left and 90 right
        
        // manages rabbit movement in both X and Y axis
        hero.position = ccp(hero.position.x + scrollSpeed * CGFloat(delta), hero.position.y);
        
        // .allowsRotation is set to false when bunny dies
        if (hero.physicsBody.allowsRotation) {
            let angularVelocity = clampf(Float(hero.physicsBody.angularVelocity), -2, 1);
            hero.physicsBody.angularVelocity = CGFloat(angularVelocity);
        }
        // starts rotating
        if (sinceTouch > 0.3) {
            let impulse = -18000.0 * delta;
            hero.physicsBody.applyAngularImpulse(CGFloat(impulse));
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
}
