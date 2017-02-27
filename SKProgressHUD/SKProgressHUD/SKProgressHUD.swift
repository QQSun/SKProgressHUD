//
//  SKProgressHUD.swift
//  SKProgressHUD
//
//  Created by nachuan on 2016/11/4.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit


/// SKProgressHUD模式
///
/// - indeterminate:            模糊的
/// - determinate:              清楚的
/// - determinateHorizontalBar: 水平bar
/// - annularDeterminate:       环形
/// - customView:               自定义
/// - text:                     文字
enum SKProgressHUDMode {
    case indeterminate
    case determinate
    case determinateHorizontalBar
    case annularDeterminate
    case customView
    case text
}


/// SKProgressHUD动画
///
/// - fade:    渐变
/// - zoom:    缩放
/// - zoomOut: 缩小
/// - zoomIn:  放大
enum SKProgressHUDAnimation {
    case fade
    case zoom
    case zoomOut
    case zoomIn
}


/// SKProgressHUD背景样式
///
/// - solidColor: 固态色
/// - blur:       模糊
enum SKProgressHUDBackgroundStyle {
    case solidColor
    case blur
}


/// 动画完成回调closure
typealias SKProgressHUDCompletionClosure = (_ finished: Bool) -> Void;


/// SKProgressHUD代理
protocol SKProgressHUDDelegate: class {
    
    /// 当hud已经完全隐藏后被调用
    ///
    /// - parameter hud: 调用者(SKProgressHUD实例)
    func wasHidden(hud: SKProgressHUD) -> Void;
}


// MARK: - 用户方法
extension SKProgressHUD {
    class func showHUDAdded(to view: UIView, animated: Bool) -> SKProgressHUD {
        let hud: SKProgressHUD = SKProgressHUD.init(frame: view.bounds);
        hud.removeFromSuperViewOnHide = true;
        view.addSubview(hud);
        hud.showAnimated(animated: animated);
        return hud;
    }
    
    class func hideHUD(for view: UIView, animated: Bool) -> Bool {
        let hud: SKProgressHUD? = SKProgressHUD.HUD(for: view);
        if hud == nil {
            return false;
        }else{
            hud!.removeFromSuperViewOnHide = true;
            hud!.hideAnimated(animated: animated);
            return true;
        }
        
    }
    
    class func HUD(for view: UIView) -> SKProgressHUD? {
        for subview in view.subviews.reversed() {
            if subview is SKProgressHUD {
                return subview as? SKProgressHUD;
            }
        }
        return nil;
        
    }
    
    func showAnimated(animated: Bool) -> Void {
        SKMainThreadAssert();
        if minShowTimer != nil {
            minShowTimer!.invalidate();
        }
        useAnimation = animated;
        hasFinished = false;
        if graceTime > 0 {
            graceTimer = Timer.init(timeInterval: graceTime, target: self, selector: #selector(handleGraceTimer(timer: )), userInfo: nil, repeats: false);
            RunLoop.current.add(graceTimer!, forMode: .commonModes);
        }else{
            showUsingAnimation(animated: useAnimation);
        }
    }
    
    func hideAnimated(animated: Bool) -> Void {
        SKMainThreadAssert();
        if graceTimer != nil {
            graceTimer!.invalidate();
        }
        useAnimation = animated;
        hasFinished = true;
        if minShowTime > 0 && showStarted != nil {
            let interV: TimeInterval = NSDate().timeIntervalSince(showStarted as! Date);
            if interV < minShowTime {
                minShowTimer = Timer.init(timeInterval: (minShowTime - interV), target: self, selector: #selector(handleMinShowTimer(timer: )), userInfo: nil, repeats: false);
                RunLoop.current.add(minShowTimer!, forMode: .commonModes);
                return;
            }
        }
        hideUsingAnimation(animated: useAnimation);
    }
    
    func hideAnimated(animated: Bool, after delay: TimeInterval) -> Void {
        hideDelayTimer = Timer.init(timeInterval: delay, target: self, selector: #selector(handleHideTimer(timer: )), userInfo: animated, repeats: false);
        RunLoop.current.add(hideDelayTimer!, forMode: .commonModes);
    }
    
    func SKMainThreadAssert() -> Void {
        assert(Thread.isMainThread, "请放到主线程执行");
    }
}


// MARK: - 私有方法
fileprivate extension SKProgressHUD {
    
    //MARK: - Timer 回调方法
    @objc func handleGraceTimer(timer: Timer) -> Void {
        if !hasFinished {
            showUsingAnimation(animated: useAnimation);
        }
    }
    
    @objc func handleMinShowTimer(timer: Timer) -> Void {
        hideUsingAnimation(animated: useAnimation);
    }
    
    @objc func handleHideTimer(timer: Timer) -> Void {
        hideAnimated(animated: timer.userInfo as! Bool);
    }
    
    func showUsingAnimation(animated: Bool) -> Void {
        bezelView.layer.removeAllAnimations();
        backgroundView.layer.removeAllAnimations();
        if hideDelayTimer != nil {
            hideDelayTimer!.invalidate();
        }
        self.showStarted = NSDate();
        self.alpha = 1;
        setProgressDisplayLink(enabled: true);
        if animated {
            animateIn(animateIn: true, with: animationType, completion: {_ in });
        }else{
            bezelView.alpha = 1;
            backgroundView.alpha = 1;
        }
        
        
    }
    
    func hideUsingAnimation(animated: Bool) -> Void {
        if animated && showStarted != nil {
            showStarted = nil;
            animateIn(animateIn: false, with: animationType, completion: { (Bool) in
                self.done();
            });
        }else{
            showStarted = nil;
            bezelView.alpha = 0;
            backgroundView.alpha = 1;
            done();
        }
    }
    
    
    func animateIn(animateIn: Bool, with type: SKProgressHUDAnimation, completion: @escaping SKProgressHUDCompletionClosure) -> Void {
        var tempType = type;
        
        if tempType == .zoom {
            tempType = animateIn ? .zoomIn : .zoomOut;
        }
        let small: CGAffineTransform = CGAffineTransform.init(scaleX: 0.5, y: 0.5);
        let large: CGAffineTransform = CGAffineTransform.init(scaleX: 1.5, y: 1.5);
        
        if animateIn && bezelView.alpha == 0 && tempType == .zoomIn {
            bezelView.transform = small;
        }else if animateIn && bezelView.alpha == 0 && tempType == .zoomOut {
            bezelView.transform = large;
        }
        
        let animations: () -> Void = {
            if animateIn {
                self.bezelView.transform = .identity;
            }else if !animateIn && tempType == .zoomIn {
                self.bezelView.transform = large;
            }else if !animateIn && tempType == .zoomOut {
                self.bezelView.transform = small;
            }
            self.bezelView.alpha = animateIn ? 1 : 0;
            self.backgroundView.alpha = animateIn ? 1 : 0;
        };
        
        
        if kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0 {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: animations, completion: completion);
        }else{
            UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: animations, completion: completion);
        }
    }
    
    
    /// 完成回调
    func done() -> Void {
        if hideDelayTimer != nil {
            hideDelayTimer!.invalidate();
        }
        setProgressDisplayLink(enabled: false);
        if hasFinished {
            self.alpha = 0;
            if removeFromSuperViewOnHide {
                self.removeFromSuperview();
            }
        }
        
        if completionClosure != nil {
            completionClosure!(true);
        }
        if delegate != nil {
            delegate!.wasHidden(hud: self);
        }
    }
    
    
}

// MARK: - 私有存储属性
fileprivate extension SKProgressHUD {
    var progressObjectDisplayLink: CADisplayLink? {
        get {
            return _progressObjectDisplayLink;
        }
        set {
            setProgressObject(displayLink: newValue);
        }
    }
}


// MARK: - 私有的setter
fileprivate extension SKProgressHUD {
    func setProgressObject(displayLink: CADisplayLink?) -> Void {
        if _progressObjectDisplayLink != displayLink  {
            if _progressObjectDisplayLink != nil {
                _progressObjectDisplayLink!.invalidate();
            }
            _progressObjectDisplayLink = displayLink;
            if _progressObjectDisplayLink != nil {
                _progressObjectDisplayLink!.add(to: RunLoop.main, forMode: .defaultRunLoopMode);
            }
        }
    }
}

// MARK: - 公共存储属性
extension SKProgressHUD {
    
    var progress: CGFloat {
        get {
            return _progress;
        }
        set {
            setProgress(progress: newValue);
        }
    }
    
    var contentColor: UIColor {
        get {
            return _contentColor;
        }
        set {
            setContentColor(color: newValue);
        }
    }
    
    var progressObject: Progress? {
        get {
            return _progressObject;
        }
        set {
            setProgressObject(object: newValue);
        }
    }
    
    var mode: SKProgressHUDMode {
        get {
            return _mode;
        }
        set {
            setMode(mode: newValue);
        }
    }
    
    
    var customView: UIView? {
        get {
            return _customView;
        }
        set {
            setCustomView(view: newValue);
        }
    }
    
    /// 统一样式
    var offset: CGPoint {
        get {
            return _offset;
        }
        set {
            setOffset(offset: newValue);
        }
    }
    
    var margin: CGFloat {
        get {
            return _margin;
        }
        set {
            setMargin(margin: newValue);
        }
    }
    
    var minSize: CGSize {
        get {
            return _minSize;
        }
        set {
            setMinSize(size: newValue);
        }
    }
    
    var square: Bool {
        get {
            return _square;
        }
        set {
            setSquare(square: newValue);
        }
    }
    
    var defaultMotionEffectsEnabled: Bool {
        get {
            return _defaultMotionEffectsEnabled;
        }
        set {
            setDefaultMotionEffects(enabled: newValue);
        }
    }
    
}


// MARK: - setter
extension SKProgressHUD {
    
    func setProgress(progress: CGFloat) -> Void {
        if _progress != progress {
            _progress = progress;
            //MARK: - 此处的indicator存在问题
            if indicator != nil && indicator!.responds(to: #selector(setProgress(progress: ))) {
                indicator!.setValue(progress, forKey: "progress");
            }
            
        }
    }
    
    func setContentColor(color: UIColor) -> Void {
        if _contentColor != color && !_contentColor.isEqual(color) {
            _contentColor = color;
            updateViewsForColor(color: color);
        }
    }
    
    func setProgressObject(object: Progress?) -> Void {
        if _progressObject != object {
            _progressObject = object;
            setProgressDisplayLink(enabled: true);
        }
    }
    
    func setMode(mode: SKProgressHUDMode) -> Void {
        if _mode != mode {
            _mode = mode;
            updateIndicators();
        }
    }
    
    func setCustomView(view: UIView?) -> Void {
        if _customView != view {
            _customView = view;
            if mode == .customView {
                updateIndicators();
            }
        }
    }
    
    /// 统一样式属性
    func setOffset(offset: CGPoint) -> Void {
        if _offset != offset {
            _offset = offset;
            setNeedsUpdateConstraints();
        }
    }
    
    func setMargin(margin: CGFloat) -> Void {
        if _margin != margin {
            _margin = margin;
            setNeedsUpdateConstraints();
        }
    }
    
    func setMinSize(size: CGSize) -> Void {
        if _minSize != size {
            _minSize = size;
            setNeedsUpdateConstraints();
        }
    }
    
    func setSquare(square: Bool) -> Void {
        if _square != square {
            _square = square;
            setNeedsUpdateConstraints();
        }
    }
    
    func setDefaultMotionEffects(enabled: Bool) -> Void {
        if _defaultMotionEffectsEnabled != enabled {
            _defaultMotionEffectsEnabled = enabled;
            updateBezelMotionEffects();
        }
    }
    
    func setProgressDisplayLink(enabled: Bool) -> Void {
        if enabled && progressObject != nil {
            if progressObjectDisplayLink == nil {
                progressObjectDisplayLink = CADisplayLink(target: self, selector: #selector(updateProgressFromProgressObject));
            }
        }else{
            progressObjectDisplayLink = nil;
        }
    }
    
}

let SKProgressMaxOffset: CGFloat = 1000000;


fileprivate let SKDefaultPadding: CGFloat = 4;
fileprivate let SKDefaultLabelFontSize: CGFloat = 16;
fileprivate let SKDefaultDetailsLabelFontSize: CGFloat = 12;

class SKProgressHUD: UIView {
    
    weak var delegate: SKProgressHUDDelegate?
    
    var completionClosure: SKProgressHUDCompletionClosure?
    
    
    //MARK: - 私有存储属性
    /// 有公开属性
    fileprivate var _progress: CGFloat = 0.0;
    fileprivate var _progressObject: Progress?
    var _mode: SKProgressHUDMode = .indeterminate;
    fileprivate var _customView: UIView?
    /// 无公开属性
    
    
    fileprivate var useAnimation: Bool = false;
    fileprivate var hasFinished: Bool = false;
    fileprivate var showStarted: NSDate?
    fileprivate var paddingConstraints: [NSLayoutConstraint]?
    fileprivate var bezelConstraints: [NSLayoutConstraint]?
    fileprivate var topSpacer: UIView = UIView()
    fileprivate var bottomSpacer: UIView = UIView();
    fileprivate var indicator: UIView?
    fileprivate var graceTimer: Timer?
    fileprivate var minShowTimer: Timer?
    fileprivate var hideDelayTimer: Timer?
    
    fileprivate var _progressObjectDisplayLink: CADisplayLink?;
    
    //MARK: - 私有存储属性之统一样式属性
    var _contentColor: UIColor = UIColor(white: 0, alpha: 0.5);
    var _offset: CGPoint = .zero;
    var _margin: CGFloat = 20.0;
    var _minSize: CGSize = .zero;
    var _square: Bool = false;
    var _defaultMotionEffectsEnabled: Bool = true;
    
    //MARK: - 公共存储属性
    var graceTime: TimeInterval = 0.0;
    var minShowTime: TimeInterval = 0.0;
    var removeFromSuperViewOnHide = false;
    var bezelView: SKBackgroundView = SKBackgroundView();
    var backgroundView: SKBackgroundView = SKBackgroundView();
    var label: UILabel = UILabel();
    var detailsLabel: UILabel = UILabel();
    var button: SKRoundedButton = SKRoundedButton();

    //MARK: - 公共存储属性之统一样式属性

    var animationType: SKProgressHUDAnimation = .fade;
    
    
    //MARK: - lifecycle(生命周期)
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    
    
    func commonInit() -> Void {
        
        let isLegacy = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0;
        contentColor = isLegacy ? .white : UIColor.init(white: 0, alpha: 0.7);
        self.isOpaque = false;
        self.backgroundColor = .clear;
        
        self.alpha = 0.0;
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        self.layer.allowsGroupOpacity = false;
        setupViews();
        updateIndicators();
        registerForNotifications();
        
    }
    
    func setupViews() -> Void {
        let defaultColor: UIColor = contentColor;
        backgroundView.style = .solidColor;
        backgroundView = SKBackgroundView.init(frame: self.bounds);
        backgroundView.backgroundColor = .clear;
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        backgroundView.alpha = 0;
        self.addSubview(backgroundView);
        
        bezelView.translatesAutoresizingMaskIntoConstraints = false;
        bezelView.layer.cornerRadius = 5;
        bezelView.alpha = 0.0;
        self.addSubview(bezelView);
        updateBezelMotionEffects();
        
        //MARK: - 此处label未添加的父视图
        label.adjustsFontSizeToFitWidth = false;
        label.textAlignment = .center;
        label.textColor = defaultColor;
        label.font = UIFont.boldSystemFont(ofSize: SKDefaultLabelFontSize);
        label.isOpaque = false;
        label.backgroundColor = .clear;
        
        detailsLabel.adjustsFontSizeToFitWidth = false;
        detailsLabel.textAlignment = .center;
        detailsLabel.textColor = defaultColor;
        detailsLabel.numberOfLines = 0;
        detailsLabel.font = UIFont.boldSystemFont(ofSize: SKDefaultDetailsLabelFontSize);
        detailsLabel.isOpaque = false;
        detailsLabel.backgroundColor = .clear;
        
        button.titleLabel!.textAlignment = .center;
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: SKDefaultDetailsLabelFontSize);
        button.setTitleColor(defaultColor, for: .normal);
        
        for view: UIView in [label, detailsLabel, button] {
            view.translatesAutoresizingMaskIntoConstraints = false;
            view.setContentCompressionResistancePriority(998, for: .horizontal);
            view.setContentCompressionResistancePriority(998, for: .vertical);
            bezelView.addSubview(view);
        }
        
        topSpacer.translatesAutoresizingMaskIntoConstraints = false;
        topSpacer.isHidden = true;
        bezelView.addSubview(topSpacer);
        
        bottomSpacer.translatesAutoresizingMaskIntoConstraints = false;
        bottomSpacer.isHidden = true;
        bezelView.addSubview(bottomSpacer);
    }
    
    
    //MARK: - Notification
    func registerForNotifications() -> Void {
        let center: NotificationCenter = .default;
        center.addObserver(self, selector: #selector(statusBarOrientation(did:)), name: Notification.Name.init(rawValue: "UIApplicationDidChangeStatusBarOrientationNotification"), object: nil);
        
    }
    
    func statusBarOrientation(did change: Notification) -> Void {
        let superView: UIView? = self.superview;
        if superView != nil {
            updateForCurrentOrientation(animated: true);
        }else{
            return;
        }
    }
    
    func unregisterFromNotifications() -> Void {
        let center: NotificationCenter = .default;
        center.removeObserver(self, name: NSNotification.Name.init(rawValue: "UIApplicationDidChangeStatusBarOrientationNotification"), object: nil);
        
    }
    
    func updateForCurrentOrientation(animated: Bool) -> Void {
        if self.superview != nil {
            self.frame = self.superview!.bounds;
        }
        
        let iOS8OrLater: Bool = kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0;
        if iOS8OrLater || !(self.superview is UIWindow) {
            return;
        }
        
        let UIApplicationClass = NSClassFromString("UIApplication") as? UIApplication.Type;
        if UIApplicationClass == nil || !UIApplicationClass!.responds(to: #selector(getter: UIApplication.shared)) {
            return;
        }else{
            let application: UIApplication = UIApplicationClass!.shared;
            let orientation: UIInterfaceOrientation = application.statusBarOrientation;
            var radius: CGFloat = 0;
            if UIInterfaceOrientationIsLandscape(orientation) {
                radius = orientation == UIInterfaceOrientation.landscapeLeft ? -CGFloat(M_PI_2) : CGFloat(M_PI_2);
                
                /// 此处可能出在问题.为什么height和Width颠倒赋值
                self.bounds = CGRect(x: 0, y: 0, width: self.bounds.height, height: self.bounds.width);
            }else{
                radius = orientation == UIInterfaceOrientation.portraitUpsideDown ? CGFloat(M_PI) : 0;
            }
            if animated {
                UIView.animate(withDuration: 0.3, animations: { 
                    self.transform = CGAffineTransform.init(rotationAngle: radius);
                });
            }else{
                self.transform = CGAffineTransform(rotationAngle: radius);
            }
        }
    }
    
    func updateBezelMotionEffects() -> Void {
        if !bezelView.responds(to: #selector(addMotionEffect(_: ))) {
            return;
        }
        if defaultMotionEffectsEnabled {
            let effectOffset: CGFloat = 10;
            let effectX: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis);
            effectX.maximumRelativeValue = effectOffset;
            effectX.minimumRelativeValue = -effectOffset;
            
            let effectY: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis);
            effectY.maximumRelativeValue = effectOffset;
            effectY.minimumRelativeValue = -effectOffset;
            
            let group: UIMotionEffectGroup = UIMotionEffectGroup();
            group.motionEffects = [effectX, effectY];
            bezelView.addMotionEffect(group);
        }else{
            let effects = bezelView.motionEffects;
            for effect: UIMotionEffect in effects {
                bezelView.removeMotionEffect(effect);
            }
        }
    }
    
    func updateProgressFromProgressObject() -> Void {
        if progressObject != nil {
            progress = CGFloat(progressObject!.fractionCompleted);
        }
    }
    
    func updateIndicators() -> Void {
        let isActivityIndicator: Bool = indicator is UIActivityIndicatorView;
        let isRoundIndicator: Bool = indicator is SKRoundProgressView;
        if mode == .indeterminate {
            if !isActivityIndicator {
                if indicator != nil {
                    indicator!.removeFromSuperview();
                    indicator = nil;
                }
                indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge);
                (indicator as! UIActivityIndicatorView).startAnimating();
                bezelView.addSubview(indicator!);
            }
        }else if mode == .determinateHorizontalBar {
            if indicator != nil {
                indicator!.removeFromSuperview();
                indicator = nil;
            }
            indicator = SKBarProgressView();
            bezelView.addSubview(indicator!);
        }else if mode == .determinate || mode == .annularDeterminate {
            if !isRoundIndicator {
                if indicator != nil {
                    indicator!.removeFromSuperview();
                    indicator = nil;
                }
                indicator = SKRoundProgressView();
                bezelView.addSubview(indicator!);
            }
            if mode == .annularDeterminate {
                (indicator as! SKRoundProgressView).isAnnular = true;
            }
        }else if mode == .customView && customView?.isEqual(indicator) != true {
            if indicator != nil {
                indicator!.removeFromSuperview();
                indicator = nil;
            }
            if customView != nil {
                indicator = customView!;
                bezelView.addSubview(indicator!);
            }
            
        }else if mode == .text {
            if indicator != nil {
                indicator!.removeFromSuperview();
                indicator = nil;
            }
        }
        if indicator != nil {
            indicator!.translatesAutoresizingMaskIntoConstraints = false;
            if indicator!.responds(to: #selector(setProgress(progress:))) {
                indicator!.setValue(progress, forKey: "progress");
            }
            
            indicator!.setContentCompressionResistancePriority(998, for: .horizontal);
            indicator!.setContentCompressionResistancePriority(998, for: .vertical);
            updateViewsForColor(color: contentColor);
            setNeedsUpdateConstraints();
            
        }
        
    }
    
    func updateViewsForColor(color: UIColor) -> Void {
        self.label.textColor = color;
        self.detailsLabel.textColor = color;
        self.button.setTitleColor(color, for: .normal);
        let isActivityIndicator: Bool = indicator is UIActivityIndicatorView;
        let isRoundProgress: Bool = indicator is SKRoundProgressView;
        let isBarProgress: Bool = indicator is SKBarProgressView;
        
        if isActivityIndicator {
            
            let appearance: UIActivityIndicatorView = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [SKProgressHUD.self]);
            if appearance.color == nil {
                if indicator != nil {
                    (indicator as! UIActivityIndicatorView).color = color;
                }
            }
        }else if isRoundProgress {
        
//  注释的方法涉及到了动态特性.会导致第一次出现时不会调用setter方法
//            let appearance: SKRoundProgressView = SKRoundProgressView.appearance(whenContainedInInstancesOf: [SKProgressHUD.self]);
//            appearance.progressTintColor = color;
//            appearance.backgroundTintColor = color.withAlphaComponent(0.1);
            
            let picker: UIImagePickerController = UIImagePickerController();
            
            
            (indicator as! SKRoundProgressView).progressTintColor = color;
            (indicator as! SKRoundProgressView).backgroundTintColor = color.withAlphaComponent(0.1);
        }else if isBarProgress {
            (indicator as! SKBarProgressView).progressColor = color;
            (indicator as! SKBarProgressView).lineColor = color;
        }else{
            if indicator != nil && indicator!.responds(to: #selector(setter: tintColor)) {
                
                indicator!.tintColor = color;
            }
        }
        if indicator != nil {
            indicator!.backgroundColor = .clear;
        }
    }
    //MARK: - Layout
    
    override func updateConstraints() {
        let bezel: UIView = bezelView;
        let topSpacer: UIView = self.topSpacer;
        let bottomSpacer: UIView = self.bottomSpacer;
        let margin: CGFloat = self.margin;
        
        bezelConstraints = [NSLayoutConstraint]();
        let metrics: [String : Any] = ["margin" : margin];
        var subViews: [UIView] = [self.topSpacer, self.label, self.detailsLabel, self.button, self.bottomSpacer];
        if indicator != nil {
            subViews.insert(indicator!, at: 1);
        }
        self.removeConstraints(self.constraints);
        topSpacer.removeConstraints(topSpacer.constraints);
        bottomSpacer.removeConstraints(bottomSpacer.constraints);
        if bezelConstraints != nil {
            bezel.removeConstraints(bezelConstraints!);
        }else{
            bezelConstraints = [NSLayoutConstraint]();
        }
        
        let offset: CGPoint = self.offset;
        var centeringConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]();
        centeringConstraints.append(NSLayoutConstraint.init(item: bezel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: offset.x));
        centeringConstraints.append(NSLayoutConstraint.init(item: bezel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: offset.y));
        applyPriority(priority: 998, to: centeringConstraints);
        self.addConstraints(centeringConstraints);
        
        /// 确保最小边缘是约束的
        var sideConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]();
        let dic: [String : UIView]? = ["bezel" : bezel];
        if dic != nil {
            sideConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[bezel]-(>=margin)-|", options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics: metrics, views: dic!));
            sideConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=margin)-[bezel]-(>=margin)-|", options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics: metrics, views: dic!));
            applyPriority(priority: 999, to: sideConstraints);
            self.addConstraints(sideConstraints);
        }
        
        /// 最小bezel的size.如果设置了
        let minimumSize = minSize;
        if minimumSize != .zero {
            var minSizeConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]();
            minSizeConstraints.append(NSLayoutConstraint.init(item: bezel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: minimumSize.width));
            minSizeConstraints.append(NSLayoutConstraint.init(item: bezel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: minimumSize.height));
            applyPriority(priority: 997, to: minSizeConstraints);
            bezelConstraints!.append(contentsOf: minSizeConstraints);
            
        }
        
        if square {
            let squareConstraint: NSLayoutConstraint = NSLayoutConstraint.init(item: bezel, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: bezel, attribute: .width, multiplier: 1, constant: 0);
            squareConstraint.priority = 997;
            bezelConstraints!.append(squareConstraint);
            
        }
        
        topSpacer.addConstraint(NSLayoutConstraint.init(item: topSpacer, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: margin));
        bottomSpacer.addConstraint(NSLayoutConstraint.init(item: bottomSpacer, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil
            , attribute: .notAnAttribute, multiplier: 1, constant: margin));
        bezelConstraints!.append(NSLayoutConstraint.init(item: topSpacer, attribute: .height, relatedBy: .equal, toItem: bottomSpacer, attribute: .height, multiplier: 1, constant: 0));
        
        if paddingConstraints != nil {
            paddingConstraints!.removeAll();
        }else{
            paddingConstraints = [NSLayoutConstraint]();
        }
        
        for (index, view) in subViews.enumerated() {
            bezelConstraints!.append(NSLayoutConstraint.init(item: view, attribute: .centerX, relatedBy: .equal, toItem: bezel, attribute: .centerX, multiplier: 1, constant: 0));
            let dic: [String : UIView]? = dictionary(for: view, index: index);
            
            if dic != nil {
                bezelConstraints!.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[view\(index)]-(>=margin)-|", options: .directionLeadingToTrailing, metrics: metrics, views: dic!));
            }
            
            if index == 0 {
                bezelConstraints!.append(NSLayoutConstraint.init(item: view, attribute: .top, relatedBy: .equal, toItem: bezel, attribute: .top, multiplier: 1, constant: 0));
            }else if index == subViews.count - 1 {
                bezelConstraints!.append(NSLayoutConstraint.init(item: view, attribute: .bottom, relatedBy: .equal, toItem: bezel, attribute: .bottom, multiplier: 1, constant: 0));
            }
            if index > 0 {
                let paddingConstraint = NSLayoutConstraint.init(item: view, attribute: .top, relatedBy: .equal, toItem: subViews[index - 1], attribute: .bottom, multiplier: 1, constant: 0);
                bezelConstraints!.append(paddingConstraint);
                paddingConstraints!.append(paddingConstraint);
                
            }
        };
        bezel.addConstraints(bezelConstraints!);
        updatePaddingContraints();
        super.updateConstraints();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        if self.needsUpdateConstraints() == false {
            updatePaddingContraints();
        }
        
        
    }
    
    func updatePaddingContraints() -> Void {
        if paddingConstraints != nil {
            var hasVisibleAncestors = false;
            
            for (_, padding) in paddingConstraints!.enumerated() {
                let firstView: UIView = padding.firstItem as! UIView;
                let secondView: UIView = padding.secondItem as! UIView;
                let firstVisible: Bool = !firstView.isHidden && !(firstView.intrinsicContentSize == .zero);
                let secondVisible: Bool = !secondView.isHidden && !(secondView.intrinsicContentSize == .zero);
                padding.constant = (firstVisible && (secondVisible || hasVisibleAncestors)) ? SKDefaultPadding : 0;
                hasVisibleAncestors = (hasVisibleAncestors || secondVisible);
            }
        }        
    }
    
    func applyPriority(priority: UILayoutPriority, to constraints: [NSLayoutConstraint]) -> Void {
        for constraint: NSLayoutConstraint in constraints {
            constraint.priority = priority;
        }
    }
    
    
    deinit {
        unregisterFromNotifications();
    }
    
}













































