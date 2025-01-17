import Foundation
import GoogleSignIn
import WordPressKit

/// LoginFields is a state container for user textfield input on the login screens
/// as well as other meta data regarding the nature of a login attempt.
///
@objc
public class LoginFields: NSObject {
    // These fields store user input from text fields.

    /// Stores the user's account identifier (either email address or username) that is
    /// entered in the login flow. By convention, even if the user is logging in
    /// via an email address this field should store that value.
    @objc public var username = ""

    /// The user's password.
    @objc public var password = ""

    /// The site address if logging in via the self-hosted flow.
    @objc public var siteAddress = ""

    /// The two factor code entered by a user.
    @objc public var multifactorCode = "" // 2fa code

    /// Nonce info in the event of a social login with 2fa
    @objc public var nonceInfo: SocialLogin2FANonceInfo?

    /// User ID for use with the nonce for social login
    @objc public var nonceUserID: Int = 0

    /// Used to restrict login to WordPress.com
    public var restrictToWPCom = false

    /// Used by the SignupViewController. Signup currently asks for both a
    /// username and an email address.  This can be factored away when we revamp
    /// the signup flow.
    @objc public var emailAddress = ""

    @objc public var meta = LoginFieldsMeta()
    var storedCredentials: SafariStoredCredentials?

    /// Convenience method for persisting stored credentials.
    ///
    @objc func setStoredCredentials(usernameHash: Int, passwordHash: Int) {
        storedCredentials = SafariStoredCredentials()
        storedCredentials?.storedUserameHash = usernameHash
        storedCredentials?.storedPasswordHash = passwordHash
    }

    class func makeForWPCom(username: String, password: String) -> LoginFields {
        let loginFields = LoginFields()

        loginFields.username = username
        loginFields.password = password

        return loginFields
    }
}

/// A helper class for storing safari saved password information.
///
class SafariStoredCredentials {
    var storedUserameHash = 0
    var storedPasswordHash = 0
}

/// An enum to indicate where the Magic Link Email was sent from.
///
enum EmailMagicLinkSource: Int {
    case login = 1
    case signup = 2
}

@objc
public class LoginFieldsMeta: NSObject {

    /// Indicates where the Magic Link Email was sent from.
    ///
    var emailMagicLinkSource: EmailMagicLinkSource?

    /// Indicates whether a self-hosted user is attempting to log in to Jetpack
    ///
    @objc public var jetpackLogin = false

    /// Indicates whether a user is logging in via the wpcom flow or a self-hosted flow.  Used by the
    /// the LoginFacade in its branching logic.
    /// This is a good candidate to refactor out and call the proper login method directly.
    ///
    @objc public var userIsDotCom = true

    /// Indicates a wpcom account created via social sign up that requires either a magic link, or a social log in option.
    /// If a user signed up via social sign up and subsequently reset their password this field will be false.
    ///
    @objc public var passwordless = false

    /// Should point to the site's xmlrpc.php for a self-hosted log in.  Should be the value returned via XML-RPC discovery.
    ///
    @objc public var xmlrpcURL: NSURL?

    /// Meta data about a site. This information is fetched and then displayed on the login epilogue.
    ///
    var siteInfo: WordPressComSiteInfo?

    /// Flags whether a 2fa challenge had to be satisfied before a log in could be complete.
    /// Included in analytics after a successful login.
    ///
    @objc public var requiredMultifactor = false // A 2fa prompt was needed.

    /// Identifies a social login and the service used.
    ///
    var socialService: SocialServiceName?

    @objc public var socialServiceIDToken: String?

    var googleUser: GIDGoogleUser?

    var appleUser: AppleUser?
}
