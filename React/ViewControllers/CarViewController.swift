//
//  CarViewController.swift
//  React
//
//  Created by Wes Billman on 9/11/15.
//  Copyright © 2015 Wes Billman. All rights reserved.
//

import UIKit

class CarViewController: ViewControllerBase {

    private var viewModel:CarViewModel
    
    init(viewModel:CarViewModel) {
        self.viewModel = viewModel        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.purpleColor()
        
        viewModel.car.name.subscribeNext { name in self.title = name }
        
        let nameLabel = UILabel(frame: CGRectMake(0, 100, view.bounds.width, 30))
        nameLabel.textAlignment = .Center
        view.addSubview(nameLabel)
        viewModel.car.name
            .map { name in
                return "name: \(name)"
            }
            .subscribeNext { name in
                nameLabel.text = name
            }
            .addDisposableTo(disposeBag)
        
        let nameText = UITextField(frame: CGRectMake(40, 140, view.bounds.width - 80, 40))
        nameText.borderStyle = .RoundedRect
        nameText.text = viewModel.car.name.value
        view.addSubview(nameText)
        nameText.rx_text
            .subscribeNext { text in
                if nameText.isFirstResponder() {
                    self.viewModel.car.name.value = text
                }
            }
            .addDisposableTo(disposeBag)
        
        let startButton = UIButton(frame: CGRectMake(40, 240, view.bounds.width - 80, 40))
        view.addSubview(startButton)
        startButton.rx_tap
            .subscribeNext {
                if self.viewModel.car.running.value {
                    self.viewModel.car.stop()
                } else {
                    self.viewModel.car.start()
                }
            }
            .addDisposableTo(disposeBag)
        
        let runningLabel = UILabel(frame: CGRectMake(0, 200, view.bounds.width, 30))
        runningLabel.textAlignment = .Center
        view.addSubview(runningLabel)
        viewModel.car.running
            .map { running in
                return (running, "running: \(running)")
            }
            .subscribeNext { (running, text) in
                let buttonText = running ? "Stop" : "Start"
                startButton.setTitle(buttonText, forState: .Normal)
                runningLabel.text = text
            }
            .addDisposableTo(disposeBag)
    }
    

}
