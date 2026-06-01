# DevOps MCP Mail Showcase

Sanitized public mirror of selected infrastructure and automation paths from a
private platform repository. It is meant to show DevOps, MCP and mail tooling
work without exposing production configuration or private operational data.

## What This Demonstrates

- Docker Compose infrastructure for local and CI workflows
- NGINX and PHP container configuration
- Mailpit-oriented local mail testing setup
- Mailcow-related automation patterns with sensitive configuration removed
- TypeScript MCP server examples for Slack and Linear-style integrations
- Node automation utilities using TypeScript
- Preserved Git history for retained infrastructure and tooling paths

## Code Map

- `docker/` contains Compose stacks, PHP-FPM, NGINX, MySQL, Mailpit and Mailcow-adjacent service configuration.
- `tools/slack-mcp-server/src/index.ts` shows an MCP-style Slack/GitHub automation server.
- `tools/linear-mcp-server/src/index.ts` shows an issue-tracking MCP server skeleton.
- `tools/template-analyzer/src/` contains a TypeScript CLI that extracts template structure and generates Strapi schema plus implementation prompts.
- `tools/site-builder/src/` contains a multi-step automation pipeline for template analysis, Strapi import, media handling, Next.js generation, DNS/SSL and VPS deployment.
- `docs/MAILPIT.md` and `docs/MAILCOW_SETUP.md` document the local mail testing and mailbox automation setup.

## Sanitization Notes

Production hostnames, credentials, private mailbox configuration, environment
files, backups and client deployment instructions were removed. This repository
is a portfolio showcase, not a production-ready infrastructure dump.
