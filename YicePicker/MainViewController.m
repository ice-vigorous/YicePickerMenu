//
//  ViewController.m
//  YiceCommonPicker
//
//  Created by 音冰冰 on 2018/5/2.
//  Copyright © 2018年 音冰冰. All rights reserved.
//

#import "MainViewController.h"
#import "YicePickerMenu.h"
#import "YicePickerMenuPch.h"
#import "YicePickerCell.h"
#import "Masonry.h"
#import "YiceTestModel.h"
#define KSCREENH [UIScreen mainScreen].bounds.size.height
#define KSCREENW [UIScreen mainScreen].bounds.size.width
#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource,YicePickerMenuDelegate,YicePickerMenuDataSource>

@property (nonatomic, strong) NSMutableArray *mainTitleArray;
@property (nonatomic, strong) NSMutableArray *subTitleArray;
@property UITableView *lazyTableview;
@property NSMutableArray *lazyArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Test";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.lazyTableview];
    
    _mainTitleArray = [NSMutableArray arrayWithArray:@[@"分类", @"城市"]];
    _subTitleArray = [NSMutableArray arrayWithArray:@[@{@"titles":[NSMutableArray arrayWithArray:@[@"船舶物资",@"船舶设备和备件"]],@"subtitles":@[[NSMutableArray arrayWithArray:@[[self yiceTestModelWithString:@"衣物"], [self yiceTestModelWithString:@"防护器具"], [self yiceTestModelWithString:@"绳索"], [self yiceTestModelWithString:@"航海器具"], [self yiceTestModelWithString:@"滑车设备"], [self yiceTestModelWithString:@"喷涂设备及工具"], [self yiceTestModelWithString:@"餐具及厨房用具"], [self yiceTestModelWithString:@"船用油漆及辅料"], [self yiceTestModelWithString:@"洗涤和化学用品"], [self yiceTestModelWithString:@"气动和电动工具"], [self yiceTestModelWithString:@"金属材料"]]],[NSMutableArray arrayWithArray:@[[self yiceTestModelWithString:@"钢铁侠"], [self yiceTestModelWithString:@"无敌浩克"], [self yiceTestModelWithString:@"奇异博士"], [self yiceTestModelWithString:@"黑寡妇"], [self yiceTestModelWithString:@"幻视超人"], [self yiceTestModelWithString:@"美国队长"]]]]},@{@"subtitles":@[[NSMutableArray arrayWithArray:@[[self yiceTestModelWithString:@"上海"], [self yiceTestModelWithString:@"武汉"], [self yiceTestModelWithString:@"北京"]]]]}
                                                      ]];
    
    YicePickerMenu *menu = [[YicePickerMenu alloc] initWithFrame:CGRectMake(0, 0, deviceWidth(), 50.f) withMultiSelect:YES];
    menu.delegate = self;
    menu.dataSource = self;
    self.lazyTableview.tableHeaderView = menu;
    // Do any additional setup after loading the view, typically from a nib.
}

- (YiceTestModel*)yiceTestModelWithString:(NSString*)str{
    YiceTestModel *model = [YiceTestModel new];
    model.isSelected = @"";
    model.text = str;
    return model;
}

-(UITableView *)lazyTableview
{
    if (_lazyTableview==nil) {
        _lazyTableview=[[UITableView alloc] init];
        _lazyTableview.frame = CGRectMake(0, 64, KSCREENW, KSCREENH - 64);
        _lazyTableview.delegate = self;
        _lazyTableview.dataSource = self;
        _lazyTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _lazyTableview;
}

-(NSMutableArray *)lazyArray
{
    if (_lazyArray==nil) {
        _lazyArray=[[NSMutableArray alloc] initWithArray:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"]];
    }
    return _lazyArray;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lazyArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.lazyArray[indexPath.row];
    cell.backgroundColor = randomColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark ----- YicePicker delegate And datasource
- (NSInteger)numberOfColumnsInMenu:(YicePickerMenu *)menu
{
    return self.mainTitleArray.count;
}

- (NSInteger)menu:(YicePickerMenu *)menu numberOfRowsInColumns:(NSInteger)column withSecondTypeIndex:(NSUInteger)index
{
    NSDictionary *dicSubTitleArray = self.subTitleArray[column];
    return [((NSMutableArray*)dicSubTitleArray[@"subtitles"])[index] count];
}

- (NSString *)menu:(YicePickerMenu *)menu titleForColumn:(NSInteger)column
{
    return self.mainTitleArray[column];
}

- (YiceTestModel *)menu:(YicePickerMenu *)menu titleForRowAtIndexPath:(YiceIndexPath *)indexPath withSecondTypeIndex:(NSUInteger)index
{
    NSDictionary *dicDataArray = self.subTitleArray[indexPath.column];
    NSArray *arrayData = dicDataArray[@"subtitles"];
    NSArray *arrayIndexData = ((NSArray*)arrayData[index]);//直接最终的数据数组
    return ((YiceTestModel*)arrayIndexData[indexPath.row]);
}

- (NSArray *)menu:(YicePickerMenu *)menu SecondTypeTitlesInColumns:(NSInteger)column
{
    NSDictionary *dicSubTitleArray = self.subTitleArray[column];
    return (NSArray*)dicSubTitleArray[@"titles"];
}

//单选
- (void)menu:(YicePickerMenu *)menu didSelectRowAtIndexPath:(YiceIndexPath *)indexPath
{
    //    NSDictionary *dicSubTitleArray = self.subTitleArray[indexPath.column];
}

//多选
- (void)menu:(YicePickerMenu *)menu didSelectRowsAtIndexPaths:(NSArray<YiceIndexPath *>*)indexPaths withSecondTypeIndex:(NSUInteger)index withColumn:(NSUInteger)column
{
    //多选
    NSDictionary *dicDataArray = self.subTitleArray[column];
    NSArray *arrayData = dicDataArray[@"subtitles"];
    NSMutableArray *arrayIndexData = ((NSMutableArray*)arrayData[index]);
    NSMutableArray *arrayNewIndexData = [NSMutableArray  arrayWithArray:arrayIndexData];
    
    //更新单元格的数据源
    for (YiceTestModel *model in arrayNewIndexData){
        model.isSelected = @"NO";
    }
    for (YiceIndexPath *yiceIndexpath in indexPaths) {
        YiceTestModel*model = arrayNewIndexData[yiceIndexpath.row];
        model.isSelected = @"YES";//表示被选中
    }
    
    if ([[dicDataArray allKeys] containsObject:@"titles"]) {
        //有二级分类
        UIButton *PrevButton = [menu.collectionView viewWithTag:100 + index];
        NSString *str =PrevButton.titleLabel.text;
        NSMutableArray *arraySecondTitle = dicDataArray[@"titles"];
        if (str.length>0) {
            [arraySecondTitle replaceObjectAtIndex:index withObject:str];
        }
        NSString * title = self.mainTitleArray[column];
        NSUInteger num = 0 ;
        for (NSString *strs in arraySecondTitle) {
            if ([strs containsString:@"("]) {
                NSUInteger numNew = [[[strs componentsSeparatedByString:@"("][1] componentsSeparatedByString:@")"][0] integerValue];
                num = num + numNew;
            }
        }
        
        NSString *newTitle = [NSString stringWithFormat:@"%@(%lu)",[title containsString:@"("]?[title componentsSeparatedByString:@"("][0]:title,num];
        if (newTitle.length>0) {
            [self.mainTitleArray replaceObjectAtIndex:column withObject:newTitle];
        }
        
    }else{
        //没有二级分类
        NSString * title = self.mainTitleArray[column];
        NSString *newTitle = [NSString stringWithFormat:@"%@(%lu)",[title containsString:@"("]?[title componentsSeparatedByString:@"("][0]:title,(unsigned long)indexPaths.count];
        [self.mainTitleArray replaceObjectAtIndex:column withObject:newTitle];
    }
    [menu configMenuMainTitle];
    
}
- (void)menu:(YicePickerMenu *)menu resetDataWithColumn:(NSUInteger)column{
    
    //1.重置最低层分类;
    NSDictionary *dicDataArray = self.subTitleArray[column];
    NSArray *arrayData = dicDataArray[@"subtitles"];
    for (NSMutableArray < YiceTestModel*>* array in arrayData) {
        for (YiceTestModel *model in array) {
            model.isSelected = @"";
        }
    }
    
    //次级分类
    if ([[dicDataArray allKeys] containsObject:@"titles"]) {
        //有二级分类
        NSMutableArray *arraySecondTitle = dicDataArray[@"titles"];
        [arraySecondTitle replaceObjectAtIndex:0 withObject:@"船舶物资"];
        [arraySecondTitle replaceObjectAtIndex:1 withObject:@"船舶设备和备件"];
    }
    
    //3.总分类
    NSString *str = self.mainTitleArray[column];
    [self.mainTitleArray replaceObjectAtIndex:column withObject:([str containsString:@"("]?[str componentsSeparatedByString:@"("][0]:str)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
