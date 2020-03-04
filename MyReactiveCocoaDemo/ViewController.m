//
//  ViewController.m
//  MyReactiveCocoaDemo
//
//  Created by ShanYuQin on 2020/3/3.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import "ViewController.h"
#import "FirstTestViewController.h"
#import "SecondTestViewController.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic , strong) NSArray * dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"FirstTab";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.dataSource = @[@"各类型RAC的使用demo",@"复杂demo"];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const indefier = @"ssdsds";
       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indefier];
       if (!cell) {
           cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indefier];
       }
    cell.textLabel.text = self.dataSource[indexPath.row];
       return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FirstTestViewController * vc = [sb instantiateViewControllerWithIdentifier:@"FirstTestViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1) {
        
    }
}



@end
