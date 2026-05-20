# Helmsman — Guardicore Operations Console

A macOS application for managing, monitoring, and debugging Guardicore-protected Kubernetes environments over double-hop SSH.

---

## What it does

Helmsman connects your Mac directly to Guardicore thin environments and their Kubernetes clusters through a bastion host. From a single window you can:

- Open interactive SSH terminals to tester, management, aggregator, and cluster nodes
- View live cluster topology — nodes, pods, namespaces, GC agent coverage
- Monitor Guardicore system status: DaemonSet readiness, gc-kube-enforce, policy revision chain (CM → Agent → Calico CRD)
- Validate traffic allow/block behaviour and correlate results with agent verdict logs
- Inspect raw Calico NetworkPolicy CRDs and check for `action: Deny` enforcement
- Export cluster snapshots as Markdown or JSON for reports and handoffs

---

## Requirements

- macOS 13 or later
- Xcode 15 or later
- `sshpass` installed locally (`brew install hudochenkov/sshpass/sshpass`)
- `xcodegen` installed locally (`brew install xcodegen`)

---

## Build

```bash
# Generate Xcode project and build the debug app
make build

# Run the app
open .build/DerivedData/Build/Products/Debug/Helmsman.app
```

---

## Project structure

```
Sources/
  Helmsman/
    App/           — App entry point and menu commands
    Models/        — Data models, SSH double-hop, cluster view model, Kube parsers
    Views/
      ThinEnv/     — Environment sidebar, cluster panel, topology, overview, GC status
      Terminal/    — Terminal tabs and pane
      Sessions/    — Generic SSH session management
      SSH/         — Proxy jump composer, connection export
      Root/        — Sidebar and root content view
      Settings/    — App settings
  SSHKit/          — SSH config parsing and proxy-jump chain builder
  VaultKit/        — Keychain credential storage
  KubeKit/         — kubeconfig parsing and kubectl snippet library
  NetScanKit/      — Local network scanner
  TerminalKit/     — SwiftTerm-based terminal session wrapper
Tests/
  SSHKitTests/
  KubeKitTests/
scripts/           — DMG packaging and notarization scripts
project.yml        — XcodeGen project spec
```

---

## Architecture

### SSH double-hop

All remote connections go through two SSH hops:

```
Mac → bastion (thin env tester) → target host (cluster master / management / aggregator)
```

Authentication uses `sshpass` for password-based lab environments.

### Cluster View

The Cluster View panel runs background `kubectl` commands against the cluster master over the double-hop SSH connection and parses the output into a live snapshot:

- **Phase 1** — nodes and all pods (fast, populates topology immediately)
- **Phase 2** — Guardicore pods, DaemonSet, deployments, Calico policies, agent revision logs, events

### Policy revision chain

The revision chain tracks whether Guardicore CM policies have propagated end-to-end:

```
CM publish → gc-agent policy revision → Calico CRD annotation
```

All three values are displayed together in the Overview tab so you can immediately see if a cluster is out of sync.

---

## License

Internal tooling. Not for public distribution.
