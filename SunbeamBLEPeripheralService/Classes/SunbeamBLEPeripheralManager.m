//
//  SunbeamBLEPeripheralManager.m
//  Pods
//
//  Created by sunbeam on 2017/2/7.
//
//

#import "SunbeamBLEPeripheralManager.h"

@interface SunbeamBLEPeripheralManager() <CBPeripheralManagerDelegate>

/**
 外设对象管理器
 */
@property (nonatomic, strong) CBPeripheralManager* sunbeamPeripheralManager;

/**
 存储所有对应特征值{"characteristicUUIDString":"CBCharacteristic"}
 */
@property (nonatomic, strong) NSMutableDictionary* characteristicList;

/**
 存储所有对应中心设备{"characteristicUUIDString":{"identifier":CBCentral}}
 */
@property (nonatomic, strong) NSMutableDictionary* centralList;

/**
 蓝牙状态改变回调block
 */
@property (nonatomic, strong) BluetoothStateChanged bluetoothStateChangedBlock;

/**
 开始广播回调block
 */
@property (nonatomic, strong) DidStartAdvertisingBlock didStartAdvertisingBlock;

/**
 添加外设服务回调block
 */
@property (nonatomic, strong) DidAddPeripheralServiceBlock didAddPeripheralServiceBlock;

/**
 订阅特征值回调block
 */
@property (nonatomic, strong) DidSubscribeCharacteristicBlock didSubscribeCharacteristicBlock;

/**
 取消订阅特征值回调block
 */
@property (nonatomic, strong) DidUnSubscribeCharacteristicBlock didUnSubscribeCharacteristicBlock;

/**
 收到read请求回调block
 */
@property (nonatomic, strong) DidReceiveReadRequestBlock didReceiveReadRequestBlock;

/**
 收到write请求回调block
 */
@property (nonatomic, strong) DidReceiveWriteRequestsBlock didReceiveWriteRequestsBlock;

/**
 收到update value failed回调block
 */
@property (nonatomic, strong) DidUpdateValueToSubscribeFaliedBlock didUpdateValueToSubscribeFaliedBlock;

@end

@implementation SunbeamBLEPeripheralManager

/**
 单例
 
 @return SunbeamBLEPeripheralManager
 */
+ (SunbeamBLEPeripheralManager *)sharedSunbeamBLEPeripheralManager
{
    static SunbeamBLEPeripheralManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)initSunbeamBLEPeripheralManager:(dispatch_queue_t)queue options:(NSDictionary<NSString *,id> *)options
{
    NSLog(@"sunbeam BLE peripheral service version %@", SUNBEAM_BLE_PERIPHERAL_SERVICE_VERSION);
    self.isBluetoothEnabled = NO;
    self.sunbeamPeripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:queue options:options];
}

- (void)startListenBluetoothState:(BluetoothStateChanged) bluetoothStateChanged
{
    if (bluetoothStateChanged) {
        self.bluetoothStateChangedBlock = bluetoothStateChanged;
    } else {
        NSLog(@"bluetooth state changed block should not be nil");
    }
}

- (void)addPeripheralService:(NSString *)serviceUUIDString characteristics:(NSMutableArray<SunbeamCharacteristic *> *)characteristics didAddPeripheralServiceBlock:(DidAddPeripheralServiceBlock)didAddPeripheralServiceBlock
{
    NSMutableArray* CBCharacteristics = [[NSMutableArray alloc] init];
    for (SunbeamCharacteristic* characteristic in characteristics) {
        CBUUID *characteristicUUID = [CBUUID UUIDWithString:characteristic.characteristicUUIDString];
        NSData* value = nil;
        if (characteristic.cacheValue) {
            value = [characteristic.cacheValue dataUsingEncoding:NSUTF8StringEncoding];
        }
        CBMutableCharacteristic *CBCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:characteristic.properties value:value permissions:characteristic.permissions];
        [CBCharacteristics addObject:CBCharacteristic];
        
        [self.characteristicList setObject:characteristic.characteristicUUIDString forKey:CBCharacteristic];
    }
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:serviceUUIDString];
    CBMutableService *CBService = [[CBMutableService alloc]initWithType:serviceUUID primary:YES];
    [CBService setCharacteristics:CBCharacteristics];
    
    [self.sunbeamPeripheralManager addService:CBService];
    
    if (didAddPeripheralServiceBlock == nil) {
        NSLog(@"peripheral did add service block should not be nil");
        return;
    }
    self.didAddPeripheralServiceBlock = didAddPeripheralServiceBlock;
}

- (void)removeAllService
{
    [self.sunbeamPeripheralManager removeAllServices];
    [self.services removeAllObjects];
    [self.characteristicList removeAllObjects];
}

- (void)startAdvertising:(NSDictionary<NSString *,id> *)advertisementData didStartAdvertisingBlock:(DidStartAdvertisingBlock)didStartAdvertisingBlock didSubscribeCharacteristicBlock:(DidSubscribeCharacteristicBlock)didSubscribeCharacteristicBlock didUnSubscribeCharacteristicBlock:(DidUnSubscribeCharacteristicBlock)didUnSubscribeCharacteristicBlock didReceiveReadRequestBlock:(DidReceiveReadRequestBlock)didReceiveReadRequestBlock didReceiveWriteRequestsBlock:(DidReceiveWriteRequestsBlock)didReceiveWriteRequestsBlock
{
    [self.sunbeamPeripheralManager startAdvertising:advertisementData];
    
    if (didStartAdvertisingBlock == nil) {
        NSLog(@"peripheral did start advertising block should not be nil");
        return;
    }
    self.didStartAdvertisingBlock = didStartAdvertisingBlock;
    if (didSubscribeCharacteristicBlock == nil) {
        NSLog(@"peripheral did subscribe characteristic block should not be nil");
        return;
    }
    self.didSubscribeCharacteristicBlock = didSubscribeCharacteristicBlock;
    if (didUnSubscribeCharacteristicBlock == nil) {
        NSLog(@"peripheral did unsubscribe characteristic block should not be nil");
        return;
    }
    self.didUnSubscribeCharacteristicBlock = didUnSubscribeCharacteristicBlock;
    if (didReceiveReadRequestBlock == nil) {
        NSLog(@"peripheral did receive read request block should not be nil");
        return;
    }
    self.didReceiveReadRequestBlock = didReceiveReadRequestBlock;
    if (didReceiveWriteRequestsBlock == nil) {
        NSLog(@"peripheral did receive write requests block should not be nil");
        return;
    }
    self.didReceiveWriteRequestsBlock = didReceiveWriteRequestsBlock;
}

- (void)stopAdvertising
{
    [self.sunbeamPeripheralManager stopAdvertising];
}

- (void)updateCharacteristicValue:(NSString *)value characteristicUUIDString:(NSString *)characteristicUUIDString didUpdateValueToSubscribeFaliedBlock:(DidUpdateValueToSubscribeFaliedBlock)didUpdateValueToSubscribeFaliedBlock
{
    if (didUpdateValueToSubscribeFaliedBlock == nil) {
        NSLog(@"peripheral did update value to subscribe failed block should not be nil");
        return;
    }
    self.didUpdateValueToSubscribeFaliedBlock = didUpdateValueToSubscribeFaliedBlock;
    
    [self.sunbeamPeripheralManager updateValue:[value dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:[self.characteristicList objectForKey:characteristicUUIDString] onSubscribedCentrals:nil];
}

- (BOOL)isAdvertising
{
    return self.sunbeamPeripheralManager.isAdvertising;
}

#pragma mark - peripheral manager delegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBManagerStatePoweredOn:
            self.isBluetoothEnabled = YES;
            if (self.bluetoothStateChangedBlock) {
                self.bluetoothStateChangedBlock(YES);
            }
            break;
            
        case CBManagerStatePoweredOff:
        case CBManagerStateUnauthorized:
        case CBManagerStateUnsupported:
        case CBManagerStateResetting:
        case CBManagerStateUnknown:
        default:
            self.isBluetoothEnabled = NO;
            if (self.bluetoothStateChangedBlock) {
                self.bluetoothStateChangedBlock(NO);
            }
            break;
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error
{
    NSLog(@"开始广播 %@, %@", peripheral, error);
    if (self.didStartAdvertisingBlock == nil) {
        NSLog(@"peripheral did start advertising block should not be nil");
        return;
    }
    self.didStartAdvertisingBlock(peripheral, error);
    self.didStartAdvertisingBlock = nil;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(nullable NSError *)error
{
    NSLog(@"添加服务 %@, %@, %@", peripheral, service, error);
    [self.services addObject:service];
    
    if (self.didAddPeripheralServiceBlock == nil) {
        NSLog(@"peripheral did add service block should not be nil");
        return;
    }
    self.didAddPeripheralServiceBlock(peripheral, service, error);
    self.didAddPeripheralServiceBlock = nil;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"订阅特征值 %@, %@, %@", peripheral, central, characteristic);
    [self addCentralToList:central characteristic:characteristic];
    NSLog(@"订阅后所有central list为:%@", self.centralList);
    
    if (self.didSubscribeCharacteristicBlock == nil) {
        NSLog(@"peripheral did subscribe characteristic block should not be nil");
        return;
    }
    self.didSubscribeCharacteristicBlock(peripheral, central, characteristic);
}

- (void)addCentralToList:(CBCentral *)central characteristic:(CBCharacteristic *)characteristic
{
    NSString* characteristicUUIDString = characteristic.UUID.UUIDString;
    NSMutableDictionary* centralDict = [self.centralList objectForKey:characteristicUUIDString];
    if (centralDict == nil) {
        centralDict = [[NSMutableDictionary alloc] init];
    }
    [centralDict setObject:central forKey:central.identifier.UUIDString];
    [self.centralList setObject:centralDict forKey:characteristicUUIDString];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"取消订阅特征值 %@, %@, %@", peripheral, central, characteristic);
    [self removeCentralFromList:central characteristic:characteristic];
    NSLog(@"取消订阅后所有central list为:%@", self.centralList);
    
    if (self.didUnSubscribeCharacteristicBlock == nil) {
        NSLog(@"peripheral did unsubscribe characteristic block should not be nil");
        return;
    }
    self.didUnSubscribeCharacteristicBlock(peripheral, central, characteristic);
}

- (void)removeCentralFromList:(CBCentral *)central characteristic:(CBCharacteristic *)characteristic
{
    NSString* characteristicUUIDString = characteristic.UUID.UUIDString;
    NSMutableDictionary* centralDict = [self.centralList objectForKey:characteristicUUIDString];
    if (centralDict == nil) {
        return;
    }
    [centralDict removeObjectForKey:central.identifier.UUIDString];
    [self.centralList setObject:centralDict forKey:characteristicUUIDString];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"收到read请求 %@, %@", peripheral, request);
    if (self.didReceiveReadRequestBlock == nil) {
        NSLog(@"peripheral did receive read request block should not be nil");
        return;
    }
    self.didReceiveReadRequestBlock(peripheral, request);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    NSLog(@"收到write请求 %@, %@", peripheral, requests);
    if (self.didReceiveWriteRequestsBlock == nil) {
        NSLog(@"peripheral did receive write requests block should not be nil");
        return;
    }
    self.didReceiveWriteRequestsBlock(peripheral, requests);
}

/*!
 *  @method peripheralManagerIsReadyToUpdateSubscribers:
 *
 *  @param peripheral   The peripheral manager providing this update.
 *
 *  @discussion         This method is invoked after a failed call to @link updateValue:forCharacteristic:onSubscribedCentrals: @/link, when <i>peripheral</i> is again
 *                      ready to send characteristic value updates.
 *
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    NSLog(@"外设准备更新数据给所有订阅者 %@", peripheral);
    if (self.didUpdateValueToSubscribeFaliedBlock == nil) {
        NSLog(@"peripheral did update value to subscribe failed block should not be nil");
        return;
    }
    self.didUpdateValueToSubscribeFaliedBlock(peripheral);
}

#pragma mark - private method
- (NSMutableArray *)services
{
    if (_services == nil) {
        _services = [[NSMutableArray alloc] init];
    }
    
    return _services;
}

- (NSMutableDictionary *)characteristicList
{
    if (_characteristicList == nil) {
        _characteristicList = [[NSMutableDictionary alloc] init];
    }
    
    return _characteristicList;
}

- (NSMutableDictionary *)centralList
{
    if (_centralList == nil) {
        _centralList = [[NSMutableDictionary alloc] init];
    }
    
    return _centralList;
}

@end
