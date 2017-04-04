//
//  SmoothPainter.cpp
//  FaceRecognizer
//
//  Created by Кирилл Делимбетов on 25.03.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

//---------------------------------------------------------------
#include <opencv2/imgproc/imgproc.hpp>
//---------------------------------------------------------------
#include "SmoothPainter.hpp"
//---------------------------------------------------------------

/***************************************************************/
namespace Constant {
	namespace FaceRect {
		// color of rectangle
		// 200, 200, 0 - yellow
		const auto scalar = cv::Scalar(200, 200, 0);
		// thickness of rectangle border line
		constexpr int thickness = 3;
	}
	
	// part of distance to new position object is moved per frame
	constexpr auto partOfLengthToBeMovedPerFrame = 5;
}

/***************************************************************/
template< typename ContainerT, typename PredicateT >
void erase_if( ContainerT& items, const PredicateT& predicate ) {
	for( auto it = items.begin(); it != items.end(); ) {
		if( predicate(*it) ) it = items.erase(it);
		else ++it;
	}
};

/***************************************************************/
/***************************************************************/
void SmoothPainter::paint(cv::Mat& image, const DetectedObjects& objects, const int scale)
{
	// erase every element if it's not found in objects (so old objects won't stay in _objectIdToRect)
	erase_if(_objectIdToRect,
			 [&](const auto& idToRectPair) {
				 // search by id
				 return std::find_if(objects.cbegin(), objects.cend(),
									 [&idToRectPair](const auto& object) {
										 return idToRectPair.first == object.second;
									 }) == objects.cend();
			 });
	
	for(const auto& object : objects)
	{
		// scale rect as if it was detected in normal sized image
		const auto scaledToNormalRect = cv::Rect(object.first.tl() * scale,  object.first.size() * scale);
		const auto foundIter = _objectIdToRect.find(object.second);
		
		// if found, take its rect as initial position and calc next rect and draw it
		if(foundIter != _objectIdToRect.cend())
		{
			const auto& id = foundIter->first;
			const auto& previousRect = foundIter->second;
			const auto nextRect = cv::Rect(pointBetween(previousRect.tl(), scaledToNormalRect.tl()), pointBetween(previousRect.br(), scaledToNormalRect.br()));
			
			_objectIdToRect.at(id) = nextRect;
			cv::rectangle(image, nextRect, Constant::FaceRect::scalar, Constant::FaceRect::thickness);
		}
		// else add and paint it
		else
		{
			_objectIdToRect[object.second] = scaledToNormalRect;
			// draw rectangles around face
			cv::rectangle(image, scaledToNormalRect, Constant::FaceRect::scalar, Constant::FaceRect::thickness);
		}
	}
}

/***************************************************************/
cv::Point SmoothPainter::pointBetween(const cv::Point& p1, const cv::Point& p2)
{
	const auto diffx = p2.x - p1.x;
	const auto diffy = p2.y - p1.y;
	
	return cv::Point(p1.x + diffx / Constant::partOfLengthToBeMovedPerFrame, p1.y + diffy / Constant::partOfLengthToBeMovedPerFrame);
}
