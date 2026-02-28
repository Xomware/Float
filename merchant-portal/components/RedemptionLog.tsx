"use client";

import React, { useEffect, useState, useCallback } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { RefreshCw, CheckCircle, Clock, XCircle } from "lucide-react";
import { cn, formatTime } from "@/lib/utils";

interface Redemption {
  id: string;
  deal_title: string;
  venue_name: string;
  redeemed_at: string;
  discount_amount: number;
  status: "completed" | "pending" | "cancelled";
}

interface RedemptionLogProps {
  merchantId: string;
  limit?: number;
  className?: string;
}

const STATUS_CONFIG = {
  completed: {
    label: "Completed",
    icon: CheckCircle,
    variant: "success" as const,
    color: "text-green-600",
  },
  pending: {
    label: "Pending",
    icon: Clock,
    variant: "warning" as const,
    color: "text-yellow-600",
  },
  cancelled: {
    label: "Cancelled",
    icon: XCircle,
    variant: "destructive" as const,
    color: "text-red-600",
  },
};

// Mock data generator — replace with real Supabase realtime subscription
function generateMockRedemptions(count: number): Redemption[] {
  const deals = ["Happy Hour 20% Off", "Free Dessert", "BOGO Drinks", "Lunch Special"];
  const venues = ["Downtown Bar & Grill", "The Rooftop Lounge", "Café Central"];
  const statuses: Array<"completed" | "pending" | "cancelled"> = [
    "completed", "completed", "completed", "pending", "cancelled",
  ];

  return Array.from({ length: count }, (_, i) => ({
    id: `r-${Date.now()}-${i}`,
    deal_title: deals[i % deals.length],
    venue_name: venues[i % venues.length],
    redeemed_at: new Date(Date.now() - i * 1000 * 60 * (Math.random() * 30 + 1)).toISOString(),
    discount_amount: Math.round((Math.random() * 25 + 2) * 100) / 100,
    status: statuses[i % statuses.length],
  }));
}

export default function RedemptionLog({
  merchantId,
  limit = 20,
  className,
}: RedemptionLogProps) {
  const [redemptions, setRedemptions] = useState<Redemption[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [lastUpdated, setLastUpdated] = useState<Date>(new Date());
  const [isPolling, setIsPolling] = useState(true);

  const fetchRedemptions = useCallback(async () => {
    // TODO: Replace with actual Supabase query when credentials are configured
    // const data = await getRedemptions(merchantId, limit);
    await new Promise((r) => setTimeout(r, 500)); // simulate network
    setRedemptions(generateMockRedemptions(limit));
    setLastUpdated(new Date());
    setIsLoading(false);
  }, [merchantId, limit]);

  useEffect(() => {
    fetchRedemptions();
  }, [fetchRedemptions]);

  // Real-time polling (replace with Supabase realtime channel)
  useEffect(() => {
    if (!isPolling) return;
    const interval = setInterval(() => {
      // Simulate new redemption arriving
      if (Math.random() > 0.7) {
        const newRedemption: Redemption = {
          id: `r-${Date.now()}`,
          deal_title: ["Happy Hour 20% Off", "Free Dessert", "BOGO Drinks"][
            Math.floor(Math.random() * 3)
          ],
          venue_name: "Downtown Bar & Grill",
          redeemed_at: new Date().toISOString(),
          discount_amount: Math.round((Math.random() * 20 + 5) * 100) / 100,
          status: "completed",
        };
        setRedemptions((prev) => [newRedemption, ...prev.slice(0, limit - 1)]);
        setLastUpdated(new Date());
      }
    }, 10000);
    return () => clearInterval(interval);
  }, [isPolling, limit]);

  if (isLoading) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle>Redemptions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="animate-pulse flex gap-3 items-center">
                <div className="w-8 h-8 rounded-full bg-muted" />
                <div className="flex-1 space-y-2">
                  <div className="h-3 bg-muted rounded w-3/4" />
                  <div className="h-3 bg-muted rounded w-1/2" />
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={className}>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-4">
        <CardTitle>Live Redemptions</CardTitle>
        <div className="flex items-center gap-2">
          <span className="text-xs text-muted-foreground">
            Updated {formatTime(lastUpdated)}
          </span>
          <Button
            variant="ghost"
            size="icon"
            onClick={fetchRedemptions}
            className="h-7 w-7"
          >
            <RefreshCw className="h-3.5 w-3.5" />
          </Button>
          <Button
            variant={isPolling ? "secondary" : "outline"}
            size="sm"
            onClick={() => setIsPolling((p) => !p)}
            className="h-7 text-xs"
          >
            {isPolling ? "⚡ Live" : "Paused"}
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        {redemptions.length === 0 ? (
          <div className="text-center py-8 text-muted-foreground">
            <p>No redemptions yet.</p>
            <p className="text-sm">They&apos;ll appear here in real-time.</p>
          </div>
        ) : (
          <div className="space-y-1 max-h-[480px] overflow-y-auto pr-2">
            {redemptions.map((r, i) => {
              const config = STATUS_CONFIG[r.status];
              const Icon = config.icon;
              const isNew = i === 0 && Date.now() - new Date(r.redeemed_at).getTime() < 15000;

              return (
                <div
                  key={r.id}
                  className={cn(
                    "flex items-center gap-3 p-3 rounded-lg transition-all",
                    isNew ? "bg-green-50 border border-green-200" : "hover:bg-muted/50"
                  )}
                >
                  <Icon className={cn("w-5 h-5 flex-shrink-0", config.color)} />
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="text-sm font-medium truncate">{r.deal_title}</p>
                      {isNew && (
                        <span className="text-xs bg-green-500 text-white px-1.5 py-0.5 rounded-full">
                          NEW
                        </span>
                      )}
                    </div>
                    <p className="text-xs text-muted-foreground truncate">{r.venue_name}</p>
                  </div>
                  <div className="flex flex-col items-end gap-1 flex-shrink-0">
                    <span className="text-sm font-semibold text-green-600">
                      -${r.discount_amount.toFixed(2)}
                    </span>
                    <span className="text-xs text-muted-foreground">{formatTime(r.redeemed_at)}</span>
                  </div>
                  <Badge variant={config.variant} className="flex-shrink-0">
                    {config.label}
                  </Badge>
                </div>
              );
            })}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
