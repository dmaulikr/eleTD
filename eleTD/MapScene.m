//
//  Map.m
//  eleTD
//
//  Created by Jan-Dawid Roodt on 18/02/14.
//  Copyright (c) 2014 JD. All rights reserved.
//


#import "MapScene.h"
#import "Bullet.h"
#import "Tower.h"
#import "Creep.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPAD ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )1024 ) < DBL_EPSILON )
#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )

@implementation MapScene

@synthesize background;
@synthesize selectedNode;

float iPadScale = 1.6;
float iPhoneScale = 3.5;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        
        //Loading the background
        background = [SKSpriteNode spriteNodeWithImageNamed:@"mapBeta1"];
        [background setName:@"background"];
        [background setAnchorPoint:CGPointZero];
        // scalling the background size
        if (IS_IPHONE_4 || IS_IPHONE_5) {
            background.size = CGSizeMake(background.size.width/iPhoneScale, background.size.height/iPhoneScale);
        } else if (IS_IPAD) {
            background.size = CGSizeMake(background.size.width/iPadScale, background.size.height/iPadScale);
        }
        [self addChild:background];
        
        
        // importing building spots
        NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"towerLocations" ofType:@"plist"];
        NSArray * towerPositions = [NSArray arrayWithContentsOfFile:plistPath];
        towerBases = [[NSMutableArray alloc] init];
        
        for(NSDictionary * towerPos in towerPositions)
        {
            
            NSLog(@"in here");
            SKSpriteNode * towerBase = [SKSpriteNode spriteNodeWithImageNamed:@"buildHighlight"];
            [background addChild:towerBase];
            towerBase.size = CGSizeMake(towerBase.size.width/iPadScale, towerBase.size.height/iPadScale);
            [towerBase setPosition:CGPointMake([[towerPos objectForKey:@"x"] intValue],
                                       [[towerPos objectForKey:@"y"] intValue])];
            NSLog(@"grass spot x: %f,   y: %f",towerBase.position.x, towerBase.position.y);
            [towerBases addObject:towerBase];
            towerBase.name = @"build_spot";
            towerBase.hidden = TRUE;
        }
        
        
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint positionOnMap = [touch locationInNode:background];
    [self findSelectedNodeInTouch:positionOnMap];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint currentLocation = [touch locationInNode:self];
    CGPoint previousLocation = [touch previousLocationInNode:self];
    float newPosX = (previousLocation.x - currentLocation.x);
    float newPosY = (previousLocation.y - currentLocation.y);
    CGPoint newPos = CGPointMake(newPosX, newPosY);
    [self scrollMap: newPos];
    
    
    
}

- (void) scrollMap: (CGPoint) newPos {
    CGSize winSize = self.size;
    CGPoint scrollPoint = CGPointMake(background.position.x - newPos.x, background.position.y - newPos.y);
    scrollPoint.x = MIN(scrollPoint.x, 0);
    scrollPoint.x = MAX(scrollPoint.x, -[background size].width+ winSize.width);
    scrollPoint.y = MIN(scrollPoint.y, 0);
    scrollPoint.y = MAX(scrollPoint.y, -[background size].height+ winSize.height);
    
    [background setPosition: scrollPoint];
}


- (void)findSelectedNodeInTouch:(CGPoint)touchLocation {
    NSLog(@"map location: x= %f, y= %f", touchLocation.x, touchLocation.y);
    SKNode *touchedNode = (SKNode *)[background nodeAtPoint:touchLocation];
    
    // deactivate nodes now that there is a new touch
    if ([[selectedNode name] isEqualToString:@"build_spot"] && selectedNode != touchedNode) {
        selectedNode.hidden = true;
    }
    
	if(![selectedNode isEqual:touchedNode]) {
		selectedNode = touchedNode;
        NSLog(@"touched %@", selectedNode.name);
        
		if([[touchedNode name] isEqualToString:@"tower"]) {
			
		} else if ([[touchedNode name] isEqualToString:@"build_spot"]) {
            selectedNode.hidden = false;
            [self glowBuildSpot];
            // show element picker button
        }
	}
    // else { touching the same thing }
}

- (void) glowBuildSpot {
    selectedNode.alpha = 0;
    SKAction *glow = [SKAction sequence:@[[SKAction fadeAlphaTo:1 duration:1], [SKAction fadeAlphaTo:0.5 duration:1]]];
    
    // double check its a build_spot
    if ([selectedNode.name isEqualToString:@"build_spot"]) {
        [selectedNode runAction:[SKAction repeatActionForever:glow]];
    }
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
