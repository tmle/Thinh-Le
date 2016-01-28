//
//  DetailProductDescriptionViewController.m
//  eCommerce-App
//
//  Created by Thinh Le on 2015-05-28.
//  Copyright (c) 2015 Skin Tree. All rights reserved.
//

#import "DetailProductDescriptionViewController.h"

@interface DetailProductDescriptionViewController ()

@end

@implementation DetailProductDescriptionViewController
{
    int _itemCount;
    int _count[20];
    float _priceFl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    UIBarButtonItem * continueShoppingButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cont. Shop.", nil) style:UIBarButtonItemStyleDone target:self action:@selector(continueShopping:)];
    self.navigationItem.leftBarButtonItem = continueShoppingButton;
    
    UIBarButtonItem * addToShoppingCartButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add to Cart", nil) style:UIBarButtonItemStyleDone target:self action:@selector(addToShoppingCart:)];
    self.navigationItem.rightBarButtonItem = addToShoppingCartButton;
    
    self.navigationItem.title = @"Details";
        
    // NSMutableArray implementation
    NSData *imageData     = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[self.prodSelected_t objectForKey:@"productImage"]]];
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.prodImageOnDetail.image = downloadedImage;
        }
    self.prodNameOnDetail.text        = [self.prodSelected_t objectForKey:@"productName"];
    self.prodDescriptionOnDetail.text = [self.prodSelected_t objectForKey:@"productDescription"];
    self.prodPriceOnDetail.text       = [NSString stringWithFormat:@"%2@", [self.prodSelected_t objectForKey:@"productPrice"]];
    self.prodCurrencyOnDetail.text    = [self.prodSelected_t objectForKey:@"productCurrency"];
    self.prodWeightOnDetail.text      = [NSString stringWithFormat:@"%2@", [self.prodSelected_t objectForKey:@"productWeight"]];
    self.prodUnitOnDetail.text        = [self.prodSelected_t objectForKey:@"productUnit"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)continueShopping:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)addToShoppingCart:(id)sender
{
    // A. algorithm to add product in to the shopping cart
    //if cart is empty add product, increase counter_of_product
    //if not, go through items by items, check product Id,
        // if there, incread counter of product
        // if not there, add product, increase counter of product
    
    // B. algorithm to take care of the product id and the corresponding quantity
    //    1. create a new dictionary with key = prodId, value = quantity
    //    2. update quantity based on the prodId.

    // add to shopping cart
    BOOL found = NO;
    NSString *key = [self.prodSelected_t objectForKey:@"productId"];
    
    if ([self.listOfProductsSelected count] == 0) {
        [self.listOfProductsSelected addObject:self.prodSelected_t];
         //NSLog(@"listOfProductSelected = %@\n", self.listOfProductsSelected);
         NSNumber *value = [NSNumber numberWithInt:1];
         //NSString *key = [self.prodSelected_t objectForKey:@"productId"];
         [self.dictOfProductOnCart setValue:value forKey:key];
         //NSLog(@"dictOfProductOnCart = %@\n", self.dictOfProductOnCart);
    }
    else {
        for (int i = 0; i <[self.listOfProductsSelected count]; ++i) {
            NSString *newlyArrivedId = [self.prodSelected_t objectForKey:@"productId"];
            NSString *existingId = [self.listOfProductsSelected[i] objectForKey:@"productId"];
            if ([newlyArrivedId isEqualToString:existingId]) {
                NSNumber *quan = [self.dictOfProductOnCart objectForKey:key];
                int quantity = (int)[quan integerValue];
                quantity++;
                quan = [NSNumber numberWithInt:quantity];
                [self.dictOfProductOnCart setValue:quan forKey:key];
                //NSLog(@"dictOfProductOnCart = %@\n", self.dictOfProductOnCart);
                found = YES;
            }
        }
     
        if (!found) {
            [self.listOfProductsSelected addObject:self.prodSelected_t];
            NSNumber *quan = [self.dictOfProductOnCart objectForKey:key];
            int quantity =  (int)[quan integerValue];
            quantity++;
            quan = [NSNumber numberWithInt:quantity];
            [self.dictOfProductOnCart setValue:quan forKey:key];
        }
     }
    
    [self performSegueWithIdentifier:@"ShowShoppingCart" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowShoppingCart"]) {
        CartViewController * cartViewController = (CartViewController *)segue.destinationViewController;
        cartViewController.listOfProductsSelected = self.listOfProductsSelected;
        cartViewController.dictOfProductOnCart = self.dictOfProductOnCart;
    }
}

@end
