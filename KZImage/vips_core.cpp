//
//  vips_core.cpp
//  KZImage
//
//  Created by uchiyama_Macmini on 2019/03/22.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#include "vips_core.hpp"

using namespace std;
using namespace vips;

#pragma mark -
#pragma mark Initialize

VipsCore::VipsCore()
{
}

VipsCore::VipsCore(const char* imgPath)
{
    image = VImage::new_from_file(imgPath, VImage::option()->set ("access", VIPS_ACCESS_SEQUENTIAL));
}

VipsCore::~VipsCore()
{
}

bool VipsCore::vipsStart(const char* app_name)
{
    if (VIPS_INIT(app_name))
    {
        vips_error_exit (NULL);
        return false;
    }
    return true;
}

void VipsCore::vipsEnd()
{
    vips_shutdown();
}

#pragma mark -
#pragma mark Internal Function
bool checkImage(VImage img)
{
    if(img.width() == 0) return false;
    if(img.height() == 0) return false;
    if(img.data() == nullptr) return false;
    if(img.xres() == 0) return false;
    if(img.yres() == 0) return false;
    return true;
}

#pragma mark -
#pragma mark Public Function

bool VipsCore::openImage(const char* imgPath, FileFormat format)
{
    bool ret = true;
    double res = 0;
    VImage tmp;
    image = VImage::new_from_file(imgPath, VImage::option()->set ("access", VIPS_ACCESS_SEQUENTIAL));
    switch (format) {
        case JPG_FORMAT:
            /*res = get_jpeg_density(imgPath);
            tmp = image.copy(VImage::option()->
                             set("xres", res)->
                             set("yres", res)->
                             set("resolution-unit", "in"));
            image = tmp;*/
            break;
            
        case PNG_FORMAT:
            /*double res = get_jpeg_density(imgPath);
            tmp = image.copy(VImage::option()->
                             set("xres", res)->
                             set("yres", res)->
                             set("resolution-unit", "in"));
            image = tmp;*/
            break;
            
        case GIF_FORMAT:
            /*double res = get_jpeg_density(imgPath);
             tmp = image.copy(VImage::option()->
             set("xres", res)->
             set("yres", res)->
             set("resolution-unit", "in"));
             image = tmp;*/
            break;
            
        case TIFF_FORMAT:
            /*double res = get_jpeg_density(imgPath);
             tmp = image.copy(VImage::option()->
             set("xres", res)->
             set("yres", res)->
             set("resolution-unit", "in"));
             image = tmp;*/
            break;
            
        default:
            ret = false;
            break;
    }
    return ret;
}

bool VipsCore::resizeDPI(double targetDPI, bool useAnti, bool isResample)
{
    if(!checkImage(image)) return false;
    VImage tmp;
    double resolution = vips_image_get_xres(image.get_image());
    resolution = round(resolution * 25.4);
    
    double scaleFactor =  targetDPI / resolution;
    double res = targetDPI / 25.4;
    if(isResample)
    {
        if(useAnti)
        {
            tmp = image.resize(scaleFactor);
        }
        else
        {
            tmp = image.shrink(scaleFactor, scaleFactor);
        }
        tmp = tmp.copy(VImage::option()->
                         set("xres", res)->
                         set("yres", res));
    }
    else
    {
        
        // xres/yres in pixels/mm
        // set_res(11.81, 11.81, "in") means 300 dpi
        tmp = image.copy(VImage::option()->
                         set("xres", res)->
                         set("yres", res));
    }
    
    if(tmp.get_image() == NULL) return false;
    
    image = tmp;
    return true;
}

bool VipsCore::changeColorSpace(ColorSpace targetColor)
{
    if(!checkImage(image)) return false;
    VImage tmp;
    VipsInterpretation space;
    
    switch (targetColor) {
        case GRAY:
            space = VIPS_INTERPRETATION_B_W;
            break;
        case SRGB:
            space = VIPS_INTERPRETATION_sRGB;
            break;
        case CMYK:
            space = VIPS_INTERPRETATION_CMYK;
            break;
        default:
            break;
    }
    
    tmp = image.colourspace(space);
    
    if(tmp.get_image() == NULL) return false;
    
    image = tmp;
    return true;
}

bool VipsCore::saveToIMG(const char *savePath, FileFormat format)
{
    bool retVal = true;
    switch (format) {
        case TIFF_FORMAT:
            image.tiffsave((char*)savePath,
                           VImage::option()->
                           set("compression", VIPS_FOREIGN_TIFF_COMPRESSION_LZW)->
                           set("predictor", VIPS_FOREIGN_TIFF_PREDICTOR_HORIZONTAL)->
                           set("resunit", VIPS_FOREIGN_TIFF_RESUNIT_INCH)->
                           set("xres", image.xres())->
                           set("yres", image.yres()));
            break;
            
        case PNG_FORMAT:
            image.pngsave((char*)savePath);
            break;
            
        case JPG_FORMAT:
            image.jpegsave((char*)savePath);
            break;
            
        default:
            retVal = false;
            break;
    }
    return retVal;
}

void VipsCore::clearImage()
{
    image.~VImage();
}
