//
//  ViewController.m
//  TBGDetial
//
//  Created by Mr.洛洛 on 2017/1/12.
//  Copyright © 2017年 coderLL. All rights reserved.
//

#import "ViewController.h"

#define SCWidth [UIScreen mainScreen].bounds.size.width
#define SCHeight [UIScreen mainScreen].bounds.size.height
#define _maxContentOffSet_Y 70

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UILabel *headLab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // first view
    [self.view addSubview:self.tableView];
    
    // second view
    [self.view addSubview:self.webView];
    
    UILabel *hv = self.headLab;
    // headLab
    [self.webView addSubview:hv];
    [self.headLab bringSubviewToFront:self.view];
    
    // 开始监听_webView.scrollView的偏移量
    [_webView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

/* 懒加载UILable */
- (UILabel *)headLab
{
    if(!_headLab){
        _headLab = [[UILabel alloc] init];
        _headLab.text = @"上拉，返回详情";
        _headLab.textAlignment = NSTextAlignmentCenter;
        _headLab.font = [UIFont systemFontOfSize:13];
        
    }
    
    _headLab.frame = CGRectMake(0, 0, SCWidth, 40.f);
    _headLab.alpha = 0.f;
    _headLab.textColor = [UIColor lightTextColor];
    
    return _headLab;
}

/* 懒加载UITable */
- (UITableView *)tableView {
    
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 40.f;
        // footerView
        UILabel *tabFootLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
        tabFootLab.text = @"继续拖动，查看图文详情";
        tabFootLab.font = [UIFont systemFontOfSize:13];
        tabFootLab.textAlignment = NSTextAlignmentCenter;
        _tableView.tableFooterView = tabFootLab;
    }
    
    return _tableView;
}

- (UIWebView *)webView
{
    if(!_webView){
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _tableView.contentSize.height, SCWidth, SCHeight)];
        _webView.delegate = self;
        _webView.scrollView.delegate = self;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    }
    
    return _webView;
}

// 进入图文详情的动画方法
- (void)goToDetailAnimation {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _webView.frame = CGRectMake(0, 0, SCWidth, SCHeight);
        _tableView.frame = CGRectMake(0, -self.view.bounds.size.height, SCWidth, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

//返回商品详情的动画方法
- (void)backToGoodPageAnimation {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _tableView.frame = CGRectMake(0, 0, SCWidth, self.view.bounds.size.height);
        _webView.frame = CGRectMake(0, _tableView.contentSize.height, SCWidth, SCHeight);
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSources
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 16;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"仿淘宝商品详情页效果 --- %zd", indexPath.row + 1];
    return cell;
}


#pragma mark ---- scrollView delegate
//完成拖拽时回调
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if([scrollView isKindOfClass:[UITableView class]]) // tableView界面上的滚动
    {
        // 能触发翻页的理想值:tableView整体的高度减去屏幕本省的高度
        CGFloat valueNum = _tableView.contentSize.height - SCHeight;
        if ((offsetY - valueNum) > _maxContentOffSet_Y)
        {
            [self goToDetailAnimation]; // 进入图文详情的动画
        }
    }
    else // webView页面上的滚动
    {
        NSLog(@"-----webView-------");
        if(offsetY<0 && -offsetY>_maxContentOffSet_Y)
        {
            [self backToGoodPageAnimation]; // 返回商品详情界面的动画
        }
    }
}

// 监听方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if(object == _webView.scrollView && [keyPath isEqualToString:@"contentOffset"])
    {
        NSLog(@"----old:%@----new:%@",change[@"old"],change[@"new"]);
        [self headLabAnimation:[change[@"new"] CGPointValue].y];
    }else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

// 头部提示文本动画
- (void)headLabAnimation:(CGFloat)offsetY
{
    _headLab.alpha = -offsetY/60;
    _headLab.center = CGPointMake(SCWidth/2, -offsetY/2.f);
    // 图标翻转，表示已超过临界值，松手就会返回上页
    if(-offsetY>_maxContentOffSet_Y){
        _headLab.textColor = [UIColor redColor];
        _headLab.text = @"释放，返回详情";
    }else{
        _headLab.textColor = [UIColor lightTextColor];
        _headLab.text = @"上拉，返回详情";
    }
}

#pragma mark - UIWebViewDelegate


@end
