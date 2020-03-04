//
//  ModelItem.h
//  MyReactiveCocoaDemo
//
//  Created by ShanYuQin on 2020/3/4.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ModelItem : NSObject

@property (nonatomic , strong) NSString *method;
@property (nonatomic , strong) NSString *title;
+ (instancetype)item:(NSDictionary *)dic;
+ (NSArray *)models;

@end

NS_ASSUME_NONNULL_END
