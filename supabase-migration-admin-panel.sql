-- Migration: Admin Panel enhancements
-- Run in Supabase SQL Editor

-- Admin-notater per bruker
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS admin_notes text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone text;

-- Abonnement per organisasjon
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS subscription_status text NOT NULL DEFAULT 'trial';
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS plan text NOT NULL DEFAULT 'free';
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS trial_ends_at timestamptz DEFAULT now() + interval '30 days';
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS admin_notes text;
