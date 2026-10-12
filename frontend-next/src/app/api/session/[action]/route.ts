import { type NextRequest } from "next/server";
import {
  handleSessionLogin,
  handleSessionLogout,
  handleSessionMe,
  handleSessionRefresh,
  unsupportedSessionRoute,
} from "../../../../lib/server/session-handler.ts";

export const dynamic = "force-dynamic";
export const revalidate = 0;
export const runtime = "nodejs";

type RouteContext = { params: Promise<{ action: string }> };

async function dispatch(request: NextRequest, context: RouteContext, method: string) {
  const { action } = await context.params;
  const allowedMethod = action === "me" ? "GET" : ["login", "refresh", "logout"].includes(action) ? "POST" : null;
  if (!allowedMethod) return unsupportedSessionRoute(404);
  if (method !== allowedMethod) return unsupportedSessionRoute(405, allowedMethod);
  if (action === "me") return handleSessionMe(request);
  if (action === "login") return handleSessionLogin(request);
  if (action === "refresh") return handleSessionRefresh(request);
  if (action === "logout") return handleSessionLogout(request);
  return unsupportedSessionRoute(404);
}

export function GET(request: NextRequest, context: RouteContext) {
  return dispatch(request, context, "GET");
}

export function POST(request: NextRequest, context: RouteContext) {
  return dispatch(request, context, "POST");
}

export function HEAD(request: NextRequest, context: RouteContext) {
  return dispatch(request, context, "HEAD");
}

export function PUT(request: NextRequest, context: RouteContext) {
  return dispatch(request, context, "PUT");
}

export function PATCH(request: NextRequest, context: RouteContext) {
  return dispatch(request, context, "PATCH");
}

export function DELETE(request: NextRequest, context: RouteContext) {
  return dispatch(request, context, "DELETE");
}

export function OPTIONS(request: NextRequest, context: RouteContext) {
  return dispatch(request, context, "OPTIONS");
}
