//
//  Obstacle.swift
//  HoppyBunny
//
//  Created by Otavio Monteagudo on 6/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Obstacle:CCNode {
    
    /* linked objects */
    weak var carrotTop:CCNode!;
    weak var carrotBottom:CCNode!;
    
    /* arbitrary constants */
    let topCarrotMinimumPositionY:CGFloat = 128;
    let bottomCarrotMaximumPositionY:CGFloat = 440;
    let carrotDistance:CGFloat = 142;
    
    /* custom methods */
    
    // assigns a random position for each new instance of Obstacle
    func setupRandomPosition() {
        let randomPrecision:UInt32 = 100;
        let random = CGFloat(arc4random_uniform(randomPrecision)) / CGFloat(randomPrecision);
        let range = self.bottomCarrotMaximumPositionY - self.carrotDistance - self.topCarrotMinimumPositionY;
        
        self.carrotTop.position = ccp(self.carrotTop.position.x, self.topCarrotMinimumPositionY + (random * range));
        
        self.carrotBottom.position = ccp(self.carrotBottom.position.x, self.carrotTop.position.y + self.carrotDistance);
    }
    
    /* cocos2d methods */
    func didLoadFromCCB() {
        self.carrotTop.physicsBody.sensor = true;
        self.carrotBottom.physicsBody.sensor = true;
    }
    
}