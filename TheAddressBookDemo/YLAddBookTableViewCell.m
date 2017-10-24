//
//  YLAddBookTableViewCell.m
//  TheAddressBookDemo
//
//  Created by YangLei on 16/3/15.
//  Copyright © 2016年 YangLei. All rights reserved.
//

#import "YLAddBookTableViewCell.h"
#define WINTHSCREEN  ([UIScreen mainScreen].bounds.size.width)

@implementation YLAddBookTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self creatUI];
    }
    return self;
}

- (void)creatUI{
    //80
    self.backgroundColor = [UIColor whiteColor];
    
    self.imageviewright = [[UIImageView alloc]initWithFrame:CGRectMake(WINTHSCREEN-17.5-63, 10, 60, 60)];
    self.imageviewright.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.imageviewright];
    
    self.labelTou = [[YLLabel alloc]initWithFrame:CGRectMake(17.5,15, 50,50)];
    self.labelTou.layer.cornerRadius = self.labelTou.bounds.size.width/2;
    self.labelTou.layer.masksToBounds = YES;
    [self.labelTou setPersistentBackgroundColor:[UIColor clearColor]];
    self.labelTou.textColor = [UIColor whiteColor];
    self.labelTou.font = [UIFont systemFontOfSize:30];
    self.labelTou.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.labelTou];
    
    self.labelmingzi = [[UILabel alloc]initWithFrame:CGRectMake(17.5+60+20,0,200,80)];
    self.labelmingzi.backgroundColor = [UIColor clearColor];
    self.labelmingzi.font = [UIFont systemFontOfSize:20.0];
    self.labelmingzi.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.labelmingzi];
    
}

@end
