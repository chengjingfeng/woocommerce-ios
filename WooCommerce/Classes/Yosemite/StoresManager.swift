import Foundation
import Yosemite



// MARK: - StoresManager
//
class StoresManager {

    /// Shared Instance
    ///
    static var shared = StoresManager(sessionManager: .standard)

    /// SessionManager: Persistent Storage for Session-Y Properties.
    ///
    private(set) var sessionManager: SessionManager

    /// Active StoresManager State.
    ///
    private var state: StoresManagerState {
        willSet {
            state.willLeave()
        }
        didSet {
            state.didEnter()
        }
    }

    /// Indicates if the StoresManager is currently authenticated, or not.
    ///
    var isAuthenticated: Bool {
        return state is AuthenticatedState
    }

    /// Indicates if we need a Default StoreID, or there's one already set.
    ///
    var needsDefaultStore: Bool {
        return sessionManager.defaultStoreID == nil
    }



    /// Designated Initializer
    ///
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        self.state = AuthenticatedState(sessionManager: sessionManager) ?? DeauthenticatedState()

        restoreSessionAccountIfPossible()
        restoreSessionSiteIfPossible()
    }


    /// Forwards the Action to the current State.
    ///
    func dispatch(_ action: Action) {
        state.onAction(action)
    }

    /// Forwards the Actions to the current State.
    ///
    func dispatch(_ actions: [Action]) {
        for action in actions {
            state.onAction(action)
        }
    }

    /// Switches the internal state to Authenticated.
    ///
    @discardableResult
    func authenticate(credentials: Credentials) -> StoresManager {
        state = AuthenticatedState(credentials: credentials)
        sessionManager.defaultCredentials = credentials

        return self
    }

    /// Synchronizes all of the Session's Entities.
    ///
    @discardableResult
    func synchronizeEntities(onCompletion: (() -> Void)? = nil) -> StoresManager {
        let group = DispatchGroup()

        group.enter()
        synchronizeAccount { _ in
            group.leave()
        }
        
        group.enter()
        synchronizeAccountSettings { _ in
            group.leave()
        }

        group.enter()
        synchronizeSites { _ in
            group.leave()
        }

        group.enter()
        synchronizeSitePlan { _ in
            group.leave()
        }

        group.notify(queue: .main) {
            onCompletion?()
        }

        return self
    }

    /// Prepares for changing the selected store and remains Authenticated.
    ///
    func removeDefaultStore() {
        WooAnalytics.shared.refreshUserData()
        ZendeskManager.shared.reset()
        AppDelegate.shared.pushNotesManager.unregisterForRemoteNotifications()
        AppDelegate.shared.pushNotesManager.resetBadgeCount()
    }

    /// Switches the state to a Deauthenticated one.
    ///
    @discardableResult
    func deauthenticate() -> StoresManager {
        state = DeauthenticatedState()

        sessionManager.reset()
        WooAnalytics.shared.refreshUserData()
        ZendeskManager.shared.reset()
        AppDelegate.shared.storageManager.reset()

        NotificationCenter.default.post(name: .logOutEventReceived, object: nil)

        return self
    }

    /// Updates the Default Store as specified.
    ///
    func updateDefaultStore(storeID: Int) {
        sessionManager.defaultStoreID = storeID
        restoreSessionSiteIfPossible()

        NotificationCenter.default.post(name: .StoresManagerDidUpdateDefaultSite, object: nil)
    }
}


// MARK: - Private Methods
//
private extension StoresManager {

    /// Loads the Default Account into the current Session, if possible.
    ///
    func restoreSessionAccountIfPossible() {
        guard let accountID = sessionManager.defaultAccountID else {
            return
        }

        restoreSessionAccount(with: accountID)
    }

    /// Loads the specified accountID into the Session, if possible.
    ///
    func restoreSessionAccount(with accountID: Int) {
        let action = AccountAction.loadAccount(userID: accountID) { [weak self] account in
            guard let `self` = self, let account = account else {
                return
            }
            self.replaceTempCredentialsIfNecessary(account: account)
            self.sessionManager.defaultAccount = account
        }

        dispatch(action)
    }

    /// Synchronizes the WordPress.com Account, associated with the current credentials.
    ///
    func synchronizeAccount(onCompletion: @escaping (Error?) -> Void) {
        let action = AccountAction.synchronizeAccount { [weak self] (account, error) in
            if let `self` = self, let account = account, self.isAuthenticated {
                self.sessionManager.defaultAccount = account
                WooAnalytics.shared.refreshUserData()
            }
            
            onCompletion(error)
        }
        
        dispatch(action)
    }
    
    /// Synchronizes the WordPress.com Account Settings, associated with the current credentials.
    ///
    func synchronizeAccountSettings(onCompletion: @escaping (Error?) -> Void) {
        guard let userID = self.sessionManager.defaultAccount?.userID else {
            onCompletion(StoresManagerError.missingDefaultSite)
            return
        }
        
        let action = AccountAction.synchronizeAccountSettings(userID: userID) { [weak self] (accountSettings, error) in
            if let `self` = self, let accountSettings = accountSettings, self.isAuthenticated {
                // TODO: Do something here to turn off tracking if we opted out already
                WooAnalytics.shared.refreshUserData()
                // Save the user's preference
                WooAnalytics.shared.setUserHasOptedOut(accountSettings.tracksOptOut)
                
                // This event will only report if the user has turned tracking back on
                WooAnalytics.shared.track(.settingsCollectInfoToggled)

            }
            
            onCompletion(error)
        }
        
        dispatch(action)
    }
    
    /// Replaces the temporary UUID username in default credentials with the
    /// actual username from the passed account.  This *shouldn't* be necessary
    /// under normal conditions but is a safety net in case there is an error
    /// preventing the temp username from being updated during login.
    ///
    func replaceTempCredentialsIfNecessary(account: Account) {
        guard
            let credentials = sessionManager.defaultCredentials,
            credentials.hasPlaceholderUsername() else {
                return
        }
        authenticate(credentials: .init(username: account.username, authToken: credentials.authToken, siteAddress: credentials.siteAddress))
    }

    /// Synchronizes the WordPress.com Sites, associated with the current credentials.
    ///
    func synchronizeSites(onCompletion: @escaping (Error?) -> Void) {
        let action = AccountAction.synchronizeSites(onCompletion: onCompletion)
        dispatch(action)
    }

    /// Synchronizes the WordPress.com Site Plan.
    ///
    func synchronizeSitePlan(onCompletion: @escaping (Error?) -> Void) {
        guard let siteID = sessionManager.defaultSite?.siteID else {
            onCompletion(StoresManagerError.missingDefaultSite)
            return
        }

        let action = AccountAction.synchronizeSitePlan(siteID: siteID, onCompletion: onCompletion)
        dispatch(action)
    }

    /// Synchronizes the settings for the specified site, if possible.
    ///
    func synchronizeSettings(with siteID: Int, onCompletion: @escaping () -> Void) {
        guard siteID != 0 else {
            // Just return if the siteID == 0 so we are not making extra requests
            return
        }

        let group = DispatchGroup()
        var errors = [Error]()

        group.enter()
        let generalSettingsAction = SettingAction.synchronizeGeneralSiteSettings(siteID: siteID) { error in
            if let error = error {
                errors.append(error)
            }
            group.leave()
        }
        dispatch(generalSettingsAction)

        group.enter()
        let productSettingsAction = SettingAction.synchronizeProductSiteSettings(siteID: siteID) { error in
            if let error = error {
                errors.append(error)
            }
            group.leave()
        }
        dispatch(productSettingsAction)

        group.notify(queue: .main) {
            if errors.isEmpty {
                DDLogInfo("🎛 Site settings sync completed for siteID \(siteID)")
            } else {
                DDLogError("⛔️ Site settings sync had \(errors.count) error(s) for siteID \(siteID): \(errors)")
            }
            onCompletion()
        }
    }

    /// Synchronizes the order statuses, if possible.
    ///
    func retrieveOrderStatus(with siteID: Int) {
        guard siteID != 0 else {
            // Just return if the siteID == 0 so we are not making extra requests
            return
        }

        let action = OrderStatusAction.retrieveOrderStatuses(siteID: siteID) { (_, error) in
            if let error = error {
                DDLogError("⛔️ Could not successfully fetch order statuses for siteID \(siteID): \(error)")
            }
        }

        dispatch(action)
    }

    /// Loads the Default Site into the current Session, if possible.
    ///
    func restoreSessionSiteIfPossible() {
        guard let siteID = sessionManager.defaultStoreID else {
            return
        }

        restoreSessionSite(with: siteID)
        synchronizeSettings(with: siteID) {
            CurrencySettings.shared.refresh()
        }
        retrieveOrderStatus(with: siteID)
    }

    /// Loads the specified siteID into the Session, if possible.
    ///
    func restoreSessionSite(with siteID: Int) {
        let action = AccountAction.loadSite(siteID: siteID) { [weak self] site in
            guard let `self` = self, let site = site else {
                return
            }

            self.sessionManager.defaultSite = site
        }

        dispatch(action)
    }
}


// MARK: - StoresManagerState
//
protocol StoresManagerState {

    /// Executed before the state is deactivated.
    ///
    func willLeave()

    /// Executed whenever the State is activated.
    ///
    func didEnter()

    /// Executed whenever an Action is received.
    ///
    func onAction(_ action: Action)
}


// MARK: - StoresManagerError
//
enum StoresManagerError: Error {
    case missingDefaultSite
}
