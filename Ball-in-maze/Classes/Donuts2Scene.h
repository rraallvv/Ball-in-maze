/**
 *  Donuts2Scene.h
 *  Donuts2
 *
 *  Created by Rhody on 6/30/13.
 *  Copyright __MyCompanyName__ 2013. All rights reserved.
 */


#import "CC3Scene.h"
#include "btBulletDynamicsCommon.h"
#include "btBulletWorldImporter.h"

/** A sample application-specific CC3Scene subclass.*/
@interface Donuts2Scene : CC3Scene {
	btDbvtBroadphase* broadphase;
	btSequentialImpulseConstraintSolver* constraintSolver;
	btDefaultCollisionConfiguration* collisionConfig;
	btCollisionDispatcher* collisionDispatcher;
	btDiscreteDynamicsWorld* discreteDynamicsWorld;
	NSDate * lastStepTime;
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration;

@end
