//
//  CJFilterView.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/6/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "CJFilterView.h"
#import "GPUImage.h"

@interface CJFilterView()
@property (strong ,nonatomic)GPUImageEmbossFilter *embossFilter;
@property (strong ,nonatomic)GPUImageGrayscaleFilter *grayScaleFilter;
@property (strong ,nonatomic)GPUImageSepiaFilter *sepiaFilter;
@property (strong ,nonatomic)GPUImageSketchFilter *sketchFilter;
@property (strong ,nonatomic)GPUImageToonFilter *toonFilter;
@property (strong ,nonatomic)GPUImagePosterizeFilter *posterizeFilter;



@end

@implementation CJFilterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (GPUImageEmbossFilter *)embossFilter
{
    if (!_embossFilter){
        _embossFilter = [GPUImageEmbossFilter new];
        _embossFilter.intensity = 1.0;
    }
    return _embossFilter;
}


- (GPUImageGrayscaleFilter *)grayScaleFilter
{
    if (!_grayScaleFilter){
        _grayScaleFilter = [GPUImageGrayscaleFilter new];
    }
    return  _grayScaleFilter;
}

- (GPUImageSepiaFilter *)sepiaFilter
{
    if (!_sepiaFilter){
        _sepiaFilter = [GPUImageSepiaFilter new];
        
    }
    return _sepiaFilter;
}

- (GPUImageSketchFilter *)sketchFilter
{
    if (!_sketchFilter){
        _sketchFilter = [GPUImageSketchFilter new];
        
    }
    return _sketchFilter;
}

- (GPUImageToonFilter *)toonFilter
{
    if (!_toonFilter){
        _toonFilter = [GPUImageToonFilter new];
        _toonFilter.threshold = 0.2;
        _toonFilter.quantizationLevels = 10.0;
        
    }
    return _toonFilter;
}

- (GPUImagePosterizeFilter *)posterizeFilter
{
    if (!_posterizeFilter){
        _posterizeFilter = [GPUImagePosterizeFilter new];
        _posterizeFilter.colorLevels = 10;
    }
    return _posterizeFilter;
}
@end

