//
//  UIImage+ImageEffects.swift
//  AWImageViewController
//
//  Created by Alex Ling on 16/12/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit
import Accelerate

public extension UIImage {
	public func applyLightEffect() -> UIImage? {
		return applyBlurWithRadius(30, tintColor: UIColor(white: 1.0, alpha: 0.3), saturationDeltaFactor: 1.8)
	}
	
	public func applyExtraLightEffect() -> UIImage? {
		return applyBlurWithRadius(20, tintColor: UIColor(white: 0.97, alpha: 0.82), saturationDeltaFactor: 1.8)
	}
	
	public func applyDarkEffect() -> UIImage? {
		return applyBlurWithRadius(20, tintColor: UIColor(white: 0.11, alpha: 0.73), saturationDeltaFactor: 1.8)
	}
	
	public func applyTintEffectWithColor(tintColor: UIColor) -> UIImage? {
		let effectColorAlpha: CGFloat = 0.6
		var effectColor = tintColor
		
		let componentCount = CGColorGetNumberOfComponents(tintColor.CGColor)
		
		if componentCount == 2 {
			var b: CGFloat = 0
			if tintColor.getWhite(&b, alpha: nil) {
				effectColor = UIColor(white: b, alpha: effectColorAlpha)
			}
		} else {
			var red: CGFloat = 0
			var green: CGFloat = 0
			var blue: CGFloat = 0
			
			if tintColor.getRed(&red, green: &green, blue: &blue, alpha: nil) {
				effectColor = UIColor(red: red, green: green, blue: blue, alpha: effectColorAlpha)
			}
		}
		
		return applyBlurWithRadius(10, tintColor: effectColor, saturationDeltaFactor: -1.0, maskImage: nil)
	}
	
	public func applyBlurWithRadius(blurRadius: CGFloat, tintColor: UIColor?, saturationDeltaFactor: CGFloat, maskImage: UIImage? = nil) -> UIImage? {
		// Check pre-conditions.
		if (size.width < 1 || size.height < 1) {
			print("*** error: invalid size: \(size.width) x \(size.height). Both dimensions must be >= 1: \(self)")
			return nil
		}
		if self.CGImage == nil {
			print("*** error: image must be backed by a CGImage: \(self)")
			return nil
		}
		if maskImage != nil && maskImage!.CGImage == nil {
			print("*** error: maskImage must be backed by a CGImage: \(maskImage)")
			return nil
		}
		
		let __FLT_EPSILON__ = CGFloat(FLT_EPSILON)
		let screenScale = UIScreen.mainScreen().scale
		let imageRect = CGRect(origin: CGPointZero, size: size)
		var effectImage = self
		
		let hasBlur = blurRadius > __FLT_EPSILON__
		let hasSaturationChange = fabs(saturationDeltaFactor - 1.0) > __FLT_EPSILON__
		
		if hasBlur || hasSaturationChange {
			func createEffectBuffer(context: CGContext) -> vImage_Buffer {
				let data = CGBitmapContextGetData(context)
				let width = vImagePixelCount(CGBitmapContextGetWidth(context))
				let height = vImagePixelCount(CGBitmapContextGetHeight(context))
				let rowBytes = CGBitmapContextGetBytesPerRow(context)
				
				return vImage_Buffer(data: data, height: height, width: width, rowBytes: rowBytes)
			}
			
			UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
			let effectInContext = UIGraphicsGetCurrentContext()
			
			CGContextScaleCTM(effectInContext, 1.0, -1.0)
			CGContextTranslateCTM(effectInContext, 0, -size.height)
			CGContextDrawImage(effectInContext, imageRect, self.CGImage)
			
			var effectInBuffer = createEffectBuffer(effectInContext!)
			
			
			UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
			let effectOutContext = UIGraphicsGetCurrentContext()
			
			var effectOutBuffer = createEffectBuffer(effectOutContext!)
			
			
			if hasBlur {
				let inputRadius = blurRadius * screenScale
				var radius = UInt32(floor(inputRadius * 3.0 * CGFloat(sqrt(2 * M_PI)) / 4 + 0.5))
				if radius % 2 != 1 {
					radius += 1 // force radius to be odd so that the three box-blur methodology works.
				}
				
				let imageEdgeExtendFlags = vImage_Flags(kvImageEdgeExtend)
				
				vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
				vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
				vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
			}
			
			var effectImageBuffersAreSwapped = false
			
			if hasSaturationChange {
				let s: CGFloat = saturationDeltaFactor
				let floatingPointSaturationMatrix: [CGFloat] = [
					0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
					0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
					0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
					0,                    0,                    0,  1
				]
				
				let divisor: CGFloat = 256
				let matrixSize = floatingPointSaturationMatrix.count
				var saturationMatrix = [Int16](count: matrixSize, repeatedValue: 0)
				
				for var i: Int = 0; i < matrixSize; ++i {
					saturationMatrix[i] = Int16(round(floatingPointSaturationMatrix[i] * divisor))
				}
				
				if hasBlur {
					vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
					effectImageBuffersAreSwapped = true
				} else {
					vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
				}
			}
			
			if !effectImageBuffersAreSwapped {
				effectImage = UIGraphicsGetImageFromCurrentImageContext()
			}
			
			UIGraphicsEndImageContext()
			
			if effectImageBuffersAreSwapped {
				effectImage = UIGraphicsGetImageFromCurrentImageContext()
			}
			
			UIGraphicsEndImageContext()
		}
		
		// Set up output context.
		UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
		let outputContext = UIGraphicsGetCurrentContext()
		CGContextScaleCTM(outputContext, 1.0, -1.0)
		CGContextTranslateCTM(outputContext, 0, -size.height)
		
		// Draw base image.
		CGContextDrawImage(outputContext, imageRect, self.CGImage)
		
		// Draw effect image.
		if hasBlur {
			CGContextSaveGState(outputContext)
			if let image = maskImage {
				CGContextClipToMask(outputContext, imageRect, image.CGImage);
			}
			CGContextDrawImage(outputContext, imageRect, effectImage.CGImage)
			CGContextRestoreGState(outputContext)
		}
		
		// Add in color tint.
		if let color = tintColor {
			CGContextSaveGState(outputContext)
			CGContextSetFillColorWithColor(outputContext, color.CGColor)
			CGContextFillRect(outputContext, imageRect)
			CGContextRestoreGState(outputContext)
		}
		
		// Output image is ready.
		let outputImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return outputImage
	}
}
