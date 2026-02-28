"use client";

import React, { useMemo, useState } from "react";
import AnalyticsChart from "@/components/AnalyticsChart";
import StatCard from "@/components/StatCard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Eye, TicketCheck, TrendingUp, Store } from "lucide-react";

type Range = "7d" | "30d" | "90d";

const VENUES = [
  { id: "all", name: "All Venues" },
  { id: "v1", name: "Downtown Bar & Grill" },
  { id: "v2", name: "The Rooftop Lounge" },
  { id: "v3", name: "Café Central" },
];

const VENUE_BREAKDOWN = [
  { name: "Downtown Bar & Grill", views: 4821, redemptions: 342, revenue: 2841.50, deals: 4 },
  { name: "The Rooftop Lounge", views: 3102, redemptions: 218, revenue: 1924.80, deals: 3 },
  { name: "Café Central", views: 1847, redemptions: 104, revenue: 892.40, deals: 2 },
];

const TOP_DEALS = [
  { title: "Happy Hour 20% Off", venue: "Downtown Bar & Grill", redemptions: 342, conversion: "7.1%" },
  { title: "BOGO Cocktails", venue: "Café Central", redemptions: 211, conversion: "11.4%" },
  { title: "Free Dessert with Entrée", venue: "The Rooftop Lounge", redemptions: 174, conversion: "5.6%" },
  { title: "Lunch Special $10 Off", venue: "Downtown Bar & Grill", redemptions: 132, conversion: "8.9%" },
  { title: "Weekend Brunch Deal", venue: "The Rooftop Lounge", redemptions: 98, conversion: "4.2%" },
];

export default function AnalyticsPage() {
  const [range, setRange] = useState<Range>("30d");
  const [selectedVenue, setSelectedVenue] = useState("all");

  const days = range === "7d" ? 7 : range === "30d" ? 30 : 90;

  const chartData = useMemo(
    () =>
      Array.from({ length: days }, (_, i) => ({
        date: new Date(Date.now() - (days - 1 - i) * 86400000).toISOString().split("T")[0],
        views: Math.floor(Math.random() * 400 + 100),
        redemptions: Math.floor(Math.random() * 50 + 10),
        revenue_impact: Math.round((Math.random() * 300 + 80) * 100) / 100,
      })),
    [days]
  );

  const totalViews = chartData.reduce((s, d) => s + d.views, 0);
  const totalRedemptions = chartData.reduce((s, d) => s + d.redemptions, 0);
  const totalRevenue = chartData.reduce((s, d) => s + (d.revenue_impact ?? 0), 0);
  const conversionRate = totalViews > 0 ? ((totalRedemptions / totalViews) * 100).toFixed(1) : "0.0";

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Analytics</h1>
          <p className="text-muted-foreground mt-1">Aggregate performance across all your venues.</p>
        </div>

        {/* Filters */}
        <div className="flex items-center gap-2">
          <select
            value={selectedVenue}
            onChange={(e) => setSelectedVenue(e.target.value)}
            className="text-sm border border-input rounded-md px-3 py-1.5 bg-background h-9 focus:outline-none focus:ring-1 focus:ring-ring"
          >
            {VENUES.map((v) => (
              <option key={v.id} value={v.id}>
                {v.name}
              </option>
            ))}
          </select>
          <div className="flex gap-1 border rounded-md p-0.5">
            {(["7d", "30d", "90d"] as Range[]).map((r) => (
              <Button
                key={r}
                variant={range === r ? "secondary" : "ghost"}
                size="sm"
                onClick={() => setRange(r)}
                className="h-7 px-2.5 text-xs"
              >
                {r}
              </Button>
            ))}
          </div>
        </div>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Total Views"
          value={totalViews.toLocaleString()}
          icon={Eye}
          color="indigo"
          subtitle={`Last ${range}`}
          trend={{ value: 14, label: "vs previous" }}
        />
        <StatCard
          title="Total Redemptions"
          value={totalRedemptions.toLocaleString()}
          icon={TicketCheck}
          color="green"
          trend={{ value: 8, label: "vs previous" }}
        />
        <StatCard
          title="Revenue Impact"
          value={`$${totalRevenue.toLocaleString("en-US", { maximumFractionDigits: 0 })}`}
          icon={TrendingUp}
          color="amber"
          trend={{ value: 18, label: "vs previous" }}
        />
        <StatCard
          title="Conversion Rate"
          value={`${conversionRate}%`}
          icon={Store}
          color="blue"
          subtitle="Views to redemptions"
        />
      </div>

      {/* Main Chart */}
      <AnalyticsChart
        data={chartData}
        title="Performance Over Time"
        description={`Aggregated across ${selectedVenue === "all" ? "all venues" : VENUES.find((v) => v.id === selectedVenue)?.name}`}
      />

      {/* Venue Breakdown + Top Deals */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Venue Breakdown */}
        <Card>
          <CardHeader>
            <CardTitle>By Venue</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {VENUE_BREAKDOWN.map((venue) => {
                const maxRedemptions = Math.max(...VENUE_BREAKDOWN.map((v) => v.redemptions));
                const pct = (venue.redemptions / maxRedemptions) * 100;
                return (
                  <div key={venue.name}>
                    <div className="flex items-center justify-between mb-1.5">
                      <div>
                        <p className="text-sm font-medium">{venue.name}</p>
                        <p className="text-xs text-muted-foreground">
                          {venue.deals} deals · {venue.views.toLocaleString()} views
                        </p>
                      </div>
                      <div className="text-right">
                        <p className="text-sm font-bold">{venue.redemptions}</p>
                        <p className="text-xs text-green-600">${venue.revenue.toFixed(0)}</p>
                      </div>
                    </div>
                    <div className="w-full bg-muted rounded-full h-1.5">
                      <div
                        className="bg-indigo-500 h-1.5 rounded-full"
                        style={{ width: `${pct}%` }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>

        {/* Top Performing Deals */}
        <Card>
          <CardHeader>
            <CardTitle>Top Deals</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {TOP_DEALS.map((deal, i) => (
                <div key={deal.title} className="flex items-center gap-3">
                  <div className="w-6 h-6 rounded-full bg-indigo-100 text-indigo-600 text-xs font-bold flex items-center justify-center flex-shrink-0">
                    {i + 1}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">{deal.title}</p>
                    <p className="text-xs text-muted-foreground truncate">{deal.venue}</p>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="text-sm font-bold">{deal.redemptions}</p>
                    <Badge variant="outline" className="text-xs">
                      {deal.conversion}
                    </Badge>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
