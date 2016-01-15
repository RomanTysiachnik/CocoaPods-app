#import "CPRecentDocumentsController.h"
#import "NSURL+TersePaths.h"

@implementation CPHomeWindowDocumentEntry

- (instancetype)copyWithZone:(NSZone *)zone
{
  CPHomeWindowDocumentEntry *copy = [[[self class] allocWithZone:zone] init];
  if (copy) {
    [copy setName:[self.name copyWithZone:zone]];
    [copy setPodfileURL:[self.podfileURL copyWithZone:zone]];
    [copy setImage:[self.image copyWithZone:zone]];
    [copy setFileDescription:[self.fileDescription copyWithZone:zone]];
  }

  return copy;
}

@end

@implementation CPRecentDocumentsController

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  NSMutableAttributedString *attrTitle =
  [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"MAIN_WINDOW_OPEN_DOCUMENT_BUTTON_TITLE", nil)];
  NSUInteger len = [attrTitle length];
  NSRange range = NSMakeRange(0, len);
  [attrTitle addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0] range:range];
  [attrTitle addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:13.0] range:range];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.alignment = NSTextAlignmentCenter;
  [attrTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
  [attrTitle fixAttributesInRange:range];
  [self.openDocumentButton setAttributedTitle:attrTitle];
  [attrTitle addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:192.0/255.0 green:192.0/255.0 blue:192.0/255.0 alpha:1.0] range:range];
  [self.openDocumentButton setAttributedAlternateTitle:attrTitle];
  
  [self setupRecentDocuments];
  [self prepareData];
}

- (void)setupRecentDocuments
{
  NSDocumentController *controller = [NSDocumentController sharedDocumentController];
  NSMutableArray *documents = [NSMutableArray arrayWithCapacity:controller.recentDocumentURLs.count];
  for (NSURL *url in controller.recentDocumentURLs) {
    [documents addObject:[self projectDetailsAtURL:url]];
  }

  self.recentDocuments = documents;
}

- (void)prepareData
{
  if ([self.recentDocuments count] > 0) {
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:0];
    [self.documentsTableView selectRowIndexes:indexes byExtendingSelection:NO];
    self.documentsTableView.hidden = NO;
    self.openDocumentButton.hidden = YES;
  } else {
    self.documentsTableView.hidden = YES;
    self.openDocumentButton.hidden = NO;
  }
}

- (CPHomeWindowDocumentEntry *)projectDetailsAtURL:(NSURL *)url
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *dirFiles = [fileManager contentsOfDirectoryAtURL:[url URLByDeletingLastPathComponent] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];

  NSPredicate *workspacePredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'xcworkspace'"];
  NSPredicate *projectPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'xcodeproj'"];
  NSURL *workspaceURL = [[dirFiles filteredArrayUsingPredicate:workspacePredicate] firstObject];
  NSURL *projectURL = [[dirFiles filteredArrayUsingPredicate:projectPredicate] firstObject];
  NSURL *bestURL = workspaceURL ?: projectURL ?: url;

  CPHomeWindowDocumentEntry *document = [CPHomeWindowDocumentEntry new];
  document.name = [bestURL lastPathComponent];
  document.image = [NSImage imageNamed:@"Podfile-icon"];
  document.podfileURL = url;
  document.fileDescription = workspaceURL? @"Podfile" : [bestURL tersePath];
  return document;
}

@end
