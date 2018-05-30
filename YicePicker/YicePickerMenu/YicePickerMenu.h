//
//  YicePickerMenu.h
//  YicePicker
//
//  Created by 音冰冰 on 2018/5/2.
//  Copyright © 2018年 音冰冰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YiceTestModel.h"

@interface YiceIndexPath : NSObject

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;
+ (instancetype)indexPathWithColumn:(NSInteger)col row:(NSInteger)row;

@end

@class YicePickerMenu;

@protocol YicePickerMenuDataSource <NSObject>
@required
- (NSInteger)numberOfColumnsInMenu:(YicePickerMenu *)menu;
- (NSInteger)menu:(YicePickerMenu *)menu numberOfRowsInColumns:(NSInteger)column withSecondTypeIndex:(NSUInteger)index;
- (NSString *)menu:(YicePickerMenu *)menu titleForColumn:(NSInteger)column;
@optional
- (YiceTestModel *)menu:(YicePickerMenu *)menu titleForRowAtIndexPath:(YiceIndexPath *)indexPath withSecondTypeIndex:(NSUInteger)index;
- (NSArray *)menu:(YicePickerMenu *)menu SecondTypeTitlesInColumns:(NSInteger)column;//在一级筛选后还有二级筛选的情况
@end

@protocol YicePickerMenuDelegate <NSObject>

@optional
- (void)menu:(YicePickerMenu *)menu didSelectRowAtIndexPath:(YiceIndexPath *)indexPath;//单选
- (void)menu:(YicePickerMenu *)menu didSelectRowsAtIndexPaths:(NSArray<YiceIndexPath *>*)indexPaths withSecondTypeIndex:(NSUInteger)index withColumn:(NSUInteger)column;//多选
- (void)menu:(YicePickerMenu *)menu resetDataWithColumn:(NSUInteger)column;
@end

@interface YicePickerMenu : UIView
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, weak) id <YicePickerMenuDataSource>dataSource;
@property (nonatomic, weak) id <YicePickerMenuDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame withMultiSelect:(BOOL)multiSelect;
- (void)configMenuMainTitle;
- (void)backgroundViewDidTap;
@end
