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
		constexpr double scaleFactor = 1.25;
		constexpr int minNeighbours = 3;
		constexpr int flags = CV_HAAR_SCALE_IMAGE;
		const auto minSize = cv::Size(30, 30);
	};
	
	namespace FaceRect {
		const auto scalar = cv::Scalar(200, 200, 0);
		constexpr int thickness = 3;
	}
	
	// multiplty by this to get normal rect from scaledDown
	constexpr int scale = 5;
	// use in resize as fx and fy
	const double downScale = 1.0 / scale;
};

//DEBUG
#include <thread>
#include <atomic>
std::thread _fpsThread;
std::atomic<int> _counter;
//

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
	
	//DEBUG
	_counter = 0;
	_fpsThread = std::thread([&]() {
		while(true) {
			std::this_thread::sleep_for(std::chrono::seconds(1));
			std::cout << "FPS=" << _counter << '\n';
			_counter = 0;
		}
	});
	//
	
	return self;
}

- (UIImage*) recognizeFacesOnImage: (UIImage*) image;
{
	cv::Mat mat;
	cv::Mat scaledDown;
	std::vector<cv::Rect> faceRects;
	
	// UIImage -> cv::Mat
	UIImageToMat(image, mat);
	
	// for some reason openCV won't draw with color if mat has alpha-channel; so convert it out
	cv::cvtColor(mat, mat, CV_BGRA2BGR);
	
	// downscale so it detects faster
	cv::resize(mat, scaledDown, scaledDown.size(), Constant::downScale, Constant::downScale, cv::INTER_CUBIC);
	
	// recognize faces
	cascade.detectMultiScale(scaledDown, faceRects,
							 Constant::DetectMultiScale::scaleFactor,
							 Constant::DetectMultiScale::minNeighbours,
							 Constant::DetectMultiScale::flags,
							 Constant::DetectMultiScale::minSize);

	// draw rectangles around faces
	for(const auto& rect : faceRects)
	{
		// scale rect as if it was detected in normal sized image
		const auto scaledToNormalRect = cv::Rect(rect.tl() * Constant::scale,  rect.size() * Constant::scale);
		
		cv::rectangle(mat, scaledToNormalRect, Constant::FaceRect::scalar, Constant::FaceRect::thickness);
	}

	//DEBUG
	++_counter;
	//
	
	// cv::Mat -> UIImage
	return MatToUIImage(mat);
}

@end
