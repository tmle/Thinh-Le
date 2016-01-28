//
//  ListOfProductTableViewController.h
//  eCommerce-App
//
//  Created by Thinh Le on 2015-05-28.
//  Copyright (c) 2015 Skin Tree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoRecord.h"
#import "PhotoRecord2.h"
#import "PendingOperations.h"
#import "ImageDownloader.h"
#import "ImageFiltration.h"
#import "AFNetworking/AFNetworking.h"
#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>
#import "Product.h"
#import "ProductList.h"
#import "DetailProductDescriptionViewController.h"
#import "ProductCell.h"
#import "ProductSelected.h"

#define kDataSourceURLString @"https://thinhmle.com/test_upload/images/bacmymarket/ProductList-Supplement-04.plist" //array of dict,

@interface ListOfProductTableViewController : UITableViewController <ImageDownloaderDelegate, ImageFiltrationDelegate> //UITableViewDataSource, UITableViewDelegate

@property (strong, nonatomic) NSArray * productListing;
@property (strong, nonatomic) NSMutableArray * listOfProductsSelected;
@property (strong, nonatomic) NSMutableDictionary * dictOfProductOnCart;

@property (nonatomic, strong) NSMutableArray *photos; // main data source of controller
@property (nonatomic, strong) PendingOperations *pendingOperations;
@end
