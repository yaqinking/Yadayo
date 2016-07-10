//
//  YDKeywordsViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/29.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDKeywordsViewController.h"
#import "YDCoreDataStackManager.h"
#import "YDAddKeywordViewController.h"
#import "YDKeywordDetailViewController.h"
#import "YDRSSNavigationController.h"

@interface YDKeywordsViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation YDKeywordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.site.name;
    [self.fetchedResultsController performFetch:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.fetchedResultsController.sections[section] name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:YDKeywordCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UINavigationController *navCon = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YDBTSiteNav"];
    YDKeywordDetailViewController *kwdDVC = navCon.childViewControllers[0];
    YDKeyword *keyword = [self.fetchedResultsController objectAtIndexPath:indexPath];
    kwdDVC.keyword = keyword;
    kwdDVC.site = self.site;
    kwdDVC.title = keyword.name;
    [self.navigationController pushViewController:kwdDVC animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    YDKeyword *keyword = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = keyword.name;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:YDAddKeywordSegueIdentifier]) {
        YDAddKeywordViewController *addKeywordVC = segue.destinationViewController;
        addKeywordVC.site = self.site;
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDKeywordEntityName];
        request.predicate = [NSPredicate predicateWithFormat:@"site == %@",self.site];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:kWeekdayUnit ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:kCreateDate ascending:YES]];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.site.managedObjectContext sectionNameKeyPath:kWeekdayUnit cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
     switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}
@end
