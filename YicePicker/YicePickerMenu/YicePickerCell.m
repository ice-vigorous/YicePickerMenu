//
//  YicePickerCell.m
//  YicePicker
//
//  Created by 音冰冰 on 2018/5/2.
//  Copyright © 2018年 音冰冰. All rights reserved.
//

#import "YicePickerCell.h"
#import "YicePickerMenuPch.h"
#import "Masonry.h"
@implementation YicePickerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self viewConfig];
    }
    return self;
}

- (void)viewConfig
{
    WS(weakSelf);
    self.label = [[UILabel alloc] init];
    self.label.layer.cornerRadius = 5;
    self.label.layer.masksToBounds = YES;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.backgroundColor = [UIColor lightGrayColor];
    self.label.font = [UIFont systemFontOfSize:yicePickerMenuCollectionViewUIValue()->CELL_LABEL_FONT];
    [self addSubview:self.label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
}

- (void)setContentString:(NSString *)contentString
{
    _contentString = [contentString copy];
    _label.text = _contentString;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    _label.backgroundColor = selected ? kPickerMenuSelectedCellColor : [UIColor lightGrayColor];
    _label.textColor = selected ? [UIColor whiteColor] : kPickerMenuUnselectedCellTextColor;
}

@end
