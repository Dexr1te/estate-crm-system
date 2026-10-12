import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { expect, it, vi } from "vitest";
import { Button } from "../../src/components/ui/button.tsx";
import { Card } from "../../src/components/ui/card.tsx";
import { Input } from "../../src/components/ui/input.tsx";

it("keeps Button native keyboard, disabled, and styling props", async () => {
  const user = userEvent.setup();
  const onClick = vi.fn();
  render(<Button type="button" variant="outline" size="sm" className="test-class" onClick={onClick}>Save client</Button>);

  const button = screen.getByRole("button", { name: "Save client" });
  expect(button).toHaveAttribute("type", "button");
  expect(button).toHaveAttribute("data-variant", "outline");
  expect(button).toHaveAttribute("data-size", "sm");
  expect(button).toHaveClass("ui-button", "test-class");
  button.focus();
  await user.keyboard("{Enter}");
  expect(onClick).toHaveBeenCalledTimes(1);

  render(<Button disabled aria-busy="true" onClick={onClick}>Saving client</Button>);
  const pendingButton = screen.getByRole("button", { name: "Saving client" });
  expect(pendingButton).toBeDisabled();
  expect(pendingButton).toHaveAttribute("aria-busy", "true");
  await user.click(pendingButton);
  expect(onClick).toHaveBeenCalledTimes(1);
});

it("renders a labeled required Input and reports typed values", async () => {
  const user = userEvent.setup();
  const onChange = vi.fn();
  render(<>
    <label htmlFor="client-email">Email</label>
    <Input id="client-email" name="email" type="email" required onChange={onChange} />
  </>);

  const input = screen.getByRole("textbox", { name: "Email" });
  expect(input).toHaveAttribute("type", "email");
  expect(input).toBeRequired();
  await user.type(input, "ada@example.test");
  expect(input).toHaveValue("ada@example.test");
  expect(onChange).toHaveBeenLastCalledWith(expect.objectContaining({ target: input }));
});

it("preserves Card children, className, and native attributes", () => {
  render(<Card className="client-card" data-area="clients"><h2>Clients</h2><p>12 records</p></Card>);

  const heading = screen.getByRole("heading", { name: "Clients" });
  const card = heading.parentElement;
  expect(card).toHaveAttribute("data-slot", "card");
  expect(card).toHaveAttribute("data-area", "clients");
  expect(card).toHaveClass("ui-card", "client-card");
  expect(within(card as HTMLElement).getByText("12 records")).toBeInTheDocument();
});
