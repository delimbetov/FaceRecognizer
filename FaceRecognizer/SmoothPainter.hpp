//
//  SmoothPainter.hpp
//  FaceRecognizer
//
//  Created by Кирилл Делимбетов on 25.03.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

#ifndef SmoothPainter_hpp
#define SmoothPainter_hpp

//---------------------------------------------------------------
#include <map>
//---------------------------------------------------------------
#include <opencv2/core/mat.hpp>
#include <opencv2/objdetect/detection_based_tracker.hpp>
//---------------------------------------------------------------

using DetectedObjects = std::vector<cv::DetectionBasedTracker::Object>;

/// @brief class for painting of face rectangles; supposed to smooth micro jumpes of rectangle on real-time video face recognition
class SmoothPainter
{
	using Rect = cv::DetectionBasedTracker::Object::first_type;
	using ObjectId = cv::DetectionBasedTracker::Object::second_type;
	
public:
	SmoothPainter() = default;
	
	void paint(cv::Mat& image, const DetectedObjects& objects, const int scale);
	
private:
	// get point between two args
	static cv::Point pointBetween(const cv::Point& p1, const cv::Point& p2);
	
	std::map<ObjectId, Rect> _objectIdToRect;
};

#endif /* SmoothPainter_hpp */
