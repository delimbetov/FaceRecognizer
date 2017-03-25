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
//---------------------------------------------------------------

class DetectionBasedTrackerAdapter
{
public:
	DetectionBasedTrackerAdapter();
	
	/// false if loading fails
	bool load(const std::string& cascadeFileName);
	
	/// 
	void process(cv::Mat& image);
	
private:
	std::unique_ptr<cv::DetectionBasedTracker> _dbtracker;
};

#endif /* DetectionBasedTrackerAdapter_hpp */
