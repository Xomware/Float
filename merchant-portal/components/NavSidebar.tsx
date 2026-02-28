"use client";

import React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  MapPin,
  Tag,
  BarChart3,
  Settings,
  LogOut,
  Waves,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { supabase } from "@/lib/supabase";
import { useRouter } from "next/navigation";

const NAV_ITEMS = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/venues", label: "Venues", icon: MapPin },
  { href: "/deals", label: "Deals", icon: Tag },
  { href: "/analytics", label: "Analytics", icon: BarChart3 },
  { href: "/settings", label: "Settings", icon: Settings },
];

export default function NavSidebar() {
  const pathname = usePathname();
  const router = useRouter();

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    router.push("/login");
  };

  return (
    <aside className="flex flex-col w-64 h-screen bg-white border-r border-border fixed left-0 top-0 z-40">
      {/* Logo */}
      <div className="flex items-center gap-2.5 px-6 py-5 border-b border-border">
        <div className="w-8 h-8 rounded-lg bg-indigo-600 flex items-center justify-center">
          <Waves className="w-5 h-5 text-white" />
        </div>
        <span className="font-bold text-lg tracking-tight">Float</span>
        <span className="text-xs bg-indigo-100 text-indigo-700 px-2 py-0.5 rounded-full font-medium ml-auto">
          Merchant
        </span>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
        {NAV_ITEMS.map(({ href, label, icon: Icon }) => {
          const isActive = pathname === href || pathname.startsWith(`${href}/`);
          return (
            <Link
              key={href}
              href={href}
              className={cn(
                "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors",
                isActive
                  ? "bg-indigo-50 text-indigo-700"
                  : "text-muted-foreground hover:bg-muted hover:text-foreground"
              )}
            >
              <Icon
                className={cn(
                  "w-4.5 h-4.5",
                  isActive ? "text-indigo-600" : "text-muted-foreground"
                )}
              />
              {label}
            </Link>
          );
        })}
      </nav>

      {/* Sign Out */}
      <div className="px-3 py-4 border-t border-border">
        <button
          onClick={handleSignOut}
          className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-muted-foreground hover:bg-red-50 hover:text-red-600 w-full transition-colors"
        >
          <LogOut className="w-4 h-4" />
          Sign Out
        </button>
      </div>
    </aside>
  );
}
