import { getServerRuntimeConfig } from "@/lib/server/env";

export const runtime = "nodejs";

type RouteContext = { params: Promise<{ kind: string }> };

function streamChunks(chunks: Uint8Array[]): ReadableStream<Uint8Array> {
  let index = 0;
  return new ReadableStream({
    async pull(controller) {
      if (index === chunks.length) {
        controller.close();
        return;
      }
      await new Promise((resolve) => setTimeout(resolve, 25));
      controller.enqueue(chunks[index]);
      index += 1;
    },
  });
}

export async function GET(_request: Request, context: RouteContext): Promise<Response> {
  getServerRuntimeConfig();
  const { kind } = await context.params;

  if (kind === "binary") {
    const bytes = [new Uint8Array([0, 255, 16]), new Uint8Array([128, 1, 0])];
    return new Response(streamChunks(bytes), {
      headers: { "Cache-Control": "no-store", "Content-Type": "application/octet-stream" },
    });
  }

  if (kind === "csv") {
    const encoder = new TextEncoder();
    const chunks = ["id,name\n", "1,Alpha\n", "2,Beta\n"].map((part) => encoder.encode(part));
    return new Response(streamChunks(chunks), {
      headers: {
        "Cache-Control": "no-store",
        "Content-Disposition": 'attachment; filename="proof.csv"',
        "Content-Type": "text/csv; charset=utf-8",
      },
    });
  }

  if (kind === "slow") {
    await new Promise((resolve) => setTimeout(resolve, 90_000));
    return new Response("synthetic 90-second response", {
      headers: { "Cache-Control": "no-store", "Content-Type": "text/plain; charset=utf-8" },
    });
  }

  return Response.json({ error: "Not found" }, { status: 404 });
}

export async function POST(request: Request, context: RouteContext): Promise<Response> {
  getServerRuntimeConfig();
  const { kind } = await context.params;
  if (kind !== "upload") return Response.json({ error: "Not found" }, { status: 404 });

  const contentLength = Number(request.headers.get("content-length"));
  const form = await request.formData();
  const file = form.get("file");
  if (typeof file === "string" || !file) {
    return Response.json({ error: "Expected a multipart file" }, { status: 400 });
  }

  return Response.json({ fileName: file.name, fileBytes: file.size, requestBytes: contentLength });
}
