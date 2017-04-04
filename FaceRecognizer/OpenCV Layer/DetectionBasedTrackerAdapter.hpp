//
//  DetectionBasedTrackerAdapter.hpp
//  FaceRecognizer
//
//  Created by Кирилл Делимбетов on 25.03.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

#ifndef DetectionBasedTrackerAdapter_hpp
#define DetectionBasedTrackerAdapter_hpp

//---------------------------------------------------------------
#include <memory>
//---------------------------------------------------------------
#include "CascadeDetectorAdapter.hpp"
#include "SmoothPainter.hpp"
//---------------------------------------------------------------

class DetectionBasedTrackerAdapter
{
public:
	DetectionBasedTrackerAdapter() = default;
	
	/// false if loading fails
	bool load(const std::string& cascadeFileName);
	
	/// detect faces on image and paint rectangles around them
	void process(cv::Mat& image);
	
private:
	std::unique_ptr<cv::DetectionBasedTracker> _dbtracker;
	SmoothPainter _painter;
};

#endif /* DetectionBasedTrackerAdapter_hpp */
