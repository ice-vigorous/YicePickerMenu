//
//  YicePickerFlowLayout.h
//  YicePicker
//
//  Created by 音冰冰 on 2018/5/4.
//  Copyright © 2018年 音冰冰. All rights reserved.
//

#import <UIKit/UIKit.h>
//collectionview对其方式
typedef NS_ENUM(NSInteger, YicePickerCollectViewAlignType) {
    HYCollectViewAlignLeft,
    HYCollectViewAlignMiddle,
    HYCollectViewAlignRight,
};
@interface YicePickerCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, readonly) YicePickerCollectViewAlignType alignType;

- (instancetype)initWithType:(YicePickerCollectViewAlignType)type;

@end
