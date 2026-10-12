import type { ComponentProps } from "react";

type ButtonProps = ComponentProps<"button"> & {
  variant?: "default" | "outline" | "secondary" | "ghost" | "destructive" | "link";
  size?: "default" | "sm" | "lg" | "icon";
};

export function Button({ className, variant = "default", size = "default", ...props }: ButtonProps) {
  return (
    <button
      data-slot="button"
      data-variant={variant}
      data-size={size}
      className={`ui-button${className ? ` ${className}` : ""}`}
      {...props}
    />
  );
}
