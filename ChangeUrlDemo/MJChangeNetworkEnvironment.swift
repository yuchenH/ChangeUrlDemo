//
//  MJChangeNetworkEnvironment.swift
//  ChangeUrlDemo
//
//  Created by huangyuchen on 2018/5/18.
//  Copyright © 2018年 caiqr. All rights reserved.
//

import UIKit

fileprivate let networkEnvironmentCacheKey = "MJNetworkEnvironmentCacheKey"

public class MJChangeNetworkEnvironment {
    
    static let shared:  MJChangeNetworkEnvironment = MJChangeNetworkEnvironment()
    private init() {}
    
    ///要添加该功能的controller
    var targetController: UIViewController?
    
    /// appId : App Store 上的appId，用于获取当前app在商店的版本
    var appId: String?
    
    /// environments：事例: 元组中 .0表示该环境的名称  .1表示该环境的具体配置（使用者可以自定义该配置，获取环境时也是该值）{("生产环境","1"),("debug环境","2"),("测试环境","0")}
    var environments: [(String, String)]?
    
    ///切换环境时使用者需要进行的操作 例如 清空缓存，或者切换私钥等
    var changeNetworkEvironmentAction: (()->Void)?
    
    public func setUpChangeNetworkEnvironment() {
        
        let long = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        long.minimumPressDuration = 10
        self.targetController?.view.addGestureRecognizer(long)
    }
    
    public func getCacheEnvironmentFlag()-> String? {
        
        if let cacheEnvironment =  UserDefaults.standard.value(forKeyPath: networkEnvironmentCacheKey) as? String {
            return cacheEnvironment
        }
        return nil
    }
    
}

fileprivate extension MJChangeNetworkEnvironment{
    
    //长按手势时间
    @objc private func longPressAction(){
        
        guard (appId != nil) else {
            debugPrint("appId is not config")
            return
        }
        guard (environments != nil) else {
            debugPrint("environments is not config")
            return
        }
        
        checkAppStoreVersion()
    }
    
    /// 获取当前环境名称
    private func getCurrentEnvironmentName() -> String {
        
        if let cacheEnvironment =  getCacheEnvironmentFlag() {
            
            if let environmentsTemp = environments {
                for item in environmentsTemp {
                    
                    if item.1 == cacheEnvironment {
                        
                        return item.0
                    }
                }
            }
        }
        return ""
    }
    
    //请求appStore上对应appId的app版本
    fileprivate func checkAppStoreVersion(){
        
        let session: URLSession = URLSession.shared
        
        let urlstr = NSString(format: "http://itunes.apple.com/lookup?id=%@",appId!) as String
        
        if let url: NSURL = NSURL(string: urlstr){
            
            let request: NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
            
            
            request.httpMethod = "POST"
            
            request.httpBody = "".data(using: String.Encoding.utf8)
            
            
            let dataTask: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                if(data != nil){
                    do {
                        let dic:[String:Any] = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as![String:Any]
                        if let resultCount = dic["resultCount"] as? NSNumber {
                            if resultCount.intValue > 0 {
                                if let arr = dic["results"] as? NSArray {
                                    if let dict = arr.firstObject as? NSDictionary {
                                        if let version = dict["version"] as? String {
                                            self.compareVersionIsLegal(appStoreVersion: version)
                                        }
                                    }
                                }
                            }
                        }
                        
                    } catch {
                        
                        debugPrint("checkAppStoreVersionFail -------- \(error)")
                        
                    }
                    
                }else{
                    debugPrint("checkAppStoreVersionFail -------- \(String(describing: error))")
                }
                
            }
            //.执行任务
            dataTask.resume()
            
        }
        
    }
    
    // 校验本地的版本大于商店的版本,则允许暴露出切换环境的功能
    fileprivate func compareVersionIsLegal(appStoreVersion: String) {
        
        let localVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        if localVersion.compare(appStoreVersion) == ComparisonResult.orderedDescending {
            
            let alert = UIAlertController(title: "切换环境", message: "当前环境: \(self.getCurrentEnvironmentName())", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "返回", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            for item in self.environments! {
                let action = UIAlertAction(title: item.0, style: .default, handler:{ Void in
                    self.changeEnvironments(environment: item)
                })
                if item.1 == getCacheEnvironmentFlag() {
                    action.isEnabled = false;
                }
                alert.addAction(action)
            }
            
            self.targetController?.present(alert, animated: false, completion: nil)
            
        }
        
    }
    
    // 本地缓存要切换的环境
    fileprivate func changeEnvironments(environment: (String, String)) {
        
        UserDefaults.standard.setValue(environment.1, forKeyPath: networkEnvironmentCacheKey)
        UserDefaults.standard.synchronize()
        self.changeNetworkEvironmentAction?()
        
        let alert = UIAlertController(title: "切换环境", message: "将要切换到: \(environment.0) \n 切换环境app会自动退出，请重新启动", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "知道了", style: .default, handler:
        { Void in
            
            self.targetController!.perform(Selector.init(("BBBBBBBB0909"))) // 制造崩溃
        }
        )
        alert.addAction(defaultAction)
        self.targetController?.present(alert, animated: false, completion: nil)
    }
}
