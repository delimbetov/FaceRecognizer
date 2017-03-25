//
//  CascadeDetectorAdapter.cpp
//  FaceRecognizer
//
//  Created by Кирилл Делимбетов on 25.03.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

//---------------------------------------------------------------
#include <stdexcept>
//---------------------------------------------------------------
#include "CascadeDetectorAdapter.hpp"
//---------------------------------------------------------------

/***************************************************************/
namespace Constant {
	namespace DetectMultiScale {
		constexpr double scaleFactor = 1.25;
		constexpr int minNeighbours = 3;
		constexpr int flagsMain = CV_HAAR_SCALE_IMAGE;
		// tracking is done for single object - so looking for single biggest is acceptable
		constexpr int flagsTracking = CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_SCALE_IMAGE;
		// min size of detectable face. lower -> worse performance
		const auto minSize = cv::Size(50, 50);
	}
}

/***************************************************************/
/***************************************************************/
CascadeDetectorAdapter::CascadeDetectorAdapter(const std::string& cascadeFileName, const DetectorType type)
{
	setScaleFactor(Constant::DetectMultiScale::scaleFactor);
	setMinNeighbours(Constant::DetectMultiScale::minNeighbours);
	setMinObjectSize(Constant::DetectMultiScale::minSize);
	
	switch(type)
	{
		case DetectorType::main:
			_flags = Constant::DetectMultiScale::flagsMain;
			break;
		case DetectorType::tracking:
			_flags = Constant::DetectMultiScale::flagsTracking;
	}
	
	if(!_cascade.load(cascadeFileName))
		throw std::runtime_error("can't load: " + cascadeFileName);
}

/***************************************************************/
void CascadeDetectorAdapter::detect(const cv::Mat& image, DetectedFaces& objects)
{
	_cascade.detectMultiScale(image, objects, getScaleFactor(), getMinNeighbours(), _flags, getMinObjectSize(), getMaxObjectSize());
}
