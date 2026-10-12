"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useRef, useState, type FocusEvent, type KeyboardEvent as ReactKeyboardEvent, type PointerEvent, type ReactNode } from "react";
import type { SessionIdentity } from "../../lib/session-types.ts";
import { isNavigationActive } from "../../lib/navigation/entry.ts";
import { Button } from "../ui/button.tsx";

type ShellIdentity = Pick<SessionIdentity, "fullName" | "role" | "teamName">;
type ShellLink = { label: string; href: string };
type Breadcrumb = { label: string; href?: string };

type Props = {
  identity: ShellIdentity;
  navigation: readonly ShellLink[];
  breadcrumbs: readonly Breadcrumb[];
  children: ReactNode;
};

const roleLabels: Record<ShellIdentity["role"], string> = {
  ADMIN: "Admin",
  MANAGER: "Manager",
  AGENT: "Agent",
};

export function AppShell({ identity, navigation, breadcrumbs, children }: Props) {
  const pathname = usePathname();
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const dialogRef = useRef<HTMLDialogElement>(null);
  const menuButtonRef = useRef<HTMLButtonElement>(null);
  const desktopToggleRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if (!(event.ctrlKey || event.metaKey) || event.key.toLowerCase() !== "b") return;
      const target = event.target;
      if (!(target instanceof HTMLElement) || target.isContentEditable || target.closest("input, textarea, select")) return;
      if (!window.matchMedia("(min-width: 640px)").matches) return;
      event.preventDefault();
      setCollapsed((value) => !value);
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, []);

  useEffect(() => {
    const desktop = window.matchMedia("(min-width: 640px)");
    const closeOnDesktop = () => {
      if (desktop.matches) setMobileOpen(false);
      document.querySelectorAll<HTMLSpanElement>(".crm-nav-tooltip").forEach((tooltip) => {
        if (tooltip.matches(":popover-open")) tooltip.hidePopover();
      });
    };
    desktop.addEventListener("change", closeOnDesktop);
    closeOnDesktop();
    return () => desktop.removeEventListener("change", closeOnDesktop);
  }, []);

  function showNavigationTooltip(event: FocusEvent<HTMLAnchorElement> | PointerEvent<HTMLAnchorElement>) {
    if (!collapsed || !event.currentTarget.closest(".crm-sidebar-desktop")) return;
    const tooltip = event.currentTarget.querySelector<HTMLSpanElement>(".crm-nav-tooltip");
    if (!tooltip || typeof tooltip.showPopover !== "function") return;
    const bounds = event.currentTarget.getBoundingClientRect();
    const sidebarRight = event.currentTarget.closest(".crm-sidebar")?.getBoundingClientRect().right ?? bounds.right;
    tooltip.style.left = `${Math.max(bounds.right, sidebarRight) + 8}px`;
    tooltip.style.top = `${bounds.top + bounds.height / 2}px`;
    if (!tooltip.matches(":popover-open")) tooltip.showPopover();
  }

  function hideNavigationTooltip(event: FocusEvent<HTMLAnchorElement> | PointerEvent<HTMLAnchorElement>) {
    const tooltip = event.currentTarget.querySelector<HTMLSpanElement>(".crm-nav-tooltip");
    if (tooltip?.matches(":popover-open")) tooltip.hidePopover();
  }

  function trapDialogTab(event: ReactKeyboardEvent<HTMLDialogElement>) {
    if (event.key !== "Tab") return;
    const dialog = dialogRef.current;
    if (!dialog?.open) return;
    const focusable = [...dialog.querySelectorAll<HTMLElement>('a[href], button:not(:disabled), input:not(:disabled), select:not(:disabled), textarea:not(:disabled), [tabindex]:not([tabindex="-1"])')]
      .filter((element) => element.getClientRects().length > 0);
    const first = focusable[0];
    const last = focusable.at(-1);
    if (event.shiftKey && document.activeElement === first && last) {
      event.preventDefault();
      last.focus();
    } else if (!event.shiftKey && document.activeElement === last && first) {
      event.preventDefault();
      first.focus();
    }
  }

  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog) return;
    if (mobileOpen && !dialog.open) dialog.showModal();
    if (!mobileOpen && dialog.open) dialog.close();
  }, [mobileOpen]);

  function navList(location: "desktop" | "mobile") {
    return (
      <nav aria-label="Primary navigation">
        <ul className="crm-nav-list">
          {navigation.map((item) => (
            <li key={item.href}>
              <Link
                aria-label={item.label}
                aria-current={isNavigationActive(pathname, item.href) ? "page" : undefined}
                className="crm-nav-link"
                href={item.href}
                onBlur={hideNavigationTooltip}
                onClick={location === "mobile" ? () => setMobileOpen(false) : undefined}
                onFocus={showNavigationTooltip}
                onKeyDown={(event) => {
                  if (event.key !== "Escape") return;
                  const tooltip = event.currentTarget.querySelector<HTMLSpanElement>(".crm-nav-tooltip");
                  if (tooltip?.matches(":popover-open")) {
                    event.preventDefault();
                    tooltip.hidePopover();
                  }
                }}
                onPointerEnter={showNavigationTooltip}
                onPointerLeave={hideNavigationTooltip}
                title={item.label}
              >
                <span aria-hidden="true" className="crm-nav-glyph">{item.label.slice(0, 1)}</span>
                <span className="crm-nav-label">{item.label}</span>
                <span aria-hidden="true" className="crm-nav-tooltip" popover="manual">{item.label}</span>
              </Link>
            </li>
          ))}
        </ul>
      </nav>
    );
  }

  function sidebar(location: "desktop" | "mobile") {
    return (
      <aside aria-label="Estate CRM workspace" className={"crm-sidebar crm-sidebar-" + location} id={location === "desktop" ? "crm-desktop-sidebar" : undefined}>
        <div className="crm-brand">
          <span aria-hidden="true" className="crm-brand-mark">◆</span>
          <span className="crm-sidebar-text">Estate CRM</span>
        </div>
        <div className="crm-workspace-context">
          <strong className="crm-sidebar-text">{identity.teamName || "No team assigned"}</strong>
          <span>{roleLabels[identity.role]}</span>
        </div>
        {navList(location)}
        <div className="crm-sidebar-identity" title={identity.fullName}>
          <span aria-hidden="true" className="crm-avatar">{identity.fullName.slice(0, 1).toUpperCase()}</span>
          <span className="crm-sidebar-text">
            <strong>{identity.fullName}</strong>
            <small>{roleLabels[identity.role]}</small>
          </span>
        </div>
      </aside>
    );
  }

  return (
    <div className="crm-shell" data-sidebar-collapsed={collapsed}>
      {sidebar("desktop")}
      <div className="crm-workspace">
        <header className="crm-topbar">
          <Button
          aria-controls="crm-mobile-navigation"
          aria-expanded={mobileOpen}
            aria-haspopup="dialog"
            aria-label="Open navigation"
            className="crm-mobile-menu-button"
            onClick={() => setMobileOpen(true)}
            ref={menuButtonRef}
            size="icon"
            type="button"
            variant="ghost"
          >
            <span aria-hidden="true">☰</span>
          </Button>
          <nav aria-label="Breadcrumbs" className="crm-breadcrumbs">
            <ol>
                {breadcrumbs.map((breadcrumb, index) => (
                <li aria-current={index === breadcrumbs.length - 1 ? "page" : undefined} key={breadcrumb.label}>
                  {index < breadcrumbs.length - 1 && breadcrumb.href
                    ? <Link href={breadcrumb.href}>{breadcrumb.label}</Link>
                    : breadcrumb.label}
                </li>
              ))}
            </ol>
          </nav>
          <Button
            aria-controls="crm-desktop-sidebar"
            aria-expanded={!collapsed}
            aria-label={collapsed ? "Expand sidebar" : "Collapse sidebar"}
            className="crm-collapse-button"
            onClick={() => setCollapsed((value) => !value)}
            ref={desktopToggleRef}
            size="sm"
            title={collapsed ? "Expand sidebar" : "Collapse sidebar"}
            type="button"
            variant="ghost"
          >
            {collapsed ? "Expand" : "Collapse"}
          </Button>
        </header>
        <main className="crm-main">{children}</main>
      </div>
      <dialog
        aria-label="Navigation"
        className="crm-mobile-dialog"
        id="crm-mobile-navigation"
        onKeyDown={trapDialogTab}
        onClose={() => {
          setMobileOpen(false);
          const menuButton = menuButtonRef.current;
          const focusTarget = menuButton && menuButton.offsetParent !== null ? menuButton : desktopToggleRef.current;
          if (focusTarget && focusTarget.offsetParent !== null) focusTarget.focus();
        }}
        onCancel={() => setMobileOpen(false)}
        ref={dialogRef}
      >
        <div className="crm-mobile-dialog-header">
          <span>Estate CRM</span>
          <Button aria-label="Close navigation" autoFocus onClick={() => setMobileOpen(false)} size="icon" type="button" variant="ghost">
            <span aria-hidden="true">×</span>
          </Button>
        </div>
        {sidebar("mobile")}
      </dialog>
    </div>
  );
}
