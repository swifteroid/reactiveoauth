import AppKit
import OAuthSwift
import ReactiveCocoa
import ReactiveSwift
import Result
import WebKit

open class OauthViewController: NSViewController
{
    @IBOutlet open weak var progressIndicator: NSProgressIndicator!
    @IBOutlet open weak var webViewBox: NSBox!

    // MARK: -

    open var webView: WKWebView! {
        get {
           return self.webViewBox.contentView as? WKWebView 
        }
        set {
            newValue?.navigationDelegate = self.webViewDelegate
            self.webViewBox.contentView = newValue
        }
    }

    open var webViewDelegate: OauthWebViewDelegate! {
        didSet {
            self.webView?.navigationDelegate = self.webViewDelegate
        }
    }

    // MARK: -

    override open var representedObject: Any? {
        didSet {
            if let oauth: OauthProtocol = self.representedObject as! OauthProtocol? {
                self.webViewDelegate.callbackUrl = URL(string: oauth.configuration.url.callback)
            }
        }
    }

    // MARK: -

    open func authorise() {
        if let oauth: OauthProtocol = self.representedObject as! OauthProtocol? {
            oauth.authorise(webView: self.webView)
        }
    }

    open func cancel() {
        if let oauth: OauthProtocol = self.representedObject as! OauthProtocol? {
            oauth.cancel()
        }
    }

    // MARK: –

    override open func loadView() {
        super.loadView()
        self.webView = OauthWebView(frame: self.webViewBox.frame)
        self.webViewDelegate = OauthWebViewDelegate(progressIndicator: self.progressIndicator)
    }

    override open func viewDidAppear() {
        self.authorise()
    }

    open override func viewDidDisappear() {
        self.cancel()
    }
}

// MARK: -

public protocol Oauthorisable: class
{
    func authorise<Detail>(oauthViewController: OauthViewController, oauth: DetailedOauth<Detail>)
}

extension Oauthorisable where Self: NSViewController
{
    public func authorise<Detail>(oauthViewController: OauthViewController, oauth: DetailedOauth<Detail>) {

        // Little hack to ensure the view and outlets are loaded. Todo: this whole approach is shitty, we must
        // todo: do this inside `OauthViewController`, not here…

        _ = oauthViewController.view
        oauthViewController.representedObject = oauth

        oauthViewController.reactive.makeBindingTarget({ (base, _) in base.progressIndicator.startAnimation(nil) }) <~ oauth.oauth.reactive.authorised.map({ _ in }).flatMapError({ _ in .never })
        oauthViewController.reactive.makeBindingTarget({ (base, _) in base.progressIndicator.stopAnimation(nil) }) <~ oauth.detalisator.reactive.detailed.map({ _ in }).flatMapError({ _ in .never })
        oauthViewController.reactive.makeBindingTarget({ (base, _) in base.dismiss(base) }) <~ oauth.reactive.authorised.map({ _ in }).flatMapError({ _ in .never })

        self.presentAsSheet(oauthViewController)
    }
}
