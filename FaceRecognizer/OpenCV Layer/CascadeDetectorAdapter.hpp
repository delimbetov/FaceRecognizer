//
//  CascadeDetectorAdapter.hpp
//  FaceRecognizer
//
//  Created by Кирилл Делимбетов on 25.03.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

#ifndef CascadeDetectorAdapter_hpp
#define CascadeDetectorAdapter_hpp

//---------------------------------------------------------------
#include <vector>
//---------------------------------------------------------------
#include <opencv2/core/mat.hpp>
#include <opencv2/objdetect/detection_based_tracker.hpp>
#include <opencv2/objdetect/objdetect.hpp>
//---------------------------------------------------------------

using DetectedFaces = std::vector<cv::Rect>;

class CascadeDetectorAdapter : public cv::DetectionBasedTracker::IDetector
{
public:
	enum class DetectorType : uint8_t {
		main,
		tracking
	};
	
	/// @exception std::runtime_error if can't load cascadeFileName
	CascadeDetectorAdapter(const std::string& cascadeFileName, const DetectorType type);
	
	/// cv::DetectionBasedTracker::IDetector
	virtual void detect(const cv::Mat& image, DetectedFaces& objects) override;
	
private:
	cv::CascadeClassifier _cascade;
	// flags passed to detectMultiScale; depend on DetectorType
	int _flags = 0;
};

#endif /* CascadeDetectorAdapter_hpp */
