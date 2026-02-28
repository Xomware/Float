"use client";

import React, { useEffect, useState } from "react";
import StatCard from "@/components/StatCard";
import RedemptionLog from "@/components/RedemptionLog";
import AnalyticsChart from "@/components/AnalyticsChart";
import { Tag, TicketCheck, Store, TrendingUp } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { formatDate } from "@/lib/utils";

// Mock data — replace with Supabase queries
const MOCK_STATS = {
  activeDeals: 8,
  totalRedemptions: 342,
  totalVenues: 3,
  revenueImpact: 4218,
};

const MOCK_CHART_DATA = Array.from({ length: 30 }, (_, i) => ({
  date: new Date(Date.now() - (29 - i) * 86400000).toISOString().split("T")[0],
  views: Math.floor(Math.random() * 200 + 80),
  redemptions: Math.floor(Math.random() * 30 + 5),
  revenue_impact: Math.round((Math.random() * 200 + 50) * 100) / 100,
}));

const MOCK_ACTIVE_DEALS = [
  {
    id: "d1",
    title: "Happy Hour 20% Off",
    venue: "Downtown Bar & Grill",
    redemptions: 84,
    end_time: new Date(Date.now() + 86400000 * 3).toISOString(),
    is_active: true,
  },
  {
    id: "d2",
    title: "Free Dessert with Entrée",
    venue: "The Rooftop Lounge",
    redemptions: 47,
    end_time: new Date(Date.now() + 86400000 * 7).toISOString(),
    is_active: true,
  },
  {
    id: "d3",
    title: "BOGO Cocktails",
    venue: "Café Central",
    redemptions: 211,
    end_time: new Date(Date.now() + 86400000 * 1).toISOString(),
    is_active: true,
  },
];

export default function DashboardPage() {
  const [merchantId] = useState("mock-merchant-id");

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Dashboard</h1>
        <p className="text-muted-foreground mt-1">Welcome back. Here&apos;s what&apos;s happening.</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Active Deals"
          value={MOCK_STATS.activeDeals}
          icon={Tag}
          color="indigo"
          trend={{ value: 12, label: "vs last week" }}
        />
        <StatCard
          title="Total Redemptions"
          value={MOCK_STATS.totalRedemptions.toLocaleString()}
          icon={TicketCheck}
          color="green"
          trend={{ value: 8, label: "vs last week" }}
        />
        <StatCard
          title="Venues"
          value={MOCK_STATS.totalVenues}
          icon={Store}
          color="blue"
        />
        <StatCard
          title="Revenue Impact"
          value={`$${MOCK_STATS.revenueImpact.toLocaleString()}`}
          icon={TrendingUp}
          color="amber"
          subtitle="Estimated this month"
          trend={{ value: 22, label: "vs last month" }}
        />
      </div>

      {/* Chart + Active Deals */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <AnalyticsChart
            data={MOCK_CHART_DATA}
            title="30-Day Overview"
            description="Views and redemptions across all venues"
          />
        </div>
        <Card>
          <CardHeader>
            <CardTitle>Active Deals</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {MOCK_ACTIVE_DEALS.map((deal) => {
                const daysLeft = Math.ceil(
                  (new Date(deal.end_time).getTime() - Date.now()) / 86400000
                );
                return (
                  <div
                    key={deal.id}
                    className="flex items-start justify-between gap-2 p-3 rounded-lg border hover:bg-muted/30 transition-colors"
                  >
                    <div className="min-w-0">
                      <p className="text-sm font-medium truncate">{deal.title}</p>
                      <p className="text-xs text-muted-foreground truncate">{deal.venue}</p>
                      <p className="text-xs text-muted-foreground mt-1">
                        {deal.redemptions} redemptions
                      </p>
                    </div>
                    <div className="flex flex-col items-end gap-1 flex-shrink-0">
                      <Badge variant={daysLeft <= 1 ? "warning" : "success"}>
                        {daysLeft}d left
                      </Badge>
                    </div>
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Redemption Log */}
      <RedemptionLog merchantId={merchantId} limit={15} />
    </div>
  );
}
