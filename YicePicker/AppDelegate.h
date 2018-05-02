//
//  AppDelegate.h
//  YicePicker
//
//  Created by 音冰冰 on 2018/5/2.
//  Copyright © 2018年 音冰冰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

