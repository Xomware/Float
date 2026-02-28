"use client";

import React, { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { supabase } from "@/lib/supabase";
import { Check, Bell, Lock, User, CreditCard } from "lucide-react";

interface NotificationPrefs {
  email_new_redemption: boolean;
  email_daily_summary: boolean;
  email_weekly_report: boolean;
  push_new_redemption: boolean;
  push_deal_expiring: boolean;
}

const DEFAULT_PREFS: NotificationPrefs = {
  email_new_redemption: true,
  email_daily_summary: true,
  email_weekly_report: true,
  push_new_redemption: false,
  push_deal_expiring: true,
};

function ToggleSwitch({
  checked,
  onChange,
}: {
  checked: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      onClick={() => onChange(!checked)}
      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 ${
        checked ? "bg-indigo-600" : "bg-gray-200"
      }`}
    >
      <span
        className={`inline-block h-4 w-4 transform rounded-full bg-white shadow-lg transition-transform ${
          checked ? "translate-x-6" : "translate-x-1"
        }`}
      />
    </button>
  );
}

const SECTIONS = [
  { id: "profile", label: "Profile", icon: User },
  { id: "notifications", label: "Notifications", icon: Bell },
  { id: "security", label: "Security", icon: Lock },
  { id: "billing", label: "Billing", icon: CreditCard },
];

export default function SettingsPage() {
  const [activeSection, setActiveSection] = useState("profile");
  const [isSaving, setIsSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [notifPrefs, setNotifPrefs] = useState<NotificationPrefs>(DEFAULT_PREFS);

  // Profile form
  const [businessName, setBusinessName] = useState("Acme Hospitality Group");
  const [contactEmail, setContactEmail] = useState("admin@acmehospitality.com");
  const [contactPhone, setContactPhone] = useState("(212) 555-0100");

  // Security form
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [passwordError, setPasswordError] = useState("");

  const handleSaveProfile = async () => {
    setIsSaving(true);
    // TODO: supabase update merchants record
    await new Promise((r) => setTimeout(r, 800));
    setIsSaving(false);
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  const handleSaveNotifications = async () => {
    setIsSaving(true);
    // TODO: supabase update notification_preferences
    await new Promise((r) => setTimeout(r, 600));
    setIsSaving(false);
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setPasswordError("");
    if (newPassword !== confirmPassword) {
      setPasswordError("Passwords do not match.");
      return;
    }
    if (newPassword.length < 8) {
      setPasswordError("Password must be at least 8 characters.");
      return;
    }
    setIsSaving(true);
    const { error } = await supabase.auth.updateUser({ password: newPassword });
    if (error) {
      setPasswordError(error.message);
    } else {
      setSaved(true);
      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");
      setTimeout(() => setSaved(false), 2000);
    }
    setIsSaving(false);
  };

  const togglePref = (key: keyof NotificationPrefs) =>
    setNotifPrefs((prev) => ({ ...prev, [key]: !prev[key] }));

  return (
    <div className="space-y-6 max-w-4xl">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Settings</h1>
        <p className="text-muted-foreground mt-1">Manage your account and preferences.</p>
      </div>

      <div className="flex gap-6">
        {/* Sidebar */}
        <div className="w-48 flex-shrink-0">
          <nav className="space-y-1">
            {SECTIONS.map(({ id, label, icon: Icon }) => (
              <button
                key={id}
                onClick={() => setActiveSection(id)}
                className={`flex items-center gap-3 w-full px-3 py-2.5 rounded-lg text-sm font-medium transition-colors text-left ${
                  activeSection === id
                    ? "bg-indigo-50 text-indigo-700"
                    : "text-muted-foreground hover:bg-muted hover:text-foreground"
                }`}
              >
                <Icon className="w-4 h-4" />
                {label}
              </button>
            ))}
          </nav>
        </div>

        {/* Content */}
        <div className="flex-1 min-w-0">
          {/* Profile */}
          {activeSection === "profile" && (
            <Card>
              <CardHeader>
                <CardTitle>Business Profile</CardTitle>
                <CardDescription>
                  Update your business information visible to merchants.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label>Business Name</Label>
                  <Input
                    value={businessName}
                    onChange={(e) => setBusinessName(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label>Contact Email</Label>
                  <Input
                    type="email"
                    value={contactEmail}
                    onChange={(e) => setContactEmail(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label>Contact Phone</Label>
                  <Input
                    type="tel"
                    value={contactPhone}
                    onChange={(e) => setContactPhone(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label>Logo URL</Label>
                  <Input placeholder="https://..." />
                  <p className="text-xs text-muted-foreground">
                    Direct link to your business logo image.
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <Button onClick={handleSaveProfile} disabled={isSaving}>
                    {saved ? <><Check className="w-4 h-4 mr-1" /> Saved</> : isSaving ? "Saving..." : "Save Changes"}
                  </Button>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Notifications */}
          {activeSection === "notifications" && (
            <Card>
              <CardHeader>
                <CardTitle>Notification Preferences</CardTitle>
                <CardDescription>
                  Choose how and when you receive notifications.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-6">
                  <div>
                    <h4 className="text-sm font-semibold mb-3 flex items-center gap-2">
                      Email Notifications
                      <Badge variant="outline">Email</Badge>
                    </h4>
                    <div className="space-y-4">
                      {[
                        {
                          key: "email_new_redemption" as const,
                          label: "New Redemption",
                          desc: "Get notified when a customer redeems a deal",
                        },
                        {
                          key: "email_daily_summary" as const,
                          label: "Daily Summary",
                          desc: "Daily digest of deal performance",
                        },
                        {
                          key: "email_weekly_report" as const,
                          label: "Weekly Report",
                          desc: "Detailed weekly analytics report",
                        },
                      ].map(({ key, label, desc }) => (
                        <div key={key} className="flex items-center justify-between gap-4">
                          <div>
                            <p className="text-sm font-medium">{label}</p>
                            <p className="text-xs text-muted-foreground">{desc}</p>
                          </div>
                          <ToggleSwitch
                            checked={notifPrefs[key]}
                            onChange={() => togglePref(key)}
                          />
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="border-t pt-6">
                    <h4 className="text-sm font-semibold mb-3 flex items-center gap-2">
                      Push Notifications
                      <Badge variant="outline">Push</Badge>
                    </h4>
                    <div className="space-y-4">
                      {[
                        {
                          key: "push_new_redemption" as const,
                          label: "New Redemption",
                          desc: "Instant push for each redemption",
                        },
                        {
                          key: "push_deal_expiring" as const,
                          label: "Deal Expiring Soon",
                          desc: "Alert when a deal expires in 24 hours",
                        },
                      ].map(({ key, label, desc }) => (
                        <div key={key} className="flex items-center justify-between gap-4">
                          <div>
                            <p className="text-sm font-medium">{label}</p>
                            <p className="text-xs text-muted-foreground">{desc}</p>
                          </div>
                          <ToggleSwitch
                            checked={notifPrefs[key]}
                            onChange={() => togglePref(key)}
                          />
                        </div>
                      ))}
                    </div>
                  </div>

                  <Button onClick={handleSaveNotifications} disabled={isSaving}>
                    {saved ? <><Check className="w-4 h-4 mr-1" /> Saved</> : isSaving ? "Saving..." : "Save Preferences"}
                  </Button>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Security */}
          {activeSection === "security" && (
            <Card>
              <CardHeader>
                <CardTitle>Security</CardTitle>
                <CardDescription>Manage your password and account security.</CardDescription>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleChangePassword} className="space-y-4">
                  <div className="space-y-2">
                    <Label>Current Password</Label>
                    <Input
                      type="password"
                      value={currentPassword}
                      onChange={(e) => setCurrentPassword(e.target.value)}
                      placeholder="••••••••"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>New Password</Label>
                    <Input
                      type="password"
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      placeholder="••••••••"
                      minLength={8}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>Confirm New Password</Label>
                    <Input
                      type="password"
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      placeholder="••••••••"
                    />
                  </div>
                  {passwordError && (
                    <p className="text-sm text-red-600 bg-red-50 px-3 py-2 rounded-lg border border-red-200">
                      {passwordError}
                    </p>
                  )}
                  <Button type="submit" disabled={isSaving || !newPassword}>
                    {saved ? <><Check className="w-4 h-4 mr-1" /> Changed</> : isSaving ? "Updating..." : "Change Password"}
                  </Button>
                </form>

                <div className="border-t mt-6 pt-6">
                  <h4 className="text-sm font-semibold mb-2">Danger Zone</h4>
                  <p className="text-xs text-muted-foreground mb-3">
                    Once you delete your account, there is no going back. Please be certain.
                  </p>
                  <Button variant="destructive" size="sm">
                    Delete Account
                  </Button>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Billing */}
          {activeSection === "billing" && (
            <Card>
              <CardHeader>
                <CardTitle>Billing & Plan</CardTitle>
                <CardDescription>Manage your subscription and payment method.</CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="p-4 rounded-lg bg-indigo-50 border border-indigo-200">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-semibold text-indigo-900">Float Pro Plan</p>
                      <p className="text-sm text-indigo-700 mt-0.5">Up to 10 venues · Unlimited deals</p>
                    </div>
                    <Badge className="bg-indigo-600 text-white">Active</Badge>
                  </div>
                  <p className="text-sm text-indigo-700 mt-3">
                    <span className="font-bold text-indigo-900">$49/mo</span> · Renews Mar 28, 2026
                  </p>
                </div>

                <div>
                  <h4 className="text-sm font-semibold mb-3">Payment Method</h4>
                  <div className="flex items-center gap-3 p-3 border rounded-lg">
                    <div className="w-10 h-6 bg-gray-100 rounded text-xs flex items-center justify-center font-bold text-gray-500">
                      VISA
                    </div>
                    <div>
                      <p className="text-sm">•••• •••• •••• 4242</p>
                      <p className="text-xs text-muted-foreground">Expires 12/27</p>
                    </div>
                    <Button variant="outline" size="sm" className="ml-auto">
                      Update
                    </Button>
                  </div>
                </div>

                <div>
                  <h4 className="text-sm font-semibold mb-3">Invoice History</h4>
                  <div className="space-y-2">
                    {["Feb 2026", "Jan 2026", "Dec 2025"].map((month) => (
                      <div key={month} className="flex items-center justify-between py-2 border-b last:border-0">
                        <span className="text-sm">{month}</span>
                        <div className="flex items-center gap-3">
                          <span className="text-sm font-medium">$49.00</span>
                          <Button variant="ghost" size="sm" className="h-7 text-xs">
                            Download
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
        </div>
      </div>
    </div>
  );
}
