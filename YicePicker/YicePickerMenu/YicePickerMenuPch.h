//
//  YicePickerMenuPch.h
//  YicePicker
//
//  Created by 音冰冰 on 2018/5/2.
//  Copyright © 2018年 音冰冰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kRGBColorFromHex(rgbValue)        [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0f green:((float)((rgbValue & 0xFF00) >> 8))/255.0f blue:((float)(rgbValue & 0xFF))/255.0f alpha:1.0f]

#define kPickerMenuSeperatorColor               kRGBColorFromHex(0xF3F3F4)
#define kPickerMenuSelectedCellColor            kRGBColorFromHex(0x05CBD8)
#define kPickerMenuUnselectedCellTextColor      kRGBColorFromHex(0x1D1D26)
#define kPickerMenuIndicatorColor               kRGBColorFromHex(0x02C1CD)
#define kPickerMenuTitleColor                   kRGBColorFromHex(0x1D1D26)

#define WS(weakSelf)                              __weak typeof(self) weakSelf = self

typedef struct {
    CGFloat ANIMATION_DURATION;
}YICEPICKERMENU_MENU_UI_VALUE;

typedef struct {
    CGFloat MAINTITLELABEL_FONT;
    
    CGFloat SUBTITLELABEL_FONT;
    CGFloat SUBTITLELABEL_TOPMARGIN;
    
    CGFloat ARROWVIEW_LEFTMARGIN;
    CGFloat ARROWVIEW_HEIGHT;
    CGFloat ARROWVIEW_WIDTH;
    
    CGFloat BOTTOMLINE_HEIGHT;
    CGFloat BOTTOMSEPERATOR_HEIGHT;
    CGFloat RIGHTSEPERATOR_WIDTH;
    
}YICEPICKERMENU_TITLEBUTTON_UI_VALUE;

typedef struct {
    CGFloat CELL_HEIGHT;
    CGFloat CELL_WIDTH;
    CGFloat LINESPACING;
    CGFloat INTERITEMSPACING;
    UIEdgeInsets SECTIONINSETS;
    CGSize ITEMSIZE;
    CGFloat CELL_LABEL_FONT;
    CGFloat CELL_LABEL_CORNERRADIUS;
    //  有多少列cell
    NSInteger VIEW_COLUMNCOUNT;
    CGFloat VIEW_TOP_BOTTOM_MARGIN;
    CGFloat VIEW_LEFT_RIGHT_MARGIN;
}YICEPICKERMENU_COLLECTIONVIEW_UI_VALUE;

YICEPICKERMENU_MENU_UI_VALUE *yicePickerMenuUIValue();
YICEPICKERMENU_TITLEBUTTON_UI_VALUE *yicePickerMenuTitleButtonUIValue();
YICEPICKERMENU_COLLECTIONVIEW_UI_VALUE *yicePickerMenuCollectionViewUIValue();

CGFloat deviceWidth();
CGFloat deviceHeight();

@interface YicePickerMenuPch : NSObject
@end
