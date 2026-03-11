# DealFlow — Email Integration Plan (Future Phase)

## Goal
Build an Outlook Add-in or Chrome Extension to connect Outlook email to DealFlow's DMS.

## Context
- Team uses Outlook (desktop + web) for email
- Manual .eml/.msg upload is impractical for real workflow
- Need one-click "Save to DealFlow" from within Outlook

## Approaches Evaluated
1. **Outlook Add-in (preferred)** — sidebar panel in Outlook, works desktop + web, official Microsoft path
2. **Chrome Extension** — simpler but only works with OWA in Chrome, fragile to UI changes
3. **Forward-to-system** — too manual, lacks deal/task context

## Requirements
- Select target deal and task when saving
- Push email body + attachments to DMS via API
- DMS must expose an API endpoint for email ingestion (design this into core DMS)

## Status
- **Phase**: Future (after core DMS is built)
- **Dependency**: Core DMS with document upload API must be ready first
