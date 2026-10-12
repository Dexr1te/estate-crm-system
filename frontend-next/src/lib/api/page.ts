export type Page<T> = {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;
  size: number;
  first: boolean;
  last: boolean;
};

function record(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nonnegativeInteger(value: unknown): value is number {
  return Number.isSafeInteger(value) && (value as number) >= 0;
}

export function projectSpringPage<T>(value: unknown, decodeItem: (value: unknown) => T): Page<T> {
  if (!record(value) || !Array.isArray(value.content) ||
      !nonnegativeInteger(value.totalElements) || !nonnegativeInteger(value.totalPages) ||
      !nonnegativeInteger(value.number) || !nonnegativeInteger(value.size) ||
      typeof value.first !== "boolean" || typeof value.last !== "boolean") {
    throw new TypeError("The paged response was invalid.");
  }
  return {
    content: value.content.map(decodeItem),
    totalElements: value.totalElements,
    totalPages: value.totalPages,
    number: value.number,
    size: value.size,
    first: value.first,
    last: value.last,
  };
}
