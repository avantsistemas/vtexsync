# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails API-only application (see `Gemfile`) that synchronizes orders from VTEX e-commerce platform to a local MySQL database. The data is then exported to Protheus ERP. Ruby version is pinned in `.ruby-version`.

## Common Commands

```bash
# Setup
mise install                              # Install Ruby (version from .ruby-version)
gem install bundler                       # Install Bundler
bundle install                            # Install dependencies (uses BUNDLED WITH from Gemfile.lock)

# Database
bin/rails db:create db:migrate            # Create database and run migrations

# Sync orders from VTEX API
bin/rails vtex:sync_orders from="2022-06-15"          # Sync from specific date
bin/rails vtex:sync_order order_id="1379680932086-01" # Sync single order
bin/rails vtex:sync_1_day_ago                         # Sync last 24 hours
bin/rails vtex:sync_2_days_ago                        # Sync last 48 hours
bin/rails vtex:full_sync                              # Sync all orders since last synced

# Re-sync orders (mark/enqueue is a producer/consumer protocol via
# vtex_order_resync_requests; the sync job completes the request only on success)
bin/rails vtex:mark_for_resync order_ids="123-01,456-01" reason="ajuste"  # Open a pending resync request per order
bin/rails vtex:enqueue_resync limit=500                                   # Drain pending_resync into the queue in waves

# Linting
bundle exec rubocop                       # Run RuboCop
bundle exec rubocop -a                    # Auto-fix issues

# Background jobs
bin/rails jobs:work                       # Start Delayed Job worker
```

## Architecture

### Data Flow
1. **VTEX API** → `Vtex::Api::Client` fetches order data
2. **Sync Layer** (`app/lib/vtex/sync/`) transforms and persists data
3. **Models** (`app/models/vtex/`) store synchronized data with Paper Trail versioning
4. **Export** (`app/models/vtex/export/protheus/`) formats data for Protheus ERP

### Key Components

**API Client** (`app/lib/vtex/api/client.rb`): HTTP client for VTEX Orders API. Credentials stored in `config/credentials.yml.enc`, account settings in `config/application.yml`.

**Sync Engine** (`app/lib/vtex/sync/`):
- `Orders` - Batch sync for date ranges with pagination
- `Order` - Single order sync orchestrator
- `models/` - Individual entity sync classes with dependency/dependent pattern

**Dependency Pattern**: Each sync model can include `Dependencies` (must sync first) and `Dependents` (sync after parent). Example: Order syncs Client and Address as dependencies, then syncs OrderItems, Payments, etc. as dependents.

**Synchronizable Concern** (`app/models/concerns/synchronizable.rb`): Provides `sync_attributes` method that maps VTEX API camelCase fields to Rails snake_case columns. Models declare which attributes to sync with `sync_attributes` and optional `remap_attributes`.

### Entry Points
- **Rake tasks** (`lib/tasks/vtex/sync.rake`) - Manual or scheduled sync
- **Webhook** (`POST /webhooks/orders`) - Real-time sync via Delayed Job
- **Cron** (`config/schedule.rb`) - Daily sync at 2am via Whenever gem

### Database
MySQL with 28 VTEX-related tables plus IBGE geographic data (Brazilian municipalities). All models use Paper Trail for audit history.

## Configuration

- `config/database.yml` - MySQL connection settings
- `config/application.yml` - VTEX account name and environment
- `config/credentials.yml.enc` - VTEX API credentials (edit with `bin/rails credentials:edit`)
