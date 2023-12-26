import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension NetworkClient.Configs {

	var isAuthEnabled: Bool {
		get { self[\.isAuthEnabled] ?? false }
		set { self[\.isAuthEnabled] = newValue }
	}
}

public extension NetworkClient {

	func auth(_ authModifier: AuthModifier) -> NetworkClient {
		enableAuth().modifyRequest { request, configs in
			if configs.isAuthEnabled {
				try authModifier.modifier(&request)
			}
		}
	}

	func disableAuth() -> NetworkClient {
		enableAuth(false)
	}

	func enableAuth(_ enabled: Bool = true) -> NetworkClient {
		configs(\.isAuthEnabled, enabled)
	}
}

public struct AuthModifier {

	let modifier: (inout URLRequest) throws -> Void

	public init(modifier: @escaping (inout URLRequest) -> Void) {
		self.modifier = modifier
	}

	public static func header(_ value: String) -> AuthModifier {
		AuthModifier {
			$0.setValue(value, forHTTPHeaderField: "Authorization")
		}
	}
}

public extension AuthModifier {

	/// Basic authentication is a simple authentication scheme built into the HTTP protocol.
	/// The client sends HTTP requests with the Authorization header that contains the word Basic word followed by a space and a base64-encoded string username:password.
	/// For example, to authorize as demo / p@55w0rd the client would send
	static func basic(_ password: String) -> AuthModifier {
		.header("Basic \(password.data(using: .utf8)?.base64EncodedString() ?? "")")
	}

	/// An API key is a token that a client provides when making API calls
	static func apiKey(_ key: String, field: String = "X-API-Key") -> AuthModifier {
		AuthModifier {
			$0.setValue(key, forHTTPHeaderField: field)
		}
	}

	/// Bearer authentication (also called token authentication) is an HTTP authentication scheme that involves security tokens called bearer tokens.
	/// The name “Bearer authentication” can be understood as “give access to the bearer of this token.”
	/// The bearer token is a cryptic string, usually generated by the server in response to a login request.
	/// The client must send this token in the Authorization header when making requests to protected resources
	static func bearer(_ password: String) -> AuthModifier {
		.header("Bearer \(password.data(using: .utf8)?.base64EncodedString() ?? "")")
	}

	//    /// OAuth 2.0 is an authorization protocol that gives an API client limited access to user data on a web server.
	//    /// GitHub, Google, and Facebook APIs notably use it.
	//    /// OAuth relies on authentication scenarios called flows, which allow the resource owner (user) to share the protected content from the resource server without sharing their credentials.
	//    /// For that purpose, an OAuth 2.0 server issues access tokens that the client applications can use to access protected resources on behalf of the resource owner.
	//    /// For more information about OAuth 2.0, see oauth.net and RFC 6749.
	//    static func oauth2(
	//        _ type: SecuritySchemeObject.OAuth2,
	//        id: String? = nil,
	//        refreshUrl: String? = nil,
	//        scopes: [String: String] = [:],
	//        description: String? = nil
	//    ) -> AuthModifier {
	//        AuthModifier(id: id, scheme: .oauth2(type, refreshUrl: refreshUrl, scopes: scopes, description: description))
	//    }
//
	//    /// OpenID Connect (OIDC) is an identity layer built on top of the OAuth 2.0 protocol and supported by some OAuth 2.0 providers, such as Google and Azure Active Directory.
	//    /// It defines a sign-in flow that enables a client application to authenticate a user, and to obtain information (or "claims") about that user, such as the user name, email, and so on.
	//    /// User identity information is encoded in a secure JSON Web Token (JWT), called ID token.
	//    static func openIDConnect(id: String? = nil, url: String, description: String? = nil) -> AuthModifier {
	//        AuthModifier(id: id, scheme: .openIDConnect(url: url, description: description))
	//    }
}
