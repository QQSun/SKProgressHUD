//
//  ViewController.swift
//  SKProgressHUD
//
//  Created by nachuan on 2016/11/4.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, URLSessionDownloadDelegate {
    var canceled: Bool = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.brown;

        
        
        let tableView = UITableView.init(frame: self.view.bounds);
        tableView.delegate = self;
        tableView.dataSource = self;
        self.view.addSubview(tableView);
        
        
        
        
    }
    
    let dataInfo = [["Indeterminate mode", "With label", "With details label"], ["Determinate mode", "Annular determinate mode", "Bar determinate mode"], ["Text only", "Custom view", "With action button", "Mode switching"], ["On window", "NSURLSession", "Determinate with NSProgress", "Dim background", "Colored"]]
    
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var hud: SKProgressHUD = SKProgressHUD.showHUDAdded(to: self.view, animated: true);
        switch dataInfo[indexPath.section][indexPath.row] {
        case "Indeterminate mode":
            DispatchQueue.global(qos: .userInitiated).async {
                self.doSomeWork();
                DispatchQueue.main.async {
                    hud.hideAnimated(animated: true);
                }
            }
        case "With label":
            hud.label.text = NSLocalizedString("loading", comment: "HUD loading title");
            DispatchQueue.global(qos: .userInitiated).async {
                self.doSomeWork();
                DispatchQueue.main.async {
                    hud.hideAnimated(animated: true);
                }
            }
        case "With details label":
            hud.label.text = NSLocalizedString("loading", comment: "HUD loading title");
            hud.detailsLabel.text = NSLocalizedString("parsing data\n(1/1)", comment: "HUD title");
            DispatchQueue.global(qos: .userInitiated).async {
                self.doSomeWork();
                DispatchQueue.main.async {
                    hud.hideAnimated(animated: true);
                }
            }
        case "Determinate mode":
            hud.mode = SKProgressHUDMode.determinate;
            hud.label.text = NSLocalizedString("loading", comment: "HUD loading title");
            DispatchQueue.global(qos: .userInitiated).async {
                self.doSomeWorkWithProgress();
                DispatchQueue.main.async {
                    hud.hideAnimated(animated: true);
                }
            }
        case "Annular determinate mode":
            hud.mode = .annularDeterminate;
            hud.label.text = NSLocalizedString("loading", comment: "HUD loading title");
            DispatchQueue.global(qos: .userInitiated).async {
                self.doSomeWorkWithProgress();
                DispatchQueue.main.async {
                    hud.hideAnimated(animated: true);
                }
            }
        case "Bar determinate mode":
            hud.mode = .determinateHorizontalBar;
            hud.label.text = NSLocalizedString("loading", comment: "HUD loading title");
            DispatchQueue.global(qos: .userInitiated).async {
                self.doSomeWorkWithProgress();
                DispatchQueue.main.async {
                    hud.hideAnimated(animated: true);
                }
            }
        case "Text only":
            hud.mode = .text;
            hud.label.text = NSLocalizedString("loading", comment: "HUD loading title");
            hud.offset = CGPoint(x: 0, y: SKProgressMaxOffset);
            hud.hideAnimated(animated: true, after: 2);
        case "Custom view":
            hud.mode = .customView;
            let image: UIImage? = UIImage.init(named: "Checkmark")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate);
            hud.customView = UIImageView.init(image: image);
            hud.square = true;
            hud.label.text = NSLocalizedString("Done", comment: "HUD done title");
            hud.hideAnimated(animated: true, after: 3);
            
        case "With action button":
            hud.mode = .determinate;
            hud.label.text = NSLocalizedString("loading", comment: "HUD loading title");
            hud.button.setTitle(NSLocalizedString("Cancel", comment: "HUD loading title"), for: .normal);
            hud.button.addTarget(self, action: #selector(cancelWork(_: )), for: .touchUpInside);
            DispatchQueue.global(qos: .userInitiated).async {
                self.doSomeWorkWithProgress();
                DispatchQueue.main.async {
                    hud.hideAnimated(animated: true);
                }
            }
        case "Mode switching":
            hud.label.text = NSLocalizedString("loading", comment: "HUD loading title");
            hud.minSize = CGSize(width: 150, height: 100);
            DispatchQueue.global(qos: .userInitiated).async {
                self.doSomeWorkWithMixedProgress();
                DispatchQueue.main.async {
                    hud.hideAnimated(animated: true);
                }
            }
        case "On window":
            if let tempHUD = SKProgressHUD.HUD(for: self.view) {
                tempHUD.removeFromSuperview();
            }
            hud = SKProgressHUD.showHUDAdded(to: self.view.window!, animated: true);
            DispatchQueue.global(qos: .userInitiated).async {
                self.doSomeWork();
                DispatchQueue.main.async {
                    hud.hideAnimated(animated: true);
                }
            }
        case "NSURLSession":
            hud.label.text = NSLocalizedString("loading", comment: "HUD loading title");
            hud.minSize = CGSize(width: 150, height: 100);
            doSomeNetworkWorkWithProgress();
        case "Determinate with NSProgress":
            hud.mode = .determinate;
            hud.label.text = NSLocalizedString("loading", comment: "HUD loading title");
            let progressObject: Progress = Progress(totalUnitCount: 100);
            hud.progressObject = progressObject;
            hud.button.setTitle(NSLocalizedString("Cancel", comment: "HUD cancel title"), for: .normal);
            hud.button.addTarget(progressObject, action: #selector(progressObject.cancel), for: .touchUpInside);
            DispatchQueue.global(qos: .userInitiated).async {
                self.doSomeWorkWithProgress(object: progressObject);
                DispatchQueue.main.async {
                    hud.hideAnimated(animated: true);
                }
            }
            
            
        case "Dim background":
            hud.backgroundView.style = .solidColor;
            DispatchQueue.global(qos: .userInitiated).async {
                self.doSomeWork();
                DispatchQueue.main.async {
                    hud.hideAnimated(animated: true);
                }
            }
        case "Colored":
            hud.contentColor = UIColor.init(red: 0, green: 0.6, blue: 0.7, alpha: 1);
            hud.label.text = NSLocalizedString("Loading", comment: "HUD loading title");
            DispatchQueue.global(qos: .userInitiated).async {
                self.doSomeWork();
                DispatchQueue.main.async {
                    hud.hideAnimated(animated: true);
                }
            }
        default:
            return;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataInfo[section].count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataInfo.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell");
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "Cell");
        }
        cell!.textLabel?.text = dataInfo[indexPath.section][indexPath.row];
        cell!.textLabel?.textAlignment = .center;
        return cell!;
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func doSomeWork() -> Void {
        sleep(2);
    }
    
    func doSomeWorkWithProgress() -> Void {
        self.canceled = false;
        var progress: CGFloat = 0;
        while progress < 1 {
            if self.canceled {
                break;
            }
            progress += 0.1;
            DispatchQueue.main.async {
                SKProgressHUD.HUD(for: self.view)?.progress = progress;
            };
            usleep(50000);
        }
        
    }
    func doSomeWorkWithProgress(object: Progress) -> Void {
        while object.fractionCompleted < 1 {
            if object.isCancelled {
                break;
            }
            object.becomeCurrent(withPendingUnitCount: 1);
            object.resignCurrent();
            usleep(50000);
        }
    }
    
    func doSomeNetworkWorkWithProgress() -> Void {
        let sessionConfig: URLSessionConfiguration = URLSessionConfiguration.default;
        let session: URLSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil);
        let url: URL = URL.init(string: "https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/HT1425/sample_iPod.m4v.zip")!;
        let task: URLSessionDownloadTask = session.downloadTask(with: url);
        task.resume();
        
        
        
        
    }
    
    
    func doSomeWorkWithMixedProgress() -> Void {
        
        
        if let hud = SKProgressHUD.HUD(for: self.view) {
            sleep(1);
            DispatchQueue.main.async {
                hud.mode = .determinate;
                hud.label.text = NSLocalizedString("Loading", comment: "HUD loading title");
            };
            var progress: CGFloat = 0;
            while progress < 1 {
                progress += 0.1;
                DispatchQueue.main.async {
                    hud.progress = progress;
                };
                usleep(50000);
            }
            DispatchQueue.main.async {
                hud.mode = .indeterminate;
                hud.label.text = NSLocalizedString("Cleaning up", comment: "HUD cleaning up title");
            };
            sleep(2);
            
        }
        
    }
    
    func cancelWork(_ sender: UIButton) -> Void {
        canceled = true;
    }
    
    
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            let hud = SKProgressHUD.HUD(for: self.view);
            if hud != nil {
                hud!.mode = .customView;
                let image: UIImage? = UIImage.init(named: "Checkmark")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate);
                hud!.customView = UIImageView.init(image: image);
                hud!.square = true;
                hud!.label.text = NSLocalizedString("Done", comment: "HUD done title");
                hud!.hideAnimated(animated: true, after: 3);
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress: CGFloat = CGFloat(totalBytesWritten / totalBytesExpectedToWrite);
        DispatchQueue.main.async {
            let hud: SKProgressHUD? = SKProgressHUD.HUD(for: self.view);
            if hud != nil {
                hud!.mode = .determinate;
                hud!.progress = progress;
            }
        };
    }
    
}

