//
//  ListOfProductTableViewController.m
//  eCommerce-App
//
//  Created by Thinh Le on 2015-05-28.
//  Copyright (c) 2015 Skin Tree. All rights reserved.
//

#import "ListOfProductTableViewController.h"

@interface ListOfProductTableViewController ()
@property NSArray *products;
@end

@implementation ListOfProductTableViewController
{
    //NSString * _key;
    NSString * _prodName;
    UIImage  * _prodThumbnail;
    UIImage  * _prodImage;
    NSString * _prodBrief;
    NSString * _prodDescription;
    NSString * _prodPrice;
    NSString * _prodCurrency;
    NSNumber * _prodWeight;
    NSString * _prodUnit;

    NSString * _prodId;
        
    //NSArray  * _prodSelected;
    NSDictionary  * _prodSelected;
    PhotoRecord2  * _recordSelected;
    
    NSInteger _num_accessing_photos;
    NSInteger _numDownload;
    
    NSMutableArray * tempRecord;
}

@synthesize photos = _photos;
@synthesize pendingOperations = _pendingOperations;

- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"%@", [PayPalMobile libraryVersion]);
    
    [self requestData];
    
    //productListing stored locally - for testing purpose
//    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:NSLocalizedString(@"ProductList-Supplement-01", @"ProductList-Supplement-04") ofType:@"plist"];
//    self.productListing = [[NSArray alloc] initWithContentsOfFile:resourcePath];
//    NSArray *newArray   = [[NSArray alloc] initWithContentsOfFile:resourcePath];

    //productListing stored remotely using non-thread download
    NSURL *dataSourceURL = [NSURL URLWithString:kDataSourceURLString];
    self.productListing = [[NSArray alloc] initWithContentsOfURL:dataSourceURL];
    
    self.navigationItem.title = @"Supplements";
    
    if (self.listOfProductsSelected == nil) {
        self.listOfProductsSelected = [[NSMutableArray alloc] init];
    }
    
    if (self.dictOfProductOnCart == nil) {
        self.dictOfProductOnCart = [[NSMutableDictionary alloc] init];
    }
}

- (void)viewDidUnload {
    [self setPendingOperations:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [self cancelAllOperations];
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.products.count;
    return count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"ProductCell";
    ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[ProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 1
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = activityIndicatorView;
    }
    
    //== beginning of ClassicPhoto example
    // 2
    PhotoRecord2 *aRecord = [self.photos objectAtIndex:indexPath.row];

    // 3    
    if (aRecord.hasImage) {
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        //cell.productThumbnail.image = [UIImage imageWithData:imageData];
        cell.productThumbnail.image = aRecord.recordThumbnailData;
        cell.productPrice.text = aRecord.recordPrice;
        //NSLog(@"finish downloading image %d", indexPath.row);
    }
    // 4
    else if (aRecord.isFailed) {
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.productThumbnail.image = [UIImage imageNamed:@"Failed.png"];
        cell.productPrice.text = @"N/A";
        //cell.textLabel.text = @"Failed to load";
        
    }
    // 5
    else {
        [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
        cell.productThumbnail.image = [UIImage imageNamed:@"Placeholder.png"];
        [self startOperationsForPhotoRecord:aRecord atIndexPath:indexPath];
    }
    
    cell.productName.text = aRecord.recordName;
    cell.productBrief.text = aRecord.recordBrief;
    cell.productPrice.text = aRecord.recordPrice;
    cell.productCurrency.text = aRecord.recordCurrency;
 
     if (!tableView.dragging && !tableView.decelerating) {
        [self startOperationsForPhotoRecord:aRecord atIndexPath:indexPath];
     }
    // == end of ClassicPhotos example */
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    PhotoRecord2 *bRecord = [self.photos objectAtIndex:indexPath.row];
    _recordSelected = bRecord;
    _prodId        = bRecord.recordId;
    _prodPrice     = bRecord.recordPrice;
    _prodSelected  = [self.productListing objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"ShowDetailProductDescription" sender:self];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDetailProductDescription"]) {
        DetailProductDescriptionViewController * detailProductDescriptionViewController = (DetailProductDescriptionViewController *)segue.destinationViewController;
        detailProductDescriptionViewController.prodSelected_t            = _prodSelected; // more important
        detailProductDescriptionViewController.listOfProductsSelected    = self.listOfProductsSelected;
        detailProductDescriptionViewController.dictOfProductOnCart       = self.dictOfProductOnCart;
    }
}

- (void)startOperationsForPhotoRecord:(PhotoRecord2 *)record atIndexPath:(NSIndexPath *)indexPath {
    
    if (!record.hasImage) {
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
    }

    if (!record.isFiltered) {
        [self startImageFiltrationForRecord:record atIndexPath:indexPath];
    }
}

- (void)startImageDownloadingForRecord:(PhotoRecord2 *)record atIndexPath:(NSIndexPath *)indexPath {
    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
        
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
}

- (void)startImageFiltrationForRecord:(PhotoRecord2 *)record atIndexPath:(NSIndexPath *)indexPath {
    if (![self.pendingOperations.filtrationsInProgress.allKeys containsObject:indexPath]) {
        
        ImageFiltration *imageFiltration = [[ImageFiltration alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        
        ImageDownloader *dependency = [self.pendingOperations.downloadsInProgress objectForKey:indexPath];
        if (dependency)
            [imageFiltration addDependency:dependency];
        
        [self.pendingOperations.filtrationsInProgress setObject:imageFiltration forKey:indexPath];
        [self.pendingOperations.filtrationQueue addOperation:imageFiltration];
    }
}

#pragma mark - Image Downloader delegate
- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}

#pragma mark - Image Filtration delegate
- (void)imageFiltrationDidFinish:(ImageFiltration *)filtration {
    NSIndexPath *indexPath = filtration.indexPathInTableView;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.pendingOperations.filtrationsInProgress removeObjectForKey:indexPath];
}

#pragma mark -
#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self suspendAllOperations];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnscreenCells];
        [self resumeAllOperations];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenCells];
    [self resumeAllOperations];
}

#pragma mark - Cancelling, suspending, resuming queues / operations

- (void)suspendAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:YES];
    [self.pendingOperations.filtrationQueue setSuspended:YES];
}

- (void)resumeAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:NO];
    [self.pendingOperations.filtrationQueue setSuspended:NO];
}

- (void)cancelAllOperations {
    [self.pendingOperations.downloadQueue cancelAllOperations];
    [self.pendingOperations.filtrationQueue cancelAllOperations];
}

- (void)loadImagesForOnscreenCells {
    
    NSSet *visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.downloadsInProgress allKeys]];
    [pendingOperations addObjectsFromArray:[self.pendingOperations.filtrationsInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    [toBeStarted minusSet:pendingOperations];
    [toBeCancelled minusSet:visibleRows];
    
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        
        ImageDownloader *pendingDownload = [self.pendingOperations.downloadsInProgress objectForKey:anIndexPath];
        [pendingDownload cancel];
        [self.pendingOperations.downloadsInProgress removeObjectForKey:anIndexPath];
        
        ImageFiltration *pendingFiltration = [self.pendingOperations.filtrationsInProgress objectForKey:anIndexPath];
        [pendingFiltration cancel];
        [self.pendingOperations.filtrationsInProgress removeObjectForKey:anIndexPath];
    }
    toBeCancelled = nil;
    
    for (NSIndexPath *anIndexPath in toBeStarted) {
        
        PhotoRecord2 *recordToProcess = [self.photos objectAtIndex:anIndexPath.row];
        [self startOperationsForPhotoRecord:recordToProcess atIndexPath:anIndexPath];
    }
    toBeStarted = nil;
    
}

#pragma mark - RESTKit
- (void)requestData {
    NSString *requestPath = @"/api/ProductList_4.json"; //dict of dict, json list of products with full details
        
    [[RKObjectManager sharedManager]
     getObjectsAtPath:requestPath
     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         //articles have been saved in core data by now
         [self fetchProductsFromContext];
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
     }
     ];
}

- (void)fetchProductsFromContext {
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ProductList"];
    
//    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"categoryId" ascending:YES];
//    fetchRequest.sortDescriptors = @[descriptor];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    ProductList *productList = [fetchedObjects firstObject];
    self.products = [productList.rel2Product allObjects];
    //NSLog(@"finish downloading and storing productList");
    
    // list of products are not in order, have to order it.
    // step 1: form a temporary array-of-keys based on the single key-in-question
    NSMutableArray *unsortedArray = [[NSMutableArray alloc] init];
    for (int i=0; i<self.products.count; i++) {
        Product *tproduct = self.products[i];
        [unsortedArray addObject:tproduct.productId];
    }
    
    // step 2: sort the temporary array-of-keys into sorted-array-of-keys
    NSArray *sortedArray =[unsortedArray sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    //NSLog(@"sortedArray entries = %@", sortedArray);
    
    // step3: form the sorted array-of-products using sorted-array-of-keys
    BOOL found = NO;
    NSMutableArray *sortedArrayOfProducts = [[NSMutableArray alloc] init];
    for (int j = 0; j<sortedArray.count; j++) {
        NSString *tempString = sortedArray[j];
        //NSLog(@"tempString = %@", sortedArray[j]);
        for (int k=0; k<self.products.count; k++) {
            Product *tproduct = self.products[k];
            //NSDictionary *tempDict = [newArray objectAtIndex:k];
            //NSLog(@"tempDict = %@", tempDict);
            if (found == NO) {
                //for (NSString *key in [tempDict allKeys]) {
                    //the value of this key must be a string for comparison
                    //if ([tempDict[key] isKindOfClass:[NSString class]]) {
                        if ([tproduct.productId isEqualToString:tempString]) {
                            found = YES;
                            //NSLog(@"found = %d", found);
                        } // if
                    //} // if
                    
                //} // for key
                if (found == YES) {
                    //NSLog(@"copy the entire dictionary having %@", tempString);
                    // copy the tempDict onto sortedArrayOfProducts atIndex j
                    sortedArrayOfProducts[j] = tproduct;
                    found = NO;
                }
            } // if not found
        } // for k
    } // for j

    self.products = sortedArrayOfProducts;
    [self.tableView reloadData];

//    NSMutableDictionary *tempDict = [NSMutableDictionary mutableCopy]; //[[NSMutableDictionary alloc] init];
//    for (int k=0; k<self.products.count; k++) {
//        Product *product = self.products[k];
//        //NSLog(@"product = %@", product);
//        ProductSelected *prodSelected = [[ProductSelected alloc] init];
//        
//        prodSelected.prodSelName = product.productName;
//        prodSelected.prodSelId = product.productId;
//        
//        NSURL *url = [NSURL URLWithString:product.productThumbnail];
//        NSData *thumbnailData = [[NSData alloc] initWithContentsOfURL:url];
//        UIImage *thumbnailImage = [UIImage imageWithData:thumbnailData];
//        prodSelected.prodSelThumbnail = thumbnailImage;
//        
//        NSURL *imageUrl = [NSURL URLWithString:product.productImage];
//        NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageUrl];
//        UIImage *fullImage = [UIImage imageWithData:imageData];
//        prodSelected.prodSelImage = fullImage;
//        
//        prodSelected.prodSelBrief = product.productBrief;
//        prodSelected.prodSelDescription = product.productDescription;
//        prodSelected.prodSelPrice = [NSNumber numberWithInt:[product.productPrice floatValue]];
//        prodSelected.prodSelCurrency = product.productCurrency;
//        prodSelected.prodSelWeight = [NSNumber numberWithInt:[product.productWeight floatValue]];
//        prodSelected.prodSelUnit = product.productUnit;
//        prodSelected.prodSelQuantity = [NSNumber numberWithInt:[product.productQuantity floatValue]];
//        
//        //NSLog(@"Record2 - name, URL: %@, %@", record.recordName, record.recordThumbnailURL);
//        //[tempDict setObject:prodSelected forKey:nil];
//        prodSelected = nil;
//    }
//    
//    self.productListing = tempDict;
    
    //==
    NSMutableArray *records2 = [[NSMutableArray array] init];
    //NSLog(@"self.product.count = %d", self.products.count);
    for (int k=0; k<self.products.count; k++) {
        //NSLog(@"k = %d", k);
        //using JSON file
        Product *product = self.products[k];
        //NSLog(@"product = %@", product);
        PhotoRecord2 *record = [[PhotoRecord2 alloc] init];
        
        record.recordName = product.productName;
        record.recordId = product.productId;
        record.recordThumbnailURL = [NSURL URLWithString:product.productThumbnail];
        record.recordImageURL = [NSURL URLWithString:product.productImage];
        record.recordBrief = product.productBrief;
        record.recordDescription = product.productDescription;
        record.recordPrice = product.productPrice;
        record.recordCurrency = product.productCurrency;
        record.recordWeight = product.productWeight;
        record.recordUnit = product.productUnit;
        record.recordQuantity = product.productQuantity;
        
        //NSLog(@"Record2 - name, URL: %@, %@", record.recordName, record.recordThumbnailURL);
        [records2 addObject:record];
        record = nil;
    }
    //tempRecord = records2;
    self.photos = records2;
    [self.tableView reloadData];
    
}

@end
