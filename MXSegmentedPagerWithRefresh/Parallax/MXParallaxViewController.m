// MXParallaxViewController.m
//
// Copyright (c) 2017 Maxime Epain
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MXSegmentedPager.h"

#import "MXParallaxViewController.h"
#import "MXCustomView.h"
#import "MJRefresh.h"

@interface MXParallaxViewController () <MXSegmentedPagerDelegate, MXSegmentedPagerDataSource, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>
@property (nonatomic, strong) UIView            * cover;
@property (nonatomic, strong) MXSegmentedPager  * segmentedPager;
@property (nonatomic, strong) UITableView       * tableView;
@property (nonatomic, strong) UIWebView         * webView;
@property (nonatomic, strong) UITextView        * textView;
@property (nonatomic, strong) MXCustomView      * customView;
@end

@implementation MXParallaxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.segmentedPager];
    
    // Parallax Header
    self.segmentedPager.parallaxHeader.view = self.cover;
    self.segmentedPager.parallaxHeader.mode = MXParallaxHeaderModeBottom;
    self.segmentedPager.parallaxHeader.height = 150;
    self.segmentedPager.parallaxHeader.minimumHeight = 20;
    
    // Segmented Control customization
    self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedPager.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedPager.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    self.segmentedPager.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor orangeColor]};
    self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedPager.segmentedControl.selectionIndicatorColor = [UIColor orangeColor];
    
    self.segmentedPager.segmentedControlEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    
    self.segmentedPager.contentView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.segmentedPager.contentView.mj_header endRefreshing];
        });
    }];
}

- (void)viewWillLayoutSubviews {
    self.segmentedPager.frame = (CGRect){
        .origin = CGPointZero,
        .size   = self.view.frame.size
    };
    [super viewWillLayoutSubviews];
}

#pragma mark Properties

- (UIView *)cover {
    if (!_cover) {
        // Set a cover on the top of the view
        _cover = [self.nibBundle loadNibNamed:@"Cover" owner:nil options:nil].firstObject;
    }
    return _cover;
}

- (MXSegmentedPager *)segmentedPager {
    if (!_segmentedPager) {
        
        // Set a segmented pager below the cover
        _segmentedPager = [[MXSegmentedPager alloc] init];
        _segmentedPager.delegate    = self;
        _segmentedPager.dataSource  = self;
    }
    return _segmentedPager;
}

- (UITableView *)tableView {
    if (!_tableView) {
        //Add a table page
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIWebView *)webView {
    if (!_webView) {
        // Add a web page
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        NSString *strURL = @"http://nshipster.com/";
        NSURL *url = [NSURL URLWithString:strURL];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:urlRequest];
    }
    return _webView;
}

- (UITextView *)textView {
    if (!_textView) {
        // Add a text page
        _textView = [[UITextView alloc] init];
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"LongText" ofType:@"txt"];
        _textView.text = [[NSString alloc]initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    }
    return _textView;
}

- (MXCustomView *)customView {
    if (!_customView) {
        _customView = [[MXCustomView alloc] init];
    }
    return _customView;
}

#pragma mark <MXSegmentedPagerDelegate>

- (CGFloat)heightForSegmentedControlInSegmentedPager:(MXSegmentedPager *)segmentedPager {
    return 30.f;
}

- (void)segmentedPager:(MXSegmentedPager *)segmentedPager didSelectViewWithTitle:(NSString *)title {
    NSLog(@"%@ page selected.", title);
}

- (void)segmentedPager:(MXSegmentedPager *)segmentedPager didScrollWithParallaxHeader:(MXParallaxHeader *)parallaxHeader {
    NSLog(@"progress %f", parallaxHeader.progress);
}

#pragma mark <MXSegmentedPagerDataSource>

- (NSInteger)numberOfPagesInSegmentedPager:(MXSegmentedPager *)segmentedPager {
    return 4;
}

- (NSString *)segmentedPager:(MXSegmentedPager *)segmentedPager titleForSectionAtIndex:(NSInteger)index {
    return @[@"Table", @"Web", @"Text", @"Custom"][index];
}

- (UIView *)segmentedPager:(MXSegmentedPager *)segmentedPager viewForPageAtIndex:(NSInteger)index {
    return @[self.tableView, self.webView, self.textView, self.customView][index];
}

#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = (indexPath.row % 2) + 1;
    [self.segmentedPager.pager showPageAtIndex:index animated:YES];
}

#pragma mark <UITableViewDataSource>

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = (indexPath.row % 2)? @"Text" : @"Web";
    
    return cell;
}

#pragma mark <UIWebViewDelegate>

- (void)webViewDidFinishLoad:(UIWebView *)webView {

}

@end
