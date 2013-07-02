/**
 *  Donuts2Scene.m
 *  Donuts2
 *
 *  Created by Rhody on 6/30/13.
 *  Copyright __MyCompanyName__ 2013. All rights reserved.
 */

#import "Donuts2Scene.h"
#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3Camera.h"
#import "CC3Light.h"


@implementation Donuts2Scene

-(void) dealloc {
	[lastStepTime release];

	delete discreteDynamicsWorld;
	discreteDynamicsWorld = NULL;
	
	[super dealloc];
}

/**
 * Constructs the 3D scene.
 *
 * Adds 3D objects to the scene, loading a 3D 'hello, world' message
 * from a POD file, and creating the camera and light programatically.
 *
 * When adapting this template to your application, remove all of the content
 * of this method, and add your own to construct your 3D model scene.
 *
 * NOTE: The POD file used for the 'hello, world' message model is fairly large,
 * because converting a font to a mesh results in a LOT of triangles. When adapting
 * this template project for your own application, REMOVE the POD file 'hello-world.pod'
 * from the Resources folder of your project!!
 */
-(void) initializeScene {
		
	lastStepTime = [[NSDate alloc] init];

	// This is the simplest way to load a POD resource file and add the
	// nodes to the CC3Scene, if no customized resource subclass is needed.
	[self addContentFromPODFile: @"scene.pod"];

	
	CC3Camera* cam = (CC3Camera*)[self getNodeNamed: @"Camera"];
	CC3Vector r = cam.rotation;
	r.x = r.x-90;	// fix camera rotation being imported with wrong rotation
	cam.rotation = r;
	
	CC3Light* lamp = (CC3Light*)[self getNodeNamed: @"Lamp"];
	r = lamp.rotation;
	r.x = r.x-90;	// fix lamp rotation being imported with wrong rotation
	lamp.rotation = r;

	
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantData];
	
	// That's it! The scene is now constructed and is good to go.
	
	// If you encounter problems displaying your models, you can uncomment one or more of the
	// following lines to help you troubleshoot. You can also use these features on a single node,
	// or a structure of nodes. See the CC3Node notes for more explanation of these properties.
	// Also, the onOpen method below contains additional troubleshooting code you can comment
	// out to move the camera so that it will display the entire scene automatically.
	
	// Displays short descriptive text for each node (including class, node name & tag).
	// The text is displayed centered on the pivot point (origin) of the node.
//	self.shouldDrawAllDescriptors = YES;
	
	// Displays bounding boxes around those nodes with local content (eg- meshes).
//	self.shouldDrawAllLocalContentWireframeBoxes = YES;
	
	// Displays bounding boxes around all nodes. The bounding box for each node
	// will encompass its child nodes.
//	self.shouldDrawAllWireframeBoxes = YES;
	
	// If you encounter issues creating and adding nodes, or loading models from
	// files, the following line is used to log the full structure of the scene.
	LogCleanDebug(@"The structure of this scene is: %@", [self structureDescription]);
	
	// ------------------------------------------

	// Load physics
	
	btBulletWorldImporter* fileLoader = NULL;

	broadphase = new btDbvtBroadphase();
	constraintSolver = new btSequentialImpulseConstraintSolver;
	collisionConfig = new btDefaultCollisionConfiguration();
	collisionDispatcher = new btCollisionDispatcher(collisionConfig);
	discreteDynamicsWorld = new btDiscreteDynamicsWorld(collisionDispatcher, broadphase, constraintSolver, collisionConfig);
	
	discreteDynamicsWorld->setGravity(btVector3(0,0,0));
	
	fileLoader = new btBulletWorldImporter(discreteDynamicsWorld);
	
	NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"scene.bullet" ofType:Nil];

	if (fileLoader->loadFile(fullPath.UTF8String))
	{
		for (int i=0; i<discreteDynamicsWorld->getNumCollisionObjects(); i++)
		{
			btCollisionObject* obj = discreteDynamicsWorld->getCollisionObjectArray()[i];
			btRigidBody* body = btRigidBody::upcast(obj);

			NSString* nodeName = [NSString stringWithUTF8String:fileLoader->getNameForPointer(body)];
			
			CC3MeshNode *nodeMesh = (CC3MeshNode*)[self getNodeNamed: nodeName];
						
			body->setUserPointer((void*) nodeMesh);
		}
	}	
}


#pragma mark Updating custom activity

/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides your app with an opportunity to perform update activities before
 * any changes are applied to the transformMatrix of the 3D nodes in the scene.
 *
 * For more info, read the notes of this method on CC3Node.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {}

/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides your app with an opportunity to perform update activities after
 * the transformMatrix of the 3D nodes in the scen have been recalculated.
 *
 * For more info, read the notes of this method on CC3Node.
 */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	// If you have uncommented the moveWithDuration: invocation in the onOpen: method,
	// you can uncomment the following to track how the camera moves, and where it ends up,
	// in order to determine where to position the camera to see the entire scene.
	
	NSDate * currentTime = [[NSDate alloc] init];

	NSTimeInterval timeInterval = [currentTime timeIntervalSinceDate:lastStepTime];
	[lastStepTime release];
	lastStepTime = currentTime;

	// update the simulation
	discreteDynamicsWorld->stepSimulation(timeInterval, 2);

	
	// update mesh node position for each object
	for (int i=0; i<discreteDynamicsWorld->getNumCollisionObjects(); i++)
	{		
		// -- For each RigidBody
		btCollisionObject* obj = discreteDynamicsWorld->getCollisionObjectArray()[i];
		btRigidBody* body = btRigidBody::upcast(obj);
		if (body)
		{
			body->setActivationState(DISABLE_DEACTIVATION);

			btDefaultMotionState* motionState = (btDefaultMotionState*) body->getMotionState();

			btTransform trans;

			if (motionState)
			{
				motionState->getWorldTransform(trans);
			}
			else
			{
				trans = body->getWorldTransform();
				motionState = new btDefaultMotionState(trans);
				body->setMotionState(motionState);				
			}
			
			if (CC3Node *node = (CC3Node*)body->getUserPointer()) {

				// fix and update physics orientation being diferent from that in the 3d model world space
				btQuaternion rotation = btQuaternion(btVector3(1,0,0), -SIMD_HALF_PI) * trans.getRotation();
				CC3Quaternion quaternion;
				quaternion.x = rotation.getX();
				quaternion.y = rotation.getY();
				quaternion.z = rotation.getZ();
				quaternion.w = -rotation.getW();
				node.quaternion = quaternion;
				
				// fix and update physics coordinates being swaped in relation to the 3d model world space
				CC3Vector position;
				position.x =  trans.getOrigin().x();
				position.y =  trans.getOrigin().z();
				position.z = -trans.getOrigin().y();
				node.location = position;
			}
		}
	}
}


#pragma mark Scene opening and closing

/**
 * Callback template method that is invoked automatically when the CC3Layer that
 * holds this scene is first displayed.
 *
 * This method is a good place to invoke one of CC3Camera moveToShowAllOf:... family
 * of methods, used to cause the camera to automatically focus on and frame a particular
 * node, or the entire scene.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) onOpen {

	// Uncomment this line to have the camera move to show the entire scene. This must be done after the
	// CC3Layer has been attached to the view, because this makes use of the camera frustum and projection.
	// If you uncomment this line, you might also want to uncomment the LogDebug line in the updateAfterTransform:
	// method to track how the camera moves, and where it ends up, in order to determine where to position
	// the camera to see the entire scene.
//	[self.activeCamera moveWithDuration: 3.0 toShowAllOf: self];

	// Uncomment this line to draw the bounding box of the scene.
//	self.shouldDrawWireframeBox = YES;
}

/**
 * Callback template method that is invoked automatically when the CC3Layer that
 * holds this scene has been removed from display.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) onClose {}


#pragma mark Handling touch events 

/**
 * This method is invoked from the CC3Layer whenever a touch event occurs, if that layer
 * has indicated that it is interested in receiving touch events, and is handling them.
 *
 * Override this method to handle touch events, or remove this method to make use of
 * the superclass behaviour of selecting 3D nodes on each touch-down event.
 *
 * This method is not invoked when gestures are used for user interaction. Your custom
 * CC3Layer processes gestures and invokes higher-level application-defined behaviour
 * on this customized CC3Scene subclass.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {}

/**
 * This callback template method is invoked automatically when a node has been picked
 * by the invocation of the pickNodeFromTapAt: or pickNodeFromTouchEvent:at: methods,
 * as a result of a touch event or tap gesture.
 *
 * Override this method to perform activities on 3D nodes that have been picked by the user.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {}


- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	static float prevX=0, prevY=0, prevZ;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	float accelZ = (float) acceleration.z * kFilterFactor + (1- kFilterFactor)*prevZ;

	prevX = accelX;
	prevY = accelY;
	prevZ = accelZ;

	btVector3 gravity( accelX * 10, accelY * 10, accelZ * 10 );
	
	discreteDynamicsWorld->setGravity(gravity);
}

@end

