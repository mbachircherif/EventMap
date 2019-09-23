//
//  UIImage + IconMap.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 24/04/2018.
//  Copyright © 2018 BACHIR-CHERIF Mohamed. All rights reserved.
//

import Foundation
import ImageIO
import Photos
import MobileCoreServices

/// https://gist.github.com/tomasbasham/10533743

// MARK: - Image Scaling.
extension UIImage {
    
    /// Represents a scaling mode
    enum ScalingMode {
        case aspectFill
        case aspectFit
        
        /// Calculates the aspect ratio between two sizes
        ///
        /// - parameters:
        ///     - size:      the first size used to calculate the ratio
        ///     - otherSize: the second size used to calculate the ratio
        ///
        /// - return: the aspect ratio between the two sizes
        func aspectRatio(between size: CGSize, and otherSize: CGSize) -> CGFloat {
            let aspectWidth  = size.width/otherSize.width
            let aspectHeight = size.height/otherSize.height
            
            switch self {
            case .aspectFill:
                return max(aspectWidth, aspectHeight)
            case .aspectFit:
                return min(aspectWidth, aspectHeight)
            }
        }
    }
    
    /// Scales an image to fit within a bounds with a size governed by the passed size. Also keeps the aspect ratio.
    ///
    /// - parameter:
    ///     - newSize:     the size of the bounds the image must fit within.
    ///     - scalingMode: the desired scaling mode
    ///
    /// - returns: a new scaled image.
    func scaled(to newSize: CGSize, scalingMode: UIImage.ScalingMode = .aspectFill) -> UIImage? {
        
        /*let data : NSMutableData = NSMutableData()
        
        let dataOptions: NSDictionary = [
            kCGImagePropertyHasAlpha: true,
            kCGImageDestinationLossyCompressionQuality: 1,
            ]
        
        let resizeOptions: NSDictionary = [
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height) * aspectRatio,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]
        
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = true
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: .image, options: nil) {
        imgManager.requestImageData(for: fetchResult.object(at: index),
                              options: requestOptions,
                              resultHandler: {(dataImg: Data?, UTIImage : String?, orientation : UIImageOrientation, info) -> Void in
                              
                                let imageSource = CGImageSourceCreateWithData(dataImg as! CFData, nil)
                                
                                let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource!, 0, resizeOptions)
                                
                                let finalImageDestinationRef = CGImageDestinationCreateWithData(data as CFMutableData, kUTTypePNG, 1, nil)!
                                CGImageDestinationAddImage(finalImageDestinationRef, scaledImage!, dataOptions)
                                CGImageDestinationFinalize(finalImageDestinationRef)
            })
        }*/
        
        /* Build the rectangle representing the area to be drawn */
        var scaledImageRect = CGRect.zero
        let aspectRatio = scalingMode.aspectRatio(between: newSize, and: size)
        
        scaledImageRect.size.width  = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x    = (newSize.width - size.width * aspectRatio) / 2.0
        scaledImageRect.origin.y    = (newSize.height - size.height * aspectRatio) / 2.0
        
        /* Draw and retrieve the scaled image */
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        //let bounds = CGRect(origin: CGPoint.zero, size: newSize)
        //UIBezierPath(roundedRect: bounds, cornerRadius: newSize.height/2).addClip()
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
