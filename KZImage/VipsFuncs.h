//
//  VipsFuncs.h
//  KZImage
//
//  Created by uchiyama_Macmini on 2019/03/22.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VipsFuncs : NSObject
- (BOOL)startEngine; // call after allocate
- (void)stopEngine;  // call in AppShutdown
- (BOOL)setImage:(NSString*)imgPath format:(int)fileFormat;
- (const void*)getImage;
- (void)clearImage;
- (BOOL)resizeDPI:(double)targetDPI useAnti:(BOOL)useAnti isResample:(BOOL)isResample;
- (BOOL)changeColorSpace:(int)targetColor; // targetColor defined enum(ColorSpace) in KZImage.h
- (BOOL)saveToIMG:(NSString*)savePath format:(int)fileFormat;
@end
