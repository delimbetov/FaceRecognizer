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

namespace Constant {
	namespace DetectMultiScale {
		constexpr double scaleFactor = 1.2;
		constexpr int minNeighbours = 3;
		constexpr int flags = CV_HAAR_SCALE_IMAGE;
		const auto minSize = cv::Size(100, 100);
	};
	
	namespace FaceRect {
		const auto scalar = cv::Scalar(255, 255, 255);
		const int thickness = 3;
	}
};

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
	const auto cascadeName = static_cast<const char *>([path UTF8String]);
	
	if(!cascade.load(cascadeName)) {
		std::cout << ("Couldn't load xml");
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
	cascade.detectMultiScale(mat, faceRects,
							 Constant::DetectMultiScale::scaleFactor,
							 Constant::DetectMultiScale::minNeighbours,
							 Constant::DetectMultiScale::flags,
							 Constant::DetectMultiScale::minSize);
	
	// draw rectangles around faces
	for(const auto& rect : faceRects)
		cv::rectangle(mat, rect, Constant::FaceRect::scalar, Constant::FaceRect::thickness);
	
	// cv::Mat -> UIImage
	return MatToUIImage(mat);
}

@end
