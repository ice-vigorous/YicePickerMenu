//
//  YicePickerMenu.m
//  YicePicker
//
//  Created by 音冰冰 on 2018/5/2.
//  Copyright © 2018年 音冰冰. All rights reserved.
//

#import "YicePickerMenu.h"
#import "YicePickerMenuPch.h"
#import "YicePickerCell.h"
#import "YicePickerCollectionViewFlowLayout.h"
#import "NSString+AdjustSize.h"
#import "Masonry.h"

const float kBaseTitleButtonTag = 2345;
const float kBaseReuseviewButtonTag = 1234;

typedef void(^YicePickerMenuAnimateCompleteHandler)(void);
@implementation YiceIndexPath
- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        _column = column;
        _row = row;
    }
    return self;
}

+ (instancetype)indexPathWithColumn:(NSInteger)col row:(NSInteger)row {
    YiceIndexPath *indexPath = [[self alloc] initWithColumn:col row:row];
    return indexPath;
}

@end

@interface YicePickerMenu()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, assign) NSInteger currentSelectedMenuIndex;//当前选中的
@property (nonatomic, assign) NSInteger numOfMenu;
@property (nonatomic, strong) UIButton *backgroundView;
@property (nonatomic, strong) UIView *coverLayerView;
@property (nonatomic, assign, getter=isShow) BOOL show;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) YicePickerCollectionViewFlowLayout *mainFlowLayout;
@property (nonatomic, weak) UIWindow *window;
//  dataSource
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSMutableArray *titleButtons;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) YicePickerCell *defaultSelectedCell;
@property (nonatomic, assign) NSUInteger selectedNum;
@property (nonatomic, assign) BOOL isMultiSelect;
//  附件功能按钮
@property (nonatomic, strong) UIView *viewHeader;//第二层细分类（第二栏）
@property (nonatomic, strong) UIView *viewBottom;//底部确认按钮栏
@property (nonatomic, strong) UIButton *btnReset;//重置按钮
@property (nonatomic, strong) UIButton *btnSure;//确认按钮
@property (nonatomic, assign) CGFloat originPointX;//控件的起始x坐标
@property (nonatomic, assign) NSUInteger secondTypeselectedIndex;
@end

static NSString * const collectionCellID = @"collectionCellID";

@implementation YicePickerMenu

- (instancetype)initWithFrame:(CGRect)frame withMultiSelect:(BOOL)multiSelect
{
    if (self = [super initWithFrame:frame]) {
        _currentSelectedMenuIndex = 0;//默认选中第一个
        _show = NO;
        _isMultiSelect = multiSelect;
        _selectedNum = 0;
        _secondTypeselectedIndex = 0;
        self.autoresizesSubviews = NO;
        _backgroundView = [UIButton buttonWithType:UIButtonTypeCustom];
        _backgroundView.userInteractionEnabled = YES;
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.f];
        _backgroundView.opaque = NO;
        [_backgroundView addTarget:self action:@selector(backgroundViewDidTap) forControlEvents:UIControlEventTouchUpInside];
        self.viewBottom.hidden = !_isMultiSelect;//是多选就有确认按钮
        _window = [self keyWindow];
    }
    return self;
}

-(UICollectionView *)collectionView
{
    if (_collectionView==nil) {
        self.mainFlowLayout = [[YicePickerCollectionViewFlowLayout alloc] initWithType:HYCollectViewAlignLeft];
        self.mainFlowLayout.sectionHeadersPinToVisibleBounds = YES;
        self.mainFlowLayout.sectionInset = UIEdgeInsetsMake(13, 15, 13, 15);
        self.mainFlowLayout.headerReferenceSize=CGSizeMake(deviceWidth()/3, 50);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.mainFlowLayout];
        _collectionView.allowsMultipleSelection = _isMultiSelect;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[YicePickerCell class] forCellWithReuseIdentifier:collectionCellID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizesSubviews = NO;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.bounces = NO;
        [self.collectionView registerClass:[UICollectionReusableView class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                       withReuseIdentifier:@"headerViewIdentifier"];
    }
    return _collectionView;
}

#pragma mark - setter
- (void)setFrame:(CGRect)frame
{
    frame = CGRectMake(frame.origin.x, frame.origin.y, deviceWidth(), frame.size.height);
    [super setFrame:frame];
}

- (void)setDataSource:(id<YicePickerMenuDataSource>)dataSource
{
    _dataSource = dataSource;
    _numOfMenu = [_dataSource numberOfColumnsInMenu:self];
    
    
    CGFloat width =  deviceWidth()  /_numOfMenu;
    
    _titleButtons = [NSMutableArray array];
    
    for (int index=0; index<_numOfMenu; index++) {
        
        UIButton *titleButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        titleButton.frame= CGRectMake(_originPointX + (width+0.5) * index, 0, width-0.5, 50);
        titleButton.backgroundColor = [UIColor whiteColor];
        [titleButton setTitle:[_dataSource menu:self titleForColumn:index] forState:UIControlStateNormal];
        [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [titleButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        titleButton.tag = kBaseTitleButtonTag + index ;
        [titleButton addTarget:self action:@selector(titleButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        titleButton.titleLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        titleButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [titleButton setImage:[UIImage imageNamed:@"jiantou_down"] forState:UIControlStateNormal];
        [titleButton setImage:[UIImage imageNamed:@"jiantou_up"] forState:UIControlStateSelected];
        
        
        
        [self addSubview:titleButton];
        [_titleButtons addObject:titleButton];
        [self refreshButtonAligment:titleButton];
        
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = [UIColor lightGrayColor];
        lineView.frame = CGRectMake(titleButton.frame.origin.x + titleButton.frame.size.width, titleButton.frame.origin.y + 10, 1, titleButton.frame.size.height - 20);
        [self addSubview:lineView];
        
    }
    
}

-(UIView *)viewBottom
{
    if (_viewBottom == nil) {
        _viewBottom = [[UIView alloc] init];
        _viewBottom.backgroundColor = [UIColor whiteColor];
        _viewBottom.bounds =  CGRectMake(0, 0, deviceWidth(), 50);
        
        _btnReset = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnReset.frame = CGRectMake(0, 0, deviceWidth()/2.0, 50);
        _btnReset.backgroundColor  = [UIColor lightGrayColor];
        [_btnReset setTitle:@"重置" forState:UIControlStateNormal];
        [_btnReset setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_btnReset addTarget:self action:@selector(resetPicker) forControlEvents:UIControlEventTouchUpInside];
        [_viewBottom addSubview:_btnReset];
        
        _btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnSure.frame = CGRectMake(deviceWidth()/2.0, 0, deviceWidth()/2.0, 50);
        _btnSure.backgroundColor = [UIColor blueColor];
        [_btnSure setTitle:@"确定" forState:UIControlStateNormal];
        [_btnSure addTarget:self action:@selector(surePicker) forControlEvents:UIControlEventTouchUpInside];
        [_viewBottom addSubview:_btnSure];
    }
    return _viewBottom;
}

#pragma mark - animation method
- (void)animationWithTitleButton:(UIButton *)button
                  BackgroundView:(UIView *)backgroundView
                  collectionView:(UICollectionView *)collectionView
                            show:(BOOL)isShow
                        complete:(YicePickerMenuAnimateCompleteHandler)complete
{
    WS(weakSelf);
    if (self.selectedButton == button)
    {
        button.selected = isShow;
        self.coverLayerView.hidden = NO;
    } else {
        button.selected = YES;
        self.selectedButton.selected = NO;
        self.selectedButton = button;
    }
    [self animationWithBackgroundView:backgroundView show:isShow complete:^{
        [weakSelf animationWithCollectionView:collectionView show:isShow complete:nil];
    }];
    if (complete) {
        complete();
    }
}

- (void)animationWithBackgroundView:(UIView *)backgroundView
                     collectionView:(UICollectionView *)collectionView
                               show:(BOOL)isShow
                           complete:(YicePickerMenuAnimateCompleteHandler)complete
{
    WS(weakSelf);
    [self animationWithBackgroundView:backgroundView show:isShow complete:^{
        [weakSelf animationWithCollectionView:collectionView show:isShow complete:nil];
    }];
    if (complete) {
        complete();
    }
}

- (void)animationWithBackgroundView:(UIView *)backgroundView
                               show:(BOOL)isShow
                           complete:(YicePickerMenuAnimateCompleteHandler)complete
{
    WS(weakSelf);
    if (isShow) {
        if (1 == clickCount)
        {
            [self.window addSubview:backgroundView];
            [backgroundView addSubview:self.collectionView];
            [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
                CGRect rect = [weakSelf convertRect:weakSelf.bounds toView:weakSelf.window];
                make.top.mas_equalTo(CGRectGetMaxY(rect));
                make.left.right.bottom.equalTo(weakSelf.window);
            }];
            [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(weakSelf.backgroundView);
                make.height.mas_equalTo(0.f);
            }];
            [backgroundView layoutIfNeeded];
        }
        [UIView animateWithDuration:yicePickerMenuUIValue()->ANIMATION_DURATION animations:^{
            backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        } completion:^(BOOL finished) {
        }];
    } else {
        [UIView animateWithDuration:yicePickerMenuUIValue()->ANIMATION_DURATION animations:^{
            backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [backgroundView removeFromSuperview];
            clickCount = 0;
        }];
    }
    if (complete) {
        complete();
    }
}

- (void)animationWithCollectionView:(UICollectionView *)collectionView
                               show:(BOOL)isShow
                           complete:(YicePickerMenuAnimateCompleteHandler)complete
{
    WS(weakSelf);
    if (isShow) {
        CGFloat collectionViewHeight = 0.f;
        if (collectionView) {
            
            NSUInteger numOfItems = [collectionView numberOfItemsInSection:0];
            YicePickerCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:[NSIndexPath indexPathForRow:numOfItems - 1 inSection:0]];
            collectionViewHeight = cell.frame.origin.y + 30 + 50;//高度
            CGFloat maxHeight = deviceHeight() - CGRectGetMaxY(self.frame) - (self.isMultiSelect?self.viewBottom.bounds.size.height:0) - 64 - 60;
            CGFloat minHeight = (deviceHeight() - 64 - 50)/2.0;
            
            collectionViewHeight = collectionViewHeight > maxHeight ? maxHeight : (collectionViewHeight < minHeight?minHeight:collectionViewHeight);
            
            if (1 == clickCount) {
                self.coverLayerView.hidden = NO;
                [UIView animateWithDuration:yicePickerMenuUIValue()->ANIMATION_DURATION animations:^{
                    [collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(collectionViewHeight);
                    }];
                    [collectionView.superview layoutIfNeeded];
                }completion:^(BOOL finished) {
                    weakSelf.coverLayerView.hidden = YES;
                    self.viewBottom.center = CGPointMake(deviceWidth()/2.0, CGRectGetMaxY(weakSelf.collectionView.frame) + 25);
                    [collectionView.superview addSubview:self.viewBottom];
                    NSLog(@"%d", self.collectionView.isUserInteractionEnabled);
                }];
            } else {
                [UIView animateWithDuration:yicePickerMenuUIValue()->ANIMATION_DURATION animations:^{
                    [collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(collectionViewHeight);
                    }];
                    [collectionView.superview layoutIfNeeded];
                } completion:^(BOOL finished) {
                    self.viewBottom.center = CGPointMake(deviceWidth()/2.0, CGRectGetMaxY(weakSelf.collectionView.frame) + 25);
                    [collectionView.superview addSubview:self.viewBottom];
                }];
                
            }
        }
        
    } else {
        
        if (collectionView)
        {
            [UIView animateWithDuration:yicePickerMenuUIValue()->ANIMATION_DURATION animations:^{
                [collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(0);
                }];
                [collectionView.superview layoutIfNeeded];
            } completion:^(BOOL finished) {
                [collectionView removeFromSuperview];
                weakSelf.coverLayerView.hidden = YES;
                clickCount = 0;
            }];
        }
        
    }
    if (complete) {
        complete();
    }
}

- (CGRect)screenBounds
{
    return [self keyWindow].bounds;
}

- (UIWindow *)keyWindow
{
    return [[UIApplication sharedApplication].delegate window];
}

#pragma mark -- lazyLoad
- (UIView *)coverLayerView
{
    if (_coverLayerView == nil) {
        _coverLayerView = [[UIView alloc] init];
        _coverLayerView.frame = [self screenBounds];
        _coverLayerView.backgroundColor = [UIColor clearColor];
        _coverLayerView.hidden = YES;
        [self.window addSubview:_coverLayerView];
    }
    return _coverLayerView;
}


#pragma mark - action method
static NSInteger clickCount;
- (void)titleButtonDidClick:(UIButton *)titleButton
{
    clickCount++;
    WS(weakSelf);
    if (titleButton.tag - kBaseTitleButtonTag != self.currentSelectedMenuIndex && self.isShow) {
        [self synchroFilterData];
    }
    if (titleButton.tag - kBaseTitleButtonTag == self.currentSelectedMenuIndex && self.isShow) {
        //点击的是同样的并且是展开状态，收回
        [self animationWithTitleButton:titleButton BackgroundView:self.backgroundView collectionView:self.collectionView show:NO complete:^{
            weakSelf.currentSelectedMenuIndex = titleButton.tag - kBaseTitleButtonTag;
            weakSelf.show = NO;
        }];
    } else {
        //点击的是不同的，或者是关闭着的，打开
        UICollectionReusableView *header = [self.collectionView viewWithTag:kBaseReuseviewButtonTag];
        [header.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.currentSelectedMenuIndex = titleButton.tag - kBaseTitleButtonTag;
        self.secondTypeselectedIndex = 0;//二级分类设置为第0个
        self.mainFlowLayout.headerReferenceSize = CGSizeMake(deviceWidth()/3, ([self.dataSource menu:self SecondTypeTitlesInColumns:self.currentSelectedMenuIndex].count>0?50:0));
        [self.collectionView reloadData];
        [self animationWithTitleButton:titleButton BackgroundView:self.backgroundView collectionView:self.collectionView show:YES complete:^{
            weakSelf.show = YES;
        }];
    }
}


- (void)backgroundViewDidTap
{
    WS(weakSelf);
    //保存原有的数据
    [self synchroFilterData];
    [self animationWithTitleButton:self.titleButtons[self.currentSelectedMenuIndex] BackgroundView:self.backgroundView collectionView:self.collectionView show:NO complete:^{
        weakSelf.show = NO;
    }];
}

#pragma mark - collectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource menu:self numberOfRowsInColumns:self.currentSelectedMenuIndex withSecondTypeIndex:self.secondTypeselectedIndex];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YicePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    cell.contentString = ((YiceTestModel*)[self.dataSource menu:self titleForRowAtIndexPath:[YiceIndexPath indexPathWithColumn:self.currentSelectedMenuIndex row:indexPath.row] withSecondTypeIndex:self.secondTypeselectedIndex]).text;
    if ([((YiceTestModel*)[self.dataSource menu:self titleForRowAtIndexPath:[YiceIndexPath indexPathWithColumn:self.currentSelectedMenuIndex row:indexPath.row] withSecondTypeIndex:self.secondTypeselectedIndex]).isSelected isEqualToString:@"YES"]) {
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }else{
        cell.selected = NO;
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
    return cell;
}

#pragma mark --UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //选中单元格
    [self.delegate menu:self didSelectRowAtIndexPath:[YiceIndexPath indexPathWithColumn:self.currentSelectedMenuIndex row:indexPath.row]];
    
    UIButton *PrevButton = [self.collectionView viewWithTag:100+self.secondTypeselectedIndex];
    NSString *str =PrevButton.titleLabel.text;
    if ([str containsString:@"("]) {
        
        str = [str componentsSeparatedByString:@"("][0];
    }
    [PrevButton setTitle:[NSString stringWithFormat:@"%@(%lu)",str,[self.collectionView indexPathsForSelectedItems].count] forState:UIControlStateNormal];
    
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中单元格
    UIButton *PrevButton = [self.collectionView viewWithTag:100+self.secondTypeselectedIndex];
    NSString *str =PrevButton.titleLabel.text;
    if ([str containsString:@"("]) {
        
        str = [str componentsSeparatedByString:@"("][0];
    }
    
    [PrevButton setTitle:[NSString stringWithFormat:@"%@(%lu)",str,[self.collectionView indexPathsForSelectedItems].count] forState:UIControlStateNormal];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *subTitle = ((YiceTestModel*)[self.dataSource menu:self titleForRowAtIndexPath:[YiceIndexPath indexPathWithColumn:self.currentSelectedMenuIndex row:indexPath.row] withSecondTypeIndex:self.secondTypeselectedIndex]).text;
    return CGSizeMake([subTitle yice_stringSizeWithFont:[UIFont systemFontOfSize:13.0] maxWidth:1000 maxHeight:30].width + 30, 30);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //如果是头视图
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerViewIdentifier" forIndexPath:indexPath];
        header.tag = kBaseReuseviewButtonTag;
        if ([self.dataSource menu:self SecondTypeTitlesInColumns:self.currentSelectedMenuIndex].count>0) {
            if (header.subviews.count==0){
                for (NSInteger index = 0; index < [self.dataSource menu:self SecondTypeTitlesInColumns:self.currentSelectedMenuIndex].count; index++){
                    UIButton * btnType = [UIButton buttonWithType:UIButtonTypeCustom];
                    btnType.tag = 100 + index;
                    btnType.titleLabel.font = [UIFont systemFontOfSize:yicePickerMenuCollectionViewUIValue()->CELL_LABEL_FONT];
                    btnType.frame = CGRectMake(deviceWidth()/([self.dataSource menu:self SecondTypeTitlesInColumns:self.currentSelectedMenuIndex].count)*index, 0, deviceWidth()/([self.dataSource menu:self SecondTypeTitlesInColumns:self.currentSelectedMenuIndex].count), 50);
                    [btnType addTarget:self action:@selector(secondTypeSelected:) forControlEvents:UIControlEventTouchUpInside];
                    [btnType setBackgroundColor:[UIColor lightGrayColor]];
                    if (index==0) {
                        [btnType setBackgroundColor:[UIColor whiteColor]];
                    }
                    [btnType setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    [btnType setTitle:[self.dataSource menu:self SecondTypeTitlesInColumns:self.currentSelectedMenuIndex][index] forState:UIControlStateNormal];
                    [header addSubview:btnType];
                }
                
            }else{
                for (NSInteger index = 0; index < [self.dataSource menu:self SecondTypeTitlesInColumns:self.currentSelectedMenuIndex].count; index++){
                    UIButton * btnType = [header viewWithTag:100+ index];
                    [btnType setTitle:[self.dataSource menu:self SecondTypeTitlesInColumns:self.currentSelectedMenuIndex][index] forState:UIControlStateNormal];
                }
            }
            
        }else{
            [header.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        };
        return header;
    }
    //如果底部视图
    return nil;;
    
}

#pragma mark -- custom selector

//更新button的对齐方式
-(void)refreshButtonAligment:(UIButton*)btn
{
#warning 前两句代码去掉会报错！要知什么原因，请听下回分解。
    CGFloat labelWidth=CGRectGetWidth(btn.titleLabel.frame);//
    CGFloat imageWidth=CGRectGetWidth(btn.imageView.frame);//
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, CGRectGetWidth(btn.titleLabel.frame), 0, 0 - CGRectGetWidth(btn.titleLabel.frame));
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, -CGRectGetWidth(btn.imageView.frame), 0, CGRectGetWidth(btn.imageView.frame));
}

-(void)secondTypeSelected:(UIButton*)btn{
    if (btn.tag - 100 == self.secondTypeselectedIndex) {
        return;//如果是点击的同一个选项，什么都不做
    }
    UIButton *PrevButton = [self.collectionView viewWithTag:100+self.secondTypeselectedIndex];
    [PrevButton setBackgroundColor:[UIColor lightGrayColor]];
    [btn setBackgroundColor:[UIColor whiteColor]];
    
    //保存原有的数据
    [self synchroFilterData];
    self.secondTypeselectedIndex = btn.tag - 100;//记录选中的是哪一个btn
    [self.collectionView reloadData];
}

- (void)configMenuMainTitle
{
    for (UIButton *button in _titleButtons) {
        NSString *strTitle = [self.dataSource menu:self titleForColumn:[_titleButtons indexOfObject:button]];
        [button setTitle:[strTitle containsString:@"(0)"]?[strTitle componentsSeparatedByString:@"("][0]:strTitle forState:UIControlStateNormal];
        [self refreshButtonAligment:button];
    }
}



- (void)resetPicker{
    //重置
    [self.delegate menu:self resetDataWithColumn:self.currentSelectedMenuIndex];
    [self.collectionView reloadData];
}

-(void)surePicker{
    //确认
    //保存原有的数据
    WS(weakSelf);
    [self synchroFilterData];
    //将没确认之前的选中的indexPath传过去
    [self animationWithTitleButton:self.titleButtons[self.currentSelectedMenuIndex] BackgroundView:self.backgroundView collectionView:self.collectionView show:NO complete:^{
        weakSelf.show = NO;
    }];
}
//同步选中的筛选类
-(void)synchroFilterData{
    NSArray<YiceIndexPath *>* arraySelectedIndexPaths = (NSArray<YiceIndexPath *>*)[self.collectionView indexPathsForSelectedItems];
    [self.delegate menu:self didSelectRowsAtIndexPaths:arraySelectedIndexPaths withSecondTypeIndex:self.secondTypeselectedIndex withColumn:self.currentSelectedMenuIndex];
}

@end

