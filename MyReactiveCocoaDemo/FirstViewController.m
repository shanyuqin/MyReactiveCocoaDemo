//
//  FirstViewController.m
//  MyReactiveCocoaDemo
//
//  Created by ShanYuQin on 2020/3/4.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import "FirstViewController.h"
#import "AllTestViewController.h"
@interface FirstViewController ()<UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic , strong) NSArray * dataSource;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"FirstTab";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self initDataSource];
    [self.tableView reloadData];
}

- (void)initDataSource {
    self.dataSource = @[@{@"method":@"testSubmitButton",
                          @"needTouchesBegin":@0,
                          @"bak":@""},
                        @{@"method":@"testSimpleCreateSignle",
                          @"title":@"创建信号"},
                        @{@"method":@"testRACSubject"},
                        @{@"method":@"testRACSequence_array",
                          @"title":@"遍历数组"},
                        @{@"method":@"testRACSequence_dic",
                          @"title":@"遍历字典"},
                        @{@"method":@"testRACSequence_transferToModel",
                          @"title":@"字典转模型"},
                        @{@"method":@"testRACSequence_transferToModel_2",
                          @"title":@"字典转模型——高级写法"},
                        @{@"method":@"testRACCommand",
                          @"title":@"RACCommand简单使用"},
                        @{@"method":@"testRACMulticastConnection",
                          @"title":@"RACMulticastConnection"}];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataSource[indexPath.row];
    
    static NSString * const indefier = @"ssdsds";
       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indefier];
       if (!cell) {
           cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indefier];
       }
    cell.textLabel.text = [dic[@"title"] length]?dic[@"title"]:dic[@"method"];
       return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataSource[indexPath.row];
    if ([dic[@"testVC"] isEqualToString:@""]) {
        
    }else {
        AllTestViewController * vc = [[AllTestViewController alloc] initWithNibName:@"AllTestViewController" bundle:nil];
        vc.paramDic = self.dataSource[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
