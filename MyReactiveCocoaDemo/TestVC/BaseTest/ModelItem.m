//
//  ModelItem.m
//  MyReactiveCocoaDemo
//
//  Created by ShanYuQin on 2020/3/4.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import "ModelItem.h"

@implementation ModelItem

+ (instancetype)item:(NSDictionary *)dic {
    ModelItem *item = [[ModelItem alloc] init];
    item.method = dic[@"method"];
    item.title = dic[@"title"];
    return item;
}

+ (NSArray *)models {
   return  @[@{@"method":@"testSubmitButton",
               @"title":@"testSubmitButton"},
            @{@"method":@"testSimpleCreateSignle",
              @"title":@"创建信号"},
            @{@"method":@"testRACSubject"},
            @{@"method":@"testRACSequence_array",
              @"title":@"遍历数组"},
            @{@"method":@"testRACSequence_dic",
              @"title":@"遍历字典"},
            @{@"method":@"testRACSequence_transferToModel",
              @"title":@"字典转模型"},
            @{@"method":@"testRACSequence_transferToModel2",
              @"title":@"字典转模型——高级写法"}];
}


@end
