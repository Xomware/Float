import React from "react";
import { Card, CardContent } from "@/components/ui/card";
import { LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";

interface StatCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  icon: LucideIcon;
  trend?: { value: number; label: string };
  color?: "indigo" | "green" | "amber" | "blue" | "red";
  className?: string;
}

const COLOR_MAP = {
  indigo: "bg-indigo-50 text-indigo-600",
  green: "bg-green-50 text-green-600",
  amber: "bg-amber-50 text-amber-600",
  blue: "bg-blue-50 text-blue-600",
  red: "bg-red-50 text-red-600",
};

export default function StatCard({
  title,
  value,
  subtitle,
  icon: Icon,
  trend,
  color = "indigo",
  className,
}: StatCardProps) {
  return (
    <Card className={cn("", className)}>
      <CardContent className="p-6">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-sm font-medium text-muted-foreground">{title}</p>
            <p className="text-2xl font-bold mt-1">{value}</p>
            {subtitle && (
              <p className="text-xs text-muted-foreground mt-0.5">{subtitle}</p>
            )}
            {trend && (
              <div
                className={cn(
                  "flex items-center gap-1 mt-2 text-xs font-medium",
                  trend.value >= 0 ? "text-green-600" : "text-red-600"
                )}
              >
                <span>{trend.value >= 0 ? "↑" : "↓"}</span>
                <span>
                  {Math.abs(trend.value)}% {trend.label}
                </span>
              </div>
            )}
          </div>
          <div className={cn("p-2.5 rounded-lg", COLOR_MAP[color])}>
            <Icon className="w-5 h-5" />
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
