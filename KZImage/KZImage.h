//
//  KZImage.h
//  KZImage
//
//  Created by uchiyama_Macmini on 2019/03/13.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for KZImage.
FOUNDATION_EXPORT double KZImageVersionNumber;

//! Project version string for KZImage.
FOUNDATION_EXPORT const unsigned char KZImageVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KZImage/PublicHeader.h>

typedef NS_ENUM(int, FileFormat)
{
    TIFF_FORMAT = 0,
    PNG_FORMAT = 1,
    JPG_FORMAT = 2,
    GIF_FORMAT = 3,
    PSD_FORMAT = 4,
    PDF_FORMAT = 5,
    UNKNOWN_FORMAT = 99,
} FILE_FORMAT;

typedef NS_ENUM(int, ColorSpace)
{
    GRAY = 0,
    SRGB = 1,
    CMYK = 2,
} COLOR_SPACE;

@interface ConvertSetting : NSObject
@property ColorSpace toSpace;
@property float Resolution;
@property BOOL isUseAntiAlias;
@property BOOL isSaveLayer; // only use PSD writing
@property BOOL isResize;    // true: resample image     false : change dpi
@property BOOL isSaveColor; // true: save RGB image     false : save Gray image
@property BOOL isMemory;    // true: save image Memory  false : save image file
@end

@interface KZImage : NSObject
- (void)startEngine;
- (void)stopEngine;

+ (BOOL)isSupported:(NSString*)imgPath;
- (BOOL)ImagetoPNG:(NSString*)pngPath;
- (BOOL)ImagetoTIFF:(NSString*)tifPath;
- (BOOL)setImage:(NSString*)imgPath;
- (const void*)getImage;
- (void)clearImage;

@property (nonatomic, retain) ConvertSetting *setting;
@end
