//
//  SBPSViewController.m
//  SunbeamBLEPeripheralService
//
//  Created by sunbeamChen on 02/07/2017.
//  Copyright (c) 2017 sunbeamChen. All rights reserved.
//

#import "SBPSViewController.h"
#import "Masonry.h"
#import "SVProgressHUD.h"
#import <SunbeamBLEPeripheralService/SunbeamBLEPeripheralService.h>

#define PeripheralName @"Sunbeam_Peripheral" //外围设备名称
#define ServiceUUID @"C4FB2349-72FE-4CA2-94D6-1F3CB16331EE" //服务的UUID
#define NotifyCharacteristicUUID @"6A3E4B28-522D-4B3B-82A9-D5E2004534FB" //特征的UUID
#define WriteCharacteristicUUID @"6A3E4B28-522D-4B3B-82A9-D5E2004534FC" //特征的UUID

@interface SBPSViewController ()

@property (nonatomic, strong) UIButton* addServiceButton;

@property (nonatomic, strong) UIButton* startAdvertisingButton;

@property (nonatomic, strong) UIButton* stopAdvertisingButton;

@property (nonatomic, strong) UIButton* notifyValueButton;

@property (nonatomic, strong) UIButton* writeValueButton;

@end

@implementation SBPSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self initSubView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addService
{
    [SVProgressHUD showInfoWithStatus:@"添加服务"];
    
    SunbeamCharacteristic* characteristic1 = [[SunbeamCharacteristic alloc] init];
    characteristic1.characteristicUUIDString = NotifyCharacteristicUUID;
    characteristic1.properties = CBCharacteristicPropertyNotify;
    characteristic1.cacheValue = nil;
    characteristic1.permissions = CBAttributePermissionsReadable;
    
    SunbeamCharacteristic* characteristic2 = [[SunbeamCharacteristic alloc] init];
    characteristic2.characteristicUUIDString = WriteCharacteristicUUID;
    characteristic2.properties = CBCharacteristicPropertyWrite;
    characteristic2.cacheValue = nil;
    characteristic2.permissions = CBAttributePermissionsWriteable;
    
    [[SunbeamBLEPeripheralManager sharedSunbeamBLEPeripheralManager] addPeripheralService:ServiceUUID characteristics:@[characteristic1, characteristic2] didAddPeripheralServiceBlock:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===添加服务:%@, %@, %@", peripheral, service, error);
    }];
}

- (void)startAdvertising
{
    [SVProgressHUD showInfoWithStatus:@"开始广播"];
    // 初始化广播数据
    NSDictionary* advertisingData = @{CBAdvertisementDataLocalNameKey:PeripheralName,
                                      CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:ServiceUUID]]};
    
    [[SunbeamBLEPeripheralManager sharedSunbeamBLEPeripheralManager] startAdvertising:advertisingData didStartAdvertisingBlock:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"===开始广播:%@, %@", peripheral, error);
        NSLog(@"===peripheral服务：%@", peripheral.services);
    } didSubscribeCharacteristicBlock:^(CBPeripheral *peripheral, CBCentral *central, CBCharacteristic *characteristic) {
        NSLog(@"===订阅服务:%@, %@, %@", peripheral, central, characteristic);
    } didUnSubscribeCharacteristicBlock:^(CBPeripheral *peripheral, CBCentral *central, CBCharacteristic *characteristic) {
        NSLog(@"===取消订阅服务:%@, %@, %@", peripheral, central, characteristic);
    } didReceiveReadRequestBlock:^(CBPeripheral *peripheral, CBATTRequest *request) {
        NSLog(@"===读取数据:%@, %@", peripheral, request);
    } didReceiveWriteRequestsBlock:^(CBPeripheral *peripheral, NSArray<CBATTRequest *> *requests) {
        NSLog(@"===写入数据:%@, %@", peripheral, requests);
    }];
}

- (void)stopAdvertising
{
    [SVProgressHUD showInfoWithStatus:@"停止广播"];
    
    [[SunbeamBLEPeripheralManager sharedSunbeamBLEPeripheralManager] stopAdvertising];
}

- (void)notifyValue
{
    [SVProgressHUD showInfoWithStatus:@"发送通知"];
}

- (void)writeValue
{
    [SVProgressHUD showInfoWithStatus:@"写入数据"];
}

- (void)initSubView
{
    [self.view addSubview:self.addServiceButton];
    [self.view addSubview:self.startAdvertisingButton];
    [self.view addSubview:self.stopAdvertisingButton];
    [self.view addSubview:self.notifyValueButton];
    [self.view addSubview:self.writeValueButton];
    
    [self updateSubViewConstraints];
}

- (void)updateSubViewConstraints
{
    [self.addServiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(50);
        make.left.mas_equalTo(self.view.mas_left).offset(20);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    [self.startAdvertisingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.addServiceButton.mas_bottom).offset(30);
        make.left.right.height.mas_equalTo(self.addServiceButton);
    }];
    
    [self.stopAdvertisingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.startAdvertisingButton.mas_bottom).offset(30);
        make.left.right.height.mas_equalTo(self.startAdvertisingButton);
    }];
    
    [self.notifyValueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.stopAdvertisingButton.mas_bottom).offset(30);
        make.left.right.height.mas_equalTo(self.stopAdvertisingButton);
    }];
    
    [self.writeValueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.notifyValueButton.mas_bottom).offset(30);
        make.left.right.height.mas_equalTo(self.notifyValueButton);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - view
- (UIButton *)addServiceButton
{
    if (_addServiceButton == nil) {
        _addServiceButton = [[UIButton alloc] init];
        _addServiceButton.backgroundColor = [UIColor redColor];
        [_addServiceButton setTitle:@"添加服务" forState:UIControlStateNormal];
        [_addServiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_addServiceButton addTarget:self action:@selector(addService) forControlEvents:UIControlEventTouchUpInside];
        _addServiceButton.showsTouchWhenHighlighted = YES;
    }
    
    return _addServiceButton;
}

- (UIButton *)startAdvertisingButton
{
    if (_startAdvertisingButton == nil) {
        _startAdvertisingButton = [[UIButton alloc] init];
        _startAdvertisingButton.backgroundColor = [UIColor redColor];
        [_startAdvertisingButton setTitle:@"开始广播" forState:UIControlStateNormal];
        [_startAdvertisingButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startAdvertisingButton addTarget:self action:@selector(startAdvertising) forControlEvents:UIControlEventTouchUpInside];
        _startAdvertisingButton.showsTouchWhenHighlighted = YES;
    }
    
    return _startAdvertisingButton;
}

- (UIButton *)stopAdvertisingButton
{
    if (_stopAdvertisingButton == nil) {
        _stopAdvertisingButton = [[UIButton alloc] init];
        _stopAdvertisingButton.backgroundColor = [UIColor redColor];
        [_stopAdvertisingButton setTitle:@"停止广播" forState:UIControlStateNormal];
        [_stopAdvertisingButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_stopAdvertisingButton addTarget:self action:@selector(stopAdvertising) forControlEvents:UIControlEventTouchUpInside];
        _stopAdvertisingButton.showsTouchWhenHighlighted = YES;
    }
    
    return _stopAdvertisingButton;
}

- (UIButton *)notifyValueButton
{
    if (_notifyValueButton == nil) {
        _notifyValueButton = [[UIButton alloc] init];
        _notifyValueButton.backgroundColor = [UIColor redColor];
        [_notifyValueButton setTitle:@"发送通知" forState:UIControlStateNormal];
        [_notifyValueButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_notifyValueButton addTarget:self action:@selector(notifyValue) forControlEvents:UIControlEventTouchUpInside];
        _notifyValueButton.showsTouchWhenHighlighted = YES;
    }
    
    return _notifyValueButton;
}

- (UIButton *)writeValueButton
{
    if (_writeValueButton == nil) {
        _writeValueButton = [[UIButton alloc] init];
        _writeValueButton.backgroundColor = [UIColor redColor];
        [_writeValueButton setTitle:@"写入数据" forState:UIControlStateNormal];
        [_writeValueButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_writeValueButton addTarget:self action:@selector(writeValue) forControlEvents:UIControlEventTouchUpInside];
        _writeValueButton.showsTouchWhenHighlighted = YES;
    }
    
    return _writeValueButton;
}

@end
