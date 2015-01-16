//
//  AirlineTableViewController.m
//  UISearchControllerDemo
//
//  Created by Jason Hoffman on 1/13/15.
//  Copyright (c) 2015 JHM. All rights reserved.
//

#import "AirlineTableViewController.h"
#import "SearchResultsTableViewController.h"

@interface AirlineTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) NSArray *airlines;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation AirlineTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get local json file we'll be using to populate our TableView
    NSString *path = [[NSBundle mainBundle] pathForResource:@"airlineData" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    self.airlines = dict[@"airlines"];
    
    // There's no transition in our storyboard to our search results tableview or navigation controller
    // so we'll have to grab it using the instantiateViewControllerWithIdentifier: method
    UINavigationController *searchResultsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TableSearchResultsNavController"];
    
    // Our instance of UISearchController will use searchResults
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    
    // The searchcontroller's searchResultsUpdater property will contain our tableView.
    self.searchController.searchResultsUpdater = self;
    
    // The searchBar contained in XCode's storyboard is a leftover from UISearchDisplayController.
    // Don't use this. Instead, we'll create the searchBar programatically.
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x,
                                                       self.searchController.searchBar.frame.origin.y,
                                                       self.searchController.searchBar.frame.size.width, 44.0);
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.airlines count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Airline" forIndexPath:indexPath];
    cell.textLabel.text = [[self.airlines objectAtIndex:indexPath.row] objectForKey:@"Name"];
    
    return cell;
}


#pragma mark - UISearchControllerDelegate & UISearchResultsDelegate

// Called when the search bar becomes first responder
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = self.searchController.searchBar.text;
    
    [self updateFilteredContentForAirlineName:searchString];
    
    if (self.searchController.searchResultsController) {
        UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
        
        SearchResultsTableViewController *vc = (SearchResultsTableViewController *)navController.topViewController;
        vc.searchResults = self.searchResults;
        
        [vc.tableView reloadData];
    }
}


- (void)updateFilteredContentForAirlineName:(NSString *)airlineName
{
    
    if (airlineName == nil) {
        self.searchResults = [self.airlines mutableCopy];
    } else {
        
        NSMutableArray *searchResults = [[NSMutableArray alloc] init];
        
        for (NSDictionary *airline in self.airlines) {
            if ([airline[@"Name"] containsString:airlineName] /*|| [airline[@"ICAO"] containsString:[airlineName uppercaseString]]*/) {
                
                NSString *str = [NSString stringWithFormat:@"%@", airline[@"Name"] /*, airline[@"icao"]*/];
                [searchResults addObject:str];
            }
            
            self.searchResults = searchResults;
        }
    }
}




@end
