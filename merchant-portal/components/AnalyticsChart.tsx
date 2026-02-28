"use client";

import React, { useState } from "react";
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface DataPoint {
  date: string;
  views?: number;
  redemptions?: number;
  revenue_impact?: number;
}

interface PeakHourData {
  hour: number;
  redemptions: number;
}

interface AnalyticsChartProps {
  data: DataPoint[];
  peakHours?: PeakHourData[];
  title?: string;
  description?: string;
  className?: string;
  showPeakHours?: boolean;
}

type ChartType = "line" | "bar";
type MetricKey = "views" | "redemptions" | "revenue_impact";

const METRICS: { key: MetricKey; label: string; color: string }[] = [
  { key: "views", label: "Views", color: "#6366f1" },
  { key: "redemptions", label: "Redemptions", color: "#10b981" },
  { key: "revenue_impact", label: "Revenue Impact", color: "#f59e0b" },
];

const formatHour = (hour: number) => {
  if (hour === 0) return "12am";
  if (hour === 12) return "12pm";
  return hour > 12 ? `${hour - 12}pm` : `${hour}am`;
};

export default function AnalyticsChart({
  data,
  peakHours = [],
  title = "Analytics",
  description,
  className,
  showPeakHours = false,
}: AnalyticsChartProps) {
  const [chartType, setChartType] = useState<ChartType>("line");
  const [activeMetrics, setActiveMetrics] = useState<MetricKey[]>(["views", "redemptions"]);
  const [activeTab, setActiveTab] = useState<"trends" | "peak_hours">("trends");

  const toggleMetric = (key: MetricKey) => {
    setActiveMetrics((prev) =>
      prev.includes(key) ? prev.filter((m) => m !== key) : [...prev, key]
    );
  };

  const ChartComponent = chartType === "line" ? LineChart : BarChart;

  return (
    <Card className={className}>
      <CardHeader className="space-y-0 pb-4">
        <div className="flex items-start justify-between">
          <div>
            <CardTitle>{title}</CardTitle>
            {description && <CardDescription className="mt-1">{description}</CardDescription>}
          </div>
          <div className="flex gap-1">
            <Button
              variant={chartType === "line" ? "secondary" : "ghost"}
              size="sm"
              onClick={() => setChartType("line")}
              className="h-7 px-2 text-xs"
            >
              Line
            </Button>
            <Button
              variant={chartType === "bar" ? "secondary" : "ghost"}
              size="sm"
              onClick={() => setChartType("bar")}
              className="h-7 px-2 text-xs"
            >
              Bar
            </Button>
          </div>
        </div>

        {showPeakHours && (
          <div className="flex gap-2 mt-3">
            <button
              onClick={() => setActiveTab("trends")}
              className={cn(
                "text-sm font-medium pb-1 border-b-2 transition-colors",
                activeTab === "trends"
                  ? "border-primary text-foreground"
                  : "border-transparent text-muted-foreground hover:text-foreground"
              )}
            >
              Trends
            </button>
            <button
              onClick={() => setActiveTab("peak_hours")}
              className={cn(
                "text-sm font-medium pb-1 border-b-2 transition-colors",
                activeTab === "peak_hours"
                  ? "border-primary text-foreground"
                  : "border-transparent text-muted-foreground hover:text-foreground"
              )}
            >
              Peak Hours
            </button>
          </div>
        )}

        {/* Metric Toggles */}
        {activeTab === "trends" && (
          <div className="flex gap-2 flex-wrap mt-2">
            {METRICS.map(({ key, label, color }) => (
              <button
                key={key}
                onClick={() => toggleMetric(key)}
                className={cn(
                  "flex items-center gap-1.5 text-xs px-2.5 py-1 rounded-full border transition-all",
                  activeMetrics.includes(key)
                    ? "border-transparent text-white"
                    : "border-border text-muted-foreground opacity-60"
                )}
                style={
                  activeMetrics.includes(key)
                    ? { backgroundColor: color, borderColor: color }
                    : {}
                }
              >
                <span
                  className="w-2 h-2 rounded-full"
                  style={{ backgroundColor: activeMetrics.includes(key) ? "white" : color }}
                />
                {label}
              </button>
            ))}
          </div>
        )}
      </CardHeader>

      <CardContent>
        {activeTab === "trends" ? (
          <ResponsiveContainer width="100%" height={280}>
            <ChartComponent data={data}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
              <XAxis
                dataKey="date"
                tick={{ fontSize: 11 }}
                tickFormatter={(v) =>
                  new Date(v).toLocaleDateString("en-US", { month: "short", day: "numeric" })
                }
              />
              <YAxis tick={{ fontSize: 11 }} />
              <Tooltip
                contentStyle={{ fontSize: 12, borderRadius: 8 }}
                labelFormatter={(v) =>
                  new Date(v).toLocaleDateString("en-US", {
                    weekday: "short",
                    month: "short",
                    day: "numeric",
                  })
                }
              />
              <Legend wrapperStyle={{ fontSize: 12 }} />
              {METRICS.filter(({ key }) => activeMetrics.includes(key)).map(({ key, label, color }) =>
                chartType === "line" ? (
                  <Line
                    key={key}
                    type="monotone"
                    dataKey={key}
                    name={label}
                    stroke={color}
                    strokeWidth={2}
                    dot={false}
                    activeDot={{ r: 4 }}
                  />
                ) : (
                  <Bar key={key} dataKey={key} name={label} fill={color} radius={[4, 4, 0, 0]} />
                )
              )}
            </ChartComponent>
          </ResponsiveContainer>
        ) : (
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={peakHours}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
              <XAxis dataKey="hour" tickFormatter={formatHour} tick={{ fontSize: 11 }} />
              <YAxis tick={{ fontSize: 11 }} />
              <Tooltip
                contentStyle={{ fontSize: 12, borderRadius: 8 }}
                labelFormatter={(v) => `Hour: ${formatHour(Number(v))}`}
              />
              <Bar dataKey="redemptions" name="Redemptions" fill="#10b981" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  );
}
