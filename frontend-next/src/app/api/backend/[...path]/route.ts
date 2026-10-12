import type { NextRequest } from "next/server";
import { handlePrivateBff } from "@/lib/server/bff-handler";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

type RouteContext = { params: Promise<{ path: string[] }> };

async function dispatch(request: NextRequest, context: RouteContext): Promise<Response> {
  const { path } = await context.params;
  return handlePrivateBff(request, path);
}

export const GET = dispatch;
export const POST = dispatch;
export const PUT = dispatch;
export const PATCH = dispatch;
export const DELETE = dispatch;
export const HEAD = dispatch;
export const OPTIONS = dispatch;
