//
//  YLAddBookViewController.m
//  TheAddressBookDemo
//
//  Created by YangLei on 16/3/15.
//  Copyright © 2016年 YangLei. All rights reserved.
//

#import "YLAddBookViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "YLChineseString.h"
#import "YLAddBookTableViewCell.h"
#define WINTHSCREEN  ([UIScreen mainScreen].bounds.size.width)

@interface YLAddBookViewController ()
{
    UISearchBar *theSearchBar;
    UITableView *tablview;
    UILabel * labelnoshouquan;//没有授权通讯录
    UILabel * labelnosousuo;//没有搜索内容
}
@end

@implementation YLAddBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self noShouquan];
    [self nosousuo];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadSearchBar];
    [self loadTableView];
    [self filterContentForSearchText:@""];//查询所有
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
    {
        if (granted)
        {
        }else
        {
            tablview.hidden = YES;
            theSearchBar.hidden = YES;
            labelnoshouquan.hidden = NO;
        }
        
    });
}
- (void)loadTableView
{
    tablview = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+40,self.view.frame.size.width, self.view.frame.size.height-64-40) style:UITableViewStylePlain];
    tablview.backgroundColor = [UIColor whiteColor];
    //改变索引的颜色
    tablview.sectionIndexColor = [UIColor redColor];
    //改变索引选中的背景颜色
    tablview.sectionIndexTrackingBackgroundColor = [UIColor yellowColor];
    tablview.dataSource = self;
    tablview.delegate = self;
    tablview.tableFooterView = [UIView new];
    [self.view addSubview:tablview];
}
- (void)loadSearchBar
{
    theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 40)];
    theSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    theSearchBar.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    theSearchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"All",@"A",@"B",@"C",@"D" ,nil];
    theSearchBar.showsScopeBar = YES;
    theSearchBar.keyboardType = UIKeyboardTypeNamePhonePad;
    //    theSearchBar.showsBookmarkButton = YES;
    theSearchBar.delegate = self;
    [self.view addSubview:theSearchBar];
}
- (void)noShouquan{
    labelnoshouquan = [[UILabel alloc]initWithFrame:CGRectMake(0, 150,WINTHSCREEN, 40)];
    labelnoshouquan.backgroundColor = [UIColor clearColor];
    labelnoshouquan.textColor = [UIColor blackColor];
    labelnoshouquan.textAlignment = NSTextAlignmentCenter;
    labelnoshouquan.numberOfLines = 0;
    labelnoshouquan.font = [UIFont systemFontOfSize:14.0];
    labelnoshouquan.text  = @"没有权限访问通讯录，请前往设置允许应用访问通讯录";
    labelnoshouquan.hidden = YES;
    [self.view addSubview:labelnoshouquan];
}
- (void)nosousuo{
    labelnosousuo = [[UILabel alloc]initWithFrame:CGRectMake(0, 150,WINTHSCREEN, 30)];
    labelnosousuo.backgroundColor = [UIColor clearColor];
    labelnosousuo.textColor = [UIColor blackColor];
    labelnosousuo.text  = @"没有您搜索的客户";
    labelnosousuo.textAlignment = NSTextAlignmentCenter;
    labelnosousuo.hidden = YES;
    [self.view addSubview:labelnosousuo];
}
- (void)filterContentForSearchText:(NSString*)searchText

{
    //如果没有授权则退出
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized)
    {
        labelnoshouquan.hidden = NO;
        return ;
    }
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if([searchText length]==0)
    {
        //查询所有
        self.listContacts = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
        theSearchBar.placeholder = [NSString stringWithFormat:@"搜索客户（共%ld位）",self.listContacts.count];
        if (self.listContacts.count == 0)
        {
            theSearchBar.placeholder = @"无客户";
            tablview.hidden = YES;
            labelnosousuo.hidden = NO;
        }else
        {
            tablview.hidden = NO;
            labelnosousuo.hidden = YES;
        }
        NSMutableArray * arrlast = [NSMutableArray array];
        for (int i = 0; i < self.listContacts.count; i ++) {
            ABRecordRef thisPerson = CFBridgingRetain(self.listContacts[i]);// ①第①行ABRecordRef thisPerson = CFBridgingRetain([self.listContacts objectAtIndex:[indexPath row]])语句是从NSArray*集合中取出一个元素，并且转化为Core Foundation类型的ABRecordRef类型。CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty))语句是将名字属性取出来，转化为NSString*类型。最后CFRelease(thisPerson)是释放ABRecordRef对象。
            NSString *firstName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty)); //②
            firstName = firstName != nil?firstName:@"";
            
            
            NSString *centerName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonMiddleNameProperty)); //②
            centerName = centerName != nil?centerName:@"";
            
            NSString *lastName =  CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonLastNameProperty));  //③
            
            lastName = lastName != nil?lastName:@"";
            
            NSString * lastStr = [NSString stringWithFormat:@"%@%@%@",lastName,centerName,firstName];
            //            NSLog(@"ffdfd%@",lastStr);
            if (lastStr) {
                [arrlast addObject:lastStr];
                
            }
            CFRelease(thisPerson);
            
        }
        
        //        NSLog(@"%@",arrlast);
        
        self.indexArray = [YLChineseString IndexArray:arrlast];
        self.letterResultArr = [YLChineseString LetterSortArray:arrlast];
        
        
    } else {
        //条件查询
        
        CFStringRef cfSearchText = (CFStringRef)CFBridgingRetain(searchText);
        
        self.listContacts = CFBridgingRelease(ABAddressBookCopyPeopleWithName(addressBook, cfSearchText));
        if (self.listContacts.count == 0) {
            tablview.hidden = YES;
            labelnosousuo.hidden = NO;
        }else{
            
            tablview.hidden = NO;
            labelnosousuo.hidden = YES;
            
        }
        
        NSMutableArray * arrlast = [NSMutableArray array];
        for (int i = 0; i < self.listContacts.count; i ++) {
            ABRecordRef thisPerson = CFBridgingRetain(self.listContacts[i]);// ①第①行ABRecordRef thisPerson = CFBridgingRetain([self.listContacts objectAtIndex:[indexPath row]])语句是从NSArray*集合中取出一个元素，并且转化为Core Foundation类型的ABRecordRef类型。CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty))语句是将名字属性取出来，转化为NSString*类型。最后CFRelease(thisPerson)是释放ABRecordRef对象。
            NSString *firstName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty)); //②
            firstName = firstName != nil?firstName:@"";
            
            
            NSString *centerName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonMiddleNameProperty)); //②
            centerName = centerName != nil?centerName:@"";
            
            NSString *lastName =  CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonLastNameProperty));  //③
            
            lastName = lastName != nil?lastName:@"";
            
            NSString * lastStr = [NSString stringWithFormat:@"%@%@%@",lastName,centerName,firstName];
            if (lastStr) {
                [arrlast addObject:lastStr];
                
            }
            CFRelease(thisPerson);
            
        }
        self.indexArray = [YLChineseString IndexArray:arrlast];
        self.letterResultArr = [YLChineseString LetterSortArray:arrlast];
        CFRelease(cfSearchText);
    }
    [tablview reloadData];
    CFRelease(addressBook);
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [theSearchBar resignFirstResponder];
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [theSearchBar resignFirstResponder];
    return YES;
}
#pragma mark –UISearchBarDelegate 协议方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //查询所有
    [self filterContentForSearchText:theSearchBar.text];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterContentForSearchText:searchText];
}
#pragma mark - UISearchDisplayController Delegate Methods
//当文本内容发生改变时候，向表视图数据源发出重新加载消息
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    //YES情况下表视图可以重新加载
    return YES;
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.indexArray;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = [self.indexArray objectAtIndex:section];
    return key;
}
//响应点击索引时的委托方法
//-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    NSInteger count = 0;
//
//    NSLog(@"%@-%d",title,index);
//
//    for(NSString *character in self.indexArray)
//    {
//        if([character isEqualToString:title])
//        {
//            return count;
//        }
//        count ++;
//    }
//    return 0;
//}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.indexArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.letterResultArr objectAtIndex:section] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    /*
     kABPersonFirstNameProperty，名字
     
     kABPersonLastNameProperty，姓氏
     
     kABPersonMiddleNameProperty，中间名
     
     kABPersonPrefixProperty，前缀
     
     kABPersonSuffixProperty，后缀
     
     kABPersonNicknameProperty，昵称
     
     kABPersonFirstNamePhoneticProperty，名字汉语拼音或音标
     
     kABPersonLastNamePhoneticProperty，姓氏汉语拼音或音标
     
     q kABPersonMiddleNamePhoneticProperty，中间名汉语拼音或音标
     
     kABPersonOrganizationProperty，组织名
     
     kABPersonJobTitleProperty，头衔
     
     kABPersonDepartmentProperty，部门
     
     kABPersonNoteProperty，备注
     
     CFTypeRef ABRecordCopyValue (
     
     ABRecordRef record,
     
     ABPropertyID property
     
     );
     
     */
    static NSString *CellIdentifier = @"cell";
    
    YLAddBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[YLAddBookTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    //    ABRecordRef thisPerson = CFBridgingRetain([[self.listContacts objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]);// ①第①行ABRecordRef thisPerson = CFBridgingRetain([self.listContacts objectAtIndex:[indexPath row]])语句是从NSArray*集合中取出一个元素，并且转化为Core Foundation类型的ABRecordRef类型。CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty))语句是将名字属性取出来，转化为NSString*类型。最后CFRelease(thisPerson)是释放ABRecordRef对象。
    //    NSString *firstName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty)); //②
    //    firstName = firstName != nil?firstName:@"";
    //
    //
    //    NSString *centerName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonMiddleNameProperty)); //②
    //    centerName = centerName != nil?centerName:@"";
    //
    //    NSString *lastName =  CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonLastNameProperty));  //③
    //
    //    lastName = lastName != nil?lastName:@"";
    //
    //    cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@",lastName,centerName,firstName];
    //
    //    CFRelease(thisPerson);
    cell.labelmingzi.text = [[self.letterResultArr objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    
    
    [cell.labelTou setPersistentBackgroundColor: [self randomColor]];
    cell.labelTou.text = [[[self.letterResultArr objectAtIndex:indexPath.section]objectAtIndex:indexPath.row] substringWithRange:NSMakeRange(0, 1)];
    
    return cell;
    
}

-(UIColor *) randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [theSearchBar resignFirstResponder];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [theSearchBar resignFirstResponder];
    
    //点击行会有对号标记
    YLAddBookTableViewCell *oneCell = [tableView cellForRowAtIndexPath: indexPath];
    //    if (oneCell.accessoryType == UITableViewCellAccessoryNone) {
    //        oneCell.accessoryType = UITableViewCellAccessoryCheckmark;
    //    } else
    //        oneCell.accessoryType = UITableViewCellAccessoryNone;
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    // ④其中第①行代码调用函数ABRecordGetRecordID是获取选中记录的ID，其中ID为ABRecordID类型。为了传递这个ID给DetailViewController视图控制器，DetailViewController视图控制器定义了personIDAsNumber属性，在第③行将ID给personIDAsNumber属性
    //    [self.navigationController pushViewController:detailViewController1 animated:YES];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
