//
//  vips_core.hpp
//  KZImage
//
//  Created by uchiyama_Macmini on 2019/03/22.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#ifndef vips_core_hpp
#define vips_core_hpp

#include <vips/vips8>
#include <stdio.h>


using namespace std;
using namespace vips;

class VipsCore
{
public:
    // typedef
    enum ColorSpace{
        GRAY = 0,
        SRGB = 1,
        CMYK = 2
    };
    
    enum FileFormat{
        TIFF_FORMAT = 0,
        PNG_FORMAT = 1,
        JPG_FORMAT = 2,
        GIF_FORMAT = 3,
    };
    
    // init
    VipsCore();
    VipsCore(const char* imgPath);
    ~VipsCore();
    bool vipsStart(const char* app_name);
    void vipsEnd();
    
    // instance
    VImage image;
    
    // function
    bool openImage(const char *imgPath, FileFormat format);
    bool resizeDPI(double targetDPI, bool useAnti, bool isResample);
    bool changeColorSpace(ColorSpace targetColor);
    bool saveToIMG(const char *savePath, FileFormat format); // savePath must includes filename
    void clearImage();
};

#endif /* vips_core_hpp */
