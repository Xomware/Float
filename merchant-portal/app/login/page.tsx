"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Waves } from "lucide-react";
import { supabase } from "@/lib/supabase";

export default function LoginPage() {
  const router = useRouter();
  const [mode, setMode] = useState<"signin" | "signup" | "reset">("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [businessName, setBusinessName] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);

  const handleSignIn = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setMessage(null);

    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) {
      setMessage({ type: "error", text: error.message });
    } else {
      router.push("/dashboard");
    }
    setIsLoading(false);
  };

  const handleSignUp = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setMessage(null);

    const { error: authError, data } = await supabase.auth.signUp({
      email,
      password,
      options: { emailRedirectTo: `${window.location.origin}/dashboard` },
    });

    if (authError) {
      setMessage({ type: "error", text: authError.message });
      setIsLoading(false);
      return;
    }

    if (data.user) {
      // Create merchant profile
      const { error: merchantError } = await supabase.from("merchants").insert({
        user_id: data.user.id,
        business_name: businessName,
        contact_email: email,
        is_active: true,
        notification_preferences: {
          email_new_redemption: true,
          email_daily_summary: true,
          email_weekly_report: true,
        },
      });

      if (merchantError) {
        setMessage({ type: "error", text: "Account created but profile setup failed. Please contact support." });
      } else {
        setMessage({ type: "success", text: "Account created! Check your email to verify your account." });
      }
    }
    setIsLoading(false);
  };

  const handleReset = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setMessage(null);

    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/settings`,
    });

    if (error) {
      setMessage({ type: "error", text: error.message });
    } else {
      setMessage({ type: "success", text: "Password reset link sent to your email." });
    }
    setIsLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-indigo-50 via-white to-purple-50 p-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="flex items-center justify-center gap-3 mb-8">
          <div className="w-10 h-10 rounded-xl bg-indigo-600 flex items-center justify-center shadow-lg">
            <Waves className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-xl font-bold">Float</h1>
            <p className="text-xs text-muted-foreground">Merchant Portal</p>
          </div>
        </div>

        <Card className="shadow-lg">
          <CardHeader className="text-center">
            <CardTitle>
              {mode === "signin" ? "Welcome back" : mode === "signup" ? "Get started" : "Reset password"}
            </CardTitle>
            <CardDescription>
              {mode === "signin"
                ? "Sign in to your merchant account"
                : mode === "signup"
                ? "Create your merchant account"
                : "We'll send you a reset link"}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form
              onSubmit={mode === "signin" ? handleSignIn : mode === "signup" ? handleSignUp : handleReset}
              className="space-y-4"
            >
              {mode === "signup" && (
                <div className="space-y-2">
                  <Label htmlFor="businessName">Business Name</Label>
                  <Input
                    id="businessName"
                    type="text"
                    placeholder="Acme Bar & Grill"
                    value={businessName}
                    onChange={(e) => setBusinessName(e.target.value)}
                    required
                  />
                </div>
              )}

              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  placeholder="you@business.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>

              {mode !== "reset" && (
                <div className="space-y-2">
                  <Label htmlFor="password">Password</Label>
                  <Input
                    id="password"
                    type="password"
                    placeholder="••••••••"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    minLength={8}
                  />
                </div>
              )}

              {message && (
                <div
                  className={`p-3 rounded-lg text-sm ${
                    message.type === "success"
                      ? "bg-green-50 text-green-700 border border-green-200"
                      : "bg-red-50 text-red-700 border border-red-200"
                  }`}
                >
                  {message.text}
                </div>
              )}

              <Button type="submit" className="w-full" disabled={isLoading}>
                {isLoading
                  ? "Loading..."
                  : mode === "signin"
                  ? "Sign In"
                  : mode === "signup"
                  ? "Create Account"
                  : "Send Reset Link"}
              </Button>
            </form>

            <div className="mt-4 text-center space-y-2">
              {mode === "signin" && (
                <>
                  <button
                    type="button"
                    onClick={() => { setMode("reset"); setMessage(null); }}
                    className="text-sm text-muted-foreground hover:text-foreground"
                  >
                    Forgot your password?
                  </button>
                  <div className="text-sm text-muted-foreground">
                    Don&apos;t have an account?{" "}
                    <button
                      type="button"
                      onClick={() => { setMode("signup"); setMessage(null); }}
                      className="text-indigo-600 hover:underline font-medium"
                    >
                      Sign up
                    </button>
                  </div>
                </>
              )}
              {(mode === "signup" || mode === "reset") && (
                <button
                  type="button"
                  onClick={() => { setMode("signin"); setMessage(null); }}
                  className="text-sm text-muted-foreground hover:text-foreground"
                >
                  ← Back to sign in
                </button>
              )}
            </div>
          </CardContent>
        </Card>

        <p className="text-center text-xs text-muted-foreground mt-6">
          By signing in, you agree to Float&apos;s{" "}
          <a href="#" className="underline">Terms of Service</a> and{" "}
          <a href="#" className="underline">Privacy Policy</a>
        </p>
      </div>
    </div>
  );
}
