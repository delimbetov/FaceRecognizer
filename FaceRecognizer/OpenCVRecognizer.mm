//
//  OpenCVRecognizer.mm
//  FaceRecognizer
//
//  Created by Кирилл Делимбетов on 24.03.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

#include <iostream>
#include <opencv2/core/mat.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/imgcodecs/ios.h>
#include <opencv2/imgproc/imgproc.hpp>
#import "OpenCVRecognizer.h"

@interface OpenCVRecognizer()
{
	cv::CascadeClassifier cascade;
}
@end

@implementation OpenCVRecognizer

- (id)init {
	self = [super init];
	
	// load xml file with some data needed by classifier
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
	std::string cascadeName = (char *)[path UTF8String];
	
	if(!cascade.load(cascadeName)) {
		std::cout << ("couldn't load xml!!!");
		return nil;
	}
	
	return self;
}

- (UIImage*) recognizeFacesOnImage: (UIImage*) image;
{
	cv::Mat mat;
	std::vector<cv::Rect> faceRects;
	
	// UIImage -> cv::Mat
	UIImageToMat(image, mat);
	
	// recognize faces
	cascade.detectMultiScale(mat, faceRects, 1.1, 2, CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
	
	// draw rectangles around faces
	for(const auto& rect : faceRects)
		cv::rectangle(mat, rect, cv::Scalar(255, 0, 0));
	
	// cv::Mat -> UIImage
	return MatToUIImage(mat);
}

@end
