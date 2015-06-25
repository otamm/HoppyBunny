import Foundation;

class MainScene: CCNode {
    
    // hero sprite
    weak var hero:CCSprite! ;
    
    /* native cocos2d methods */
    
    // called every time a CCB file is loaded
    func didLoadFromCCB() {
        userInteractionEnabled = true;
    }
    
    // called at every frame; will limit max velocity in the Y axis.
    override func update(delta: CCTime) {
        // clamp: test and optionally change a value so it won't exceed a given limit.
        // in this case, limits upwards velocity to 200ccp/s. Not limiting the downwards velocity.
        // clampf(maximum value, minimum value);
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200);
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY));
    }
    
    /* native iOS methods */
    
    // overrides a touch event with impulse being applied to make bunny jump/fly
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        hero.physicsBody.applyImpulse(ccp(0,400)); // goes 0 ccp in X direction and 400 in Y direction. Gravity acceleration is currently 700ccp/s
    }
}
