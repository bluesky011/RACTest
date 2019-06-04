//
//  ViewController.m
//  RACTest
//
//  Created by linyansen on 2019/6/4.
//  Copyright © 2019 linyansen. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()<UIGestureRecognizerDelegate>

@property(nonatomic,copy)NSString *textString;
@property(nonatomic,strong) id subscriber ;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    textField.backgroundColor = [UIColor redColor];
    [textField.rac_textSignal subscribeNext:^(id x){
        NSLog(@"%@",x);
    }];
    [self.view addSubview:textField];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 200, 100, 40);
    [btn setBackgroundColor:[UIColor redColor]];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    RACSignal *firstSignal = [textField.rac_textSignal map:^(NSString *firstString){
        NSInteger length = firstString.length;
        if (length>=5&&length<=10) {
            return @(YES);
        }
        return @(NO);
    }];
    
    RAC(btn,enabled) = [RACSignal combineLatest:@[firstSignal] reduce:^(NSNumber *firstRes){
        return @(firstRes.boolValue);
    }];
    
    
    
    
    self.textString = @"123";
    self.textString = @"456";
    self.textString = @"ddd";
    [RACObserve(self, textString) subscribeNext: ^(NSString *newString){
        NSLog(@"newString = %@", newString);
    }];
    self.textString = @"ads";
    self.textString = @"adsmmmm";
    
    
    //NSNotification 添加信号
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"MYNOTIFICATION" object:nil]subscribeNext:^(NSNotification *noti) {
        NSLog(@"*****  Notification Received  %@ *****",noti.userInfo[@"data"]);
    }];
    
    NSNotification *noti1 = [[NSNotification alloc]initWithName:@"MYNOTIFICATION" object:nil userInfo:@{@"data":[NSString stringWithFormat:@"%d",arc4random()%100]}];
    [[NSNotificationCenter defaultCenter]postNotification:noti1];
    
    
    NSNotification *noti2 = [[NSNotification alloc]initWithName:@"MYNOTIFICATION" object:nil userInfo:@{@"data":[NSString stringWithFormat:@"%d",arc4random()%100]}];
    [[NSNotificationCenter defaultCenter]postNotification:noti2];
    
    //button
    UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
    bu.frame = CGRectMake(20, 400, 300, 40);
    bu.backgroundColor = [UIColor orangeColor];
    [self.view  addSubview:bu];
    [[bu rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        NSLog(@"*****  响应RAC button的点击  *****");
    }];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //手势
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
    [[tap rac_gestureSignal] subscribeNext:^(UITapGestureRecognizer * tap) {
        NSLog(@"*****  响应单击手势  *****");
    }];
    
    //    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 100, 40)];
    //    back.backgroundColor = [UIColor greenColor];
    //    back.userInteractionEnabled = YES;
    //    [self.view addSubview:back];
    
    
    //    self.view.userInteractionEnabled = YES;
    //    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClick:)];
    //    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    
    
    //    [[RACScheduler mainThreadScheduler]afterDelay:2 schedule:^{
    //        NSLog(@"*****  first 延时rac写法  *****");
    //    }];
    //
    //    [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSDate * date) {
    //        NSLog(@"***** second 延时rac写法  *****");
    //    }];
    
    
    // 处理多个请求，都返回结果的时候，统一做处理.
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 发送请求1
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求2
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    
    // 使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
    [self rac_liftSelector:@selector(totalFuctonR1:R2:) withSignalsFromArray:@[request1,request2]];
    
    
    // 把参数中的数据包装成元组
    RACTuple *tuple = RACTuplePack(@"xmg",@20,@"m",@(999),@[@"a"],@{@"key":@"value"});
    
    RACTupleUnpack(NSString *name,NSNumber *age,NSString *sex,NSNumber *price,NSArray *arr,NSDictionary *dic) = tuple;
    NSLog(@"name:%@  age:%@  sex:%@  price:%@ arr:%@  dic:%@",name,age,sex,price,arr,dic);
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 300, 300, 40)];
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    RAC(label,text) = textField.rac_textSignal;
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id  _Nonnull subscriber) {
        NSLog(@"block excute");
        [subscriber sendNext:@"haha"];
        _subscriber = subscriber ;//如果不保存的话就会自动[subscriber sendCompleted];
        RACDisposable * disponse = [RACDisposable disposableWithBlock:^{
            NSLog(@"当信号发送完成或者发送错误，就会自动执行这个block,执行完Block后，当前信号就不在被订阅了。");
        }];
        return disponse;
        
    }];
    
    // 订阅信号
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",[NSString stringWithFormat:@"receive:%@",x]);
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",[NSString stringWithFormat:@"receive:%@",x]);
    }];
}

- (void)btnClick:(UIButton *)sender
{
    NSLog(@"enable");
}

- (void)viewClick:(UITapGestureRecognizer *)sender
{
    NSLog(@"viewClick");
}


-(void)totalFuctonR1:(id)data1 R2:(id)data2{
    NSLog(@"总方法触发:data1 = %@    -----  data2 = %@",data1,data2);
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isKindOfClass:[UIButton class]]) {
        //放过button点击拦截
        return NO;
    }else{
        return YES;
    }
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_subscriber sendNext:@"lol"];
    [_subscriber sendCompleted];
    [_subscriber sendNext:@"lalala"]; // 不会执行
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
