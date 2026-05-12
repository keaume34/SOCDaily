"use server";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";

import { loginCookieName } from "@/lib/auth";

export async function login(form: FormData): Promise<void> {
  const expected = process.env.ADMIN_PASSWORD;
  const given = form.get("password");
  if (typeof given !== "string") redirect("/login?error=missing");
  if (!expected || given !== expected) redirect("/login?error=bad");
  cookies().set(loginCookieName(), expected, {
    httpOnly: true,
    sameSite: "lax",
    path: "/",
    maxAge: 60 * 60 * 24 * 7,
  });
  redirect("/");
}

export async function logout(): Promise<void> {
  cookies().delete(loginCookieName());
  redirect("/login");
}
