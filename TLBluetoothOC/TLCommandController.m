//
//  TLCommandController.m
//  TLBluetoothOC
//
//  Created by Will on 2021/4/15.
//

#import "TLCommandController.h"

@interface TLCommandController ()

///
@property (nonatomic, strong) UITextView *textView;

///
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end

@implementation TLCommandController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    _textView.textColor = UIColor.blackColor;
    _textView.editable = NO;
    _textView.font = [UIFont systemFontOfSize:16];
    
    [self.view addSubview:_textView];
    
    if ([self.commands isKindOfClass:[NSArray class]] && self.commands.count > 0) {
        _textView.text = [self.commands componentsJoinedByString:@"\n\n"];
    }
    else {
        _textView.text = @"空";
    }
    
    UIBarButtonItem *copyItem = [[UIBarButtonItem alloc] initWithTitle:@"复制" style:UIBarButtonItemStylePlain target:self action:@selector(dc_copyItemAction:)];
    [self.navigationItem setRightBarButtonItem:copyItem];
}

- (void)dc_copyItemAction:(UIBarButtonItem *)sender {
    //UIPasteboard *pab = [UIPasteboard generalPasteboard];
    [[UIPasteboard generalPasteboard] setString:_textView.text];
}

- (void)exportFileToOtherApp:(NSString *)filePath {
    NSURL *url = [NSURL fileURLWithPath:filePath];
    _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];

    //[documentInteractionController setDelegate:self];
    
    CGRect rect = CGRectMake(self.view.bounds.size.width, 40.0, 0.0, 0.0);
    
    [_documentInteractionController presentOpenInMenuFromRect:rect inView:self.view animated:YES];
}

@end
