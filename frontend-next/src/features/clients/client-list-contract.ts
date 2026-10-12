import { projectSpringPage, type Page } from "../../lib/api/page.ts";

const clientSortFields = new Set(["id", "createdAt", "fullName"]);

export function decodeClientListPage<T>(value: unknown, decodeItem: (value: unknown) => T): Page<T> {
  const page = projectSpringPage(value, decodeItem);
  if (page.size < 1 || page.size > 100) throw new TypeError("The API028 page size was invalid.");
  return page;
}

export function isClientListSort(value: string): boolean {
  const match = /^([A-Za-z][A-Za-z0-9]*),(asc|desc)$/.exec(value);
  return match !== null && clientSortFields.has(match[1]!);
}
