"use client";

import React, { useMemo } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import AnalyticsChart from "@/components/AnalyticsChart";
import StatCard from "@/components/StatCard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Eye, TicketCheck, TrendingUp, Clock } from "lucide-react";
import { formatDate } from "@/lib/utils";

// Mock deal data (would be fetched from Supabase)
const MOCK_DEAL = {
  id: "d1",
  title: "Happy Hour 20% Off",
  description: "20% off all food and drinks during happy hour",
  venue_name: "Downtown Bar & Grill",
  discount_type: "percentage" as const,
  discount_value: 20,
  start_time: new Date(Date.now() - 86400000 * 5).toISOString(),
  end_time: new Date(Date.now() + 86400000 * 3).toISOString(),
  max_redemptions: 100,
  total_redemptions: 84,
  is_active: true,
  recurrence: { frequency: "weekly", days_of_week: [1, 2, 3, 4, 5] },
};

export default function DealAnalyticsPage() {
  const params = useParams();
  const dealId = params.id as string;

  // Mock 30-day analytics data
  const chartData = useMemo(
    () =>
      Array.from({ length: 30 }, (_, i) => ({
        date: new Date(Date.now() - (29 - i) * 86400000).toISOString().split("T")[0],
        views: Math.floor(Math.random() * 120 + 40),
        redemptions: Math.floor(Math.random() * 15 + 2),
        revenue_impact: Math.round((Math.random() * 150 + 30) * 100) / 100,
      })),
    []
  );

  // Mock peak hours
  const peakHours = useMemo(
    () =>
      Array.from({ length: 24 }, (_, hour) => ({
        hour,
        redemptions:
          hour >= 11 && hour <= 14
            ? Math.floor(Math.random() * 20 + 10) // lunch
            : hour >= 17 && hour <= 20
            ? Math.floor(Math.random() * 30 + 15) // happy hour
            : hour >= 21 && hour <= 23
            ? Math.floor(Math.random() * 15 + 5) // evening
            : Math.floor(Math.random() * 5),
      })),
    []
  );

  const totalViews = chartData.reduce((sum, d) => sum + d.views, 0);
  const totalRedemptions = chartData.reduce((sum, d) => sum + d.redemptions, 0);
  const conversionRate = totalViews > 0 ? ((totalRedemptions / totalViews) * 100).toFixed(1) : "0.0";
  const peakHour = peakHours.reduce((max, h) => (h.redemptions > max.redemptions ? h : max), peakHours[0]);

  const formatPeakHour = (hour: number) => {
    if (hour === 0) return "12am";
    if (hour === 12) return "12pm";
    return hour > 12 ? `${hour - 12}pm` : `${hour}am`;
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-start gap-4">
        <Link href="/deals">
          <Button variant="ghost" size="icon" className="mt-0.5">
            <ArrowLeft className="w-4 h-4" />
          </Button>
        </Link>
        <div className="flex-1">
          <div className="flex items-center gap-3 flex-wrap">
            <h1 className="text-2xl font-bold tracking-tight">{MOCK_DEAL.title}</h1>
            <Badge variant={MOCK_DEAL.is_active ? "success" : "secondary"}>
              {MOCK_DEAL.is_active ? "Active" : "Inactive"}
            </Badge>
          </div>
          <div className="flex items-center gap-4 mt-1 text-sm text-muted-foreground flex-wrap">
            <span>{MOCK_DEAL.venue_name}</span>
            <span>·</span>
            <span>{MOCK_DEAL.discount_value}% off</span>
            <span>·</span>
            <span>
              {formatDate(MOCK_DEAL.start_time)} — {formatDate(MOCK_DEAL.end_time)}
            </span>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Total Views"
          value={totalViews.toLocaleString()}
          icon={Eye}
          color="indigo"
          subtitle="Last 30 days"
        />
        <StatCard
          title="Redemptions"
          value={totalRedemptions.toLocaleString()}
          icon={TicketCheck}
          color="green"
          subtitle={`${MOCK_DEAL.total_redemptions} all-time`}
        />
        <StatCard
          title="Conversion Rate"
          value={`${conversionRate}%`}
          icon={TrendingUp}
          color="amber"
          subtitle="Views to redemptions"
        />
        <StatCard
          title="Peak Hour"
          value={formatPeakHour(peakHour.hour)}
          icon={Clock}
          color="blue"
          subtitle={`${peakHour.redemptions} avg redemptions`}
        />
      </div>

      {/* Redemption Progress */}
      {MOCK_DEAL.max_redemptions && (
        <Card>
          <CardHeader>
            <CardTitle>Redemption Cap</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-end justify-between mb-2">
              <span className="text-2xl font-bold">{MOCK_DEAL.total_redemptions}</span>
              <span className="text-muted-foreground text-sm">of {MOCK_DEAL.max_redemptions} max</span>
            </div>
            <div className="w-full bg-muted rounded-full h-3">
              <div
                className="bg-indigo-500 h-3 rounded-full transition-all"
                style={{
                  width: `${Math.min((MOCK_DEAL.total_redemptions / MOCK_DEAL.max_redemptions) * 100, 100)}%`,
                }}
              />
            </div>
            <p className="text-xs text-muted-foreground mt-2">
              {MOCK_DEAL.max_redemptions - MOCK_DEAL.total_redemptions} redemptions remaining
            </p>
          </CardContent>
        </Card>
      )}

      {/* Trend Chart + Peak Hours */}
      <AnalyticsChart
        data={chartData}
        peakHours={peakHours}
        title="Deal Analytics"
        description={`Performance trends for ${MOCK_DEAL.title}`}
        showPeakHours
      />

      {/* Daily Breakdown */}
      <Card>
        <CardHeader>
          <CardTitle>Daily Breakdown</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b text-muted-foreground text-left">
                  <th className="pb-3 font-medium">Date</th>
                  <th className="pb-3 font-medium text-right">Views</th>
                  <th className="pb-3 font-medium text-right">Redemptions</th>
                  <th className="pb-3 font-medium text-right">Conversion</th>
                  <th className="pb-3 font-medium text-right">Revenue Impact</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {[...chartData].reverse().slice(0, 7).map((row) => (
                  <tr key={row.date} className="hover:bg-muted/30">
                    <td className="py-3">
                      {new Date(row.date).toLocaleDateString("en-US", {
                        weekday: "short",
                        month: "short",
                        day: "numeric",
                      })}
                    </td>
                    <td className="py-3 text-right">{row.views}</td>
                    <td className="py-3 text-right">{row.redemptions}</td>
                    <td className="py-3 text-right">
                      {row.views > 0 ? ((row.redemptions / row.views) * 100).toFixed(1) : "0.0"}%
                    </td>
                    <td className="py-3 text-right text-green-600">
                      ${row.revenue_impact?.toFixed(2) ?? "0.00"}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
