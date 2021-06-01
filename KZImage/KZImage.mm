//
//  KZImage.m
//  KZImage
//
//  Created by uchiyama_Macmini on 2019/03/13.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import "VipsFuncs.h"
#import <KZImage.h>
#import <KZLibs.h>

@interface ConvertSetting()
@property UInt16 magic;
@property FileFormat SourceFormat;
@property FileFormat TargetFormat;
@end

@implementation ConvertSetting
@end

@interface KZImage()
{
    void *image_buffer;
}
@property (retain) VipsFuncs *vips;
@property (retain) NSString *imagePath;
@end

@implementation KZImage

#define SUPPORT_EXT @[@"pdf", @"png", @"psd", @"gif", @"jpg", @"jpeg", @"tif", @"tiff"]

#pragma mark -
#pragma mark Initialize

- (id)init
{
    self = [super init];
    if(self){
        _setting = [[ConvertSetting alloc] init];
        _vips = [[VipsFuncs alloc] init];
    }
    return self;
}

- (void)startEngine
{
    [_vips startEngine];
}

- (void)stopEngine
{
    [_vips stopEngine];
}

#pragma mark -
#pragma mark Internal Funcs
+ (BOOL)checkFormat:(NSString*)imgPath magick:(UInt16*)magicNum format:(FileFormat*)format
{
    BOOL ret = NO;
    
    NSFileHandle* filehandle = [NSFileHandle fileHandleForReadingAtPath:imgPath];
    if(!filehandle) return ret;
    NSData* header = [filehandle readDataOfLength:8];
    
    NSString* headStr = nil;
    const NSStringEncoding * enc = [NSString availableStringEncodings];
    while (*enc) {
        headStr = [[NSString alloc] initWithData:header encoding:*enc];
        if(headStr) break;
        enc++;
    }
    
    if([KZLibs isExistString:headStr searchStr:@"âPNG"])
        *format = PNG_FORMAT;
    else if([KZLibs isExistString:headStr searchStr:@"%PDF-"])
        *format = PDF_FORMAT;
    else if([KZLibs isExistString:headStr searchStr:@"GIF89"] ||
            [KZLibs isExistString:headStr searchStr:@"GIF87"])
        *format = GIF_FORMAT;
    else if([KZLibs isExistString:headStr searchStr:@"8BPS"] ||
            [KZLibs isExistString:headStr searchStr:@".PSD"])
        *format = PSD_FORMAT;
    else if([KZLibs isExistString:headStr searchStr:@"MM.*"] ||
            [KZLibs isExistString:headStr searchStr:@"II*."])
        *format = TIFF_FORMAT;
    
    CFByteOrder order = CFByteOrderGetCurrent();
    [header getBytes:magicNum length:2];
    *magicNum = (order == CFByteOrderLittleEndian)? _OSSwapInt16(*magicNum) : *magicNum;
    
    if(*format == UNKNOWN_FORMAT)
    {
        // JPEG MagicNumber is 0xFFD8
        *format = (*magicNum == 65496)? JPG_FORMAT : UNKNOWN_FORMAT;
    }
    
    ret = (*format != UNKNOWN_FORMAT)? YES : NO;
    
    return ret;
}

- (BOOL)isVips:(FileFormat)format
{
    BOOL ret;
    switch (_setting.SourceFormat) {
        case PNG_FORMAT:
        case GIF_FORMAT:
        case TIFF_FORMAT:
        case JPG_FORMAT:
            ret = YES;
            break;
        case PDF_FORMAT:
        case PSD_FORMAT:
            ret = NO;
            break;
        default:
            ret = NO;
            break;
    }
    return ret;
}

- (BOOL)isIM:(FileFormat)format
{
    BOOL ret;
    switch (_setting.SourceFormat) {
        case PNG_FORMAT:
        case GIF_FORMAT:
        case TIFF_FORMAT:
        case JPG_FORMAT:
        case PDF_FORMAT:
            ret = NO;
            break;
        case PSD_FORMAT:
            ret = YES;
            break;
        default:
            ret = NO;
            break;
    }
    return ret;
}

- (BOOL)isPdfium:(FileFormat)format
{
    BOOL ret;
    switch (_setting.SourceFormat) {
        case PNG_FORMAT:
        case GIF_FORMAT:
        case TIFF_FORMAT:
        case JPG_FORMAT:
        case PSD_FORMAT:
            ret = NO;
            break;
        case PDF_FORMAT:
            ret = YES;
            break;
        default:
            ret = NO;
            break;
    }
    return ret;
}

- (NSString*)getExtFromFormat:(FileFormat)format
{
    NSString *ext = nil;
    switch (format) {
        case PNG_FORMAT:
            ext = @"png";
            break;
        case PDF_FORMAT:
            ext = @"pdf";
            break;
        case GIF_FORMAT:
            ext = @"gif";
            break;
        case PSD_FORMAT:
            ext = @"psd";
            break;
        case TIFF_FORMAT:
            ext = @"tif";
            break;
        case JPG_FORMAT:
            ext = @"jpg";
            break;
        default:
            break;
    }
    return ext;
}

- (BOOL)modifyExtention:(NSString*)srcPath realExt:(FileFormat)format
{
    NSString *extention = [srcPath pathExtension];
    NSString *targetExt = [self getExtFromFormat:format];
    
    if(!targetExt) return NO;
    
    NSString *makePath = [srcPath stringByReplacingOccurrencesOfString:extention withString:targetExt];
    NSError *er = nil;
    
    [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:makePath error:&er];
    if(er){
        LogF(@"%@", er.description);
        return NO;
    }
    return YES;
}

- (BOOL)checkFileFormat:(NSString*)imgPath
{
    FileFormat format = UNKNOWN_FORMAT;
    UInt16 magick;
    BOOL ret = [KZImage checkFormat:imgPath magick:&magick format:&format];
    _setting.magic = magick;
    
    if(ret)
    {
        NSString *extention = [[imgPath pathExtension] lowercaseString];
        NSString *realExt = [self getExtFromFormat:format];
        if(NEQ_STR(extention, realExt))
        {
            if(![self modifyExtention:imgPath realExt:format])
            {
                ret = NO;
            }
        }
        else
        {
            _setting.SourceFormat = format;
        }
    }
    
    return ret;
}

- (BOOL)ImageConvertMain:(NSString*)toPath
{    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *er = nil;
    
    if(!_setting.isMemory && toPath == nil)
    {
        Log(@"Please Set SavePath");
        return NO;
    }
    
    if(_setting.Resolution <= 0)
    {
        LogF(@"Invalid Resolution %f dpi", _setting.Resolution);
        return NO;
    }
    
    if(!_setting.isMemory && [fm fileExistsAtPath:toPath])
    {
        [fm removeItemAtPath:toPath error:&er];
        if(er){
            Log(er.description);
            return NO;
        }
    }
    
    BOOL opRet = YES;

    // resample dpi
    try {
        if([self isVips:_setting.SourceFormat])
        {
            opRet = [_vips resizeDPI:_setting.Resolution
                             useAnti:_setting.isUseAntiAlias
                          isResample:_setting.isResize];
        }
        else if ([self isIM:_setting.SourceFormat])
        {
            
        }
        else if ([self isPdfium:_setting.SourceFormat])
        {
            
        }
    } catch (NSException *ex) {
        opRet = NO;
        LogF(@"Resample Error! : %@", ex.description);
    }
    if(!opRet) return NO;
    
    // convert colorspace
    try {
        if([self isVips:_setting.SourceFormat])
        {
            opRet = [_vips changeColorSpace:_setting.toSpace];
        }
        else if ([self isIM:_setting.SourceFormat])
        {
            
        }
        else if ([self isPdfium:_setting.SourceFormat])
        {
            
        }
    } catch (NSException *ex) {
        opRet = NO;
        LogF(@"Convert Color Error! : %@", ex.description);
    }
    
    if(!opRet) return NO;
    
    if((_setting.SourceFormat != _setting.TargetFormat) &&
       !_setting.isMemory)
    {
        try {
            if([self isVips:_setting.SourceFormat])
            {
                opRet = [_vips saveToIMG:toPath format:_setting.TargetFormat];
            }
            else if ([self isIM:_setting.SourceFormat])
            {
                
            }
            else if ([self isPdfium:_setting.SourceFormat])
            {
                
            }
        } catch (NSException *ex) {
            opRet = NO;
            LogF(@"Convert Format Error! : %@", ex.description);
        }
    }

    return opRet;
}

#pragma mark -
#pragma mark Public Funcs


+ (BOOL)isSupported:(NSString*)imgPath
{
    UInt16 m;
    FileFormat f;
    return [self checkFormat:imgPath magick:&m format:&f];
}

- (BOOL)ImagetoPNG:(NSString*)pngPath
{
    _setting.TargetFormat = PNG_FORMAT;
    return [self ImageConvertMain:pngPath];
}

- (BOOL)ImagetoTIFF:(NSString*)tifPath
{
    _setting.TargetFormat = TIFF_FORMAT;
    return [self ImageConvertMain:tifPath];
}

#pragma mark -

- (BOOL)setImage:(NSString*)imgPath
{
    _imagePath = imgPath;
    
    if(![self checkFileFormat:_imagePath])
    {
        LogF(@"Unsupported Format!! MagicNumber=0x%lx",(unsigned long)_setting.magic);
        return NO;
    }
    
    return [_vips setImage:imgPath format:_setting.SourceFormat];
}

- (const void*)getImage
{
    return image_buffer;
}

- (void)clearImage
{
    [_vips clearImage];
}
@end
