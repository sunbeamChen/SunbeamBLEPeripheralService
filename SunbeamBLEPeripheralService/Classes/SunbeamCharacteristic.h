//
//  SunbeamCharacteristic.h
//  Pods
//
//  Created by sunbeam on 2017/2/7.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SunbeamCharacteristic : NSObject

@property (nonatomic, copy) NSString* characteristicUUIDString;

@property (nonatomic, assign) CBCharacteristicProperties properties;

@property (nonatomic, copy) NSString* cacheValue;

@property (nonatomic, assign) CBAttributePermissions permissions;

@end
