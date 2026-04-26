import Link from "next/link";
import { requirePlaceholderAdmin } from "@/lib/admin-auth";

const navItems = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/localities", label: "Localities" },
  { href: "/rent-reports", label: "Rent Reports" },
  { href: "/forum", label: "Forum" },
  { href: "/quests", label: "Quests" },
  { href: "/mentors", label: "Mentors" }
];

export function AdminShell({ children }: { children: React.ReactNode }) {
  const admin = requirePlaceholderAdmin();

  return (
    <div className="min-h-screen bg-stone-50 text-neutral-950">
      <aside className="fixed inset-y-0 left-0 hidden w-64 border-r border-stone-200 bg-white px-4 py-6 lg:block">
        <div>
          <p className="text-xs font-semibold uppercase text-emerald-700">NammaCircle</p>
          <h1 className="mt-1 text-xl font-semibold">Admin</h1>
        </div>
        <nav className="mt-8 space-y-1">
          {navItems.map((item) => (
            <Link
              className="block rounded-md px-3 py-2 text-sm font-medium text-neutral-700 hover:bg-stone-100 hover:text-neutral-950"
              href={item.href}
              key={item.href}
            >
              {item.label}
            </Link>
          ))}
        </nav>
        <p className="absolute bottom-6 left-4 right-4 rounded-md bg-amber-50 p-3 text-xs text-amber-900">
          Placeholder auth: {admin.displayName}. Replace with role-checked auth before production.
        </p>
      </aside>
      <div className="lg:pl-64">
        <header className="border-b border-stone-200 bg-white px-5 py-4 lg:hidden">
          <p className="text-sm font-semibold">NammaCircle Admin</p>
          <nav className="mt-3 flex gap-2 overflow-x-auto">
            {navItems.map((item) => (
              <Link
                className="whitespace-nowrap rounded-md bg-stone-100 px-3 py-2 text-xs font-medium"
                href={item.href}
                key={item.href}
              >
                {item.label}
              </Link>
            ))}
          </nav>
        </header>
        <main className="px-5 py-8">{children}</main>
      </div>
    </div>
  );
}
