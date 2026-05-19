// Centralized utilities shared across the admin app. Keep this lean —
// anything specific to one screen lives next to that screen.

export function cn(...parts: Array<string | false | null | undefined>): string {
  return parts.filter(Boolean).join(" ");
}

export function formatNumber(n: number): string {
  return new Intl.NumberFormat("en-US").format(n);
}

export function isAdminAuthEnabled(): boolean {
  return Boolean(process.env.ADMIN_PASSWORD);
}
