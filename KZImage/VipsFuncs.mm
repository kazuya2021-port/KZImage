//
//  VipsFuncs.m
//  KZImage
//
//  Created by uchiyama_Macmini on 2019/03/22.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//
#include "vips_core.hpp"
#import "VipsFuncs.h"
#import <KZLibs.h>

@interface VipsFuncs()
{
    VipsCore *core;
}
@property BOOL isVipsRunning;
@end

@implementation VipsFuncs
const char *app_name = "VipsFuncs";

#pragma mark -
#pragma mark Initialize

- (id)init
{
    self = [super init];
    if(self){
        core = new VipsCore();
    }
    return self;
}

- (BOOL)startEngine
{
    if(!_isVipsRunning)
        _isVipsRunning = (core->vipsStart(app_name))? YES : NO;
    
    if(!_isVipsRunning)
    {
        Log(@"vips start error!");
    }
    
    return _isVipsRunning;
}

- (void)stopEngine
{
    core->vipsEnd();
}

#pragma mark - I/O Funcs

- (BOOL)setImage:(NSString*)imgPath format:(int)fileFormat
{
    return (core->openImage([imgPath UTF8String], (VipsCore::FileFormat)fileFormat))? YES : NO;
}

- (const void*)getImage
{
    return core->image.data();
}

- (void)clearImage
{
    core->clearImage();
}

#pragma mark - Process Image
- (BOOL)resizeDPI:(double)targetDPI useAnti:(BOOL)useAnti isResample:(BOOL)isResample
{    
    return (core->resizeDPI(targetDPI,
                            (useAnti)? true : false,
                            (isResample)? true : false))? YES : NO;
}

- (BOOL)changeColorSpace:(int)targetColor
{
    return (core->changeColorSpace((VipsCore::ColorSpace)targetColor))? YES : NO;
}

- (BOOL)saveToIMG:(NSString*)savePath format:(int)fileFormat
{
    return (core->saveToIMG([savePath UTF8String], (VipsCore::FileFormat)fileFormat))? YES : NO;
}
@end
