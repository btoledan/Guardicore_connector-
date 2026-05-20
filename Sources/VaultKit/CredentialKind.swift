// CredentialKind.swift — VaultKit
// Defines the classification of credentials stored in the Keychain.
// Each kind maps to a distinct Keychain service string,
// preventing password blobs from spanning multiple security domains.

import Foundation

public enum CredentialKind: String, Sendable, CaseIterable {
    /// Passphrase for an SSH private key (identity file).
    /// Stored per key-file path.
    case sshIdentityPassphrase = "com.guardicore_connector.vault.ssh.identity"

    /// Password for a gateway / bastion hop (password-based auth).
    /// Only created in Lab workspace profiles.
    case gatewayPassword = "com.guardicore_connector.vault.ssh.gateway"

    /// Password for a direct SSH session (user@host password auth).
    /// Only created in Lab workspace profiles.
    case sshPassword = "com.guardicore_connector.vault.ssh.password"

    /// Master unlock secret for the Guardicore_connector session vault.
    case vaultUnlock = "com.guardicore_connector.vault.unlock"

    // MARK: Helpers

    /// Human-readable label shown in Keychain Access.
    public var keychainLabel: String {
        switch self {
        case .sshIdentityPassphrase: return "Guardicore_connector SSH Key Passphrase"
        case .gatewayPassword:       return "Guardicore_connector Gateway Password"
        case .sshPassword:           return "Guardicore_connector SSH Password"
        case .vaultUnlock:           return "Guardicore_connector Vault Unlock"
        }
    }

    /// Whether Touch ID / biometric access control is required for this kind.
    /// In Prod profiles all kinds require biometry; in Lab only vaultUnlock does.
    public func requiresBiometry(inProdProfile: Bool) -> Bool {
        if inProdProfile { return true }
        return self == .vaultUnlock
    }
}
