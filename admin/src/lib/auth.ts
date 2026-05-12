// Cookie-based password gate. If `ADMIN_PASSWORD` env is unset the admin
// runs in "open" mode (no auth) so local dev is friction-free.

import { cookies } from "next/headers";

const COOKIE = "socdaily_admin";

export function isAuthEnabled(): boolean {
  return Boolean(process.env.ADMIN_PASSWORD);
}

export function isAuthed(): boolean {
  if (!isAuthEnabled()) return true;
  const expected = process.env.ADMIN_PASSWORD;
  const c = cookies().get(COOKIE);
  return c?.value === expected;
}

export function loginCookieName(): string {
  return COOKIE;
}
