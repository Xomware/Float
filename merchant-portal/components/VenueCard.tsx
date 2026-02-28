"use client";

import React, { useState } from "react";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import {
  MapPin,
  Phone,
  Globe,
  Clock,
  Edit2,
  Check,
  X,
  ImagePlus,
} from "lucide-react";
import { cn } from "@/lib/utils";

export interface VenueData {
  id: string;
  name: string;
  address: string;
  city: string;
  state: string;
  zip: string;
  phone: string | null;
  website: string | null;
  cover_image_url: string | null;
  hours: Record<string, { open: string; close: string; closed: boolean }>;
  is_active: boolean;
}

interface VenueCardProps {
  venue: VenueData;
  onSave?: (updated: VenueData) => Promise<void>;
  onDelete?: (id: string) => Promise<void>;
  className?: string;
}

const DAYS = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];
const DAY_LABELS: Record<string, string> = {
  monday: "Mon", tuesday: "Tue", wednesday: "Wed", thursday: "Thu",
  friday: "Fri", saturday: "Sat", sunday: "Sun",
};

const DEFAULT_HOURS = DAYS.reduce(
  (acc, day) => ({
    ...acc,
    [day]: { open: "11:00", close: "22:00", closed: ["sunday"].includes(day) },
  }),
  {} as Record<string, { open: string; close: string; closed: boolean }>
);

export default function VenueCard({ venue, onSave, onDelete, className }: VenueCardProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [activeSection, setActiveSection] = useState<"info" | "hours">("info");
  const [draft, setDraft] = useState<VenueData>({ ...venue });

  const hours = { ...DEFAULT_HOURS, ...(venue.hours as typeof DEFAULT_HOURS) };
  const draftHours = { ...DEFAULT_HOURS, ...(draft.hours as typeof DEFAULT_HOURS) };

  const update = (field: keyof VenueData, value: unknown) =>
    setDraft((prev) => ({ ...prev, [field]: value }));

  const updateHour = (day: string, field: "open" | "close" | "closed", value: string | boolean) =>
    setDraft((prev) => ({
      ...prev,
      hours: { ...draftHours, [day]: { ...draftHours[day], [field]: value } },
    }));

  const handleSave = async () => {
    if (!onSave) return;
    setIsSaving(true);
    try {
      await onSave(draft);
      setIsEditing(false);
    } finally {
      setIsSaving(false);
    }
  };

  const handleCancel = () => {
    setDraft({ ...venue });
    setIsEditing(false);
  };

  return (
    <Card className={cn("overflow-hidden", className)}>
      {/* Cover Image */}
      <div className="relative h-40 bg-gradient-to-br from-indigo-100 to-purple-100">
        {venue.cover_image_url ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={venue.cover_image_url}
            alt={venue.name}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="flex items-center justify-center h-full text-muted-foreground">
            <ImagePlus className="w-10 h-10 opacity-40" />
          </div>
        )}
        <div className="absolute top-3 right-3 flex gap-2">
          <Badge variant={venue.is_active ? "success" : "secondary"}>
            {venue.is_active ? "Active" : "Inactive"}
          </Badge>
          {!isEditing && (
            <Button size="sm" variant="secondary" className="h-7" onClick={() => setIsEditing(true)}>
              <Edit2 className="w-3.5 h-3.5" />
            </Button>
          )}
        </div>
      </div>

      <CardHeader className="pb-2">
        {isEditing ? (
          <Input
            value={draft.name}
            onChange={(e) => update("name", e.target.value)}
            className="text-lg font-semibold"
          />
        ) : (
          <h3 className="text-lg font-semibold">{venue.name}</h3>
        )}

        {/* Section Tabs */}
        {isEditing && (
          <div className="flex gap-4 mt-2">
            {(["info", "hours"] as const).map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveSection(tab)}
                className={cn(
                  "text-sm font-medium pb-1 border-b-2 capitalize transition-colors",
                  activeSection === tab
                    ? "border-primary text-foreground"
                    : "border-transparent text-muted-foreground"
                )}
              >
                {tab === "info" ? "Info" : "Hours"}
              </button>
            ))}
          </div>
        )}
      </CardHeader>

      <CardContent className="space-y-4">
        {/* View Mode */}
        {!isEditing && (
          <>
            <div className="space-y-2 text-sm">
              <div className="flex items-start gap-2 text-muted-foreground">
                <MapPin className="w-4 h-4 mt-0.5 flex-shrink-0" />
                <span>
                  {venue.address}, {venue.city}, {venue.state} {venue.zip}
                </span>
              </div>
              {venue.phone && (
                <div className="flex items-center gap-2 text-muted-foreground">
                  <Phone className="w-4 h-4 flex-shrink-0" />
                  <span>{venue.phone}</span>
                </div>
              )}
              {venue.website && (
                <div className="flex items-center gap-2 text-muted-foreground">
                  <Globe className="w-4 h-4 flex-shrink-0" />
                  <a
                    href={venue.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-primary hover:underline truncate"
                  >
                    {venue.website.replace(/^https?:\/\//, "")}
                  </a>
                </div>
              )}
            </div>

            <div className="border-t pt-3">
              <div className="flex items-center gap-2 text-sm font-medium mb-2">
                <Clock className="w-4 h-4" />
                Hours
              </div>
              <div className="grid grid-cols-7 gap-1">
                {DAYS.map((day) => {
                  const h = hours[day];
                  return (
                    <div key={day} className="text-center">
                      <div
                        className={cn(
                          "text-xs font-medium mb-1",
                          h?.closed ? "text-muted-foreground" : "text-foreground"
                        )}
                      >
                        {DAY_LABELS[day]}
                      </div>
                      {h?.closed ? (
                        <div className="text-xs text-muted-foreground">Closed</div>
                      ) : (
                        <div className="text-xs">
                          <div>{h?.open}</div>
                          <div>{h?.close}</div>
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          </>
        )}

        {/* Edit Mode — Info */}
        {isEditing && activeSection === "info" && (
          <div className="space-y-3">
            <div className="space-y-1.5">
              <Label>Address</Label>
              <Input
                value={draft.address}
                onChange={(e) => update("address", e.target.value)}
                placeholder="Street address"
              />
            </div>
            <div className="grid grid-cols-3 gap-2">
              <div className="space-y-1.5">
                <Label>City</Label>
                <Input value={draft.city} onChange={(e) => update("city", e.target.value)} />
              </div>
              <div className="space-y-1.5">
                <Label>State</Label>
                <Input value={draft.state} onChange={(e) => update("state", e.target.value)} maxLength={2} />
              </div>
              <div className="space-y-1.5">
                <Label>ZIP</Label>
                <Input value={draft.zip} onChange={(e) => update("zip", e.target.value)} />
              </div>
            </div>
            <div className="space-y-1.5">
              <Label>Phone</Label>
              <Input
                value={draft.phone ?? ""}
                onChange={(e) => update("phone", e.target.value || null)}
                placeholder="(555) 000-0000"
              />
            </div>
            <div className="space-y-1.5">
              <Label>Website</Label>
              <Input
                value={draft.website ?? ""}
                onChange={(e) => update("website", e.target.value || null)}
                placeholder="https://..."
              />
            </div>
            <div className="space-y-1.5">
              <Label>Cover Image URL</Label>
              <Input
                value={draft.cover_image_url ?? ""}
                onChange={(e) => update("cover_image_url", e.target.value || null)}
                placeholder="https://..."
              />
            </div>
            <div className="flex items-center gap-2">
              <input
                type="checkbox"
                id="is_active"
                checked={draft.is_active}
                onChange={(e) => update("is_active", e.target.checked)}
                className="h-4 w-4"
              />
              <Label htmlFor="is_active">Venue is active</Label>
            </div>
          </div>
        )}

        {/* Edit Mode — Hours */}
        {isEditing && activeSection === "hours" && (
          <div className="space-y-2">
            {DAYS.map((day) => {
              const h = draftHours[day];
              return (
                <div key={day} className="flex items-center gap-3">
                  <span className="text-sm w-8 font-medium">{DAY_LABELS[day]}</span>
                  <input
                    type="checkbox"
                    checked={!h?.closed}
                    onChange={(e) => updateHour(day, "closed", !e.target.checked)}
                    className="h-4 w-4"
                  />
                  {!h?.closed ? (
                    <>
                      <Input
                        type="time"
                        value={h?.open ?? "11:00"}
                        onChange={(e) => updateHour(day, "open", e.target.value)}
                        className="h-8 flex-1"
                      />
                      <span className="text-muted-foreground text-sm">to</span>
                      <Input
                        type="time"
                        value={h?.close ?? "22:00"}
                        onChange={(e) => updateHour(day, "close", e.target.value)}
                        className="h-8 flex-1"
                      />
                    </>
                  ) : (
                    <span className="text-sm text-muted-foreground flex-1">Closed</span>
                  )}
                </div>
              );
            })}
          </div>
        )}

        {/* Edit Actions */}
        {isEditing && (
          <div className="flex gap-2 pt-2">
            <Button onClick={handleSave} disabled={isSaving} size="sm" className="flex-1">
              <Check className="w-4 h-4 mr-1" />
              {isSaving ? "Saving..." : "Save"}
            </Button>
            <Button variant="outline" onClick={handleCancel} size="sm">
              <X className="w-4 h-4" />
            </Button>
            {onDelete && (
              <Button
                variant="destructive"
                size="sm"
                onClick={() => onDelete(venue.id)}
              >
                Delete
              </Button>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
