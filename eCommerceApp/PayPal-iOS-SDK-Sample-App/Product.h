//
//  Product.h
//  eCommerce-App
//
//  Created by Thinh Le on 2015-05-28.
//  Copyright (c) 2015 Skin Tree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Product : NSManagedObject

@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *productId;
@property (nonatomic, strong) NSString *productThumbnail;
@property (nonatomic, strong) NSString *productImage;
@property (nonatomic, strong) NSString *productBrief;
@property (nonatomic, strong) NSString *productDescription;
@property (nonatomic, strong) NSString *productPrice;
@property (nonatomic, strong) NSString *productCurrency;
@property (nonatomic, strong) NSString *productWeight;
@property (nonatomic, strong) NSString *productUnit;
@property (nonatomic, strong) NSString *productQuantity;

@end
