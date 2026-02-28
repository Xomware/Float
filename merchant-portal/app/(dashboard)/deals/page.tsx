"use client";

import React, { useState } from "react";
import Link from "next/link";
import DealForm, { DealFormData } from "@/components/DealForm";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import {
  Plus,
  Search,
  BarChart2,
  Edit2,
  ToggleLeft,
  ToggleRight,
  Repeat,
  Calendar,
} from "lucide-react";
import { formatDate, formatTime } from "@/lib/utils";
import { cn } from "@/lib/utils";

interface Deal {
  id: string;
  title: string;
  description: string;
  venue_name: string;
  venue_id: string;
  discount_type: "percentage" | "fixed" | "bogo" | "free_item";
  discount_value: number;
  start_time: string;
  end_time: string;
  max_redemptions: number | null;
  total_redemptions: number;
  is_active: boolean;
  recurrence: { frequency: "daily" | "weekly" | "monthly"; days_of_week?: number[]; end_date?: string } | null;
}

const MOCK_DEALS: Deal[] = [
  {
    id: "d1",
    title: "Happy Hour 20% Off",
    description: "20% off all food and drinks during happy hour",
    venue_name: "Downtown Bar & Grill",
    venue_id: "v1",
    discount_type: "percentage",
    discount_value: 20,
    start_time: new Date(Date.now() - 86400000).toISOString(),
    end_time: new Date(Date.now() + 86400000 * 3).toISOString(),
    max_redemptions: 100,
    total_redemptions: 84,
    is_active: true,
    recurrence: { frequency: "weekly" },
  },
  {
    id: "d2",
    title: "Free Dessert with Entrée",
    description: "Get a free dessert when you order any entrée",
    venue_name: "The Rooftop Lounge",
    venue_id: "v2",
    discount_type: "free_item",
    discount_value: 0,
    start_time: new Date(Date.now() - 86400000 * 2).toISOString(),
    end_time: new Date(Date.now() + 86400000 * 7).toISOString(),
    max_redemptions: null,
    total_redemptions: 47,
    is_active: true,
    recurrence: null,
  },
  {
    id: "d3",
    title: "BOGO Cocktails",
    description: "Buy one cocktail, get one free",
    venue_name: "Café Central",
    venue_id: "v3",
    discount_type: "bogo",
    discount_value: 0,
    start_time: new Date(Date.now() - 86400000 * 5).toISOString(),
    end_time: new Date(Date.now() + 86400000 * 1).toISOString(),
    max_redemptions: 50,
    total_redemptions: 211,
    is_active: false,
    recurrence: { frequency: "daily" },
  },
];

const VENUES = [
  { id: "v1", name: "Downtown Bar & Grill" },
  { id: "v2", name: "The Rooftop Lounge" },
  { id: "v3", name: "Café Central" },
];

function discountLabel(deal: Deal): string {
  if (deal.discount_type === "percentage") return `${deal.discount_value}% off`;
  if (deal.discount_type === "fixed") return `$${deal.discount_value} off`;
  if (deal.discount_type === "bogo") return "BOGO";
  return "Free item";
}

export default function DealsPage() {
  const [deals, setDeals] = useState<Deal[]>(MOCK_DEALS);
  const [search, setSearch] = useState("");
  const [view, setView] = useState<"list" | "create" | "edit">("list");
  const [editingDeal, setEditingDeal] = useState<Deal | null>(null);
  const [filter, setFilter] = useState<"all" | "active" | "inactive">("all");

  const filtered = deals.filter((d) => {
    const matchesSearch =
      d.title.toLowerCase().includes(search.toLowerCase()) ||
      d.venue_name.toLowerCase().includes(search.toLowerCase());
    const matchesFilter =
      filter === "all" || (filter === "active" && d.is_active) || (filter === "inactive" && !d.is_active);
    return matchesSearch && matchesFilter;
  });

  const handleCreate = async (data: DealFormData) => {
    const newDeal: Deal = {
      id: `d${Date.now()}`,
      ...data,
      venue_name: VENUES.find((v) => v.id === data.venue_id)?.name ?? "",
      total_redemptions: 0,
    };
    setDeals((prev) => [newDeal, ...prev]);
    setView("list");
  };

  const handleUpdate = async (data: DealFormData) => {
    if (!editingDeal) return;
    setDeals((prev) =>
      prev.map((d) =>
        d.id === editingDeal.id
          ? {
              ...d,
              title: data.title,
              description: data.description,
              venue_id: data.venue_id,
              discount_type: data.discount_type,
              discount_value: data.discount_value,
              start_time: data.start_time,
              end_time: data.end_time,
              max_redemptions: data.max_redemptions,
              recurrence: data.recurrence,
              is_active: data.is_active,
              venue_name: VENUES.find((v) => v.id === data.venue_id)?.name ?? d.venue_name,
            }
          : d
      )
    );
    setView("list");
    setEditingDeal(null);
  };

  const toggleActive = (id: string) => {
    setDeals((prev) => prev.map((d) => (d.id === id ? { ...d, is_active: !d.is_active } : d)));
  };

  if (view === "create") {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Create Deal</h1>
          <p className="text-muted-foreground mt-1">Set up a new deal for your venue.</p>
        </div>
        <DealForm
          venues={VENUES}
          onSubmit={handleCreate}
          onCancel={() => setView("list")}
        />
      </div>
    );
  }

  if (view === "edit" && editingDeal) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Edit Deal</h1>
          <p className="text-muted-foreground mt-1">Update the deal details.</p>
        </div>
        <DealForm
          venues={VENUES}
          initialData={editingDeal}
          onSubmit={handleUpdate}
          onCancel={() => { setView("list"); setEditingDeal(null); }}
        />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Deals</h1>
          <p className="text-muted-foreground mt-1">Create and manage your deals.</p>
        </div>
        <Button onClick={() => setView("create")}>
          <Plus className="w-4 h-4 mr-2" />
          New Deal
        </Button>
      </div>

      {/* Filters */}
      <div className="flex items-center gap-4 flex-wrap">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input
            placeholder="Search deals..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-9 max-w-xs"
          />
        </div>
        <div className="flex gap-1">
          {(["all", "active", "inactive"] as const).map((f) => (
            <Button
              key={f}
              variant={filter === f ? "secondary" : "ghost"}
              size="sm"
              onClick={() => setFilter(f)}
              className="capitalize"
            >
              {f}
            </Button>
          ))}
        </div>
      </div>

      {/* Deals Table */}
      {filtered.length === 0 ? (
        <div className="text-center py-16 text-muted-foreground">
          <p className="text-lg font-medium">No deals found</p>
          <p className="text-sm mt-1">Try adjusting your search or create a new deal.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {filtered.map((deal) => {
            const progress = deal.max_redemptions
              ? (deal.total_redemptions / deal.max_redemptions) * 100
              : null;
            const isExpired = new Date(deal.end_time) < new Date();

            return (
              <Card key={deal.id} className={cn(!deal.is_active && "opacity-60")}>
                <CardContent className="p-4">
                  <div className="flex items-center gap-4">
                    {/* Deal Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 flex-wrap">
                        <h3 className="font-semibold text-sm">{deal.title}</h3>
                        <Badge variant={deal.is_active && !isExpired ? "success" : "secondary"}>
                          {isExpired ? "Expired" : deal.is_active ? "Active" : "Paused"}
                        </Badge>
                        <Badge variant="outline">{discountLabel(deal)}</Badge>
                        {deal.recurrence && (
                          <Badge variant="outline" className="gap-1">
                            <Repeat className="w-3 h-3" />
                            {deal.recurrence.frequency}
                          </Badge>
                        )}
                      </div>
                      <p className="text-xs text-muted-foreground mt-1">{deal.venue_name}</p>
                      <div className="flex items-center gap-4 mt-2 text-xs text-muted-foreground">
                        <span className="flex items-center gap-1">
                          <Calendar className="w-3.5 h-3.5" />
                          {formatDate(deal.start_time)} — {formatDate(deal.end_time)}
                        </span>
                        <span>
                          {deal.total_redemptions}
                          {deal.max_redemptions ? ` / ${deal.max_redemptions}` : ""} redemptions
                        </span>
                      </div>
                      {progress !== null && (
                        <div className="mt-2 w-full max-w-48 bg-muted rounded-full h-1.5">
                          <div
                            className="bg-indigo-500 h-1.5 rounded-full"
                            style={{ width: `${Math.min(progress, 100)}%` }}
                          />
                        </div>
                      )}
                    </div>

                    {/* Actions */}
                    <div className="flex items-center gap-2 flex-shrink-0">
                      <Link href={`/deals/${deal.id}`}>
                        <Button variant="ghost" size="sm">
                          <BarChart2 className="w-4 h-4" />
                        </Button>
                      </Link>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => { setEditingDeal(deal); setView("edit"); }}
                      >
                        <Edit2 className="w-4 h-4" />
                      </Button>
                      <Button variant="ghost" size="sm" onClick={() => toggleActive(deal.id)}>
                        {deal.is_active ? (
                          <ToggleRight className="w-4 h-4 text-green-600" />
                        ) : (
                          <ToggleLeft className="w-4 h-4 text-muted-foreground" />
                        )}
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}

      <p className="text-sm text-muted-foreground">
        Showing {filtered.length} of {deals.length} deal{deals.length !== 1 ? "s" : ""} ·{" "}
        {deals.filter((d) => d.is_active).length} active
      </p>
    </div>
  );
}
