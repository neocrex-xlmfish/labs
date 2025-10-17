# xlm.fish — Multi-chain Platform

## Vision
Build a multi-blockchain web platform that lets users connect wallets, view unified balances, send/receive assets, and enable cross-chain flows and advanced tooling.

## Current Repositories
- **neocrex-xlmfish/labs** — Project planning and orchestration (this repo)
- **neocrex-xlmfish/home** — Home Repository
- **neocrex-xlmfish/xlm.fish** — Marketing/static site (HTML)
- **neocrex-xlmfish/xlmfish-stellar** — Stellar connector/service (Rust)

## MVP Goals
1. Stellar + EVM chain connectors
2. Next.js frontend with wallet connect, balances, and send/receive
3. Indexer service for transaction history (PostgreSQL)
4. CI/CD and basic deployment

## Architecture
- **Frontend**: Next.js (React + TypeScript) on Vercel
- **Wallet Integration**: Web3Modal, WalletConnect, Phantom, Solana, Stellar SDKs
- **Connectors**: Per-chain services (Stellar Rust, EVM Node/TS, Solana Node/TS)
- **Indexer**: PostgreSQL + Redis for transaction history and caching
- **Deployment**: Docker, Kubernetes (optional), Vercel

## Roadmap
- **Phase 0**: Planning & repo scaffolding (current)
- **Phase 1**: Connectors & indexers (2–3 weeks)
- **Phase 2**: Frontend MVP (2–3 weeks)
- **Phase 3**: Testing & security (1–2 weeks)
- **Phase 4**: Additional chains and cross-chain features

## Key Principles
- **Non-custodial**: No private key storage on servers
- **Modular**: Easy to add new chains
- **Secure**: HSM/KMS for any server-side operations
- **Observable**: Prometheus, Grafana, Sentry integration

## How to Contribute
- Use feature branches and open PRs
- Add tests for connectors and UI
- Follow codeowners policy

## Status
🚧 Planning phase — repositories scaffolding in progress
