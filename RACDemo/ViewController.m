//
//  ViewController.m
//  RACDemo
//
//  Created by shiwei on 17/6/15.
//  Copyright © 2017年 shiwei. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveObjC.h"
#import "Person.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *RACAcion;
@property (weak, nonatomic) IBOutlet UITextField *RACFiled;
@property (weak, nonatomic) IBOutlet UITextView *RACTextView;

@property (nonatomic, strong) id<RACSubscriber> subscriber;
@property (nonatomic, strong) Person *person;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
 }

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // KVO
    // 在这里改变name的值
    self.person.name = [NSString stringWithFormat:@"ThinkDifferent%u", arc4random_uniform(10000)];
    
    // 通知 - 退下键盘
    [self.view endEditing:true];
}

#pragma mark - 创建 -- 订阅 -- 发送
- (void)demo1 {
    
    // 创建信号必须先订阅
    // 订阅信号必须先发送
    
    // 创建信号(冷信号)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // 发送信号
        [subscriber sendNext:@"This is RAC"];
        
        return nil;
    }];
    
    
    // 订阅信号(热信号)
    [signal subscribeNext:^(id  _Nullable x) {
        // x : 指的是信号本身的数据内容
        NSLog(@"x = %@", x);
    }];

}

#pragma mark - 取消订阅
- (void)demo2 {
    // 1.信号发送完成
    // 2.信号发送失败
    
    // 订阅的取消取决于 `subscriber` 是否存在
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"this is RAC"];
        self.subscriber = subscriber;
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"我取消了订阅");
        }];
    }];
    RACDisposable *disposable = [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"disposable - %@", x);
    }];
    [disposable dispose];
}

#pragma mark - KVO
- (void)demo3 {
    // KVO
    self.person = [[Person alloc] init];
    // 监听 person 的 name 属性
    [_RACObserve(self.person, name) subscribeNext:^(id  _Nullable x) {
        NSLog(@"name - %@", x);
    }];
}

#pragma mark - action target
- (void)demo4 {
    
    // target
    [[self.RACAcion rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"Click - RACAcion");
    }];
}

#pragma mark - 通知
- (void)demo5 {
    
    // 通知, 监听键盘弹出通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidChangeFrameNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"motification - %@", x);
    }];
    
}

#pragma mark - 文本框代理
- (void)demo6 {
    
    // 充当textView的代理
    [[self.RACTextView rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"textView - %@", x);
    }];
}

// asi http终结者  ios 2 MRC
// 网络异步请求  ios 5
// block ios 4

// AFN ARC

@end
