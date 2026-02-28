"use client";

import React, { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { cn } from "@/lib/utils";
import { ChevronRight, ChevronLeft, Check } from "lucide-react";

interface DealFormProps {
  venues?: { id: string; name: string }[];
  initialData?: Partial<DealFormData>;
  onSubmit: (data: DealFormData) => Promise<void>;
  onCancel?: () => void;
}

export interface DealFormData {
  title: string;
  description: string;
  venue_id: string;
  discount_type: "percentage" | "fixed" | "bogo" | "free_item";
  discount_value: number;
  start_time: string;
  end_time: string;
  max_redemptions: number | null;
  recurrence: RecurrenceConfig | null;
  is_active: boolean;
}

interface RecurrenceConfig {
  frequency: "daily" | "weekly" | "monthly";
  days_of_week?: number[];
  end_date?: string;
}

const STEPS = ["Deal Info", "Schedule", "Recurrence", "Review"];

const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

export default function DealForm({ venues = [], initialData, onSubmit, onCancel }: DealFormProps) {
  const [step, setStep] = useState(0);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formData, setFormData] = useState<DealFormData>({
    title: initialData?.title ?? "",
    description: initialData?.description ?? "",
    venue_id: initialData?.venue_id ?? "",
    discount_type: initialData?.discount_type ?? "percentage",
    discount_value: initialData?.discount_value ?? 0,
    start_time: initialData?.start_time ?? "",
    end_time: initialData?.end_time ?? "",
    max_redemptions: initialData?.max_redemptions ?? null,
    recurrence: initialData?.recurrence ?? null,
    is_active: initialData?.is_active ?? true,
  });

  const [enableRecurrence, setEnableRecurrence] = useState(!!initialData?.recurrence);

  const update = (field: keyof DealFormData, value: unknown) =>
    setFormData((prev) => ({ ...prev, [field]: value }));

  const handleSubmit = async () => {
    setIsSubmitting(true);
    try {
      await onSubmit(formData);
    } finally {
      setIsSubmitting(false);
    }
  };

  const isStepValid = () => {
    if (step === 0) return formData.title && formData.venue_id && formData.discount_value > 0;
    if (step === 1) return formData.start_time && formData.end_time;
    return true;
  };

  return (
    <div className="space-y-6">
      {/* Step Progress */}
      <div className="flex items-center gap-2">
        {STEPS.map((s, i) => (
          <React.Fragment key={s}>
            <div
              className={cn(
                "flex items-center justify-center w-8 h-8 rounded-full text-sm font-medium transition-colors",
                i < step
                  ? "bg-green-500 text-white"
                  : i === step
                  ? "bg-primary text-primary-foreground"
                  : "bg-muted text-muted-foreground"
              )}
            >
              {i < step ? <Check className="w-4 h-4" /> : i + 1}
            </div>
            <span
              className={cn(
                "text-sm",
                i === step ? "font-medium text-foreground" : "text-muted-foreground"
              )}
            >
              {s}
            </span>
            {i < STEPS.length - 1 && (
              <div className={cn("flex-1 h-px", i < step ? "bg-green-500" : "bg-border")} />
            )}
          </React.Fragment>
        ))}
      </div>

      {/* Step Content */}
      <Card>
        <CardHeader>
          <CardTitle>{STEPS[step]}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {step === 0 && (
            <>
              <div className="space-y-2">
                <Label htmlFor="title">Deal Title *</Label>
                <Input
                  id="title"
                  placeholder="e.g., Happy Hour 20% Off"
                  value={formData.title}
                  onChange={(e) => update("title", e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  placeholder="Describe your deal..."
                  value={formData.description}
                  onChange={(e) => update("description", e.target.value)}
                  rows={3}
                />
              </div>
              <div className="space-y-2">
                <Label>Venue *</Label>
                <Select value={formData.venue_id} onValueChange={(v) => update("venue_id", v)}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select venue" />
                  </SelectTrigger>
                  <SelectContent>
                    {venues.map((v) => (
                      <SelectItem key={v.id} value={v.id}>
                        {v.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>Discount Type *</Label>
                  <Select
                    value={formData.discount_type}
                    onValueChange={(v) => update("discount_type", v)}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="percentage">Percentage Off</SelectItem>
                      <SelectItem value="fixed">Fixed Amount Off</SelectItem>
                      <SelectItem value="bogo">Buy One Get One</SelectItem>
                      <SelectItem value="free_item">Free Item</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="discount_value">
                    Value *{" "}
                    {formData.discount_type === "percentage"
                      ? "(%)"
                      : formData.discount_type === "fixed"
                      ? "($)"
                      : ""}
                  </Label>
                  <Input
                    id="discount_value"
                    type="number"
                    min={0}
                    value={formData.discount_value || ""}
                    onChange={(e) => update("discount_value", parseFloat(e.target.value) || 0)}
                    disabled={["bogo", "free_item"].includes(formData.discount_type)}
                  />
                </div>
              </div>
            </>
          )}

          {step === 1 && (
            <>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="start_time">Start Date & Time *</Label>
                  <Input
                    id="start_time"
                    type="datetime-local"
                    value={formData.start_time}
                    onChange={(e) => update("start_time", e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="end_time">End Date & Time *</Label>
                  <Input
                    id="end_time"
                    type="datetime-local"
                    value={formData.end_time}
                    onChange={(e) => update("end_time", e.target.value)}
                  />
                </div>
              </div>
              <div className="space-y-2">
                <Label htmlFor="max_redemptions">Max Redemptions (leave blank for unlimited)</Label>
                <Input
                  id="max_redemptions"
                  type="number"
                  min={1}
                  placeholder="Unlimited"
                  value={formData.max_redemptions ?? ""}
                  onChange={(e) =>
                    update("max_redemptions", e.target.value ? parseInt(e.target.value) : null)
                  }
                />
              </div>
            </>
          )}

          {step === 2 && (
            <>
              <div className="flex items-center gap-3">
                <input
                  type="checkbox"
                  id="enable_recurrence"
                  checked={enableRecurrence}
                  onChange={(e) => {
                    setEnableRecurrence(e.target.checked);
                    if (!e.target.checked) update("recurrence", null);
                    else
                      update("recurrence", { frequency: "weekly", days_of_week: [1, 2, 3, 4, 5] });
                  }}
                  className="h-4 w-4"
                />
                <Label htmlFor="enable_recurrence">Enable recurring deal</Label>
              </div>

              {enableRecurrence && (
                <div className="space-y-4 pl-7">
                  <div className="space-y-2">
                    <Label>Frequency</Label>
                    <Select
                      value={formData.recurrence?.frequency ?? "weekly"}
                      onValueChange={(v) =>
                        update("recurrence", {
                          ...formData.recurrence,
                          frequency: v as "daily" | "weekly" | "monthly",
                        })
                      }
                    >
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="daily">Daily</SelectItem>
                        <SelectItem value="weekly">Weekly</SelectItem>
                        <SelectItem value="monthly">Monthly</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  {formData.recurrence?.frequency === "weekly" && (
                    <div className="space-y-2">
                      <Label>Days of Week</Label>
                      <div className="flex gap-2">
                        {DAYS.map((day, i) => (
                          <button
                            key={day}
                            type="button"
                            onClick={() => {
                              const days = formData.recurrence?.days_of_week ?? [];
                              const newDays = days.includes(i)
                                ? days.filter((d) => d !== i)
                                : [...days, i];
                              update("recurrence", { ...formData.recurrence, days_of_week: newDays });
                            }}
                            className={cn(
                              "w-10 h-10 rounded-full text-xs font-medium border transition-colors",
                              (formData.recurrence?.days_of_week ?? []).includes(i)
                                ? "bg-primary text-primary-foreground border-primary"
                                : "bg-background text-foreground border-border hover:bg-muted"
                            )}
                          >
                            {day}
                          </button>
                        ))}
                      </div>
                    </div>
                  )}

                  <div className="space-y-2">
                    <Label htmlFor="end_date">Recurrence End Date (optional)</Label>
                    <Input
                      id="end_date"
                      type="date"
                      value={formData.recurrence?.end_date ?? ""}
                      onChange={(e) =>
                        update("recurrence", { ...formData.recurrence, end_date: e.target.value })
                      }
                    />
                  </div>
                </div>
              )}
            </>
          )}

          {step === 3 && (
            <div className="space-y-4">
              <div className="rounded-lg bg-muted p-4 space-y-3">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Title</span>
                  <span className="font-medium">{formData.title}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Venue</span>
                  <span className="font-medium">
                    {venues.find((v) => v.id === formData.venue_id)?.name ?? "—"}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Discount</span>
                  <span className="font-medium">
                    {formData.discount_type === "percentage"
                      ? `${formData.discount_value}% off`
                      : formData.discount_type === "fixed"
                      ? `$${formData.discount_value} off`
                      : formData.discount_type === "bogo"
                      ? "Buy One Get One"
                      : "Free Item"}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Schedule</span>
                  <span className="font-medium text-right text-sm">
                    {formData.start_time && new Date(formData.start_time).toLocaleString()} →{" "}
                    {formData.end_time && new Date(formData.end_time).toLocaleString()}
                  </span>
                </div>
                {formData.max_redemptions && (
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Max Redemptions</span>
                    <span className="font-medium">{formData.max_redemptions}</span>
                  </div>
                )}
                {formData.recurrence && (
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Recurrence</span>
                    <span className="font-medium capitalize">{formData.recurrence.frequency}</span>
                  </div>
                )}
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Navigation */}
      <div className="flex justify-between">
        <Button
          variant="outline"
          onClick={step === 0 ? onCancel : () => setStep((s) => s - 1)}
        >
          {step === 0 ? "Cancel" : <><ChevronLeft className="w-4 h-4" /> Back</>}
        </Button>
        {step < STEPS.length - 1 ? (
          <Button onClick={() => setStep((s) => s + 1)} disabled={!isStepValid()}>
            Next <ChevronRight className="w-4 h-4" />
          </Button>
        ) : (
          <Button onClick={handleSubmit} disabled={isSubmitting}>
            {isSubmitting ? "Saving..." : "Save Deal"}
          </Button>
        )}
      </div>
    </div>
  );
}
