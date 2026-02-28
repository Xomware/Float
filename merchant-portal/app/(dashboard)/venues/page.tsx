"use client";

import React, { useState } from "react";
import VenueCard, { VenueData } from "@/components/VenueCard";
import { Button } from "@/components/ui/button";
import { Plus, Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

const MOCK_VENUES: VenueData[] = [
  {
    id: "v1",
    name: "Downtown Bar & Grill",
    address: "123 Main Street",
    city: "New York",
    state: "NY",
    zip: "10001",
    phone: "(212) 555-0100",
    website: "https://downtownbargrill.com",
    cover_image_url: null,
    hours: {
      monday: { open: "11:00", close: "23:00", closed: false },
      tuesday: { open: "11:00", close: "23:00", closed: false },
      wednesday: { open: "11:00", close: "23:00", closed: false },
      thursday: { open: "11:00", close: "23:00", closed: false },
      friday: { open: "11:00", close: "01:00", closed: false },
      saturday: { open: "12:00", close: "01:00", closed: false },
      sunday: { open: "12:00", close: "22:00", closed: false },
    },
    is_active: true,
  },
  {
    id: "v2",
    name: "The Rooftop Lounge",
    address: "456 Sky Avenue",
    city: "New York",
    state: "NY",
    zip: "10002",
    phone: "(212) 555-0200",
    website: "https://rooftoplounge.com",
    cover_image_url: null,
    hours: {
      monday: { open: "17:00", close: "23:00", closed: false },
      tuesday: { open: "17:00", close: "23:00", closed: false },
      wednesday: { open: "17:00", close: "23:00", closed: false },
      thursday: { open: "17:00", close: "23:00", closed: false },
      friday: { open: "16:00", close: "01:00", closed: false },
      saturday: { open: "14:00", close: "02:00", closed: false },
      sunday: { open: "14:00", close: "21:00", closed: false },
    },
    is_active: true,
  },
  {
    id: "v3",
    name: "Café Central",
    address: "789 Park Lane",
    city: "Brooklyn",
    state: "NY",
    zip: "11201",
    phone: "(718) 555-0300",
    website: null,
    cover_image_url: null,
    hours: {
      monday: { open: "07:00", close: "21:00", closed: false },
      tuesday: { open: "07:00", close: "21:00", closed: false },
      wednesday: { open: "07:00", close: "21:00", closed: false },
      thursday: { open: "07:00", close: "21:00", closed: false },
      friday: { open: "07:00", close: "22:00", closed: false },
      saturday: { open: "08:00", close: "22:00", closed: false },
      sunday: { open: "08:00", close: "20:00", closed: false },
    },
    is_active: false,
  },
];

export default function VenuesPage() {
  const [venues, setVenues] = useState<VenueData[]>(MOCK_VENUES);
  const [search, setSearch] = useState("");
  const [showAddForm, setShowAddForm] = useState(false);

  const filtered = venues.filter(
    (v) =>
      v.name.toLowerCase().includes(search.toLowerCase()) ||
      v.city.toLowerCase().includes(search.toLowerCase())
  );

  const handleSave = async (updated: VenueData) => {
    // TODO: supabase.from('venues').update(updated).eq('id', updated.id)
    setVenues((prev) => prev.map((v) => (v.id === updated.id ? updated : v)));
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure you want to delete this venue?")) return;
    // TODO: supabase.from('venues').delete().eq('id', id)
    setVenues((prev) => prev.filter((v) => v.id !== id));
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Venues</h1>
          <p className="text-muted-foreground mt-1">Manage your venue profiles and hours.</p>
        </div>
        <Button onClick={() => setShowAddForm(true)}>
          <Plus className="w-4 h-4 mr-2" />
          Add Venue
        </Button>
      </div>

      {/* Search */}
      <div className="relative max-w-xs">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input
          placeholder="Search venues..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="pl-9"
        />
      </div>

      {/* Add Venue Form */}
      {showAddForm && (
        <Card className="border-dashed border-2 border-indigo-300">
          <CardHeader>
            <CardTitle>New Venue</CardTitle>
            <CardDescription>Fill in the details to add a new venue.</CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              {/* TODO: Implement AddVenueForm with Supabase insert */}
              Add venue form — connect to Supabase to enable.
            </p>
            <Button variant="outline" onClick={() => setShowAddForm(false)} className="mt-4">
              Cancel
            </Button>
          </CardContent>
        </Card>
      )}

      {/* Venues Grid */}
      {filtered.length === 0 ? (
        <div className="text-center py-16 text-muted-foreground">
          <p className="text-lg font-medium">No venues found</p>
          <p className="text-sm mt-1">Try adjusting your search or add a new venue.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
          {filtered.map((venue) => (
            <VenueCard
              key={venue.id}
              venue={venue}
              onSave={handleSave}
              onDelete={handleDelete}
            />
          ))}
        </div>
      )}

      {/* Summary */}
      <p className="text-sm text-muted-foreground">
        Showing {filtered.length} of {venues.length} venue{venues.length !== 1 ? "s" : ""} ·{" "}
        {venues.filter((v) => v.is_active).length} active
      </p>
    </div>
  );
}
