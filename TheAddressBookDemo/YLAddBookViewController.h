//
//  YLAddBookViewController.h
//  TheAddressBookDemo
//
//  Created by YangLei on 16/3/15.
//  Copyright © 2016年 YangLei. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface YLAddBookViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, UISearchDisplayDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *listContacts;
//拼音排序
@property(nonatomic,strong)NSMutableArray *indexArray;
@property(nonatomic,strong)NSMutableArray *letterResultArr;
- (void)filterContentForSearchText:(NSString*)searchText;
@end
