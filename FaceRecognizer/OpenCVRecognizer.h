//
//  OpenCVRecognizer.h
//  FaceRecognizer
//
//  Created by Кирилл Делимбетов on 24.03.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVRecognizer : NSObject

// constructor; might fail if cant find .xml file
- (id) init;
// returns received image with rectangles around recognized faces
- (UIImage*) recognizeFacesOnImage: (UIImage*) image;

@end
