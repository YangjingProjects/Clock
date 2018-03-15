//
//  ViewController.m
//  Day1 Clock
//
//  Created by YangJing on 2018/3/5.
//  Copyright © 2018年 YangJing. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *mainTimerLabel;

@property (nonatomic, strong) UIButton *startBtn;

@property (nonatomic, strong) UIButton *resetBtn;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, assign) long timerCount;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) long currentCount;

@property (nonatomic, assign) long maxCount;

@property (nonatomic, assign) long minCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configNavigationBar];
    [self configSubview];
    
    //    [self equalWidthFont];
}

//找等宽字体，要不显示器总是闪动（1最窄，4最宽）
- (void)equalWidthFont {
    NSArray *fontArray = [UIFont familyNames];
    for (NSString *fontName in fontArray) {
        CGFloat width1 = [@"11" boundingRectWithSize:CGSizeMake(MAXFLOAT, [UIFont fontWithName:fontName size:68].lineHeight) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:fontName size:68]} context:nil].size.width;
        CGFloat width2 = [@"44" boundingRectWithSize:CGSizeMake(MAXFLOAT, [UIFont fontWithName:fontName size:68].lineHeight) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:fontName size:68]} context:nil].size.width;
        if (width1 == width2) {
            NSLog(@"yangjing_timer: %@", fontName);
        }
    }
    
}

//MARK: - timer
- (void)timerStart {
    [self.startBtn setTitle:@"停止" forState:UIControlStateNormal];
    self.startBtn.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.3];
    [self.startBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.startBtn removeTarget:self action:@selector(timerStart) forControlEvents:UIControlEventTouchUpInside];//???
    
    [self.startBtn addTarget:self action:@selector(timerStop) forControlEvents:UIControlEventTouchUpInside];
    
    self.resetBtn.enabled = YES;
    [self.resetBtn setTitle:@"计次" forState:UIControlStateNormal];
    self.resetBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
    [self.resetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.resetBtn removeTarget:self action:@selector(timerReset) forControlEvents:UIControlEventTouchUpInside];//???
    
    [self.resetBtn addTarget:self action:@selector(timerRecord) forControlEvents:UIControlEventTouchUpInside];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), 0.01*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.timer, ^{
        self.timerCount ++;
        self.currentCount ++;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainTimerLabel.text = [NSString stringWithFormat:@"%.2ld:%.2ld.%.2ld", self.timerCount/100/60, self.timerCount/100%60, self.timerCount%100];
        });
    });
    dispatch_resume(self.timer);
}

- (void)timerStop {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
    
    [self.startBtn setTitle:@"开始" forState:UIControlStateNormal];
    self.startBtn.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3];
    [self.startBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.startBtn removeTarget:self action:@selector(timerStop) forControlEvents:UIControlEventTouchUpInside];
    
    [self.startBtn addTarget:self action:@selector(timerStart) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.timerCount > 0) {
        [self.resetBtn setTitle:@"复位" forState:UIControlStateNormal];
        self.resetBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
        [self.resetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.resetBtn removeTarget:self action:@selector(timerRecord) forControlEvents:UIControlEventTouchUpInside];
        
        [self.resetBtn addTarget:self action:@selector(timerReset) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)timerReset {
    self.timerCount = 0;
    self.mainTimerLabel.text = @"00:00.00";
    self.currentCount = 0;
    self.maxCount = 0;
    self.minCount = 0;
    [self.dataArray removeAllObjects];
    
    self.resetBtn.enabled = NO;
    [self.resetBtn setTitle:@"计次" forState:UIControlStateDisabled];
    self.resetBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    [self.resetBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.resetBtn removeTarget:self action:@selector(timerReset) forControlEvents:UIControlEventTouchUpInside];
    
    [self.resetBtn addTarget:self action:@selector(timerRecord) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tableView reloadData];
}

- (void)timerRecord {
    if (self.currentCount > self.maxCount || self.maxCount == 0) self.maxCount = self.currentCount;
    if (self.currentCount < self.minCount || self.minCount == 0) self.minCount = self.currentCount;
    
    [self.dataArray insertObject:[NSNumber numberWithLong:self.currentCount] atIndex:0];
    
    self.currentCount = 0;
    
    [self.tableView reloadData];
    
}

//MARK: - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellId"];
    }
    
    long count = [self.dataArray[indexPath.row] longValue];
    
    cell.textLabel.text = [NSString stringWithFormat:@"计次 %ld", (long)(self.dataArray.count - indexPath.row)];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2ld:%.2ld.%.2ld", count/100/60, count/100%60, count%100];
    if (count >= self.maxCount) {
        cell.textLabel.textColor = [UIColor greenColor];
        cell.detailTextLabel.textColor = [UIColor greenColor];
        
    } else if (count <= self.minCount) {
        cell.textLabel.textColor = [UIColor redColor];
        cell.detailTextLabel.textColor = [UIColor redColor];
        
    } else {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    
    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

//MARK: - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

//MARK: - view
- (void)configNavigationBar {
    self.navigationItem.title = @"秒表";
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (void)configSubview {
    self.dataArray = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.mainTimerLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"Arial Hebrew" size:68];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.text = @"00:00.00";
        label.adjustsFontSizeToFitWidth = YES;
        label;
    });
    [self.view addSubview:self.mainTimerLabel];
    self.mainTimerLabel.frame = CGRectMake(15, 100, [UIScreen mainScreen].bounds.size.width-30, [UIFont fontWithName:@"Arial Hebrew" size:68].lineHeight);
    
    self.resetBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.cornerRadius = 40;
        btn.clipsToBounds = YES;
        [btn setTitle:@"计次" forState:UIControlStateDisabled];
        btn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        [btn addTarget:self action:@selector(timerRecord) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:self.resetBtn];
    self.resetBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/4-80/2, 250, 80, 80);
    self.resetBtn.enabled = NO;
    
    self.startBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.cornerRadius = 40;
        btn.clipsToBounds = YES;
        [btn setTitle:@"开始" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3];
        [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        [btn addTarget:self action:@selector(timerStart) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:self.startBtn];
    self.startBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/4*3-80/2, 250, 80, 80);
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 250+80+30, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-(250+80+30)) style:UITableViewStylePlain];
        tableView.separatorColor = [UIColor grayColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor blackColor];
        tableView;
    });
    [self.view addSubview:self.tableView];
    
}

@end

