//
//  DropTextView.m
//  LinkageMenu
//
//  Created by ios 001 on 2019/12/19.
//  Copyright © 2019 mango. All rights reserved.
//

#import "DropTextView.h"
#define viewWidth [UIScreen mainScreen].bounds.size.width

#define viewheight [UIScreen mainScreen].bounds.size.height

@interface DropTextView ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger selects[3];
}
/** tableViewarr */
@property (nonatomic,strong) NSArray *tableviewArr;
/** <#assign属性注释#> */
@property (nonatomic,strong) NSArray *dataArr;
/** <#assign属性注释#> */
@property (nonatomic,assign) NSInteger tableViewCount;
/** 表视图的 底部视图 */
@property (nonatomic, strong) UIView *tableViewUnderView;
/* 底层取消按钮 */
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, assign) BOOL show;   // 按钮点击后 视图显示/隐藏



@end
@implementation DropTextView

-(instancetype)init{
    self = [super init];
    self.show = NO;
    self.dataArr = [NSArray array];
    //保存初始值
    for (int i =0; i<3; i++) {
        selects[i]  = -1;
    }
    /* 底层取消按钮 */
           self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
           self.cancelButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
           [self.cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
           [self addSubview:self.cancelButton];
    
    self.tableViewUnderView = [[UIView alloc]init];
    [self.cancelButton addSubview:self.tableViewUnderView];
    return self;
}
-(void)creatDropTextView:(UIView *)view withShowTableNum:(NSInteger)tableNum withData:(NSArray *)arr{
    if (!self.show) {
        self.show = !self.show;
        //显示tableview数量
        self.tableViewCount = tableNum;
        //数据
        self.dataArr = arr;
        for (UITableView *tableview in self.tableviewArr) {
            [tableview reloadData];
        }
        
        //初始设置
        CGFloat x = 0.f;
        CGFloat y = view.frame.origin.y+view.frame.size.height;
        CGFloat width = viewWidth;
        CGFloat height = viewheight -y;
        
        self.frame = CGRectMake(x, y, width, height);
        self.cancelButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        self.tableViewUnderView.frame= CGRectMake(0, 0, self.frame.size.width, 40*7);
        if (!self.superview) {
            [[UIApplication sharedApplication].delegate.window addSubview:self];
            self.alpha = 0.0f;
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 1.0f;
            }];
            [self loadSelects];
            [self adjustTableView];
        }
    }
}
-(void)adjustTableView{
    //显示tab数量
    int addtableCount = 0;
    for (UITableView *tableView in _tableviewArr) {
        if (tableView.superview) {
            addtableCount++;
        }
    }
    for (int i =0; i<addtableCount; i++) {
        UITableView *tableView = self.tableviewArr[i];
        CGRect adjustframe = tableView.frame;
        adjustframe.size.width = viewWidth/addtableCount;
        adjustframe.origin.x = adjustframe.size.width*i +0.5*i;
        adjustframe.size.height = self.tableViewUnderView.frame.size.height;
        tableView.frame = adjustframe;
    }
}
//加载选中的
-(void)loadSelects{
    [self.tableviewArr enumerateObjectsUsingBlock:^(UITableView *tableView, NSUInteger idx, BOOL * _Nonnull stop) {
           
           [tableView reloadData];
           
           // 选中TableView某一行
           [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selects[idx] inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
           
           //  加 !idx 是 循环第一次 idx == 0 方法不执行, 所以循环一次 加载一个TableView.
           if((selects[idx] != -1 && !tableView.superview) || !idx) {
               
               [self.tableViewUnderView addSubview:tableView];
               
               [UIView animateWithDuration:0.2f animations:^{
                   if (self.arrowView) {
                       self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
                   }
               }];
           }
       }];
}
#pragma mark - tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger __block count;
    [self.tableviewArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == tableView) {
            NSInteger firstSelectRow = ((UITableView *)self.tableviewArr[0]).indexPathForSelectedRow.row;
            NSInteger secondSelectRow = ((UITableView *)self.tableviewArr[1]).indexPathForSelectedRow.row;
            count =[self countForChooseTable:idx firstTableSelectRow:firstSelectRow withSecondSelectRow:secondSelectRow];
        }
    }];
    return count;
}
-(NSInteger)countForChooseTable:(NSInteger)index firstTableSelectRow:(NSInteger)firseSelectRow withSecondSelectRow:(NSInteger)secondSelectRow{
    
    if (index == 0) {
        return self.dataArr.count;
    }else if (index == 1){
        if (firseSelectRow == -1) {
            return 0;
        } else {
            if (self.tableViewCount == 2) {
                return [self.dataArr[firseSelectRow][@"subcategories"] count];
            }else{
                return [self.dataArr[firseSelectRow][@"sub"] count];
            }
        }
    }else{
        if (secondSelectRow == -1) {
            return 0;
        }else{
            return [self.dataArr[firseSelectRow][@"sub"][secondSelectRow][@"sub"] count];
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
      cell.textLabel.font = [UIFont systemFontOfSize:14];
    if (self.tableViewCount == 1) {
        cell.textLabel.text  = self.dataArr[indexPath.row][@"label"];
    }else if(self.tableViewCount == 2){
          NSInteger firstSelectRow = ((UITableView *)self.tableviewArr[0]).indexPathForSelectedRow.row;
        if (tableView == self.tableviewArr[0]) {
            cell.textLabel.text = self.dataArr[indexPath.row][@"name"];
        }else if (tableView == self.tableviewArr[1]){
            cell.textLabel.text = self.dataArr[firstSelectRow][@"subcategories"][indexPath.row];
        }
    }else if (self.tableViewCount == 3){
        NSInteger firstSelectRow = ((UITableView *)self.tableviewArr[0]).indexPathForSelectedRow.row;
                NSInteger secondSelectRow = ((UITableView *)self.tableviewArr[1]).indexPathForSelectedRow.row;
        if (tableView == self.tableviewArr[0]) {
                  
                  cell.textLabel.text = self.dataArr[indexPath.row][@"name"];
                  
              }else if (tableView == self.tableviewArr[1]){
                  
                  cell.textLabel.text = self.dataArr[firstSelectRow][@"sub"][indexPath.row][@"name"];
                  
              }else if (tableView == self.tableviewArr[2]){
                  
                  
                 cell.textLabel.text =  self.dataArr[firstSelectRow][@"sub"][secondSelectRow][@"sub"][indexPath.row];
              }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableView *secondtableView = self.tableviewArr[1];
    UITableView *thirdTableView = self.tableviewArr[2];
    if (self.tableViewCount == 1) {
        [self saveSelects];
        [self dismiss];
    [_delegate dropMenuView:self didSelectName:self.dataArr[indexPath.row][@"label"]];
    }else if (self.tableViewCount == 2){
        if (tableView == self.tableviewArr[0]) {
            if (!secondtableView.superview) {
                [self.tableViewUnderView addSubview:secondtableView];
            }
            [secondtableView reloadData];
            [self adjustTableView];
        }else if (tableView == self.tableviewArr[1]){
            [self saveSelects];
            [self dismiss];
              NSInteger firstSelectRow = ((UITableView *)self.tableviewArr[0]).indexPathForSelectedRow.row;
      [_delegate dropMenuView:self didSelectName:self.dataArr[firstSelectRow][@"subcategories"][indexPath.row]];
        }
    }else if (self.tableViewCount == 3){
        NSInteger firstSelectRow = ((UITableView *)self.tableviewArr[0]).indexPathForSelectedRow.row;
              NSInteger secondSelectRow = ((UITableView *)self.tableviewArr[1]).indexPathForSelectedRow.row;
        if (tableView == self.tableviewArr[0]) {
            if (!secondtableView.superview) {
                [self.tableViewUnderView addSubview:secondtableView];
            }
            [self adjustTableView];
            [secondtableView reloadData];
            [thirdTableView reloadData];
        }else if(tableView == self.tableviewArr[1]){
            if (!thirdTableView.superview) {
                          [self.tableViewUnderView addSubview:thirdTableView];
                      }
                      [self adjustTableView];
                      [thirdTableView reloadData];
        }else if(tableView == self.tableviewArr[2]){
            [self saveSelects];
            [self dismiss];
            [_delegate dropMenuView:self didSelectName:self.dataArr[firstSelectRow][@"sub"][secondSelectRow][@"sub"][indexPath.row]];
        }
    }
}

/** 底部按钮, 视图消失 */
-(void)clickCancelButton:(UIButton *)button{
    
    [self dismiss];
}

-(void)saveSelects{
    [self.tableviewArr enumerateObjectsUsingBlock:^(UITableView *tableView, NSUInteger idx, BOOL * _Nonnull stop) {
        selects[idx] = tableView.superview?tableView.indexPathForSelectedRow.row:-1;
    }];
}
-(void)dismiss{
    
    if (self.superview) {
        self.show = !self.show;
        [self endEditing:YES];
        self.alpha = 0.f;
        [self.tableViewUnderView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        
        [self removeFromSuperview];
        
        [UIView animateWithDuration:0.3 animations:^{
        if (self.arrowView) {
                       self.arrowView.transform = CGAffineTransformMakeRotation(0);
                   }

         }];
    }
   
}
#pragma mark ——— lazy
- (NSArray *)tableviewArr {
    if (!_tableviewArr) {
        _tableviewArr = @[[[UITableView alloc]init],[[UITableView alloc]init],[[UITableView alloc]init]];
        for (UITableView * tableview in _tableviewArr) {
            [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
            tableview.delegate = self;
            tableview.dataSource = self;
            tableview.frame = CGRectMake(0, 0, 0, 0);
        }
    }
    return _tableviewArr;
}

@end
