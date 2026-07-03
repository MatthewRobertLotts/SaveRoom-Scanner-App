# Fixture Mode

Tags: #type/project

## Overview

Fixture mode is the default development mode for the first app shell. It loads sanitized v12.2.0 POS/frontend fixtures copied from the released API repo.

## Body

### Copied fixture list

- `card_detail_response.json`
- `inventory_item_list_filtered_response.json`
- `inventory_item_workflow_response.json`
- `listing_draft_list_filtered_response.json`
- `listing_draft_workflow_response.json`
- `local_sales_summary_response.json`

### Source

Source API release: `v12.2.0` at `4a3d91806999b168c6866c0c4f050ddae8557205`.

### Rules

- Sanitized fixtures only.
- Local/dev-only.
- Not live provider data.
- Not marketplace data.
- No private provider payloads, headers, account metadata, `.env`, SQLite DB, or credentials.

## Links

- Related: [APP_ARCHITECTURE.md](APP_ARCHITECTURE.md)
- Related: [API_INTEGRATION_PLAN.md](API_INTEGRATION_PLAN.md)
