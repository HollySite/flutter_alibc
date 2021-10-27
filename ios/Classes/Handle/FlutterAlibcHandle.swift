//
//  FlutterAlibcHandle.swift
//  flutter_alibc
//
//  Created by xing.wu on 2021/5/15.
//

import Foundation

struct OpenParams {
    var showParams: AlibcTradeShowParams?
    var taokeParams: AlibcTradeTaokeParams?
    var urlParams: AlibcTradeUrlParams?
    var trackParams: Dictionary<String, Any>?
}

class FlutterAlibcHandle: NSObject, AlibcWkWebViewDelegate {
    func noticeToken(result: String) {
        if result == "" {
            channel?.invokeMethod(FlutterAlibcConstKey.CallBackString.AlibcTaokeLogin.rawValue, arguments: [
                FlutterAlibcConstKey.ErrorCode : "-1",
                FlutterAlibcConstKey.ErrorMessage:"取消授权",
            ])
        }else{
            let array : Array = result.components(separatedBy: "=")
            let token:String = array[1]
            channel?.invokeMethod(FlutterAlibcConstKey.CallBackString.AlibcTaokeLogin.rawValue, arguments: [
                FlutterAlibcConstKey.ErrorCode : "0",
                FlutterAlibcConstKey.ErrorMessage:"success",
                FlutterAlibcConstKey.Data :[
                    "accessToken":token]
            ])
        }
        
    }
    
    func noticeCode(result: String) {
        if result == "" {
            channel?.invokeMethod(FlutterAlibcConstKey.CallBackString.AlibcTaokeLoginForCode.rawValue, arguments: [
                FlutterAlibcConstKey.ErrorCode : "-1",
                FlutterAlibcConstKey.ErrorMessage:"取消授权",
            ])
        }else{
            let array : Array = result.components(separatedBy: "=")
            let code : String = array[1]
            channel?.invokeMethod(FlutterAlibcConstKey.CallBackString.AlibcTaokeLoginForCode.rawValue, arguments: [
                FlutterAlibcConstKey.ErrorCode : "0",
                FlutterAlibcConstKey.ErrorMessage:"success",
                FlutterAlibcConstKey.Data :["code":code]
            ])
        }
    }
    
    var channel : FlutterMethodChannel? = nil;
    
    init(channel:FlutterMethodChannel) {
        super.init()
        self.channel = channel
    }
    
    //    MARK: - 对flutter暴露的方法
    
    //    MARK:  初始化阿里百川
    public func initAlibc(call : FlutterMethodCall , result : @escaping FlutterResult){
        AlibcTradeUltimateSDK.sharedInstance().setDebugLogOpen(true)
        AlibcTradeUltimateSDK.sharedInstance().asyncInit {
            print("百川初始化成功")
            AlibcTradeUltimateSDK.sharedInstance().enableAutoShowDebug(true)
            WMLHandlerFactory.registerHandler(TrvZipArchiver(), with: TRVZipArchiveProtocol.self)
            let dic = [FlutterAlibcConstKey.ErrorCode :"0",FlutterAlibcConstKey.ErrorMessage:"success"]
            result(dic);
        } failure: { error in
            print("百川初始化失败")
            let dic = [FlutterAlibcConstKey.ErrorCode :String((error as NSError).code) ,FlutterAlibcConstKey.ErrorMessage:error.localizedDescription]
            result(dic);
        }
    }
    
    //    MARK:  淘宝登录
    public func loginTaoBao(call : FlutterMethodCall , result : @escaping FlutterResult){
        //        判断是否登录
        if(!ALBBCompatibleSession.sharedInstance().isLogin()){
            // 登陆
            let rootViewController : UIViewController = UIApplication.shared.windows.last!.rootViewController!
            ALBBSDK.sharedInstance().auth(rootViewController) {
                let userInfo : ALBBUser = ALBBCompatibleSession.sharedInstance().getUser()
                self.channel?.invokeMethod(FlutterAlibcConstKey.CallBackString.AlibcTaobaoLogin.rawValue, arguments: [
                    FlutterAlibcConstKey.ErrorCode : "0",
                    FlutterAlibcConstKey.ErrorMessage:"success",
                    FlutterAlibcConstKey.Data :[
                        "nick":userInfo.nick,
                        "avatarUrl":userInfo.avatarUrl,
                        "openId":userInfo.openId,
                        "openSid":userInfo.openSid,
                        "topAccessToken":userInfo.topAccessToken,
                        "topAuthCode":userInfo.topAuthCode,
                    ]
                ])
            } failureCallback: { error in
                let dic = [FlutterAlibcConstKey.ErrorCode :String((error! as NSError).code) ,FlutterAlibcConstKey.ErrorMessage: String(error!.localizedDescription)]
                result(dic);
                self.channel?.invokeMethod(FlutterAlibcConstKey.CallBackString.AlibcTaobaoLogin.rawValue, arguments: [dic])
            }
        }else{
            // 返回数据
            let userInfo : ALBBUser = ALBBCompatibleSession.sharedInstance().getUser()
            channel?.invokeMethod(FlutterAlibcConstKey.CallBackString.AlibcTaobaoLogin.rawValue, arguments: [
                FlutterAlibcConstKey.ErrorCode : "0",
                FlutterAlibcConstKey.ErrorMessage:"success",
                FlutterAlibcConstKey.Data :[
                    "nick":userInfo.nick,
                    "avatarUrl":userInfo.avatarUrl,
                    "openId":userInfo.openId,
                    "openSid":userInfo.openSid,
                    "topAccessToken":userInfo.topAccessToken,
                    "topAuthCode":userInfo.topAuthCode,]
            ])
        }
    }
    
    //    MARK:  退出登陆
    public func loginOut(call : FlutterMethodCall , result : @escaping FlutterResult){
        ALBBSDK.sharedInstance()?.logout()
    }
    
    //        MARK:  淘客授权，拿token
    
    public func openByAsyncWebView(call: FlutterMethodCall, result : @escaping FlutterResult, callBackString: String){
        let rootViewController : UIViewController = UIApplication.shared.windows.last!.rootViewController!
        let url : String = getStringFromCall(key: "url", call: call);
        
        let params: OpenParams = urlParams(call: call)
        
        let wkvc = AlibcWkWebView()
        wkvc.delegate = self
        if callBackString == FlutterAlibcConstKey.CallBackString.AlibcTaokeLogin.rawValue {
            wkvc.fuctionType = "token"
        } else {
            wkvc.fuctionType = "code"
        }
        
        AlibcTradeUltimateSDK.sharedInstance().tradeService().openTradeUrl(url, parentController: rootViewController, showParams: params.showParams, taoKeParams: params.taokeParams, trackParam: nil) { (error : Error?) in
            if error != nil {
                print("openByAsyncWebView url = \(url) failed: \(error.debugDescription)")
                return
            }
            let nav = UINavigationController.init(rootViewController: wkvc)
            nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            rootViewController.present(nav, animated: true) {}
        }
    }
    
    //    MARK: 通过url打开，包括h5唤起手机淘宝等
    public func openByUrl(call : FlutterMethodCall , result : @escaping FlutterResult, callBackString: String){
        let rootViewController : UIViewController = UIApplication.shared.windows.last!.rootViewController!
        let url : String = getStringFromCall(key: "url", call: call);
        let params: OpenParams = urlParams(call: call)
        AlibcTradeUltimateSDK.sharedInstance().tradeService().openTradeUrl(url, parentController: rootViewController, showParams: params.showParams, taoKeParams: params.taokeParams, trackParam: params.trackParams, openUrlCallBack: {(error: Error?) in
            if error != nil {
                let dic = [FlutterAlibcConstKey.ErrorCode :String((error! as NSError).code) ,FlutterAlibcConstKey.ErrorMessage:error?.localizedDescription]
                self.channel?.invokeMethod(callBackString, arguments: [dic]);
                return
            }
            self.channel?.invokeMethod(callBackString, arguments: [
                FlutterAlibcConstKey.ErrorCode:"0",
                FlutterAlibcConstKey.ErrorMessage:"",
            ])
        })
    }
    
    private func urlParams(call: FlutterMethodCall) -> OpenParams {
        let showParams = AlibcTradeShowParams.init()
        showParams.isNeedOpenByAliApp = true
        showParams.isPushBCWebView = true
        let failMode : Int = (getNumberFromCall(key: "nativeFailMode", call: call)).intValue;
        showParams.failMode =  NativeFailMode(mode: failMode)
        let tmpSchemeType : Int = (getNumberFromCall(key: "schemeType", call: call)).intValue;
        showParams.linkKey = schemeType(mode: tmpSchemeType)
        showParams.degradeUrl = getStringFromCall(key: "degradeUrl", call: call);
        let taokeParam = getTaokeParams(call: call) ?? nil
        let urlParam = getUrlParams(call: call)
        let trackParam : Dictionary<String,Any>? = getDicFromCall(key: "trackParam", call: call) ?? nil
        return OpenParams(showParams: showParams, taokeParams: taokeParam, urlParams: urlParam, trackParams: trackParam)
    }
    
    public func openItemDetail(call : FlutterMethodCall , result : @escaping FlutterResult, callBackString: String){
        let code = "suite://bc.suite.basic/bc.template.detail"
        let openParams: OpenParams = urlParams(call: call)
        let rootViewController : UIViewController = UIApplication.shared.windows.last!.rootViewController!
        AlibcTradeUltimateSDK.sharedInstance().tradeService().openTradePage(byCode: code, parentController: rootViewController, urlParams: openParams.urlParams, showParams: openParams.showParams, taoKeParams: openParams.taokeParams, trackParam: openParams.trackParams) { (error: Error?) in
            if error != nil {
                let dic = [FlutterAlibcConstKey.ErrorCode :String((error! as NSError).code) ,FlutterAlibcConstKey.ErrorMessage:error?.localizedDescription]
                self.channel?.invokeMethod(callBackString, arguments: [dic]);
                return
            }
            self.channel?.invokeMethod(callBackString, arguments: [
                FlutterAlibcConstKey.ErrorCode:"0",
                FlutterAlibcConstKey.ErrorMessage:"",
            ])
        }
    }
    
    public func openShop(call : FlutterMethodCall , result : @escaping FlutterResult, callBackString: String){
//        let shopId : String = getStringFromCall(key: "shopId", call: call);
//        let page = AlibcTradePageFactory.shopPage(shopId)
//        self.openPageByNewWay(page: page, bizcode: "shop", call: call, result: result, callBackString: callBackString)
    }
    
    public func openCart(call : FlutterMethodCall , result : @escaping FlutterResult, callBackString: String){
        let code = "suite://bc.suite.basic/bc.template.cart"
        let openParams: OpenParams = urlParams(call: call)
        let rootViewController : UIViewController = UIApplication.shared.windows.last!.rootViewController!
        AlibcTradeUltimateSDK.sharedInstance().tradeService().openTradePage(byCode: code, parentController: rootViewController, urlParams: openParams.urlParams, showParams: openParams.showParams, taoKeParams: openParams.taokeParams, trackParam: openParams.trackParams) { (error: Error?) in
            if error != nil {
                let dic = [FlutterAlibcConstKey.ErrorCode :String((error! as NSError).code) ,FlutterAlibcConstKey.ErrorMessage:error?.localizedDescription]
                self.channel?.invokeMethod(callBackString, arguments: [dic]);
                return
            }
            self.channel?.invokeMethod(callBackString, arguments: [
                FlutterAlibcConstKey.ErrorCode:"0",
                FlutterAlibcConstKey.ErrorMessage:"",
            ])
        }
    }

    //    MARK: 唤起端失败的策略转换
    private func NativeFailMode(mode: Int) -> AlibcOpenByAliAppFailedMode{
        var failType = AlibcOpenByAliAppFailedMode.aliAppDownloadPage
        switch mode {
        case 0:
            failType = AlibcOpenByAliAppFailedMode.aliAppDownloadPage
            break
        case 1 :
            failType = AlibcOpenByAliAppFailedMode.inAppByCustomerDegradeUrl
            break
        case 2 :
            failType = AlibcOpenByAliAppFailedMode.doNothing
            break
        default:
            break
        }
        return failType
    }
    
    private func schemeType(mode: Int) -> String{
        var linkKey = "tmall"
        switch mode {
        case 0:
            linkKey = "tmall"
            break
        case 1 :
            linkKey = "taobao"
            break
        default:
            break
        }
        return linkKey
    }
    
    //    MARK: - 获取参数
    private func getStringFromCall(key:String,call : FlutterMethodCall) -> String{
        guard let result = (call.arguments as? Dictionary<String, Any>)?[key] as? String else {
//          result(FlutterError(code: "参数异常", message: "参数url不能为空", details: nil))
            return ""
        }
        
        return result
    }
    
    private func getNumberFromCall(key:String,call : FlutterMethodCall) -> NSNumber{
        guard let result = (call.arguments as? Dictionary<String, Any>)?[key] as? NSNumber else {
            //            随便定个数字，如果没有，就是这个数字
            return FlutterAlibcConstKey.EmptyNum
        }
        return result
    }
    
    private func getBoolFromCall(key:String,call : FlutterMethodCall) -> Bool{
        guard let result = (call.arguments as? Dictionary<String, Any>)?[key] as? Bool else {
            return false
        }
        return result
    }
    
    private func getDicFromCall(key:String,call : FlutterMethodCall) -> Dictionary<String, Any>?{
        guard let result = (call.arguments as? Dictionary<String, Any>)?[key] as? Dictionary<String, Any> else {
            return nil
        }
        return result
    }
    
    //    MARK: - 设置淘客参数
    private func getTaokeParams(call : FlutterMethodCall) -> AlibcTradeTaokeParams?{
        let taoke : AlibcTradeTaokeParams = AlibcTradeTaokeParams.init()
        if getDicFromCall(key: "taoKeParams", call: call) == nil {
            return nil
        }
        let taokeParams = getDicFromCall(key: "taoKeParams", call: call)
        taoke.relationId = (taokeParams!["relationId"] is NSNull) ? nil : taokeParams!["relationId"] as? String
        taoke.materialSourceUrl = (taokeParams!["materialSourceUrl"] is NSNull) ? nil : taokeParams!["materialSourceUrl"] as? String
        taoke.pid = (taokeParams!["pid"] is NSNull) ? nil : taokeParams!["pid"] as? String
        taoke.unionId = (taokeParams!["unionId"] is NSNull) ? nil : taokeParams!["unionId"] as? String
        taoke.subPid = (taokeParams!["subPid"] is NSNull) ? nil : taokeParams!["subPid"] as? String
        taoke.extParams = (taokeParams!["extParams"] is NSNull) ? nil : taokeParams!["extParams"] as? [AnyHashable : Any]
        return taoke
    }
    
    private func getUrlParams(call: FlutterMethodCall) -> AlibcTradeUrlParams? {
        let urlParams: AlibcTradeUrlParams = AlibcTradeUrlParams()
        if getDicFromCall(key: "urlParams", call: call) == nil {
            return nil
        }
        let params = getDicFromCall(key: "urlParams", call: call)
        urlParams.id = ((params!["id"] is NSNull) ? nil : params!["id"] as? String) ?? ""
        urlParams.shopId = ((params!["shopId"] is NSNull) ? nil : params!["shopId"] as? String) ?? ""
        urlParams.bizExtMap = ((params!["bizExtMap"] is NSNull) ? nil : params!["bizExtMap"] as? [AnyHashable : Any]) ?? [:]
        return urlParams
    }

}


/**
 可设置的参数
 1.是否同步淘客打点
 2.是否使用Native支付宝
 3.是否使用淘客参数（是，需要设置如下参数）
 adzoneId
 pid
 //有adzoneId则pid失效
 unionId
 subPid
 extParams{
 sellerId
 taokeAppkey
 }
 4.页面打开方式
 是否唤端 Auto/Native
 唤起目标应用 淘宝/天猫
 是否以push的方式打开页面
 是否绑定webview
 是否自定义唤端失败策略（若是：H5，DownLoad，None）
 5.跟踪参数 customParams自定义
 */
