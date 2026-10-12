const longMax = 9_223_372_036_854_775_807n;

export function isLongIdString(value: string): boolean {
  if (!/^[1-9]\d{0,18}$/.test(value)) return false;
  return BigInt(value) <= longMax;
}

export function requireSafeApiId(value: unknown): number {
  if (typeof value !== "number" || !Number.isSafeInteger(value) || value <= 0) {
    throw new TypeError("The response contained an unsafe identifier.");
  }
  return value;
}

export function isLocalDate(value: string): boolean {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
  if (!match) return false;
  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);
  if (month < 1 || month > 12) return false;
  const leap = year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0);
  const days = [31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  return day >= 1 && day <= days[month - 1]!;
}

export function isYearMonth(value: string): boolean {
  const match = /^(\d{4})-(\d{2})$/.exec(value);
  return match !== null && Number(match[2]) >= 1 && Number(match[2]) <= 12;
}

export function isLocalDateTime(value: string): boolean {
  const match = /^(\d{4}-\d{2}-\d{2})T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{1,9}))?)?$/.exec(value);
  return match !== null && isLocalDate(match[1]!) && Number(match[2]) <= 23 &&
    Number(match[3]) <= 59 && (match[4] === undefined || Number(match[4]) <= 59);
}

type DecimalValue = { coefficient: bigint; scale: bigint };

function decimalValue(value: string): DecimalValue {
  const match = /^([+-]?)(?:(\d+)(?:\.(\d*))?|\.(\d+))(?:[eE]([+-]?\d+))?$/.exec(value);
  if (!match || value.length > 1024) throw new RangeError("Unsupported decimal precision.");
  const fraction = match[4] ?? match[3] ?? "";
  const digits = `${match[2] ?? "0"}${fraction}`.replace(/^0+/, "") || "0";
  let coefficient = BigInt(`${match[1] === "-" ? "-" : ""}${digits}`);
  if (coefficient === 0n) return { coefficient: 0n, scale: 0n };
  let scale = BigInt(fraction.length) - BigInt(match[5] ?? "0");
  while (scale > 0n && coefficient % 10n === 0n) {
    coefficient /= 10n;
    scale -= 1n;
  }
  if (scale < 0n) {
    if (-scale > 400n) throw new RangeError("Unsupported decimal precision.");
    coefficient *= 10n ** -scale;
    scale = 0n;
  }
  return { coefficient, scale };
}

export function decimalDraftToWireNumber(draft: string): number {
  if (draft.length === 0) throw new RangeError("Unsupported decimal precision.");
  const originalValue = decimalValue(draft);
  const number = Number(draft);
  if (!Number.isFinite(number) || (number === 0 && !/^[-+]?0*(?:\.0*)?(?:[eE][+-]?\d+)?$/.test(draft))) {
    throw new RangeError("Unsupported decimal precision.");
  }
  if (number === 0) return number;
  const serialized = JSON.stringify(number);
  if (serialized === undefined) throw new RangeError("Unsupported decimal precision.");
  const wireValue = decimalValue(serialized);
  if (originalValue.coefficient !== wireValue.coefficient || originalValue.scale !== wireValue.scale) {
    throw new RangeError("Unsupported decimal precision.");
  }
  return number;
}
