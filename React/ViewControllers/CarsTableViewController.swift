//
//  CarsTableViewController.swift
//  React
//
//  Created by Wes Billman on 9/11/15.
//  Copyright © 2015 Wes Billman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CarsTableViewController: TableViewControllerBase {
    private var viewModel:CarsViewModel
    private var moving = false
    
    init(viewModel:CarsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "😻"
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        viewModel.cars.collectionChanged
            .subscribeNext { event in
                if self.moving {
                    return
                }
                switch event {
                case let .Inserted(location, _):
                    self.tableView.beginUpdates()
                    let paths = [NSIndexPath(forRow: location, inSection: 0)]
                    self.tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .Fade)
                    self.tableView.endUpdates()
                case let .Removed(location, _):
                    self.tableView.beginUpdates()
                    let paths = [NSIndexPath(forRow: location, inSection: 0)]
                    self.tableView.deleteRowsAtIndexPaths(paths, withRowAnimation: .Fade)
                    self.tableView.endUpdates()
                    break
                default: break
                }
            }
            .addDisposableTo(disposeBag)

        let button = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: nil)
        button.rx_tap
            .subscribeNext {
                let alertView = UIAlertController(title: "Add Car", message: nil, preferredStyle: .Alert)
                alertView.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                    textField.placeholder = "Car name"
                })
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
                    let name = alertView.textFields?.first
                    if let text = name?.text {
                        self.viewModel.addCar(Car(name: text))
                    }
                })
                alertView.addAction(okAction)
                self.presentViewController(alertView, animated: true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        self.navigationItem.leftBarButtonItem = button
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.cars.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let car = viewModel.cars[indexPath.row]

        combineLatest(car.name, car.running) {
                let a = $1 ? "running" : "not running"
                return "\($0) is \(a)" as String
            }
            .subscribeNext { text in
                cell.textLabel?.text = text
            }
            .addDisposableTo(disposeBag)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let car = viewModel.cars[indexPath.row]
        let carViewModel = CarViewModel(car: car)
        navigationController?.pushViewController(CarViewController(viewModel: carViewModel), animated: true)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            viewModel.cars.removeAtIndex(indexPath.row)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let car = viewModel.cars[fromIndexPath.row]
        moving = true
        viewModel.cars.removeAtIndex(fromIndexPath.row)
        viewModel.cars.insert(car, atIndex: toIndexPath.row)
        moving = false
//        Moneybox *employee = [empArray objectAtIndex:fromIndexPath.row];
//        [empArray removeObject: employee];
//        [empArray insertObject:employee atIndex:toIndexPath.row];

    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

}
