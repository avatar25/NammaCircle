import type { Metadata } from "next";
import { LandingPageClient } from "./LandingPageClient";

export const metadata: Metadata = {
  title: "NammaCircle | Bangalore area match",
  description: "Find where to live in Bangalore before you pay deposit."
};

export default function LandingPage() {
  return <LandingPageClient />;
}
