//
//  SunbeamBLEPeripheralManager.h
//  Pods
//
//  Created by sunbeam on 2017/2/7.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SunbeamCharacteristic.h"

#define SUNBEAM_BLE_PERIPHERAL_SERVICE_VERSION @"0.1.1"

// 蓝牙功能开启关闭通知
typedef void(^BluetoothStateChanged)(BOOL isOn);

// 开始广播回调
typedef void(^DidStartAdvertisingBlock)(CBPeripheral* peripheral, NSError* error);

// 添加外设服务回调
typedef void(^DidAddPeripheralServiceBlock)(CBPeripheral* peripheral, CBService* service, NSError* error);

// 订阅特征值回调
typedef void(^DidSubscribeCharacteristicBlock)(CBPeripheral* peripheral, CBCentral * central, CBCharacteristic* characteristic);

// 取消订阅特征值回调
typedef void(^DidUnSubscribeCharacteristicBlock)(CBPeripheral* peripheral, CBCentral * central, CBCharacteristic* characteristic);

// 收到read请求
typedef void(^DidReceiveReadRequestBlock)(CBPeripheral* peripheral, CBATTRequest* request);

// 收到write请求
typedef void(^DidReceiveWriteRequestsBlock)(CBPeripheral* peripheral, NSArray<CBATTRequest *>* requests);

// update value to characteristic failed block
typedef void(^DidUpdateValueToSubscribeFaliedBlock)(CBPeripheral* peripheral);

@interface SunbeamBLEPeripheralManager : NSObject

/**
 蓝牙功能是否开启
 */
@property (nonatomic, assign) BOOL isBluetoothEnabled;

/**
 外设是否正在广播
 */
@property (nonatomic, assign) BOOL isAdvertising;

/**
 外设的所有服务
 */
@property (nonatomic, strong) NSMutableArray* services;

/**
 单例
 
 @return SunbeamBLEPeripheralManager
 */
+ (SunbeamBLEPeripheralManager *)sharedSunbeamBLEPeripheralManager;

/**
 初始化外设管理器

 @param queue 队列
 @param options 配置
 */
- (void)initSunbeamBLEPeripheralManager:(dispatch_queue_t)queue options:(NSDictionary<NSString *, id> *)options;

/**
 开始监听蓝牙状态
 
 @param bluetoothStateChanged 蓝牙状态改变回调
 */
- (void)startListenBluetoothState:(BluetoothStateChanged) bluetoothStateChanged;

/**
 添加外设服务

 @param serviceUUIDString 服务UUID
 @param characteristics 服务特征值数组(一个服务对应多个特征值)
 */
- (void)addPeripheralService:(NSString *)serviceUUIDString characteristics:(NSArray<SunbeamCharacteristic *> *)characteristics didAddPeripheralServiceBlock:(DidAddPeripheralServiceBlock)didAddPeripheralServiceBlock;

/**
 移除所有服务
 */
- (void)removeAllService;

/**
 开始广播数据

 @param advertisementData 广播数据{key有：CBAdvertisementDataLocalNameKey、CBAdvertisementDataServiceUUIDsKey}
 */
- (void)startAdvertising:(NSDictionary<NSString *,id> *)advertisementData didStartAdvertisingBlock:(DidStartAdvertisingBlock)didStartAdvertisingBlock didSubscribeCharacteristicBlock:(DidSubscribeCharacteristicBlock)didSubscribeCharacteristicBlock didUnSubscribeCharacteristicBlock:(DidUnSubscribeCharacteristicBlock)didUnSubscribeCharacteristicBlock didReceiveReadRequestBlock:(DidReceiveReadRequestBlock)didReceiveReadRequestBlock didReceiveWriteRequestsBlock:(DidReceiveWriteRequestsBlock)didReceiveWriteRequestsBlock;

/**
 停止广播数据
 */
- (void)stopAdvertising;

/**
 收到peripheralManager:didReceiveReadRequest:或者peripheralManager:didReceiveWriteRequests:时进行相应请求操作

 @param request 请求
 @param result 收到数据后操作结果
 */
- (void)respondToRequest:(CBATTRequest *)request withResult:(CBATTError)result;

/**
 像订阅指定特征值的中心设备发送数据

 @param value 发送的数据
 @param characteristicUUIDString 特征值UUID
 */
- (void)updateCharacteristicValue:(NSString *)value characteristicUUIDString:(NSString *)characteristicUUIDString didUpdateValueToSubscribeFaliedBlock:(DidUpdateValueToSubscribeFaliedBlock)didUpdateValueToSubscribeFaliedBlock;

@end
