//
//  DropTextView.h
//  LinkageMenu
//
//  Created by ios 001 on 2019/12/19.
//  Copyright © 2019 mango. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DropTextView;
@protocol DropTextViewDelegate <NSObject>

@required // 必须实现的方法 默认

@optional // 可选实现的方法
-(void)dropMenuView:(DropTextView *)view didSelectName:(NSString *)str;

@end


@interface DropTextView : UIView
 
@property(nonatomic, weak) id<DropTextViewDelegate> delegate;
/** 箭头变化 */
@property (nonatomic, strong) UIView *arrowView;

-(void)creatDropTextView:(UIView *)view withShowTableNum:(NSInteger)tableNum withData:(NSArray *)arr;

/** 视图消失 */
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
