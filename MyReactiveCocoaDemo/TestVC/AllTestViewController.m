//
//  AllTestViewController.m
//  MyReactiveCocoaDemo
//
//  Created by ShanYuQin on 2020/3/4.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import "AllTestViewController.h"
#import "ModelItem.h"

@interface AllTestViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@property (nonatomic , strong) NSArray *modelArr;
@property (nonatomic , strong) RACCommand *command;

@end

@implementation AllTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self.paramDic[@"title"] length]?self.paramDic[@"title"]:self.paramDic[@"method"];

    if (![self.paramDic[@"needTouchesBegin"] boolValue]) {
        [self executeMethod];
        
    }else {
        NSLog(@"请点击屏幕触发%@方法",self.paramDic[@"method"]);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (![self.paramDic[@"needTouchesBegin"] boolValue] || [self.paramDic[@"method"] length] == 0) {
        return;
    }
    [self executeMethod];
    
}


- (void)executeMethod {
   SEL sel = NSSelectorFromString(self.paramDic[@"method"]);
    if ([self respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector: sel withObject: nil];
//        NSLog(@"----------------%@方法已执行完毕----------------",self.paramDic[@"method"]);
#pragma clang diagnostic pop
    }
    if ([self.paramDic[@"bak"] length]) {
        NSLog(@" %@ ", self.paramDic[@"bak"]);
    }
        
}



- (void)testSubmitButton {
    self.tfLastName.hidden = self.tfFirstName.hidden = self.btnSubmit.hidden = NO;
    RAC(self.btnSubmit,enabled) = [RACSignal combineLatest:@[self.tfFirstName.rac_textSignal,self.tfLastName.rac_textSignal,] reduce:^id(NSString *firstName, NSString *lastName){
        return @(firstName.length >= 6 && lastName.length >= 6);
    }];

    [RACObserve(self.tfLastName,text) subscribeNext:^(NSString *newLastName) {
        NSLog(@"%@", newLastName);
    }];

    [[RACObserve(self.tfFirstName,text) filter:^BOOL(NSString *newFirstName) {
        return [newFirstName hasPrefix:@"S"];
    }] subscribeNext:^(NSString *newFirstName) {
        NSLog(@"%@", newFirstName);
    }];

}

- (void)testSimpleCreateSignle {
    /**
      RACSignal使用步骤：
      1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id subscriber))didSubscribe
      2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
      3.发送信号 - (void)sendNext:(id)value
    
逻辑：
    一.创建信号，
        1.首先把didSubscribe保存到信号中，但是当前是一个冷信号不会触发；
        2.didSubscribe 实际上就是一个负责控制信号源如何变化的一个block，每当有订阅者订阅信号就会调用这个block；
        3.下边的例子实际上信号的变化逻辑就是调用了sendNext：1，通过 next 事件向订阅者传送新的值；
        4.如果不再发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号；
        5.return的RACDisposable 其实就是所谓的清洁工，当调用了error和complete事件后，内部取消订阅信号后，
           如果你又什么想做的，就写一个这样的block，会在调用了error和complete事件后，自动执行。
           执行完后，当前信号就销毁不能再被订阅了。如果不需要其他操作返回nil也可以。
    二.订阅信号
        subscribeNext方法就是订阅了信号，此时会调用上边的didSubscribe，当有next事件调用后，就会调用后边的block

     */
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       [subscriber sendNext:@1];
       [subscriber sendCompleted];
       return [RACDisposable disposableWithBlock:^{
           NSLog(@"信号被销毁");
       }];
    }];
    
    [siganl subscribeNext:^(id x) {
        // block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据:%@",x);
    }];
}

- (void)testRACSubject  {
    /**
      1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
      2.可以先订阅信号，也可以先发送信号。
      3.但是先发送的信号不会被订阅者收到,但是RACReplaySubject是可以的
     */
    // 1.创建信号
      RACSubject *subject = [RACSubject subject];
      [subject sendNext:@"1"];
      // 2.订阅信号
      [subject subscribeNext:^(id x) {
          NSLog(@"RACSubject第一个订阅者%@",x);
      }];
      [subject subscribeNext:^(id x) {
          NSLog(@"RACSubject第二个订阅者%@",x);
      }];
      // 3.发送信号
      [subject sendNext:@"2"];
    
    
    [self testRACReplaySubject];
}

- (void)testRACReplaySubject  {
   /**
       RACReplaySubject:底层实现和RACSubject不一样。
       1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
       2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock

       如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
       也就是先保存值，在订阅值
    */
    // 1.创建信号
      RACReplaySubject *subject = [RACReplaySubject subject];
      [subject sendNext:@"1"];
      // 2.订阅信号
      [subject subscribeNext:^(id x) {
          NSLog(@"RACReplaySubject第一个订阅者%@",x);
      }];
      [subject subscribeNext:^(id x) {
          NSLog(@"RACReplaySubject第二个订阅者%@",x);
      }];
      // 3.发送信号
      [subject sendNext:@"2"];
    
}

- (void)testRACSequence_array {
    // 1.遍历数组
       NSArray *numbers = @[@1,@2,@3,@4];

       // 这里其实是三步
       // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
       // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
       // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
       [numbers.rac_sequence.signal subscribeNext:^(id x) {
           NSLog(@"%@",x);
       }];
}
- (void)testRACSequence_dic {
     // 2.遍历字典,遍历出来的键值对会包装成RACTuple(元组对象)
        NSDictionary *dict = @{@"name":@"xmg",@"age":@18};
        [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
            // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
            RACTupleUnpack(NSString *key,NSString *value) = x;
            // 相当于以下写法
    //        NSString *key = x[0];
    //        NSString *value = x[1];
            NSLog(@"%@ %@",key,value);

        }];
}
- (void)testRACSequence_transferToModel {
    NSArray *dictArr = [ModelItem models];
    NSMutableArray *modelArr = [NSMutableArray array];
    _modelArr = modelArr;
    // rac_sequence注意点：调用subscribeNext，并不会马上执行nextBlock，而是会等一会。
    [dictArr.rac_sequence.signal subscribeNext:^(id x) {
        // 运用RAC遍历字典，x：字典
        ModelItem *item = [ModelItem item:x];
        [modelArr addObject:item];
    } completed:^{
        NSLog(@"%@",self->_modelArr);
    }];
    

}

- (void)testRACSequence_transferToModel_2 {
    // map:映射的意思，目的：把原始值value映射成一个新值
    // array: 把集合转换成数组
    // 底层实现：当信号被订阅，会遍历集合中的原始值，映射成新值，并且保存到新的数组里。
    NSArray *dictArr = [ModelItem models];
    NSArray *modelArr = [[dictArr.rac_sequence map:^id(id value) {

        return [ModelItem item:value];

    }] array];
    NSLog(@"%@",modelArr);
}

- (void)testRACCommand {
    /**
      一、RACCommand使用步骤:
        1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
        2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
        3.执行命令 - (RACSignal *)execute:(id)input

      二、RACCommand使用注意:
      1.signalBlock必须要返回一个信号，不能返回nil.
      2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
      3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
      4.RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的。

      三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
      1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
      2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。

      四、如何拿到RACCommand中返回信号发出的数据。
      1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
      2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。

      五、监听当前命令是否正在执行executing

      六、使用场景,监听按钮点击，网络请求
     */
    
    // 1.创建命令
     RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
         NSLog(@"执行命令");
         // 如果是创建空信号,必须返回信号
         // return [RACSignal empty];

         // 2.创建信号,用来传递数据
         return [RACSignal createSignal:^RACDisposable *(id subscriber) {
             [subscriber sendNext:@"请求数据"];
             // 注意：数据传递完，最好调用sendCompleted，这时命令才执行完毕。
             [subscriber sendCompleted];
             return nil;
         }];
     }];
     // 强引用命令，不要被销毁，否则接收不到数据
    _command = command;
     // 3.1订阅RACCommand中的信号
     [command.executionSignals subscribeNext:^(id x) {
         [x subscribeNext:^(id x) {
             NSLog(@"executionSignals - %@",x);
         }];
     }];

     // 3.2 RAC高级用法
//    switchToLatest: 的作用是自动切换signal of signals到最后一个
     [command.executionSignals.switchToLatest subscribeNext:^(id x) {
         NSLog(@"switchToLatest - %@",x);
     }];

     // 4.监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
     [[command.executing skip:1] subscribeNext:^(id x) {
         if ([x boolValue] == YES) {
             // 正在执行
             NSLog(@"正在执行");
         }else{
             // 执行完成
             NSLog(@"执行完成");
         }
     }];
    // 5.执行命令
     [self.command execute:@1];
}

- (void)testRACMulticastConnection {
    /**
     用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理。
    RACMulticastConnection使用步骤:
        1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id subscriber))didSubscribe
        2.创建连接 RACMulticastConnection *connect = [signal publish];
        3.订阅信号,注意：订阅的不在是之前的信号，而是连接的信号。 [connect.signal subscribeNext:nextBlock]
        4.连接 [connect connect]

        RACMulticastConnection底层原理:
        1.创建connect，connect.sourceSignal -> RACSignal(原始信号)  connect.signal -> RACSubject
        2.订阅connect.signal，会调用RACSubject的subscribeNext，创建订阅者，而且把订阅者保存起来，不会执行block。
        3.[connect connect]内部会订阅RACSignal(原始信号)，并且订阅者是RACSubject
        3.1.订阅原始信号，就会调用原始信号中的didSubscribe
        3.2 didSubscribe，拿到订阅者调用sendNext，其实是调用RACSubject的sendNext
        4.RACSubject的sendNext,会遍历RACSubject所有订阅者发送信号。
        4.1 因为刚刚第二步，都是在订阅RACSubject，因此会拿到第二步所有的订阅者，调用他们的nextBlock

        需求：假设在一个信号中发送请求，每次订阅一次都会发送请求，这样就会导致多次请求。
        解决：使用RACMulticastConnection就能解决.
     */
    NSLog(@"未使用RACMulticastConnection-----------");
     // 1.创建请求信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
         NSLog(@"发送请求");
        [subscriber sendNext:@1];
         return nil;
     }];
     // 2.订阅信号
     [signal subscribeNext:^(id x) {
         NSLog(@"接收数据1");
     }];
     // 2.订阅信号
     [signal subscribeNext:^(id x) {
         NSLog(@"接收数据2");
     }];

     // 3.运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求

    NSLog(@"-----使用RACMulticastConnection-----------");
     // RACMulticastConnection:解决重复请求问题
     // 1.创建信号
     signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
         NSLog(@"发送请求");
         [subscriber sendNext:@1];
         return nil;
     }];
     // 2.创建连接
     RACMulticastConnection *connect = [signal publish];
     // 3.订阅信号，
     // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
     [connect.signal subscribeNext:^(id x) {
         NSLog(@"订阅者一信号");
     }];
     [connect.signal subscribeNext:^(id x) {
         NSLog(@"订阅者二信号");
     }];
     // 4.连接,激活信号
     [connect connect];
}

@end
