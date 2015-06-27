//
//  Goal.swift
//  HoppyBunny
//
//  Created by Otavio Monteagudo on 6/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Goal:CCNode {
    
    func didLoadFromCCB() {
        self.physicsBody.sensor = true; // a sensor does not collide; score will be incremented each time.
    }
    
}