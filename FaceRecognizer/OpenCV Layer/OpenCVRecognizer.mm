//
//  OpenCVRecognizer.mm
//  FaceRecognizer
//
//  Created by Кирилл Делимбетов on 24.03.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

#include <iostream>
#include <opencv2/core/mat.hpp>
#include <opencv2/imgcodecs/ios.h>
#include "DetectionBasedTrackerAdapter.hpp"
#import "OpenCVRecognizer.h"

@interface OpenCVRecognizer()
{
	DetectionBasedTrackerAdapter _dbtAdapter;
}
@end

@implementation OpenCVRecognizer

- (id)init {
	self = [super init];
	
	// load xml file with some data needed by classifier
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
	const auto cascadeName = static_cast<const char *>([path UTF8String]);
	
	if(!_dbtAdapter.load(cascadeName)) {
		std::cout << ("Couldn't load xml");
		return nil;
	}
	
	return self;
}

- (UIImage*) recognizeFacesOnImage: (UIImage*) image;
{
	cv::Mat mat;
	
	// UIImage -> cv::Mat
	UIImageToMat(image, mat);
	
	// detect faces and draw rectangles around them on mat
	_dbtAdapter.process(mat);
	
	// cv::Mat -> UIImage
	return MatToUIImage(mat);
}

@end
