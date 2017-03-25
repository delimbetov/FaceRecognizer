//
//  DetectionBasedTrackerAdapter.cpp
//  FaceRecognizer
//
//  Created by Кирилл Делимбетов on 25.03.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

//---------------------------------------------------------------
#include <iostream>
//---------------------------------------------------------------
#include <opencv2/imgproc/imgproc.hpp>
#include "DetectionBasedTrackerAdapter.hpp"
//---------------------------------------------------------------

/***************************************************************/
namespace Constant {
	namespace FaceRect {
		// color of rectangle
		// 200, 200, 0 - yellow
		const auto scalar = cv::Scalar(200, 200, 0);
		// thickness of rectange border line
		constexpr int thickness = 3;
	}
	
	// cv::DetectionBasedTracker::Parameters
	namespace Param {
		// how much frames without detecting (if not mistaken)
		constexpr auto maxTrackLifetime = 30;
		// min time between rerunning detector on whole image in ms
		constexpr auto minDetectionPeriod = 1000; // 1000ms == 1second
	}
	
	// multiplty by this to get normal rect from scaledDown
	constexpr int scale = 5;
	// use in resize as fx and fy
	const double downScale = 1.0 / scale;
	
}

/***************************************************************/
/***************************************************************/
DetectionBasedTrackerAdapter::DetectionBasedTrackerAdapter()
{
	
}

/***************************************************************/
bool DetectionBasedTrackerAdapter::load(const std::string& cascadeFileName)
{
	try
	{
		auto mainDetector = cv::makePtr<CascadeDetectorAdapter>(CascadeDetectorAdapter(cascadeFileName, CascadeDetectorAdapter::DetectorType::main));
		auto trackingDetector = cv::makePtr<CascadeDetectorAdapter>(CascadeDetectorAdapter(cascadeFileName, CascadeDetectorAdapter::DetectorType::tracking));
		auto params = cv::DetectionBasedTracker::Parameters();
		
		params.maxTrackLifetime = Constant::Param::maxTrackLifetime;
		params.minDetectionPeriod = Constant::Param::minDetectionPeriod;
		_dbtracker = std::make_unique<cv::DetectionBasedTracker>(mainDetector, trackingDetector, params);
			
		return true;
	}
	catch(const std::exception& e)
	{
		std::cerr << "Error during loading of file: " << e.what();
	}
	catch(...)
	{
		std::cerr << "Unknown error during loading of file";
	}
	
	return false;
}

/***************************************************************/
void DetectionBasedTrackerAdapter::process(cv::Mat& image)
{
	cv::Mat scaledDownGrayImage;
	DetectedFaces faceRects;
	
	if(!_dbtracker)
	{
		std::cerr << "_dbtracker == 0";
		return;
	}
	
	// for some reason openCV won't draw with color if mat has alpha-channel; so convert it out
	cv::cvtColor(image, image, CV_BGRA2BGR);
	
	// downscale so it detects faster
	cv::resize(image, scaledDownGrayImage, scaledDownGrayImage.size(), Constant::downScale, Constant::downScale, cv::INTER_CUBIC);
	
	// gray images are faster to process (also DetectionBasedTracker has assert to check mat type)
	cv::cvtColor(scaledDownGrayImage, scaledDownGrayImage, CV_BGR2GRAY);
	
	// recognize faces
	_dbtracker->process(scaledDownGrayImage);
	
	// extract rects with detected faces
	_dbtracker->getObjects(faceRects);
	
	//DEBUG
	std::vector<std::pair<cv::Rect, int>> objs;
	_dbtracker->getObjects(objs);
	for(auto& obj : objs)
		std::cerr << "OBJECT id=" << obj.second << '\n';
	//
	
	for(const auto& rect : faceRects)
	{
		// scale rect as if it was detected in normal sized image
		const auto scaledToNormalRect = cv::Rect(rect.tl() * Constant::scale,  rect.size() * Constant::scale);
		
		// draw rectangles around faces
		cv::rectangle(image, scaledToNormalRect, Constant::FaceRect::scalar, Constant::FaceRect::thickness);
	}
}
